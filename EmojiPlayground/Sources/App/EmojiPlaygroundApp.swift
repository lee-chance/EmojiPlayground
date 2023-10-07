//
//  EmojiPlaygroundApp.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI
import FirebaseCore
import FirebaseRemoteConfig

@main
struct EmojiPlaygroundApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var mainRouter = MainRouter()
    @StateObject var emoticonStorage = EmoticonStorage()
    
    @State private var iCloudAccountNotFoundAlert = false
    @State private var isSuccessedVersionCheck: Bool?
    
    init() {
        FirebaseApp.configure()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
    }
    
    var body: some Scene {
        WindowGroup {
            if isSuccessedVersionCheck == true {
                MainView()
                    .environment(\.managedObjectContext, PersistenceController.shared.context)
                    .environmentObject(mainRouter)
                    .environmentObject(emoticonStorage)
                    .environmentObject(Theme.shared)
                    .overlay(mainOverlay)
                    .alert("로그인 오류", isPresented: $iCloudAccountNotFoundAlert, actions: {
                        Button("설정으로 이동") {
                            UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!)
                        }
                        
                        Button("취소", role: .cancel) { }
                    }, message: {
                        Text("설정에서 iCloud에 로그인을 해주세요.")
                    })
                    .onAppear {
                        checkiCloudLoggedIn()
                    }
                    .onChange(of: scenePhase) { newValue in
                        if newValue == .active {
                            checkiCloudLoggedIn()
                        }
                    }
            } else {
                Color(uiColor: .systemBackground)
                    .alert("업데이트가 필요합니다.", presenting: $isSuccessedVersionCheck, actions: { _ in
                        Button("업데이트") {
                            UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!)
                        }
                    }, message: { _ in
                        Text("앱 업데이트 후 이용가능합니다.")
                    })
                    .onAppear {
                        RemoteConfig.remoteConfig().fetch { (status, error) -> Void in
                            if status == .success {
                                RemoteConfig.remoteConfig().activate { changed, error in }
                            } else {
                                print("Error: \(error?.localizedDescription ?? "No error available.")")
                            }
                            checkMinVersion()
                        }
                    }
            }
        }
    }
    
    private func checkiCloudLoggedIn() {
        Task {
            do {
                let _ = try await CloudKitUtility.getiCloudStatus()
            } catch CloudKitUtility.CloudKitError.iCouldAccountNotFound {
                iCloudAccountNotFoundAlert = true
            } catch CloudKitUtility.CloudKitError.iCouldAccountTemporarilyUnavailable {
                iCloudAccountNotFoundAlert = true
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
    
    private func checkMinVersion() {
        let minimumVersion = RemoteConfig.remoteConfig().configValue(forKey: "minimum_version")
        guard
            let minimumVersion = minimumVersion.stringValue,
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else {
            isSuccessedVersionCheck = false
            return
        }
        
        isSuccessedVersionCheck = minimumVersion <= appVersion
    }
    
    @ViewBuilder
    var mainOverlay: some View {
        if let content = mainRouter.content {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .overlay(
                    content
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                )
        }
    }
}

@MainActor
final class MainRouter: ObservableObject {
    @Published fileprivate var content: AnyView?
    
    func show<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }
    
    func hide() {
        self.content = nil
    }
}

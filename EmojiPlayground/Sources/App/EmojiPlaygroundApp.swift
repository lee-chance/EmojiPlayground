//
//  EmojiPlaygroundApp.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseRemoteConfig

@main
struct EmojiPlaygroundApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.font) private var font
    
    @StateObject var mainRouter = MainRouter()
    @StateObject var userStore = UserStore.shared
    
    @State private var isSuccessedVersionCheck: Bool?
    
    init() {
        FirebaseApp.configure()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        
        let title = "hi"
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title)",
            AnalyticsParameterItemName: title,
            AnalyticsParameterContentType: "cont",
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            if isSuccessedVersionCheck == true {
                MainView()
                    .environmentObject(mainRouter)
                    .environmentObject(userStore)
                    .environmentObject(EmoticonStore())
                    .environmentObject(TagStore())
                    .environmentObject(Settings())
                    .overlay(mainOverlay)
                    .font(.body)
            } else {
                Color(uiColor: .systemBackground)
                    .alert("업데이트가 필요합니다.", presenting: $isSuccessedVersionCheck, actions: { _ in
                        Button("업데이트") {
                            guard let url = URL(string: "itms-apps://itunes.apple.com/app/\(AppInfo.appStoreAppleID)") else { return }
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
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
    
    private func checkMinVersion() {
        let minimumVersion = RemoteConfig.remoteConfig().configValue(forKey: "minimum_version")
        guard
            let minimumVersion = minimumVersion.stringValue,
            !minimumVersion.isEmpty,
            let appVersion = AppInfo.appVersion
        else {
            isSuccessedVersionCheck = false
            return
        }
        
        isSuccessedVersionCheck = Version(string: minimumVersion) <= Version(string: appVersion)
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
                        .clipShape(.rect(cornerRadius: 8))
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

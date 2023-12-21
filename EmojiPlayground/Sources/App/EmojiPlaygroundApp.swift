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
//    @UIApplicationDelegateAdaptor var delegate: MyAppDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var mainRouter = MainRouter()
    @StateObject var userStore = UserStore.shared
    @StateObject var emoticonStore = EmoticonStore()
    
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
                    .environmentObject(emoticonStore)
                    .environmentObject(Theme.shared)
                    .overlay(mainOverlay)
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

//class MyAppDelegate: NSObject, UIApplicationDelegate {
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
//    ) -> Bool {
//        FirebaseApp.configure()
//        let settings = RemoteConfigSettings()
//        settings.minimumFetchInterval = 0
//        RemoteConfig.remoteConfig().configSettings = settings
//        
//        let title = "hi"
//        
//        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//            AnalyticsParameterItemID: "id-\(title)",
//            AnalyticsParameterItemName: title,
//            AnalyticsParameterContentType: "cont",
//        ])
//        return true
//    }
//    func application(
//        _ application: UIApplication,
//        configurationForConnecting connectingSceneSession: UISceneSession,
//        options: UIScene.ConnectionOptions
//    ) -> UISceneConfiguration {
//        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
//        sceneConfig.delegateClass = MySceneDelegate.self
//        return sceneConfig
//    }
//}
//
//class MySceneDelegate: NSObject, UIWindowSceneDelegate {
//    var window: UIWindow?
//    
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let _ = (scene as? UIWindowScene) else { return }
//    }
//    
//    func sceneDidDisconnect(_ scene: UIScene) {
//        
//    }
//    
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        
//    }
//    
//    func sceneWillResignActive(_ scene: UIScene) {
//        
//    }
//    
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        
//    }
//    
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        
//    }
//}

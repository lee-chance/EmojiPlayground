//
//  EmojiPlaygroundApp.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI
import FirebaseCore

@main
struct EmojiPlaygroundApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var mainRouter = MainRouter()
    
    @State private var iCloudAccountNotFoundAlert = false
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, PersistenceController.shared.context)
                .environmentObject(mainRouter)
                .overlay(mainOverlay)
                .alert("로그인 오류", isPresented: $iCloudAccountNotFoundAlert, actions: {
                    Button("설정으로 이동") {
                        UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!)
                    }
                    
                    Button("취소", role: .cancel) { }
                }, message: {
                    Text("설정에서 iCloud에 로그인을 해주세요.")
                })
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                Task {
                    do {
                        let _ = try await CloudKitUtility.getiCloudStatus()
                    } catch CloudKitUtility.CloudKitError.iCouldAccountNotFound {
                        iCloudAccountNotFoundAlert = true
                    } catch {
                        print("cslog error: \(error)")
                    }
                }
            default:
                break
            }
        }
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

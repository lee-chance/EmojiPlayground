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
    @StateObject var mainRouter = MainRouter()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(mainRouter)
                .overlay(mainOverlay)
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

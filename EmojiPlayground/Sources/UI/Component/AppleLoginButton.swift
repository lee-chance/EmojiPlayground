//
//  AppleLoginButton.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/04.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginButton<Content: View>: View {
    @EnvironmentObject private var userStore: UserStore
    
    @State private var presentAlreadyInUseAlert: Bool = false
    @State private var errorMessage: String? = nil
    
    private let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    init(_ label: SignInWithAppleButton.Label = .signIn) where Content == SignInWithAppleButton {
        self.content = SignInWithAppleButton(label, onRequest: { _ in }, onCompletion: { _ in })
    }
    
    var body: some View {
        Button(action: {
            AppleAuthManager.shared.processLogin { request in
                AppleAuthManager.shared.makeRequest(request)
            } onCompletion: { authResult in
                Task { await linkWithApple(authResult) }
            }
        }) {
            content
        }
        .alert("오류", presenting: $errorMessage, actions: { _ in
            Button("확인") { errorMessage = nil }
        }, message: { message in
            #if DEBUG
            Text(message)
            #else
            Text("알 수 없는 오류가 발생했습니다.")
            #endif
        })
        .alert("로그인 전환", isPresented: $presentAlreadyInUseAlert) {
            Button("취소", role: .cancel) {}
            
            Button("로그인") {
                AppleAuthManager.shared.processLogin { request in
                    AppleAuthManager.shared.makeRequest(request)
                } onCompletion: { authResult in
                    Task { await loginWithApple(authResult) }
                }
            }
        } message: {
            // 여기서 기존 데이터가 사라진다는 말을 해야될까??
            Text("이미 연결된 계정입니다.\n로그인을 다시 시도해주세요.")
        }
    }
    
    private func linkWithApple(_ authResult: AppleAuthResult) async {
        do {
            try await userStore.linkWithApple(authResult)
        } catch AuthError.notLoggedIn {
            await userStore.loginAnonymous()
            errorMessage = "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        } catch AuthError.credentialAlreadyInUse {
            presentAlreadyInUseAlert = true
        } catch {
            errorMessage = error.localizedDescription
            print("error: \(error)")
        }
    }
    
    private func loginWithApple(_ authResult: AppleAuthResult) async {
        do {
            try await userStore.loginWithApple(authResult)
        } catch AuthError.userDisabled {
            errorMessage = "해당 계정은 사용 중지되었습니다."
        } catch {
            errorMessage = error.localizedDescription
            print("error: \(error)")
        }
    }
}

#Preview {
    AppleLoginButton {
        Text("hi")
    }
}

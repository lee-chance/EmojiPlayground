//
//  LoginView.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/02.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userStore: UserStore
    
    var body: some View {
        if userStore.user?.isGuest ?? true {
            VStack(spacing: 36) {
                Image(.icon0)
                    .resizable()
                    .frame(width: 200, height: 200)
                
                Text("지금 계정을 연동하여 데이터를 안전하게 보관하고 다양한 기능들을 사용해 보세요.")
                    .font(.title)
                    .lineSpacing(4)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
                
                VStack {
                    AppleLoginButton()
                        .frame(maxHeight: 56)
                    
                    // TODO: 만료 후 처리
                    if let dayOfExpiredDate = userStore.user?.dayOfExpiredDate, dayOfExpiredDate > 0 {
                        Text("현재 계정은 게스트 로그인이며 \(userStore.user?.dayOfExpiredDate ?? 14)일 후 만료됩니다.")
                            .font(.callout)
                            .foregroundStyle(.black.opacity(0.7))
                    }
                }
            }
            .padding()
        } else {
            VStack {
                Text("유저이름: \(userStore.user?.displayName ?? "-")")
                
                Button("로그아웃") {
                    Task {
                        userStore.logout()
                        await userStore.loginAnonymous()
                    }
                }
                
                Button("계정삭제") {
                    Task {
                        do {
                            try await userStore.signout()
                            await userStore.loginAnonymous()
                        } catch {
                            print("error: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    private func GoogleLoginButton() -> some View {
        Button {
            Task { await userStore.linkWithGoogle() }
        } label: {
            Text("Sign in with Google")
                .frame(width: 280, height: 60)
                .background(alignment: .leading) {
                    Image("google")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal)
                }
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
//    Text("")
//        .sheet(isPresented: .constant(true), content: {
            LoginView()
                .environmentObject(UserStore.shared)
//        })
}

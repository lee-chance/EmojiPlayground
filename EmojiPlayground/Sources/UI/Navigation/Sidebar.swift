//
//  Sidebar.swift
//  EmojiPlayground
//
//  Created by 이창수 on 2023/05/15.
//

import SwiftUI

enum Panel: Hashable {
    /// The value for the ``HomeView``.
    case home
    /// The value for the ``EmoticonStorageView``.
    case emoticonStorage
    /// The value for the ``CommunityView``.
    case community
    /// The value for the ``SettingsView``.
    case settings
    /// The value for the ``CanvasView``.
    case canvas
}

struct Sidebar: View {
    @EnvironmentObject private var userStore: UserStore
    
    @Binding var selection: Panel?
    
    var body: some View {
        List(selection: $selection) {
            Section("바로가기") {
                NavigationLink(value: Panel.home) {
                    Label("연습장", systemImage: "note.text")
                }
                
                NavigationLink(value: Panel.canvas) {
                    Label("캔버스", systemImage: "paintbrush")
                }
                
                NavigationLink(value: Panel.emoticonStorage) {
                    Label("보관함", systemImage: "archivebox")
                }
                
//                NavigationLink(value: Panel.community) {
//                    Label("커뮤니티", systemImage: "globe")
//                }
                
//                NavigationLink(value: Panel.settings) {
//                    Label("설정", systemImage: "gearshape")
//                }
            }
            
            Section("앱 설정") {
                if userStore.user?.isGuest ?? false {
                    AppleLoginButton {
                        Label("연동하기/로그인", systemImage: "apple.logo")
                    }
                } else {
                    SidebarLogoutButton()
                    
                    SidebarSignoutButton()
                }
                
//                NavigationLink(destination: LoginView()) {
//                    Label("계정정보", systemImage: "person.circle")
//                }
                
                NavigationLink(destination: IconSettingsView()) {
                    Label {
                        Text("앱 아이콘")
                    } icon: {
                        let icon = IconSettingsView.Icon(string: UIApplication.shared.alternateIconName)
                        
                        Image(uiImage: .init(named: icon.iconName)!)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .clipShape(.rect(cornerRadius: 4))
                    }
                }
                
                if let reviewURL = URL(string: "https://apps.apple.com/app/id\(AppInfo.appStoreAppleID)?action=write-review") {
                    Link(destination: reviewURL) {
                        Label("리뷰 남기러 가기", systemImage: "star.bubble")
                    }
                    .tint(Color.black)
                }
                
//                NavigationLink(destination: AboutView()) {
//                  Label("settings.app.about", systemImage: "info.circle")
//                }
                
                if let appVersion = AppInfo.appVersion {
                    Label("앱 버전: \(appVersion)", systemImage: "info.circle")
                }
            }
            
            Section("일반 설정") {
                NavigationLink(destination: DisplaySettingsView()) {
                    Label("화면 설정", systemImage: "paintpalette")
                }
                
                Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                    Label("시스템 설정", systemImage: "gear")
                }
                .tint(Color.black)
            }
        }
        .navigationTitle("테스티콘")
    }
}

struct Sidebar_Previews: PreviewProvider {
    struct Preview: View {
        @State private var selection: Panel? = Panel.home
        var body: some View {
            Sidebar(selection: $selection)
                .environmentObject(UserStore.shared)
        }
    }
    
    static var previews: some View {
        NavigationSplitView {
            Preview()
        } detail: {
           Text("Detail!")
        }
    }
}

struct SidebarLogoutButton: View {
    @EnvironmentObject private var userStore: UserStore
    
    @State private var presentAlert = false
    
    var body: some View {
        Button("로그아웃", systemImage: "rectangle.portrait.and.arrow.right") {
            presentAlert.toggle()
        }
        .alert("로그아웃을 할까요?", isPresented: $presentAlert, actions: {
            Button("취소", role: .cancel) { }
            
            Button("로그아웃") {
                Task {
                    userStore.logout()
                    await userStore.loginAnonymous()
                }
            }
        }, message: {
            Text("언제든지 다시 로그인할 수 있습니다.")
        })
    }
}

struct SidebarSignoutButton: View {
    @EnvironmentObject private var userStore: UserStore
    
    @State private var presentAlert = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        Button("회원탈퇴", systemImage: "person.crop.circle.badge.xmark") {
            presentAlert.toggle()
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
        .alert("정말 탈퇴하시겠어요?", isPresented: $presentAlert, actions: {
            Button("취소", role: .cancel) { }
            
            Button("탈퇴", role: .destructive) {
                Task { await signout() }
            }
        }, message: {
            Text("회원탈퇴시 계정과 모든 데이터는 삭제되며 복구되지 않습니다.")
        })
    }
    
    private func signout() async {
        do {
            try await userStore.signout()
            await userStore.loginAnonymous()
        } catch AuthError.requiresRecentLogin {
            AppleAuthManager.shared.processLogin { request in
                AppleAuthManager.shared.makeRequest(request)
            } onCompletion: { authResult in
                Task { await reauthenticate(authResult) }
            }
        } catch {
            errorMessage = error.localizedDescription
            print("error: \(error)")
        }
    }
    
    private func reauthenticate(_ authResult: AppleAuthResult) async {
        do {
            try await userStore.reauthenticate(authResult)
            await signout()
        } catch AuthError.notLoggedIn {
            await userStore.loginAnonymous()
            errorMessage = "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        } catch AuthError.userMismatch {
            errorMessage = "로그인 되어있는 계정으로 인증을 시도해주세요."
        } catch AuthError.userDisabled {
            errorMessage = "해당 계정은 사용 중지되었습니다."
        } catch {
            errorMessage = error.localizedDescription
            print("error: \(error)")
            // TODO: 로그 보내기
        }
    }
}

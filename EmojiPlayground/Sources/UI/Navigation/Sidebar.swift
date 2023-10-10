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
}

struct Sidebar: View {
    @Binding var selection: Panel?
    
    var body: some View {
        List(selection: $selection) {
            Section("바로가기") {
                NavigationLink(value: Panel.home) {
                    Label("연습장", systemImage: "note.text")
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
                NavigationLink(destination: IconSettingsView()) {
                    Label {
                        Text("앱 아이콘")
                    } icon: {
                        let icon = IconSettingsView.Icon(string: UIApplication.shared.alternateIconName)
                        
                        Image(uiImage: .init(named: icon.iconName)!)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .cornerRadius(4)
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

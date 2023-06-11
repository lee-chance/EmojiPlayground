//
//  SettingsView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/06/11.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            appSection
            
            generalSection
        }
        .navigationTitle("설정")
    }
    
    private var appSection: some View {
        Section("앱") {
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
            
            if let reviewURL = URL(string: "https://apps.apple.com/app/id(AppInfo.appStoreAppId)?action=write-review") {
                Link(destination: reviewURL) {
                    Label("리뷰 남기러 가기", systemImage: "star.bubble")
                }
                .tint(Color.black)
            }
            
//            NavigationLink(destination: AboutView()) {
//              Label("settings.app.about", systemImage: "info.circle")
//            }
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Label("앱 버전: \(appVersion)", systemImage: "info.circle")
            }
        }
    }
    
    private var generalSection: some View {
        Section("일반") {
            NavigationLink(destination: DisplaySettingsView()) {
                Label("화면 설정", systemImage: "paintpalette")
            }
            
            Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                Label("시스템 설정", systemImage: "gear")
            }
            .tint(Color.black)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

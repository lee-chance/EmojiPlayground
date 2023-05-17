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
            NavigationLink(value: Panel.home) {
                Label("연습장", systemImage: "note.text")
            }
            
            NavigationLink(value: Panel.emoticonStorage) {
                Label("보관함", systemImage: "archivebox")
            }
            
            NavigationLink(value: Panel.community) {
                Label("커뮤니티", systemImage: "globe")
            }
            
//            NavigationLink(value: Panel.settings) {
//                Label("설정", systemImage: "gearshape")
//            }
        }
        .navigationTitle("Emote")
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

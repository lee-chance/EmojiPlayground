//
//  EmoticonStorageTabView.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/03.
//

import SwiftUI

struct EmoticonStorageTabView: View {
    @EnvironmentObject private var navigation: NavigationManager
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var store: EmoticonStore
    
    @State private var selectedEmoticon: Emoticon?
    @State private var tab: TabIndex = .list
    
    private enum TabIndex {
        case list, detail
    }
    
    private var group: EmoticonGroup? {
        store.emoticonGroup(name: groupName)
    }
    
    let groupName: String
    
    var body: some View {
        if let group {
            TabView(selection: $tab) {
                EmoticonStorageListView(emoticons: group.emoticons, selectEmoticon: onTapEmoticon)
                    .tabItem({
                        Image(systemName: "square.grid.3x3.fill")
                        Text("리스트")
                    })
                    .tag(TabIndex.list)
                
                let selectedEmoticonID = Binding<Emoticon.ID?>(
                    get: { selectedEmoticon?.id },
                    set: { id in selectedEmoticon = store.emoticons.first(where: { $0.id == id }) }
                )
                EmoticonStorageDetailView(selectedEmoticonID: selectedEmoticonID, emoticons: group.emoticons)
                    .tabItem({
                        Image(systemName: "square.text.square.fill")
                        Text("상세보기")
                    })
                    .tag(TabIndex.detail)
            }
            .navigationTitle(groupName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    Picker("비율", selection: $settings.imageRatioType) {
                        ForEach(ImageRatioType.allCases, id: \.rawValue) { type in
                            Text(type.displayedName + "비율")
                                .tag(type)
                        }
                    }
                    
                    if settings.imageRatioType == .original {
                        Toggle("배경 숨기기", isOn: $settings.imageIsClearBackgroundColor)
                        
                        if !settings.imageIsClearBackgroundColor {
                            NavigationLink(destination: DisplaySettingsView()) {
                                Label("배경색 설정하러 가기", systemImage: "paintpalette")
                            }
                        }
                    }
                } label: {
                    Label("Settings", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                }
            }
        } else {
            DismissActionView()
        }
    }
    
    func onTapEmoticon(emoticon: Emoticon) {
        selectedEmoticon = emoticon
        tab = .detail
    }
}

struct DismissActionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Color.clear
            .onAppear {
                dismiss()
            }
    }
}

//#Preview {
//    EmoticonStorageTabView()
//}

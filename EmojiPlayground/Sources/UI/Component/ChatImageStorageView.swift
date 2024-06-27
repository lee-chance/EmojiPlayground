//
//  ChatImageStorageView.swift
//  Emote
//
//  Created by Changsu Lee on 2023/09/10.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatImageStorageView: View {
    @EnvironmentObject private var store: EmoticonStore
    @EnvironmentObject private var settings: Settings
    
    @State private var internalIndex: Int = 0
    @State private var isMini: Bool = false
    
    private var tabs: [EmoticonGroup] {
        store.emoticonGroups
    }
    
    private let leftOffset: CGFloat = 0.1
    
    let onTapEmoticon: (Emoticon, Bool) -> Void
    let delete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if tabs.count > 0 {
                tabHeader
                
                tabBody
            } else {
                Text("사용할 수 있는 이모티콘이 없어요! 🥲")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGray6)
        .task {
            await store.fetchEmoticons()
        }
    }
    
    private var tabHeader: some View {
        HStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(tabs.indices, id: \.self) { index in
                            let tab = tabs[index]
                            
                            Text(String(tab.firstCharacterOfName))
                                .font(.body)
                                .foregroundStyle(internalIndex == index ? .black : .gray)
                                .padding()
                                .background(internalIndex == index ? Color.systemGray5 : nil)
                                .id(index)
                                .onTapGesture {
                                    withAnimation {
                                        internalIndex = index
                                    }
                                }
                        }
                    }
                }
                .border(Color.systemGray5)
                .onChange(of: internalIndex) { value in
                    withAnimation {
                        proxy.scrollTo(value, anchor: UnitPoint(x: UnitPoint.leading.x + leftOffset, y: UnitPoint.leading.y))
                    }
                }
                .animation(.easeInOut, value: internalIndex)
            }
            
            Text("<")
                .font(.body)
                .foregroundStyle(.gray)
                .padding()
                .onTapGesture {
                    delete()
                }
        }
    }
    
    private var tabBody: some View {
        TabView(selection: $internalIndex) {
            ForEach(tabs.indices, id: \.self) { index in
                let tab = tabs[index]
                
                ScrollView {
                    VStack {
                        HStack {
                            Text(tab.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Toggle("Mini", isOn: $isMini)
                                .fixedSize()
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 4)) {
                            ForEach(tab.emoticons) { emoticon in
                                WebImage(url: emoticon.url)
                                    .resizable()
                                    .customLoopCount(4)
                                    .aspectRatio(1, contentMode: .fit)
                                    .onTapGesture {
                                        onTapEmoticon(emoticon, isMini)
                                    }
                            }
                        }
                    }
                    .padding()
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct ChatImageStorageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatImageStorageView { _, _ in } delete: { }
            .environmentObject(EmoticonStore())
            .environmentObject(Settings())
    }
}

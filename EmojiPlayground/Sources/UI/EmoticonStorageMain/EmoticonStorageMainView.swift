//
//  EmoticonStorageMainView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/08.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageMainView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @State private var isLoading: Bool = false
    
    private var emoticonGroups: [EmoticonGroup] {
        store.emoticonGroups
    }
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 200), alignment: .top)]
    }
    
    var body: some View {
        GeometryReader { geometry in // 이거로 loadingView, emptyView를 화면 중앙에 두기
            ScrollView {
                if isLoading, emoticonGroups.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else if emoticonGroups.isEmpty {
                    Text("사용할 수 있는 이모티콘이 없어요! 🥲")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    VStack(alignment: .leading) {
                        Text("이모티콘은 1:1 비율의 사이즈를 권장합니다.")
                            .font(.callout)
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                        
                        gridView
                    }
                }
            }
        }
        .navigationTitle("보관함")
        .navigationDestination(for: EmoticonGroup.self) { group in
            EmoticonStorageTabView(groupName: group.name)
        }
        .task {
            isLoading = true
            await store.fetchEmoticons()
            isLoading = false
        }
    }
    
    private var gridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
            ForEach(emoticonGroups) { group in
                NavigationLink(value: group) {
                    VStack {
                        EmoticonGroupView(emoticons: group.emoticons)
                        
                        Text(group.name)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

struct EmoticonGroupView: View {
    let emoticons: [Emoticon]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(0..<4, id: \.self
            ) { index in
                ZStack {
                    thumbnail(of: index)
                    
                    if index == 3, emoticons.count > 4 {
                        Color.black
                            .opacity(0.5)
                            .overlay(
                                Text("+\(emoticons.count - 3)")
                                    .foregroundStyle(.white)
                            )
                    }
                }
                .clipShape(.rect(cornerRadius: 4))
            }
        }
        .padding(8)
        .background(.ultraThickMaterial)
        .clipShape(.rect(cornerRadius: 8))
    }
    
    @ViewBuilder
    func thumbnail(of index: Int) -> some View {
        if 0 <= index && index < emoticons.count {
            ImageView(url: emoticons[index].url)
        } else {
            Rectangle()
                .aspectRatio(1, contentMode: .fit)
                .opacity(0)
        }
    }
}

struct EmoticonStorageMainView_Previews: PreviewProvider {
    static var previews: some View {
        EmoticonStorageMainView()
    }
}

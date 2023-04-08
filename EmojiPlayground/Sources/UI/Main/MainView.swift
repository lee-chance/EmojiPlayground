//
//  MainView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/11.
//

import SwiftUI

struct MainView: View {
    let chatRoomStore = ChatRoomStore<ChatStore>()
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                EmoticonStorageView()
            } label: {
                HStack {
                    Image(systemName: "archivebox")
                    
                    Text("이모티콘 보관함 가기")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .frame(height: 32)
                .frame(width: 200)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .background(.black)
                .cornerRadius(4)
            }
            
            NavigationLink {
                HomeView(store: chatRoomStore)
                    .environment(\.theme, .cocoa)
            } label: {
                themeButton(.cocoa)
            }
            
            NavigationLink {
                HomeView(store: chatRoomStore)
                    .environment(\.theme, .lime)
            } label: {
                themeButton(.lime)
            }
        }
    }
    
    private func themeButton(_ theme: Theme) -> some View {
        HStack {
            theme.icon
            
            Text("\(theme.name) 스타일로 보기")
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(height: 32)
        .frame(width: 200)
        .font(.system(size: 12))
        .foregroundColor(theme.primaryFontColor)
        .background(theme.secondaryColor)
        .cornerRadius(4)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

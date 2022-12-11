//
//  HomeView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct HomeView: View {
    let viewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("보낼 때") {
                    ChatView(chatting: viewModel, showingMode: .me)
                }
                
                NavigationLink("보낼 때") {
                    ChatView(chatting: viewModel, showingMode: .other)
                }
            }
            .navigationTitle("연습장 📝")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack) // ipad에서 Drawer를 사용하지 않고 iphone과 같은 UI로 동작
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

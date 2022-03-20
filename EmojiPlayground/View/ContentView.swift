//
//  ContentView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct ContentView: View {
    let viewModel = ChatViewModel()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("보낼 때", destination: ChatView(chatting: viewModel, showingMode: .me))
                
                NavigationLink("받을 때", destination: ChatView(chatting: viewModel, showingMode: .other))
            }
            .navigationTitle("이모티콘 연습장 📝")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // ipad에서 Drawer를 사용하지 않고 iphone과 같은 UI로 동작
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

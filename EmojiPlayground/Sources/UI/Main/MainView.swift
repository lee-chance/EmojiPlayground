//
//  MainView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/11.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                HomeView()
            } label: {
                themButton(.cocoa)
            }
            
            NavigationLink {
                HomeView()
            } label: {
                themButton(.lime)
            }
        }
    }
    
    private func themButton(_ theme: Theme) -> some View {
        HStack {
            theme.icon
            
            Text("\(theme.name) 스타일로 보기")
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(height: 32)
        .frame(width: 200)
        .font(.system(size: 12))
        .foregroundColor(theme.fontColor)
        .background(theme.backgroundColor)
        .cornerRadius(4)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

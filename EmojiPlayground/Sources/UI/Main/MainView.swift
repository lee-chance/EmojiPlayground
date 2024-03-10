//
//  MainView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/11.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userStore: UserStore
    
    @StateObject private var navigation = NavigationManager()
    
    @State private var selection: Panel? = Panel.home
    @State private var presentLoginSheet: Bool = false
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selection)
        } detail: {
            NavigationStack(path: $navigation.path) {
                DetailColumn(selection: $selection)
            }
        }
        .onChange(of: selection) { _ in
            navigation.path.removeLast(navigation.path.count)
        }
        .task {
            await userStore.autoLogin()
        }
        .onChange(of: userStore.presentLoginSheet) { newValue in
            presentLoginSheet = newValue
        }
        .sheet(isPresented: $presentLoginSheet) {
            LoginView()
        }
        .environmentObject(navigation)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

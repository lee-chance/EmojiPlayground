//
//  HomeView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct HomeView<Store: ChatRoomStoreProtocol>: View {
    @StateObject var store: Store
    
    @State private var showNewRoomAlert: Bool = false
    @State private var newRoomName: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    roomListView
                } footer: {
                    listFooterAddButtonView
                }
            }
            .navigationTitle("연습장 📝")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button("Add") {
                    showNewRoomAlert.toggle()
                }
            }
        }
        .navigationViewStyle(.stack) // ipad에서 Drawer를 사용하지 않고 iphone과 같은 UI로 동작
    }
    
    private var roomListView: some View {
        ForEach(store.rooms) { room in
            NavigationLink(room.name) {
                ChatView(chatting: room.chattings)
            }
        }
    }
    
    private var listFooterAddButtonView: some View {
        Button(action: {
            showNewRoomAlert.toggle()
        }) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 18, height: 18)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .alert("새로운 대화방", isPresented: $showNewRoomAlert, actions: {
            TextField("대화방 이름을 입력해주세요.", text: $newRoomName)
            
            Button("만들기", action: {
                if newRoomName.count > 0 {
                    store.add(newRoom: Room(name: newRoomName))
                    newRoomName = ""
                }
            })
            Button("취소", role: .cancel, action: {})
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: MockChatRoomStore())
    }
}

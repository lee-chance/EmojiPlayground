//
//  HomeView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct HomeView: View {
    @State private var presentNewRoomAlert: Bool = false
    @State private var newRoomName: String = ""
    
    @FetchRequest(fetchRequest: Room.all()) private var rooms
    
    var body: some View {
        Form {
            Section {
                NavigationLink("이모티콘 보관함으로 가기") {
                    EmoticonStorageView()
                }
                
                roomListView
            } footer: {
                listFooterAddButtonView
            }
        }
        .toolbar {
            Button("Add") {
                presentNewRoomAlert.toggle()
            }
        }
        .navigationTitle("연습장 📝")
        .navigationDestination(for: Room.self) { room in
            ChatView(room: room)
        }
    }
    
    private var roomListView: some View {
        ForEach(rooms) { room in
            NavigationLink(room.name, value: room)
        }
//        .onDelete(perform: removeLanguages)
    }
    
    // FIXME: Room을 삭제해도 이미지가 남아있다. 이것도 삭제되어야 Room 삭제 가능
    func removeLanguages(at offsets: IndexSet) {
        for index in offsets {
            let room = rooms[index]
            PersistenceController.shared.delete(room)
        }
    }
    
    private var listFooterAddButtonView: some View {
        Button(action: {
            presentNewRoomAlert.toggle()
        }) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 18, height: 18)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .alert("새로운 대화방", isPresented: $presentNewRoomAlert, actions: {
            TextField("대화방 이름을 입력해주세요.", text: $newRoomName)
            
            Button("만들기", action: {
                if newRoomName.count > 0 {
                    PersistenceController.shared.addRoom(name: newRoomName)
                    newRoomName = ""
                }
            })
            
            Button("취소", role: .cancel, action: {})
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

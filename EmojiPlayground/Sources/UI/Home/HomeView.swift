//
//  HomeView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userStore: UserStore
    
    @Binding var navigationSelection: Panel?
    
    @State private var presentNewRoomAlert: Bool = false
    @State private var newRoomName: String = ""
    
    @State private var rooms: [Room] = []
    
    var body: some View {
        Form {
            Link("이모티콘 제안 가이드로 이동하기", destination: URL(string: "https://emoticonstudio.kakao.com/pages/start")!)
            
            NavigationLink("내 보관함", value: Panel.emoticonStorage)
            
//            NavigationLink("커뮤니티로 가기", value: Panel.community)
            
            Section {
                roomListView
            } header: {
                Text("대화방")
            } footer: {
                listFooterAddButtonView
            }
        }
        .task {
            rooms = await Room.all()
        }
        .onChange(of: userStore.user?.uid, perform: { value in
            Task { rooms = await Room.all() }
        })
        .toolbar {
            Button("새 대화방") {
                presentNewRoomAlert.toggle()
            }
        }
        .navigationTitle("연습장 📝")
        .navigationDestination(for: Room.self) { room in
            ChatView(room: room)
                .environmentObject(MessageStore(id: room.id!))
        }
        .navigationDestination(for: Panel.self) { panel in
            switch panel {
            case .emoticonStorage:
                EmoticonStorageMainView()
            case .community:
                CommunityView()
            default:
                Text("Error")
            }
        }
    }
    
    private var roomListView: some View {
        ForEach(rooms) { room in
            NavigationLink(room.name, value: room)
        }
        .onDelete(perform: removeLanguages)
    }
    
    func removeLanguages(at offsets: IndexSet) {
        for index in offsets {
            let room = rooms[index]
            Task { await room.delete() }
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
                    let room = Room(name: newRoomName)
                    Task {
                        await room.add()
                        newRoomName = ""
                        rooms = await Room.all()
                    }
                }
            })
            
            Button("취소", role: .cancel, action: {
                newRoomName = ""
            })
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(navigationSelection: .constant(.home))
    }
}

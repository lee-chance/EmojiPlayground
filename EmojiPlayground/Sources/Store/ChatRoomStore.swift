//
//  ChatRoomStore.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/24.
//

import SwiftUI

protocol ChatRoomStoreProtocol: ObservableObject {
    associatedtype ChatStore: ChatStoreProtocol
    var rooms: [Room<ChatStore>] { get set }
}

extension ChatRoomStoreProtocol {
    func add(newRoom: Room<ChatStore>) {
        rooms.append(newRoom)
    }
}

final class MockChatRoomStore: ChatRoomStoreProtocol {
    @Published var rooms: [Room] = [
        Room(name: "MOCK", chattings: MockChatStore())
    ]
}

final class ChatRoomStore<ChatStore: ChatStoreProtocol>: ChatRoomStoreProtocol {
    @Published var rooms: [Room<ChatStore>] = []
}

struct Room<Store: ChatStoreProtocol>: Identifiable {
    let name: String
    let chattings: Store
    
    var id: String { UUID().uuidString }
    
    init(name: String, chattings: Store = .init()) {
        self.name = name
        self.chattings = chattings
    }
}

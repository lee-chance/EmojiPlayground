//
//  MessageStore.swift
//  Emote
//
//  Created by Changsu Lee on 2023/11/29.
//

import Foundation

@MainActor
final class MessageStore: ObservableObject {
    @Published private(set) var messages: [Message] = []
    
    private let roomID: String
    private var listener: FirestoreListener?
    
    init(id: String) {
        self.roomID = id
        
        addSnapshot()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func addSnapshot() {
        listener = FirestoreManager
            .reference(path: .rooms)
            .reference(path: roomID)
            .reference(path: .messages)
            .order(by: Message.CodingKeys.timestamp.stringValue)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.messages = snapshot?.documents.compactMap { try? $0.data(as: Message.self) } ?? []
            }
    }
    
    func add(message: Message) async {
        await FirestoreManager
            .reference(path: .rooms)
            .reference(path: roomID)
            .reference(path: .messages)
            .setData(from: message)
    }
    
    func delete(message: Message) async {
        await FirestoreManager
            .reference(path: .rooms)
            .reference(path: roomID)
            .reference(path: .messages)
            .reference(path: message.id!)
            .remove()
    }
}

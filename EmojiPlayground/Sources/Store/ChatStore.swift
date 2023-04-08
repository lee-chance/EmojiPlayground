//
//  ChatStore.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

protocol ChatStoreProtocol: ObservableObject {
    var messages: [Message] { get set }
    
    init()
}

final class MockChatStore: ChatStoreProtocol {
    @Published var messages = mockChatData
    
    private static var mockChatData: [Message] = [
        Message(content: .string(content: "Hello"), sender: .me, type: .text),
        Message(content: .string(content: "World!"), sender: .other, type: .text)
    ]
}

final class ChatStore: ChatStoreProtocol {
    @Published var messages = [Message]() {
        didSet {
            saveMessages(messages)
        }
    }
    
    init() {
        if let data = UserDefaults.standard.value(forKey: "messages") as? Data,
           let messagesData = try? PropertyListDecoder().decode([Message].self, from: data) {
            messages = messagesData
        }
    }
    
    private func saveMessages(_ messages: [Message]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(messages), forKey: "messages")
    }
}

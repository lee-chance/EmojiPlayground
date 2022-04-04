//
//  ChatViewModel.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

class ChatViewModel: ObservableObject {
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

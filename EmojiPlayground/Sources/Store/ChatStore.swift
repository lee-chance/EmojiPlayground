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
        Message(content: .plainText(content: "Hello"), sender: .me),
        Message(content: .plainText(content: "World!"), sender: .other)
    ]
}

final class ChatStore: ChatStoreProtocol {
    @AppStorage("messages") var messages: [Message] = []
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        
        self = result
    }

    public var rawValue: String {
        guard
            let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else { return "[]" }
        
        return result
    }
}

//
//  Message.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct Message: Codable {
    let id = UUID().description
    let content: MessageContent
    let sender: Sender
    let type: MessageType
    
    var reversedSender: Message {
        Message(content: content, sender: sender == .other ? .me : .other, type: type)
    }
}

enum MessageContent: Codable {
    case string(content: String)
    case url(content: URL)
}

enum Sender: String, Codable {
    case me, other
    
    var messageBackgroundColor: Color {
        switch self {
        case .me: return .myMessageBackground
        case .other: return .otherMessageBackground
        }
    }
    
    var messageAlignment: Alignment {
        switch self {
        case .me: return .trailing
        case .other: return .leading
        }
    }
}

enum MessageType: String, Codable {
    case text, image, emoji
}

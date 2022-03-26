//
//  Message.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct Message {
    let id = UUID()
    let content: Any
    let sender: Sender
    let type: MessageType
    
    var reversedSender: Message {
        Message(content: content, sender: sender == .other ? .me : .other, type: type)
    }
}

enum Sender {
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

enum MessageType {
    case text, image, emoji
}

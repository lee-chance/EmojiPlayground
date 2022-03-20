//
//  Message.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import Foundation

struct Message {
    let id = UUID()
    let content: Any
    let sender: Sender
    let type: MessageType
    
    var reversedSender: Message {
        Message(content: content, sender: sender == .other ? .me : .other, type: type)
    }
}

//
//  Message.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct Message: Codable {
    let id: UUID
    let content: MessageContent
    let sender: Sender
    
    init(content: MessageContent, sender: Sender) {
        self.id = UUID()
        self.content = content
        self.sender = sender
    }
    
    var reversedSender: Message {
        Message(content: content, sender: sender == .other ? .me : .other)
    }
    
    var isPlainText: Bool {
        content.isPlainText
    }
    
    var isLocalImage: Bool {
        content.isLocalImage
    }
    
    var isStorageImage: Bool {
        content.isStorageImage
    }
}

enum MessageContent: Codable {
    case plainText(content: String)
    case localImage(url: URL)
    case storageImage(url: URL)
    
    var isPlainText: Bool {
        switch self {
        case .plainText:
            return true
        default:
            return false
        }
    }
    
    var isLocalImage: Bool {
        switch self {
        case .localImage:
            return true
        default:
            return false
        }
    }
    
    var isStorageImage: Bool {
        switch self {
        case .storageImage:
            return true
        default:
            return false
        }
    }
    
    var isGIFImage: Bool {
        switch self {
        case .localImage(let url):
            return url.pathExtension == "gif"
        case .storageImage(let url):
            return false
        default:
            return false
        }
    }
    
    func getLocalImageURL() -> URL? {
        switch self {
        case .localImage(let url):
            return url
        default:
            return nil
        }
    }
}

enum Sender: String, Codable {
    case me, other
    
    var messageAlignment: Alignment {
        switch self {
        case .me: return .trailing
        case .other: return .leading
        }
    }
}

//
//  Message.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var timestamp: Date?
    
    let contentValue: String
    let contentType: MessageContentType
    let sender: MessageSender
    
    var imageURL: URL? {
        URL(string: contentValue)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case timestamp
        case contentValue
        case contentType
        case sender
    }
    
    init(plainText: String, sender: MessageSender) {
        self.contentValue = plainText
        self.contentType = .plainText
        self.sender = sender
    }
    
    init(imageURLString: String, sender: MessageSender) {
        self.contentValue = imageURLString
        self.contentType = .image
        self.sender = sender
    }
    
    func setEmoticon(groupName: String, tag: String? = nil) async {
        guard contentType == .image else { return }
                
        await FirestoreManager
            .reference(path: .users)
            .reference(path: UserStore.shared.userID)
            .reference(path: .emoticons)
            .setData(from: Emoticon(urlString: contentValue, groupName: groupName, tag: tag))
    }
}

extension Message {
    static func getMessages(of room: Room) async -> [Self] {
        await FirestoreManager
            .reference(path: .users)
            .reference(path: UserStore.shared.userID)
            .reference(path: .rooms)
            .reference(path: room.id!)
            .reference(path: .messages)
            .order(by: CodingKeys.timestamp.stringValue)
            .get(type: Message.self)
    }
}

enum MessageSender: String, Codable {
    case from, to
    
    var messageAlignment: Alignment {
        switch self {
        case .to: return .trailing
        case .from: return .leading
        }
    }
}

enum MessageContentType: String, Codable {
    case plainText, image
}

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
    
    init(miniItems: [MiniItem], sender: MessageSender) {
        self.contentValue = miniItems.contentValue
        self.contentType = .mini
        self.sender = sender
    }
    
    init(attributedString: NSAttributedString, sender: MessageSender) {
        self.contentValue = (try! attributedString.data()).base64EncodedString()
        self.contentType = .attributed
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
    case plainText, image, mini, attributed
}

enum MiniItem: Hashable {
    case plain(String)
    case image(String)
    
    var value: String {
        switch self {
        case .plain(let string):
            "plain(\(string))"
        case .image(let string):
            "image(\(string))"
        }
    }
    
    var contentValue: String {
        switch self {
        case .plain(let string):
            string
        case .image(let string):
            string
        }
    }
    
    var isPlain: Bool {
        switch self {
        case .plain(_):
            true
        case .image(_):
            false
        }
    }
}

extension [MiniItem] {
    var contentValue: String {
        map { $0.value }.joined(separator: ",")
    }
}

extension NSAttributedString {
    func data() throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

extension Data {
    func topLevelObject() throws -> Any? {
        try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: self)
    }
    
    func unarchive<T>() throws -> T? {
        try topLevelObject() as? T
    }
    
    func attributedString() throws -> NSAttributedString? {
        try unarchive()
    }
}

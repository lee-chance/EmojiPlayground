//
//  Room.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Room: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    @ServerTimestamp var timestamp: Date?
    
    let name: String
    
    var messages: [Message] {
        get async throws {
            guard let id else { return [] }
            
            return await FirestoreManager
                .reference(path: .rooms)
                .reference(path: id)
                .reference(path: .messages)
                .order(by: Message.CodingKeys.timestamp.stringValue)
                .get(type: Message.self)
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    func add() async {
        await FirestoreManager
            .reference(path: .rooms)
            .setData(from: self)
    }
    
    func delete() async {
        guard let id else { return }
        
        await FirestoreManager
            .reference(path: .rooms)
            .reference(path: id)
            .remove()
    }
}

extension Room {
    static func all() async -> [Self] {
        await FirestoreManager
            .reference(path: .rooms)
            .order(by: CodingKeys.timestamp.stringValue)
            .get(type: Self.self)
    }
}

//
//  Emoticon.swift
//  Emote
//
//  Created by Changsu Lee on 2023/11/29.
//

import Foundation
import FirebaseFirestoreSwift

struct Emoticon: Codable, Identifiable, Hashable, Equatable {
    @DocumentID var id: String?
    @ServerTimestamp var timestamp: Date?
    
    let urlString: String
    let memo: String?
    let groupName: String
    
    var url: URL {
        URL(string: urlString)!
    }
    
    enum CodingKeys: CodingKey {
        case id
        case timestamp
        case urlString
        case memo
        case groupName
    }
    
    init(urlString: String, memo: String? = nil, groupName: String) {
        self.urlString = urlString
        self.memo = memo
        self.groupName = groupName
    }
    
    func delete() async {
        await FirestoreManager
            .reference(path: .users)
            .reference(path: UserStore.shared.userID)
            .reference(path: .emoticons)
            .reference(path: id!)
            .remove()
    }
    
    func update(groupName: String) async {
        await FirestoreManager
            .reference(path: .users)
            .reference(path: UserStore.shared.userID)
            .reference(path: .emoticons)
            .reference(path: id!)
            .update([CodingKeys.groupName.stringValue : groupName])
    }
}

extension Emoticon {
    static func all() async -> [Self] {
        await FirestoreManager
            .reference(path: .users)
            .reference(path: UserStore.shared.userID)
            .reference(path: .emoticons)
            .order(by: CodingKeys.timestamp.stringValue)
            .get(type: Self.self)
    }
}

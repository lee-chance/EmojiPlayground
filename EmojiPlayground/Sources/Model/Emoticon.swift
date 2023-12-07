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

extension Emoticon {
    private static var baseURLString: String {
        "https://firebasestorage.googleapis.com/v0/b/emote-543b9.appspot.com/o"
    }
    
    static var cuteMonsters: [Emoticon] {
        (1...10).map { Emoticon(urlString: "\(baseURLString)/common%2FCute%20Monsters%2FFrame%20\($0).png?alt=media", groupName: "Cute Monsters") }
    }
    
    static var tdchs: [Emoticon] {
        (1...46).map { Emoticon(urlString: "\(baseURLString)/common%2FTdch%2FSticker%20\($0).gif?alt=media", groupName: "Tdch") }
    }
}

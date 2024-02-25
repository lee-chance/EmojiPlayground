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
    let filename: String
    let groupName: String
    let tag: String?
    
    var url: URL {
        URL(string: urlString)!
    }
    
    var isSample: Bool {
        EmoticonSample.allGroupNames.contains(groupName)
    }
    
    init(urlString: String, filename: String? = nil, groupName: String, tag: String? = nil) {
        self.urlString = urlString
        self.filename = filename ?? URL(string: urlString)?.lastPathComponent ?? ""
        self.groupName = groupName
        self.tag = tag
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
    
    static func loadSamplesFromOrigin() async -> [Self] {
        await FirestoreManager
            .reference(path: .samples)
            .reference(path: "emoticons")
            .reference(path: .emoticons)
            .get(type: Self.self)
    }
}

enum EmoticonSample: CaseIterable {
    case cuteMonsters, tdchs
    
    private var baseURLString: String {
        "https://firebasestorage.googleapis.com/v0/b/emote-543b9.appspot.com/o"
    }
    
    private var totalCount: Int {
        switch self {
        case .cuteMonsters:
            10
        case .tdchs:
            46
        }
    }
    
    private var groupName: String {
        switch self {
        case .cuteMonsters:
            "Cute Monsters"
        case .tdchs:
            "Tdch"
        }
    }
    
    private var pathName: String {
        "common/\(groupName)"
    }
    
    private var filePrefixName: String {
        switch self {
        case .cuteMonsters:
            "Frame"
        case .tdchs:
            "Sticker"
        }
    }
    
    private var fileExtension: String {
        switch self {
        case .cuteMonsters:
            "png"
        case .tdchs:
            "gif"
        }
    }
    
    private func fileName(of number: Int) -> String {
        "\(filePrefixName) \(number).\(fileExtension)"
    }
    
    var emoticons: [Emoticon] {
        (1...totalCount).map { imageNumber in
            let firebaseURLString = "\(baseURLString)/"
            let encodedURLString = "\(pathName)/\(fileName(of: imageNumber))".addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!
            let queryString = "?alt=media"
            let urlString = firebaseURLString + encodedURLString + queryString
            return Emoticon(urlString: urlString, filename: fileName(of: imageNumber), groupName: groupName)
        }
    }
    
    static var allGroupNames: [String] {
        Self.allCases.map { $0.groupName }
    }
}

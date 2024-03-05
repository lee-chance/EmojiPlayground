//
//  Tag.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/03.
//

import Foundation

struct Tag: Codable, Identifiable, Hashable, Equatable {
    let name: String
    let isPublic: Bool
    let isValid: Bool
    let usedUsers: [String]
    
    var id: String { name }
    
    func add() async {
        await FirestoreManager
            .reference(path: .tags)
            .reference(path: id)
            .setData(from: self)
    }
    
    func update(userID: String) async {
        let updateUsedUsers = {
            var result = usedUsers
            if !usedUsers.contains(userID) {
                result.append(userID)
            }
            return result
        }()
        
        let updateIsPublic = {
            guard isValid else {
                return false
            }
            
            guard !isPublic else {
                return true
            }
            
            return updateUsedUsers.count > 5
        }()
        
        let updatFields: [String : Any] = [
            CodingKeys.isPublic.stringValue : updateIsPublic,
            CodingKeys.usedUsers.stringValue : updateUsedUsers
        ]
        await FirestoreManager
            .reference(path: .tags)
            .reference(path: id)
            .update(updatFields)
    }
}

extension Tag {
    static func all() async -> [Self] {
        await FirestoreManager
            .reference(path: .tags)
            .whereField(CodingKeys.isPublic.stringValue, isEqualTo: true)
            .whereField(CodingKeys.isValid.stringValue, isEqualTo: true)
            .get(type: Self.self)
    }
    
    static func get(id: String) async -> Self? {
        await FirestoreManager
            .reference(path: .tags)
            .reference(path: id)
            .get(type: Self.self)
    }
}

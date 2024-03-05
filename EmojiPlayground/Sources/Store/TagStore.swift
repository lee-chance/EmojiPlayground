//
//  TagStore.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/03.
//

import Foundation

@MainActor
final class TagStore: ObservableObject {
    @Published private(set) var tags: [Tag] = []
    
    func fetchTags() async {
        let fetchedTags = await Tag.all()
        if (fetchedTags != tags) {
            tags = fetchedTags
        }
    }
    
    func upsert(id: String) async {
        if let tag = await Tag.get(id: id) {
            await tag.update(userID: UserStore.shared.userID)
        } else {
            let tag = Tag(name: id, isPublic: false, isValid: true, usedUsers: [UserStore.shared.userID])
            await tag.add()
        }
    }
}

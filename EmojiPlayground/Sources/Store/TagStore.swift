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
    
    /// 업데이트 or 추가
    ///
    /// Firestore의 tags/{id}의 usedUsers필드에 사용자 추가하며
    /// usedUsers의 사용자가 5명 이상이 되면 자동으로 isPublic필드가 true가 된다.
    ///
    /// - Parameter id: 업데이트하거나 추가할 tag 이름
    func upsert(id: String) async {
        if let tag = await Tag.get(id: id) {
            await tag.update(userID: UserStore.shared.userID)
        } else {
            let tag = Tag(name: id, isPublic: false, isValid: true, usedUsers: [UserStore.shared.userID])
            await tag.add()
        }
    }
}

//
//  EmoticonStore.swift
//  Emote
//
//  Created by Changsu Lee on 2023/11/30.
//

import Foundation

@MainActor
final class EmoticonStore: ObservableObject {
    @Published private(set) var emoticons: [Emoticon] = []
    
    private var listener: FirestoreListener?
    
    var emoticonGroups: [EmoticonGroup] {
        Dictionary(grouping: emoticons, by: { $0.groupName })
            .sorted(by: { $0.key > $1.key })
            .map { EmoticonGroup(name: $0.key, emoticons: $0.value) }
    }
    
    var groupNames: [String] {
        Array(Set(emoticons.compactMap { $0.groupName }))
            .sorted()
    }
    
    func emoticonGroup(name: String) -> EmoticonGroup? {
        emoticonGroups.filter { $0.name == name }.first
    }
    
    func fetchEmoticons() async {
        emoticons = await Emoticon.all()
    }
    
    func add(emoticon: Emoticon) async {
        await FirestoreManager
            .reference(path: .users)
            .reference(path: UserStore.shared.userID)
            .reference(path: .emoticons)
            .setData(from: emoticon)
    }
    
    func delete(emoticon: Emoticon) async {
        await FirestoreManager
            .reference(path: .users)
            .reference(path: UserStore.shared.userID)
            .reference(path: .emoticons)
            .reference(path: emoticon.id!)
            .remove()
    }
}

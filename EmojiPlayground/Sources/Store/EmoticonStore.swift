//
//  EmoticonStore.swift
//  Emote
//
//  Created by Changsu Lee on 2023/11/30.
//

import Foundation

@MainActor
final class EmoticonStore: ObservableObject {
    @Published private(set) var emoticons: [Emoticon] = [] {
        didSet {
            let dict = Dictionary(grouping: emoticons, by: { $0.groupName })
            
            var result = [EmoticonGroup]()
            for groupName in groupNames {
                result.append(EmoticonGroup(name: groupName, emoticons: dict[groupName] ?? []))
            }
            
            emoticonGroups =  result
        }
    }
    var emoticonGroups: [EmoticonGroup] = []
    
    var groupNames: [String] {
        Array(Set(emoticons.compactMap { $0.groupName }))
            .sorted()
            .filter { !EmoticonSample.allGroupNames.contains($0) }
        + EmoticonSample.groupNames
    }
    
    func emoticonGroup(name: String) -> EmoticonGroup? {
        emoticonGroups.filter { $0.name == name }.first
    }
    
    func fetchEmoticons() async {
        let fetchedEmoticons = await Emoticon.all()
        if (fetchedEmoticons != emoticons) {
            emoticons = fetchedEmoticons
        }
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

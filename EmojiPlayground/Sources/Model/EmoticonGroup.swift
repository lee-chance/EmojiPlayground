//
//  EmoticonGroup.swift
//  Emote
//
//  Created by Changsu Lee on 2023/11/30.
//

import Foundation

struct EmoticonGroup: Identifiable, Hashable {
    let name: String
    let emoticons: [Emoticon]
    
    var id: String { name }
    
    var firstCharacterOfName: Character {
        if let first = name.trimmingCharacters(in: .whitespacesAndNewlines).first {
            return first
        } else {
            return "-"
        }
    }
}

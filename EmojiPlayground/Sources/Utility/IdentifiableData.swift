//
//  IdentifiableData.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/16.
//

import Foundation

struct IdentifiableData: Identifiable {
    let rawValue: Data
    
    init(_ data: Data) {
        rawValue = data
    }
    
    var id: String {
        rawValue.base64EncodedString()
    }
}

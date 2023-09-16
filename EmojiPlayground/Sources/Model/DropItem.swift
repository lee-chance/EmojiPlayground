//
//  DropItem.swift
//  Emote
//
//  Created by Changsu Lee on 2023/09/16.
//

import CoreTransferable

enum DropItem: Codable, Transferable {
    case text(String)
    case data(Data)
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { DropItem.text($0) }
        ProxyRepresentation { DropItem.data($0) }
    }
}

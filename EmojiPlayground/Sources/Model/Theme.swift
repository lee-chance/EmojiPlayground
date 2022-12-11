//
//  Theme.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/11.
//

import SwiftUI

enum Theme {
    case cocoa, lime
    
    var name: String {
        switch self {
        case .cocoa:
            return "코코아"
        case .lime:
            return "라임"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .cocoa:
            return Color(rgb: 0xFEE500)
        case .lime:
            return Color(rgb: 0x06C755)
        }
    }
    
    var fontColor: Color {
        switch self {
        case .cocoa:
            return Color.black
        case .lime:
            return Color.white
        }
    }
    
    var icon: Image {
        switch self {
        case .cocoa:
            return Image("CocoaIcon")
        case .lime:
            return Image("LimeIcon")
        }
    }
}

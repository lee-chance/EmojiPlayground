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
    
    var icon: Image {
        switch self {
        case .cocoa:
            return Image("CocoaIcon")
        case .lime:
            return Image("LimeIcon")
        }
    }
}

extension Theme {
    var primaryColor: Color {
        switch self {
        case .cocoa:
            return Color(rgb: 0xFEF01B)
        case .lime:
            return Color(rgb: 0x06C755)
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .cocoa:
            return Color(rgb: 0xFEE500)
        case .lime:
            return Color(rgb: 0x06C755)
        }
    }
    
    var primaryFontColor: Color {
        switch self {
        case .cocoa:
            return Color(rgb: 0x000000)
        case .lime:
            return Color(rgb: 0x000000)
        }
    }
    
    var secondaryFontColor: Color {
        switch self {
        case .cocoa:
            return Color(rgb: 0x556677)
        case .lime:
            return Color(rgb: 0x556677)
        }
    }
    
    var chatBackgroundColor: Color {
        switch self {
        case .cocoa:
            return Color(rgb: 0x9bbbd4)
        case .lime:
            return Color(rgb: 0x9bbbd4)
        }
    }
}

//
//  ColorExtension.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI

extension Color: RawRepresentable {
    public init?(rawValue: Int) {
        let red = Double((rawValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rawValue & 0x00FF00) >> 8) / 0xFF
        let blue = Double(rawValue & 0x0000FF) / 0xFF
        self = Color(red: red, green: green, blue: blue)
    }
    
    public var rawValue: Int {
        guard let coreImageColor = coreImageColor else {
            return 0
        }
        let red = Int(coreImageColor.red * 255 + 0.5)
        let green = Int(coreImageColor.green * 255 + 0.5)
        let blue = Int(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }
    
    private var coreImageColor: CIColor? {
        CIColor(color: .init(self))
    }
}

extension Color {
    static let systemGray = Color(uiColor: UIColor.systemGray)
    static let systemGray2 = Color(uiColor: UIColor.systemGray2)
    static let systemGray3 = Color(uiColor: UIColor.systemGray3)
    static let systemGray4 = Color(uiColor: UIColor.systemGray4)
    static let systemGray5 = Color(uiColor: UIColor.systemGray5)
    static let systemGray6 = Color(uiColor: UIColor.systemGray6)
}

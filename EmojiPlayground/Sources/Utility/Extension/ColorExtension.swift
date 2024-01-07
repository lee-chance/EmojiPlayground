//
//  ColorExtension.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI

/**
 AppStorage에서 사용하기 위해 RawRepresentable 프로토콜을 채택하여 사용
 */
extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard 
            let data = Data(base64Encoded: rawValue),
            let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        else { return nil }
        
        self = Color(color)
    }

    public var rawValue: String {
        let data = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false)
        
        return data?.base64EncodedString() ?? ""
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

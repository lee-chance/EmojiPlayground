//
//  Environment.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/21.
//

import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .cocoa
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

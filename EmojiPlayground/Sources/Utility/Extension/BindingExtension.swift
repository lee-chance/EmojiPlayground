//
//  BindingExtension.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/03.
//

import SwiftUI

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}

//
//  UIApplicationExtension.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/21.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

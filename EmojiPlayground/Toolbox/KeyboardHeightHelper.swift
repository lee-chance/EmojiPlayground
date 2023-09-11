//
//  KeyboardHeightHelper.swift
//
//
//  Created by Changsu Lee
//

import UIKit

final class KeyboardHeightHelper: ObservableObject {
    @Published var height: CGFloat = 0
    
    init() {
        listenForKeyboardNotifications()
    }
    
    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard
                let userInfo = notification.userInfo,
                let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.height = keyboardRect.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification,
            object: nil,
            queue: .main
        ) { notification in
            DispatchQueue.main.async { [weak self] in
                self?.height = 0
            }
        }
    }
}

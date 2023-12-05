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

extension UIApplication {
    var window: UIWindow? {
        let windowScene = connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        return window
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.window?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}

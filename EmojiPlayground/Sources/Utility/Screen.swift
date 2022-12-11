//
//  Screen.swift
//
//
//  Created by Changsu Lee
//

import UIKit

struct Screen {
    static var height: CGFloat { UIScreen.main.bounds.height }
    
    static var width: CGFloat { UIScreen.main.bounds.width }
    
    static var navigationBarHeight: CGFloat { 44 }
    
    static var tabBarHeight: CGFloat { 49 }
    
    static var statusBar: CGFloat {
        guard #available(iOS 13.0, *) else {
            // deviceVersion < iOS 13
            return UIApplication.shared.statusBarFrame.height
        }
        
        guard #available(iOS 15.0, *) else {
            // iOS 13 <= deviceVersion < iOS 15
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0 // has a bug in IPhone 12 mini
            return window?.safeAreaInsets.top ?? 0
        }
        
        // iOS 15 <= deviceVersion
        let window = UIApplication.shared.connectedScenes
               .filter { $0.activationState == .foregroundActive }
               .map {$0 as? UIWindowScene }
               .compactMap { $0 }
               .first?.windows
               .filter({ $0.isKeyWindow }).first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
    static var bottomSafeArea: CGFloat {
        guard #available(iOS 15.0, *) else {
            // deviceVersion < iOS 15
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return window?.safeAreaInsets.bottom ?? 0
        }
        
        // iOS 15 <= deviceVersion
        let window = UIApplication.shared.connectedScenes
               .filter { $0.activationState == .foregroundActive }
               .map {$0 as? UIWindowScene }
               .compactMap { $0 }
               .first?.windows
               .filter({ $0.isKeyWindow }).first
        return window?.safeAreaInsets.bottom ?? 0
    }
}

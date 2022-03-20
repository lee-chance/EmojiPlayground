//
//  NavigationBarColor.swift
//  
//
//  Created by Changsu Lee
//

import SwiftUI

struct NavigationBarColor: ViewModifier {
    init(backgroundColor: UIColor, tintColor: UIColor) {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: tintColor]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = tintColor
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor, tintColor: UIColor) -> some View {
        self.modifier(NavigationBarColor(backgroundColor: backgroundColor, tintColor: tintColor))
    }
    
    func navigationBarColor(backgroundColor: Color, tintColor: Color) -> some View {
        let uiBackgroundColor = UIColor(backgroundColor)
        let uiTintColor = UIColor(tintColor)
        return self.modifier(NavigationBarColor(backgroundColor: uiBackgroundColor, tintColor: uiTintColor))
    }
}

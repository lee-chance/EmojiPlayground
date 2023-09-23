//
//  Alerts.swift
//
//
//  Created by Changsu Lee
//

import SwiftUI

public extension View {
    func alert<T, A: View, M: View>(
        title: Text,
        presenting: Binding<T?>,
        @ViewBuilder actions: (T) -> A,
        @ViewBuilder message: (T) -> M
    ) -> some View {
        alert(title, isPresented: isPresented(of: presenting), presenting: presenting.wrappedValue, actions: actions, message: message)
    }
    
    func alert<T, A: View>(
        title: Text,
        presenting: Binding<T?>,
        @ViewBuilder actions: (T) -> A
    ) -> some View {
        alert(title, isPresented: isPresented(of: presenting), presenting: presenting.wrappedValue, actions: actions)
    }
    
    func alert<T, A: View, M: View>(
        _ titleKey: LocalizedStringKey,
        presenting: Binding<T?>,
        @ViewBuilder actions: (T) -> A,
        @ViewBuilder message: (T) -> M
    ) -> some View {
        alert(titleKey, isPresented: isPresented(of: presenting), presenting: presenting.wrappedValue, actions: actions, message: message)
    }
    
    func alert<T, A: View>(
        _ titleKey: LocalizedStringKey,
        presenting: Binding<T?>,
        @ViewBuilder actions: (T) -> A
    ) -> some View {
        alert(titleKey, isPresented: isPresented(of: presenting), presenting: presenting.wrappedValue, actions: actions)
    }
    
    private func isPresented<T>(of presenting: Binding<T?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { presenting.wrappedValue != nil },
            set: { if !$0 { presenting.wrappedValue = nil } }
        )
    }
}

//
//  TagModifier.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/06.
//

import SwiftUI

struct TagModifier: ViewModifier {
    private let color: Color
    
    init(color: Color = .primary) {
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(.capsule)
    }
}

#Preview {
    Text("hi")
        .modifier(TagModifier(color: .accentColor))
}

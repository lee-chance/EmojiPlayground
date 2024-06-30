//
//  PlainTextMessageView.swift
//  Emote
//
//  Created by Changsu Lee on 6/30/24.
//

import SwiftUI

struct PlainTextMessageView: View {
    @EnvironmentObject private var settings: Settings
    
    let message: Message
    
    var body: some View {
        Text(message.contentValue)
            .foregroundStyle(message.sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
            .padding(12)
            .background(message.sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor)
            .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    let plain = Message(plainText: "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World", sender: .to)
    
    return PlainTextMessageView(message: plain)
        .font(.largeTitle)
        .environmentObject(Settings())
}

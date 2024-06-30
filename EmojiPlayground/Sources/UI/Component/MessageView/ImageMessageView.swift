//
//  ImageMessageView.swift
//  Emote
//
//  Created by Changsu Lee on 6/30/24.
//

import SwiftUI

struct ImageMessageView: View {
    let message: Message
    
    var body: some View {
        ImageView(url: message.imageURL, size: .large)
            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
}

#Preview {
    let image = Message(imageURLString: "https://picsum.photos/200", sender: .from)
    
    return ImageMessageView(message: image)
        .font(.largeTitle)
        .environmentObject(Settings())
}

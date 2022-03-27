//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView: View {
    let content: Any
    let sender: Sender
    let type: MessageType
    
    var body: some View {
        HStack {
            if sender == .me {
                emptySpacer
            }
            
            switch content {
            case is String:
                Text(content as! String)
                    .foregroundColor(.mainTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(sender.messageBackgroundColor)
                    .cornerRadius(4)
            case is URL:
                ZStack {
                    let data = try! Data(contentsOf: content as! URL)
                    switch type {
                    case .image:
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 200, alignment: sender.messageAlignment)
                                .frame(maxWidth: .infinity, alignment: sender.messageAlignment)
                        }
                    case .emoji:
                        AnimatedImage(data: data)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200, alignment: sender.messageAlignment)
                            .frame(maxWidth: .infinity, alignment: sender.messageAlignment)
                    default: EmptyView()
                    }
                }
            default: emptySpacer
            }
            
            if sender == .other {
                emptySpacer
            }
        }
        .frame(maxWidth: .infinity, alignment: sender.messageAlignment)
    }
    
    private var emptySpacer: some View {
        Text(" ")
            .frame(width: Screen.width * 0.15)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(content: "ㅎㅎ", sender: .me, type: .text)
    }
}

//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI

struct MessageView: View {
    let content: Any
    let sender: Sender
    
    var body: some View {
        HStack {
            if sender == .me {
                emptySpacer
            }
            
            switch content {
            case is Image:
                (content as! Image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200, alignment: sender.messageAlignment)
                    .frame(maxWidth: .infinity, alignment: sender.messageAlignment)
            case is String:
                Text(content as! String)
                    .foregroundColor(.mainTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(sender.messageBackgroundColor)
                    .cornerRadius(4)
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
        MessageView(content: "ㅎㅎ", sender: .me)
    }
}


enum Sender {
    case me, other
    
    var messageBackgroundColor: Color {
        switch self {
        case .me: return .myMessageBackground
        case .other: return .otherMessageBackground
        }
    }
    
    var messageAlignment: Alignment {
        switch self {
        case .me: return .trailing
        case .other: return .leading
        }
    }
}

enum MessageType {
    case text, image, emoji
}

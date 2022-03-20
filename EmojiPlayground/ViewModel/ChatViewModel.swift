//
//  ChatViewModel.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages = [Message]()
}

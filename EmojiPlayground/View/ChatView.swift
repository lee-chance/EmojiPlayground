//
//  ChatView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var chatting: ChatViewModel
    let showingMode: Sender
    
    @State private var text = ""
    @State private var showsPhotoLibrary = false
    @State private var showsEmojiLibrary = false
    
    private var chatMessages: [Message] {
        var chattings = chatting.messages
        if showingMode == .other {
            chattings = chattings.map { $0.reversedSender }
        }
        return chattings
    }
    
    private func moveToBottom(of proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(emptyScrollToString, anchor: .bottom)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            chatListView
            
            bottomInputView
            
            bottomEmojiView
        }
        .background(Color.background)
        .navigationTitle(showingMode == .me ? "보낼 때" : "받을 때")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showsPhotoLibrary) {
            ImagePicker { res in
                let message = Message(content: .url(content: res.url), sender: .me, type: res.ext == "gif" ? .emoji : .image)
                chatting.messages.append(message)
            }
        }
    }
    
    private var chatListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(chatMessages, id: \.id) { msg in
                        MessageView(chatting: chatting, message: msg)
                    }
                    .padding(.horizontal)
                    
                    HStack { Spacer() }
                        .id(emptyScrollToString)
                }
                .onChange(of: chatMessages.count) { _ in
                    moveToBottom(of: proxy)
                }
                .onAppear {
                    moveToBottom(of: proxy)
                }
            }
        }
        .padding(.top, 1) // Solid Navigation Bar
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    private var bottomInputView: some View {
        HStack(spacing: 0) {
            Button(action: {
                showsPhotoLibrary = true
            }) {
                Image(systemName: "plus")
                    .buttonModifier
                    .foregroundColor(.subTextColor)
            }
            
            TextEditor(text: $text)
                .frame(height: 40) // 40으로해야 글자의 높이가 중앙에 위치한다.
                .onTapGesture {
                    showsEmojiLibrary = false
                }
            
            Button(action: {
                showsPhotoLibrary = true // 임시
                
                // TODO: Emoji
//                UIApplication.shared.endEditing()
//                withAnimation(.linear(duration: 0.001)) {
//                    showsEmojiLibrary = true
//                }
            }) {
                Image(systemName: "face.smiling")
                    .buttonModifier
                    .foregroundColor(.subTextColor)
            }
            
            if text.count > 0 {
                Button(action: {
                    let message = Message(content: .string(content: text), sender: .me, type: .text)
                    chatting.messages.append(message)
                    text = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .buttonModifier
                        .foregroundColor(.mainTextColor)
                        .background(Color.myMessageBackground)
                }
            } else {
                Button(action: {}) {
                    Image(systemName: "number")
                        .buttonModifier
                        .foregroundColor(.subTextColor)
                }
            }
        }
        .padding(.bottom, Screen.bottomSafeArea > 0 ? 1 : 0) // Solid Bottom SafeArea
        .frame(minHeight: 48)
        .background(Color.white)
    }
    
    private var bottomEmojiView: some View {
        VStack(spacing: 0) {
            Text("무야호~ ")
                .background(Color.red)
        }
        .frame(height: showsEmojiLibrary ? Screen.height / 3 : 0)
        .frame(maxWidth: .infinity)
        .opacity(showsEmojiLibrary ? 1 : 0)
        .background(Color.white)
    }
    
    private let emptyScrollToString = "Empty"
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(chatting: ChatViewModel(), showingMode: .me)
    }
}

extension Image {
    var buttonModifier: some View {
        self
            .resizable()
            .padding(14)
            .frame(width: 48, height: 48)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

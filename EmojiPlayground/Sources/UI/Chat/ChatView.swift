//
//  ChatView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI

struct ChatView: View {
    @EnvironmentObject private var messageStore: MessageStore
    @EnvironmentObject private var settings: Settings
    @Environment(\.font) private var font
    
    @State private var message = NSAttributedString()
    @State private var showsEmojiLibrary = false
    @State private var sender: MessageSender = .to
    @State private var photoSelections: [PhotosPickerItem] = []
    @State private var errorAlertMessage: String?
    @State private var isPresentedUploadOverlay = false
    
    private let room: Room
    
    init(room: Room) {
        self.room = room
    }
    
    private func moveToBottom(of proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(emptyScrollToString, anchor: .bottom)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            chatListView
                .dropDestination(for: DropItem.self) { items, _ in
                    isPresentedUploadOverlay = true
                    
                    for item in items {
                        Task {
                            switch item {
                            case .text(let message):
                                let message = Message(plainText: message, sender: sender)
                                await messageStore.add(message: message)
                            case .data(let data):
                                guard let url = await FirebaseStorageManager.upload(data: data, to: "private/\(UserStore.shared.userID)") else {
                                    isPresentedUploadOverlay = false
                                    return false
                                }
                                
                                let message = Message(imageURLString: url.absoluteString, sender: sender)
                                await messageStore.add(message: message)
                                await message.setEmoticon(groupName: room.name)
                            }
                            return true
                        }
                    }
                    
                    isPresentedUploadOverlay = false
                    return true
                }
            
//            senderPickerView
            
            bottomInputView
            
            bottomEmojiView
        }
        .background(settings.roomBackgoundColor)
        .overlay {
            if isPresentedUploadOverlay {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.large)
                            .tint(.white)
                    )
            }
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
    
    private var chatListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(messageStore.messages) { msg in
                        MessageView(message: msg)
                    }
                    .padding(.horizontal)
                    
                    HStack { Spacer() }
                        .id(emptyScrollToString)
                }
                .onChange(of: messageStore.messages.count) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        moveToBottom(of: proxy)
                    }
                }
                .onAppear {
                    moveToBottom(of: proxy)
                }
            }
        }
        .padding(.top, 1) // Solid Navigation Bar
        .onTapGesture {
            UIApplication.shared.endEditing()
            showsEmojiLibrary = false
        }
    }
    
    private var senderPickerView: some View {
        Picker("", selection: $sender) {
            Text("👈")
                .font(.title2)
                .tag(MessageSender.from)
            
            Text("👉")
                .font(.title2)
                .tag(MessageSender.to)
        }
        .pickerStyle(.segmented)
    }
    
    private var bottomInputView: some View {
        HStack(spacing: 8) {
            PhotosPicker(
                selection: $photoSelections,
                matching: .images) {
                    Image(systemName: "plus.app")
                        .buttonModifier
                        .foregroundStyle(.gray)
                }
                .onChange(of: photoSelections) { newValue in
                    guard !newValue.isEmpty else { return }
                    photoSelections.removeAll()
                    
                    isPresentedUploadOverlay = true
                    
                    Task {
                        for selection in newValue {
                            guard
                                let data = try await selection.loadTransferable(type: Data.self),
                                let url = await FirebaseStorageManager.upload(data: data, to: "private/\(UserStore.shared.userID)")
                            else {
                                isPresentedUploadOverlay = false
                                errorAlertMessage = "업로드 중 오류가 발생했습니다."
                                return
                            }
                            
                            let message = Message(imageURLString: url.absoluteString, sender: sender)
                            await messageStore.add(message: message)
                            await message.setEmoticon(groupName: room.name)
                        }
                        
                        isPresentedUploadOverlay = false
                    }
                }
                .alert("오류", presenting: $errorAlertMessage) { _ in
                    Button("확인", role: .cancel, action: {})
                } message: { message in
                    Text(message)
                }
            
            let textInputViewMinimumHeight: CGFloat = 36
            HStack(spacing: 0) {
                RichTextInputView(attributedText: $message)
                    .padding(.horizontal, 8)
                    .frame(minHeight: textInputViewMinimumHeight)
                    .onTapGesture {
                        showsEmojiLibrary = false
                    }
                
                HStack(spacing: 8) {
                    Button(action: {
                        UIApplication.shared.endEditing()
                        withAnimation(.linear(duration: 0.001)) {
                            showsEmojiLibrary.toggle()
                        }
                    }) {
                        Image(systemName: "face.smiling")
                            .buttonModifier
                            .foregroundStyle(.gray)
                    }
                    
                    if message.length > 0 {
                        Button(action: {
                            Task {
                                let sendingMessage = Message(attributedString: message, sender: sender)
                                message = NSAttributedString()
                                await messageStore.add(message: sendingMessage)
                            }
                        }) {
                            Image(systemName: "arrow.up")
                                .buttonModifier
                                .foregroundStyle(sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
                                .background(
                                    Circle()
                                        .stroke(Color.black.opacity(0.1))
                                        .background(Circle().fill(sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor))
                                )
                        }
                    } else {
                        Button(action: {
                            if sender == .to { sender = .from }
                            else { sender = .to }
                        }) {
                            Image(systemName: sender == .to ? "hand.point.right" : "hand.point.left")
                                .buttonModifier
                                .foregroundStyle(.gray)
                                .animation(nil, value: sender)
                        }
                    }
                }
            }
            .padding(4)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: textInputViewMinimumHeight, style: .circular))
            .background(
                RoundedRectangle(cornerRadius: textInputViewMinimumHeight, style: .circular)
                    .stroke(Color.black.opacity(0.1))
            )
            .padding(.vertical, 2)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, Screen.bottomSafeArea > 0 ? 1 : 0) // Solid Bottom SafeArea
        .frame(minHeight: 56)
        .background(Color.white)
    }
    
    @ViewBuilder
    private var bottomEmojiView: some View {
        if showsEmojiLibrary {
            ChatImageStorageView { emoticon, isMini in
                if isMini {
                    let urlString = emoticon.urlString
                    let height = font.uiFont.lineHeight
                    let textAttachment = ImageTextAttachment(urlString: urlString, height: height)
                    let oldText = NSMutableAttributedString(attributedString: message)
                    let newString = NSAttributedString(attachment: textAttachment)
                    oldText.append(newString)
                    message = oldText
                } else {
                    Task {
                        let message = Message(imageURLString: emoticon.urlString, sender: sender)
                        await messageStore.add(message: message)
                    }
                }
            } delete: {
//                if let last = miniItems.last {
//                    let _ = miniItems.popLast()
//                    if last.isPlain {
//                        miniItems.append(MiniItem.plain(String(last.contentValue.dropLast())))
//                    }
//                } else {
//                    let _ = text.popLast()
//                }
            }
            .frame(height: Screen.height / 3)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
    }
    
    private let emptyScrollToString = "Empty"
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(chatting: MockChatStore())
//            .environment(\.settings, .cocoa)
//    }
//}

private extension Image {
    var buttonModifier: some View {
        self
            .resizable()
            .scaledToFit()
            .padding(6)
            .frame(width: 32, height: 32)
    }
}

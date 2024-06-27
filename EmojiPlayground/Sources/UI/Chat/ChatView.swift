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
    
//    @State private var text = ""
//    @State private var miniItems: [MiniItem] = []
    @State private var message = NSAttributedString()
    @State private var showsEmojiLibrary = false
    @State private var sender: MessageSender = .to
    @State private var photoSelections: [PhotosPickerItem] = []
    @State private var errorAlertMessage: String?
    @State private var isPresentedUploadOverlay = false
    
    let room: Room
    
    private var fontSize: CGFloat {
        UIFont.preferredFont(from: font ?? .body).lineHeight
    }
    
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
            
            HStack(spacing: 0) {
                RichTextView(attributedText: $message)
                    .frame(minHeight: 36)
                    .onTapGesture {
                        showsEmojiLibrary = false
                    }
//                if miniItems.isEmpty {
//                    TextEditor(text: $text)
//                        .scrollContentBackground(.hidden)
//                        .background(.clear)
//                        .frame(height: 36) // 36으로해야 글자의 높이가 중앙에 위치한다.
//                        .onTapGesture {
//                            showsEmojiLibrary = false
//                        }
//                } else {
//                    HStack(spacing: 0) {
//                        ForEach(miniItems, id: \.self) { item in
//                            switch item {
//                            case .image(let contentValue):
//                                ImageView(url: URL(string: contentValue), size: .mini)
//                            case .plain(let contentValue):
//                                Text(contentValue)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 6)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .frame(height: 36)
//                    .onTapGesture {
//                        showsEmojiLibrary = false
//                    }
//                }
                
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
                    
//                    if text.count > 0 || !miniItems.isEmpty {
                    if message.length > 0 {
                        Button(action: {
                            Task {
                                let message = {
//                                    if !miniItems.isEmpty {
//                                        return Message(miniItems: miniItems, sender: sender)
//                                    } else {
//                                        return Message(plainText: text, sender: sender)
//                                    }
                                    return Message(attributedString: self.message, sender: sender)
                                }()
                                self.message = NSAttributedString()
//                                text = ""
//                                miniItems = []
                                await messageStore.add(message: message)
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
            .background(
                Capsule()
                    .stroke(Color.black.opacity(0.1))
                    .background(Capsule().fill(Color.gray.opacity(0.1)))
                    .padding(.vertical, 2)
            )
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
//                    if miniItems.isEmpty, !text.isEmpty {
//                        miniItems = [.plain(text)]
//                        text = ""
//                    }
//                    miniItems.append(.image(emoticon.urlString))
                    
                    Task { await loadGIF(from: emoticon.urlString) }
                    
                    // TODO: throws 추가하기
                    func loadGIF(from url: String) async {
                        guard let imageURL = URL(string: url) else { return }
                        
                        if let data = try? Data(contentsOf: imageURL) {
                            data.isGIF ? await insertGIF(data) : await insertImage(data)
                        }
                    }
                    
                    @MainActor
                    func insertGIF(_ data: Data) {
                        let textAttachment = GIFTextAttachment(data: data, fontSize: fontSize)
                        let oldText = NSMutableAttributedString(attributedString: message)
                        let newGIFString = NSAttributedString(attachment: textAttachment)
                        oldText.append(newGIFString)
                        message = oldText
                    }
                    
                    @MainActor
                    func insertImage(_ data: Data) {
                        let textAttachment = IMGTextAttachment(data: data, fontSize: fontSize)
                        let oldText = NSMutableAttributedString(attributedString: message)
                        let newIMGString = NSAttributedString(attachment: textAttachment)
                        oldText.append(newIMGString)
                        message = oldText
                    }
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






extension UIFont {
    class func preferredFont(from font: Font) -> UIFont {
        let uiFont: UIFont
        
        switch font {
        case .largeTitle:
            uiFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            uiFont = UIFont.preferredFont(forTextStyle: .title1)
        case .title2:
            uiFont = UIFont.preferredFont(forTextStyle: .title2)
        case .title3:
            uiFont = UIFont.preferredFont(forTextStyle: .title3)
        case .headline:
            uiFont = UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            uiFont = UIFont.preferredFont(forTextStyle: .subheadline)
        case .callout:
            uiFont = UIFont.preferredFont(forTextStyle: .callout)
        case .caption:
            uiFont = UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2:
            uiFont = UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote:
            uiFont = UIFont.preferredFont(forTextStyle: .footnote)
        case .body:
            fallthrough
        default:
            uiFont = UIFont.preferredFont(forTextStyle: .body)
        }
        
        return uiFont
    }
}




extension UIImage {
  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
    defer { UIGraphicsEndImageContext() }
        
    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
    ctx.draw(image, in: rect)
        
    return UIGraphicsGetImageFromCurrentImageContext() ?? self
  }
}

//
//  MessageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView: CoreMessageView {
    @EnvironmentObject private var messageStore: MessageStore
    
    let message: Message
    
    @State private var presentAlert = false
    
    var body: some View {
        messageRow
            .onTapGesture { /* SCROLLABLE WITH LONG PRESS GESTURE */ }
            .onLongPressGesture {
                presentAlert = true
            }
            .confirmationDialog("", isPresented: $presentAlert) {
                Button("메시지 삭제", role: .destructive) {
                    Task {
                        await messageStore.delete(message: message)
                    }
                }
                
                Button("취소", role: .cancel) { }
            }
            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
}

struct MockMessageView: CoreMessageView {
    let message: Message
    
    var body: some View {
        messageRow
            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
}

fileprivate protocol CoreMessageView: View {
    var message: Message { get }
}

extension CoreMessageView {
    var messageRow: some View {
        HStack {
            if message.sender == .to {
                emptySpacer
            }

            switch message.contentType {
            case .plainText:
                PlainTextMessageView(message: message)
            case .image:
                ImageMessageView(message: message)
            case .mini:
                MiniMessageView(message: message)
            case .attributed:
                AttributedMessageView(message: message)
            }
            
            if message.sender == .from {
                emptySpacer
            }
        }
    }
    
    private var emptySpacer: some View {
        Text(" ")
            .frame(width: Screen.width * 0.15)
    }
}


fileprivate struct PlainTextMessageView: View {
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

fileprivate struct ImageMessageView: View {
    let message: Message
    
    var body: some View {
        ImageView(url: message.imageURL, size: .large)
            .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
    }
}

struct ImageView: View {
    @EnvironmentObject private var settings: Settings
    
    @State private var isLoadSuccessed = false
    
    let url: URL?
    let size: Size
    
    enum Size {
        case large, middle, small, mini
        
        var length: CGFloat {
            switch self {
            case .large:
                160
            case .middle:
                80
            case .small:
                40
            case .mini:
                20
            }
        }
    }
    
    var body: some View {
        WebImage(url: url)
            .resizable()
            .placeholder {
                Rectangle()
                    .foregroundStyle(.black.opacity(0.3))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .onSuccess { _, _, _ in
                isLoadSuccessed = true
            }
            .aspectRatio(settings.imageRatioType.ratio, contentMode: .fit)
            .frame(width: size.length, height: size.length)
            .background {
                if isLoadSuccessed {
                    Rectangle()
                        .foregroundStyle(settings.imageBackgroundColor)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
    }
}

fileprivate struct MiniMessageView: View {
    @EnvironmentObject private var settings: Settings
    
    @State private var isLoadSuccessed = false
    
    let message: Message
    
    var unwrappedItems: [MiniItem] {
        message.contentValue
            .split(separator: ",")
            .map { value in
                if value.hasPrefix("image") {
                    let rangeStartIndex = value.index(value.startIndex, offsetBy: 6)
                    let rangeEndIndex = value.index(value.endIndex, offsetBy: -2)
                    let image = value[rangeStartIndex...rangeEndIndex]
                    return MiniItem.image(String(image))
                }
                
                if value.hasPrefix("plain") {
                    let rangeStartIndex = value.index(after: "plain".endIndex)
                    let rangeEndIndex = value.index(value.endIndex, offsetBy: -2)
                    let plain = value[rangeStartIndex...rangeEndIndex]
                    return MiniItem.plain(String(plain))
                }
                
                return MiniItem.image(String(value))
            }
    }
    
    var body: some View {
        if unwrappedItems.count == 1 {
            let item = unwrappedItems[0]
            if item.isPlain {
                PlainTextMessageView(message: Message(plainText: item.contentValue, sender: message.sender))
            } else {
                ImageView(url: URL(string: item.contentValue), size: .middle)
                    .frame(maxWidth: .infinity, alignment: message.sender.messageAlignment)
            }
        } else if unwrappedItems.count < 7, unwrappedItems.filter({ $0.isPlain }).count == 0 {
            HStack(spacing: 0) {
                ForEach(unwrappedItems, id: \.self) { item in
                    ImageView(url: URL(string: item.contentValue), size: .small)
                }
            }
        } else {
            WrappingHStack(horizontalSpacing: 0) {
                ForEach(unwrappedItems, id: \.self) { item in
                    switch item {
                    case .image(let contentValue):
                        ImageView(url: URL(string: contentValue), size: .mini)
                    case .plain(let contentValue):
                        Text(contentValue)
                    }
                }
            }
//            HStack(spacing: 0) {
//                ForEach(unwrappedItems, id: \.self) { item in
//                    switch item {
//                    case .image(let contentValue):
//                        ImageView(url: URL(string: contentValue), size: .mini)
//                    case .plain(let contentValue):
//                        Text(contentValue)
//                    }
//                }
//            }
            .foregroundStyle(message.sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
            .padding(12)
            .background(message.sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

private struct WrappingHStack: Layout {
    // inspired by: https://stackoverflow.com/a/75672314
    private var horizontalSpacing: CGFloat
    private var verticalSpacing: CGFloat
    public init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat? = nil) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing ?? horizontalSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let height = subviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0

        var rowWidths = [CGFloat]()
        var currentRowWidth: CGFloat = 0
        subviews.forEach { subview in
            if currentRowWidth + horizontalSpacing + subview.sizeThatFits(proposal).width >= proposal.width ?? 0 {
                rowWidths.append(currentRowWidth)
                currentRowWidth = subview.sizeThatFits(proposal).width
            } else {
                currentRowWidth += horizontalSpacing + subview.sizeThatFits(proposal).width
            }
        }
        rowWidths.append(currentRowWidth)

        let rowCount = CGFloat(rowWidths.count)
        return CGSize(width: min(rowWidths.max() ?? 0, proposal.width ?? 0), height: rowCount * height + (rowCount - 1) * verticalSpacing)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let height = subviews.map { $0.dimensions(in: proposal).height }.max() ?? 0
        guard !subviews.isEmpty else { return }
        var x = bounds.minX
        var y = height / 2 + bounds.minY
        subviews.forEach { subview in
            x += subview.dimensions(in: proposal).width / 2
            if x + subview.dimensions(in: proposal).width / 2 > bounds.maxX {
                x = bounds.minX + subview.dimensions(in: proposal).width / 2
                y += height + verticalSpacing
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .center,
                proposal: ProposedViewSize(
                    width: subview.dimensions(in: proposal).width,
                    height: subview.dimensions(in: proposal).height
                )
            )
            x += subview.dimensions(in: proposal).width / 2 + horizontalSpacing
        }
    }
}

private struct AttributedMessageView: View {
    @EnvironmentObject private var settings: Settings
    
    @State private var isLoadSuccessed = false
    @State private var includedText = false
    @State private var lotsOfData = false
    @State private var showImage = false
    @State private var showMiniImage = false
    
    let message: Message
    
    private var attr: NSAttributedString {
        let data = Data(base64Encoded: message.contentValue)!
        let attr = try? data.attributedString()
        return attr ?? NSAttributedString()
    }
    
    var body: some View {
        if includedText {
            RichTextMessageView(attributedText: attr)
                .foregroundStyle(message.sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
                .padding(12)
                .background(message.sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor)
                .clipShape(.rect(cornerRadius: 12))
        } else if lotsOfData {
            RichTextMessageView(attributedText: attr)
                .foregroundStyle(message.sender == .to ? settings.myMessageFontColor : settings.otherMessageFontColor)
                .padding(12)
                .background(message.sender == .to ? settings.myMessageBubbleColor : settings.otherMessageBubbleColor)
                .clipShape(.rect(cornerRadius: 12))
        } else if showImage {
            RichTextMessageView(attributedText: attr)
                .background(Color.blue)
        } else if showMiniImage {
            RichTextMessageView(attributedText: attr)
                .background(Color.green)
        } else {
            Text("Hmm..")
                .background(Color.orange)
                .onAppear {
                    if attr.length > 6 {
                        lotsOfData = true
                        return
                    }
                    
                    let range = NSRange(location: 0, length: attr.length)
                    attr.enumerateAttribute(.attachment, in: range) { value, range, _ in
                        if value == nil {
                            includedText = true
                            return
                        }
                        
                        if attr.length == 1 {
                            showImage = true
                            return
                        } else {
                            showMiniImage = true
                            return
                        }
                    }
                }
        }
//        .border(Color.black)
//        .background(
//            GeometryReader { geometry in
//                Color.white
//                    .onAppear {
//                        print("cslog: \(geometry.size)")
//                    }
//            }
//        )
    }
}

struct MessageView_Previews: PreviewProvider {
    struct Wrapper: View {
        @Environment(\.font) private var font
        
//        let plain = Message(plainText: "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World", sender: .to)
//        let image = Message(imageURLString: "https://picsum.photos/200", sender: .from)
//        let mini1 = Message(miniItems: [
//            .image("https://picsum.photos/200")
//        ], sender: .to)
//        let mini2 = Message(miniItems: [
//            .plain("Hello, World! "),
//            .image("https://picsum.photos/250")
//        ], sender: .to)
//        let mini3 = Message(miniItems: [
//            .image("https://picsum.photos/100"),
//            .image("https://picsum.photos/200"),
//            .image("https://picsum.photos/300"),
//            .image("https://picsum.photos/400"),
//            .image("https://picsum.photos/500"),
//            .image("https://picsum.photos/600")
//        ], sender: .to)
        
        private let photoURL = "https://firebasestorage.googleapis.com/v0/b/emote-543b9.appspot.com/o/common%2FCute%20Monsters%2FFrame%201.png?alt=media&token=f7812a72-c9ac-4cba-9cfa-59d8dbfc9f45"
        private let gifURL = "https://www.easygifanimator.net/images/samples/eglite.gif"
        
        let attr1: Message = {
            let attr = NSAttributedString("Hello")
            return Message(attributedString: attr, sender: .to)
        }()
        
        var attr2: Message {
            var attr = NSAttributedString()
            
            loadGIF(from: photoURL, attr: &attr)
            
            return Message(attributedString: attr, sender: .to)
        }
        
//        var attr3: Message {
//            var attr = NSAttributedString()
//            
//            loadGIF(from: gifURL, attr: &attr)
//            
//            return Message(attributedString: attr, sender: .to)
//        }
//        
//        var attr4: Message {
//            var attr = NSAttributedString("Hello")
//            
//            loadGIF(from: photoURL, attr: &attr)
//            
//            return Message(attributedString: attr, sender: .to)
//        }
//        
//        var attr5: Message {
//            var attr = NSAttributedString("Hello")
//            
//            loadGIF(from: gifURL, attr: &attr)
//            
//            return Message(attributedString: attr, sender: .to)
//        }
//        
//        var attr6: Message {
//            var attr = NSAttributedString("jKf")
//            
//            loadGIF(from: photoURL, attr: &attr)
//            loadGIF(from: gifURL, attr: &attr)
//            
//            return Message(attributedString: attr, sender: .to)
//        }
//        
//        var attr7: Message {
//            var attr = NSAttributedString()
//            
//            loadGIF(from: photoURL, attr: &attr)
//            loadGIF(from: gifURL, attr: &attr)
//            loadGIF(from: photoURL, attr: &attr)
//            loadGIF(from: gifURL, attr: &attr)
//            loadGIF(from: photoURL, attr: &attr)
//            loadGIF(from: gifURL, attr: &attr)
//            
//            return Message(attributedString: attr, sender: .to)
//        }
        
        var attr8: Message {
            var attr = NSAttributedString()
            
            loadGIF(from: photoURL, attr: &attr)
            loadGIF(from: gifURL, attr: &attr)
            loadGIF(from: photoURL, attr: &attr)
            loadGIF(from: gifURL, attr: &attr)
            loadGIF(from: photoURL, attr: &attr)
            loadGIF(from: gifURL, attr: &attr)
            loadGIF(from: photoURL, attr: &attr)
            
            return Message(attributedString: attr, sender: .to)
        }
        
        var attr9: Message {
            var attr = NSAttributedString()
            
            loadGIF(from: photoURL, attr: &attr)
            loadGIF(from: gifURL, attr: &attr)
            
            return Message(attributedString: attr, sender: .to)
        }
        
        func loadGIF(from url: String, attr: inout NSAttributedString) {
            guard let imageURL = URL(string: url) else { return }
            
            if let data = try? Data(contentsOf: imageURL) {
                if data.isGIF {
                    attr = insertGIF(data, attr: attr)
                } else if let _ = UIImage(data: data) {
                    attr = insertImage(data, attr: attr)
                }
            }
        }
        
        func insertGIF(_ data: Data, attr: NSAttributedString) -> NSAttributedString {
            let font = UIFont.preferredFont(from: font ?? .body)
            let fontSize = font.lineHeight
            
            let textAttachment = GIFTextAttachment(data: data, fontSize: fontSize)
            let oldText = NSMutableAttributedString(attributedString: attr)
            let newGIFString = NSAttributedString(attachment: textAttachment)
            oldText.append(newGIFString)
            return oldText
        }
        
        func insertImage(_ data: Data, attr: NSAttributedString) -> NSAttributedString {
            let font = UIFont.preferredFont(from: font ?? .body)
            let fontSize = font.lineHeight
            
            let textAttachment = IMGTextAttachment(data: data, fontSize: fontSize)
            let oldText = NSMutableAttributedString(attributedString: attr)
            let newIMGString = NSAttributedString(attachment: textAttachment)
            oldText.append(newIMGString)
            return oldText
        }
        
        var body: some View {
            VStack {
//                MockMessageView(message: plain)
                
//                MockMessageView(message: image)
                
//                MockMessageView(message: mini1)
//                MockMessageView(message: mini2)
//                MockMessageView(message: mini3)
                
                MockMessageView(message: attr1)
                MockMessageView(message: attr2)
//                MockMessageView(message: attr3)
//                MockMessageView(message: attr4)
//                MockMessageView(message: attr5)
//                MockMessageView(message: attr6)
//                MockMessageView(message: attr7)
                MockMessageView(message: attr8)
                MockMessageView(message: attr9)
            }
        }
    }
    
    static var previews: some View {
        Wrapper()
            .font(.largeTitle)
            .environmentObject(Settings())
    }
}

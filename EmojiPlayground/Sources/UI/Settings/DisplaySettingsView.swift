//
//  DisplaySettingsView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/06/11.
//

import SwiftUI

private final class MockMessage: Message {
    convenience init(contentType: MessageContentType = .plainText, contentValue: String, sender: MessageSender) {
        self.init()
        self.mockContentType = contentType
        self.mockContentValue = contentValue
        self.mockSender = sender
    }
    
    var mockContentType: MessageContentType = .plainText
    var mockContentValue: String = ""
    var mockSender: MessageSender = .me
    
    override var contentTypeValue: Int16 {
        get { mockContentType.rawValue }
        set { }
    }
    
    override var contentValue: String {
        get { mockContentValue }
        set { }
    }
    
    override var senderValue: Int16 {
        get { mockSender.rawValue }
        set { }
    }
}

struct DisplaySettingsView: View {
    @EnvironmentObject private var theme: Theme
    
    var body: some View {
        ZStack(alignment: .top) {
            Form {
                mockChatView
                    .opacity(0)
                    .hidden()
                    .listRowBackground(Color.clear)
                
                themeSection
                
//                resetSection
            }
            
            mockChatView
                .padding(20)
                .padding(.vertical, 13)
                .background(theme.roomBackgoundColor)
                .cornerRadius(8)
                .padding(.horizontal, 20)
//                .padding(.top, 26)
        }
        .navigationTitle("화면 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var mockChatView: some View {
        VStack {
            MessageView(message: MockMessage(contentValue: "내가 보낸 메세지", sender: .me))
            
            MessageView(message: MockMessage(contentValue: "상대방이 보낸 메세지", sender: .other))
        }
    }
    
    private var themeSection: some View {
        Section {
            Picker("테마", selection: $theme.selectedThemeName) {
                ForEach(ThemeName.allCases, id: \.rawValue) { name in
                    Text(name.displayedName)
                        .tag(name)
                }
            }
            
            Group {
                ColorPicker("배경 색상", selection: $theme.roomBackgoundColor)
                
                ColorPicker("내 채팅 색상", selection: $theme.myMessageBubbleColor)
                
                ColorPicker("내 채팅 폰트 색상", selection: $theme.myMessageFontColor)
                
                ColorPicker("상대 채팅 색상", selection: $theme.otherMessageBubbleColor)
                
                ColorPicker("상대 채팅 폰트 색상", selection: $theme.otherMessageFontColor)
            }
            .disabled(theme.selectedThemeName != .custom)
            .opacity(theme.selectedThemeName != .custom ? 0.5 : 1.0)
        } header: {
            Text("채팅방")
        }
    }
    
    private var resetSection: some View {
        Section {
            Button {
                // TODO: 설정 초기화
            } label: {
                Text("설정 초기화")
            }
        }
    }
}

struct DisplaySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DisplaySettingsView()
            .environmentObject(Theme.shared)
    }
}

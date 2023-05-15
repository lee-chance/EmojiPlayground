//
//  ChatView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.theme) private var theme
    
    @State private var text = ""
    @State private var showsPhotoLibrary = false
    @State private var showsEmojiLibrary = false
    @State private var iCloudAccountNotFoundAlert = false
    
    let room: Room
    
    @FetchRequest var chatMessages: FetchedResults<Message>
    
    init(room: Room) {
        self.room = room
        self._chatMessages = FetchRequest(fetchRequest: Message.all(of: room))
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
        .background(theme.chatBackgroundColor)
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .sheet(isPresented: $showsPhotoLibrary) {
            ImagePicker { imageURL in
                if CloudKitUtility.isLoggedIn {
                    PersistenceController.shared.addImageMessage(type: .image, imageURL: imageURL, sender: .me, in: room)
                } else {
                    // 네비게이션 버그로 즉시 실행하면 alert가 실행되지 않는다.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        iCloudAccountNotFoundAlert = true
                    }
                }
            }
        }
        .alert("로그인 오류", isPresented: $iCloudAccountNotFoundAlert, actions: {
            Button("설정으로 이동") {
                UIApplication.shared.open(URL(string: UIApplication.openNotificationSettingsURLString)!)
            }
            
            Button("취소", role: .cancel) { }
        }, message: {
            Text("로그인 후에 사용할 수 있는 기능입니다.\n설정에서 iCloud에 로그인을 해주세요.")
        })
    }
    
    private var chatListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(chatMessages) { msg in
                        MessageView(message: msg)
                            .id(msg.id)
                    }
                    .padding(.horizontal)
                    
                    HStack { Spacer() }
                        .id(emptyScrollToString)
                }
                .onChange(of: chatMessages.count) { _ in
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
    
    private var bottomInputView: some View {
        HStack(spacing: 8) {
            Button(action: {
                showsPhotoLibrary = true
            }) {
                Image(systemName: "plus.app")
                    .buttonModifier
                    .foregroundColor(theme.secondaryFontColor)
            }
            
            HStack(spacing: 0) {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(height: 36) // 36으로해야 글자의 높이가 중앙에 위치한다.
                    .onTapGesture {
                        showsEmojiLibrary = false
                    }
                
                HStack(spacing: 8) {
                    Button(action: {
//                        showsPhotoLibrary = true // 임시
                        
                        // TODO: Emoji
                        UIApplication.shared.endEditing()
                        withAnimation(.linear(duration: 0.001)) {
                            showsEmojiLibrary = true
                        }
                    }) {
                        Image(systemName: "face.smiling")
                            .buttonModifier
                            .foregroundColor(theme.secondaryFontColor)
                    }
                    
                    if text.count > 0 {
                        Button(action: {
                            PersistenceController.shared.addMessage(type: .plainText, value: text, sender: .me, in: room)
                            text = ""
                        }) {
                            Image(systemName: "arrow.up")
                                .buttonModifier
                                .foregroundColor(theme.primaryFontColor)
                                .background(
                                    Circle()
                                        .stroke(Color.black.opacity(0.1))
                                        .background(Circle().fill(theme.primaryColor))
                                )
                        }
                    } else {
                        Button(action: {}) {
                            Image(systemName: "number")
                                .buttonModifier
                                .foregroundColor(theme.secondaryFontColor)
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

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(chatting: MockChatStore())
//            .environment(\.theme, .cocoa)
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

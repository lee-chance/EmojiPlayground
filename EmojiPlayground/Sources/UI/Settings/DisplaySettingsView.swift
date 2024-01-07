//
//  DisplaySettingsView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/06/11.
//

import SwiftUI

struct DisplaySettingsView: View {
    @EnvironmentObject private var settings: Settings
    
    @State private var isFoldedMockView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Form {
                mockChatView
                    .padding(-20)
                    .padding(.vertical, -13)
                    .opacity(0)
                    .hidden()
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 24)
                
                ChatSettingSection
                
                imageSettingSection
                
//                resetSection
            }
            
            VStack(spacing: 0, content: {
                mockChatView
                
                Button(action: {
                    withAnimation(.easeOut) {
                        isFoldedMockView.toggle()
                    }
                }, label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(isFoldedMockView ? .degrees(180) : .zero)
                        .frame(height: 24)
                        .frame(maxWidth: .infinity)
                })
            })
            .background(.white)
            .clipShape(.rect(cornerRadius: 8))
            .padding(.horizontal, 20)
//            .padding(.top, 26)
        }
        .navigationTitle("화면 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var mockChatView: some View {
        ScrollView {
            VStack {
                MockMessageView(message: Message(plainText: "내가 보낸 메시지", sender: .to))
                
                MockMessageView(message: Message(plainText: "상대방이 보낸 메시지", sender: .from))
                
                MockMessageView(message: Message(imageURLString: "https://fakeimg.pl/300x200", sender: .to))
                
                MockMessageView(message: Message(imageURLString: "https://fakeimg.pl/200x300", sender: .from))
            }
            .padding(20)
            .padding(.vertical, 13)
            .background(settings.roomBackgoundColor)
        }
        .frame(maxHeight: isFoldedMockView ? 200 : .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var ChatSettingSection: some View {
        Section {
            Picker("테마", selection: $settings.selectedThemeName) {
                ForEach(ThemeName.allCases, id: \.rawValue) { name in
                    Text(name.displayedName)
                        .tag(name)
                }
            }
            
            Group {
                ColorPicker("배경 색상", selection: $settings.roomBackgoundColor)
                
                ColorPicker("내 채팅 색상", selection: $settings.myMessageBubbleColor)
                
                ColorPicker("내 채팅 폰트 색상", selection: $settings.myMessageFontColor)
                
                ColorPicker("상대 채팅 색상", selection: $settings.otherMessageBubbleColor)
                
                ColorPicker("상대 채팅 폰트 색상", selection: $settings.otherMessageFontColor)
            }
            .settingDisabled(settings.selectedThemeName != .custom)
        } header: {
            Text("채팅방")
        }
    }
    
    private var imageSettingSection: some View {
        Section {
            Picker("비율", selection: $settings.imageRatioType) {
                ForEach(ImageRatioType.allCases, id: \.rawValue) { type in
                    Text(type.displayedName)
                        .tag(type)
                }
            }
            
            Toggle("배경 숨기기", isOn: $settings.imageIsClearBackgroundColor)
                .settingEnabled(settings.imageRatioType == .original)
            
            ColorPicker("배경 색상", selection: $settings.imageBackgroundColor)
                .settingDisabled(settings.imageIsClearBackgroundColor)
        } header: {
            Text("이미지")
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
            .environmentObject(Settings())
    }
}

private extension View {
    func settingDisabled(_ disabled: Bool) -> some View {
        self
            .disabled(disabled)
            .opacity(disabled ? 0.5 : 1.0)
    }
    
    func settingEnabled(_ enabled: Bool) -> some View {
        settingDisabled(!enabled)
    }
}

//
//  EmoticonStorageDetailView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/05/28.
//

import SwiftUI
import SDWebImageSwiftUI

private struct EmoticonEnvironmentKey: EnvironmentKey {
    static let defaultValue: Emoticon? = nil
}

extension EnvironmentValues {
    var emoticon: Emoticon? {
        get { self[EmoticonEnvironmentKey.self] }
        set { self[EmoticonEnvironmentKey.self] = newValue }
    }
}

struct EmoticonStorageDetailView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @State private var tagAlert: Bool = false
    @State private var uiImage: UIImage?
    
    private var emoticon: Emoticon {
        store.emoticons.first(where: { $0.id == selectedEmoticonID }) ?? emoticons.first!
    }
    
    @Binding var selectedEmoticonID: Emoticon.ID?
    
    let emoticons: [Emoticon]
    
    var body: some View {
        VStack {
            TabView(selection: $selectedEmoticonID) {
                ForEach(emoticons) { emoticon in
                    VStack(alignment: .leading, spacing: 16) {
                        WebImage(url: emoticon.url)
                            .resizable()
                            .onSuccess(perform: { image, data, cacheType in
                                uiImage = image
                            })
                            .aspectRatio(1, contentMode: .fit)
                        
                        Button(action: {
                            tagAlert.toggle()
                        }) {
                            if let tag = emoticon.tag {
                                Text("# \(tag)")
                                    .modifier(TagModifier())
                            } else {
                                Text("+ 태그 추가하기")
                                    .modifier(TagModifier(color: .gray))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding()
                    .tag(Optional(emoticon.id))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onAppear {
                UIPageControl.appearance().pageIndicatorTintColor = .systemGray2
                UIPageControl.appearance().currentPageIndicatorTintColor = .black
            }
            .onDisappear {
                UIPageControl.appearance().pageIndicatorTintColor = nil
                UIPageControl.appearance().currentPageIndicatorTintColor = nil
            }
             
            HStack(spacing: 0) {
                // 자랑하기
//                Button(action: {
//                    print("자랑하기")
//                }) {
//                    Image(systemName: "hands.clap")
//                }
//                .frame(maxWidth: .infinity)
//                .disabled(true)
                
                // 그룹 수정
                ItemGroupManagementButton()
                    .disabled(emoticon.isSample)
                
                // 태그 관리
                ItemTagManagementButton(isPresented: $tagAlert)
                
                // 저장
//                SaveButton(uiImage: uiImage ?? UIImage())
//                    .disabled(uiImage == nil)
                
                // 삭제
                ItemDeleteButton()
            }
            .environment(\.emoticon, emoticon)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.systemGray5)
            .padding(.bottom, 1)
        }
        .background(Color.systemGray6)
    }
}

#Preview {
    VStack {
        Text("# 브이")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.gray)
            .clipShape(.capsule)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.8))
}



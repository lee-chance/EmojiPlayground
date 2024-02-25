//
//  EmoticonStorageDetailView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/05/28.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageDetailView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var presentActionAlert: Bool = false
    @State private var selectedEmoticon: Emoticon?
    
    let groupName: String
    
    var group: EmoticonGroup? {
        store.emoticonGroup(name: groupName)
    }
    
    var body: some View {
        ScrollView {
            if let group {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 16), count: 3), spacing: 16) {
                    ForEach(group.emoticons) { emoticon in
                        EmoticonView(isPresentedActionAlert: $presentActionAlert, selectedEmoticon: $selectedEmoticon, emoticon: emoticon)
                    }
                }
                .padding()
                .fullScreenCover(item: $selectedEmoticon, content: { emoticon in
                    if #available(iOS 16.4, *) {
                        EmoticonEditView(emoticon: emoticon, of: group.emoticons)
                            .presentationBackground(.clear)
                    } else {
                        EmoticonEditView(emoticon: emoticon, of: group.emoticons)
                            .background(BackgroundBlurView(color: .clear))
                    }
                })
                .transaction({ transaction in
                    transaction.disablesAnimations = true
                })
            } else {
                Color.clear
                    .onAppear {
                        dismiss()
                    }
            }
        }
        .background(Color.systemGray6)
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EmoticonView: View {
    // MEMO: 이게 @State면 뷰가 렌더링할 때 alert가 뜨지 않는 버그가 있다.
    @Binding var isPresentedActionAlert: Bool
    @Binding var selectedEmoticon: Emoticon?
    
    let emoticon: Emoticon
    
    var body: some View {
        WebImage(url: emoticon.url)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
                isPresentedActionAlert = true
                selectedEmoticon = emoticon
            }
    }
}

struct EmoticonChangeGroupView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var newGroupName: String = ""
    
    @FocusState private var fieldIsFocused: Bool
    
    let emoticon: Emoticon
    
    var body: some View {
        NavigationView {
            Form {
                TextField("새 그룹명", text: $newGroupName)
                    .focused($fieldIsFocused)
                    .onAppear {
                        fieldIsFocused = true
                    }
                
                EmoticonGroupListView(groupName: emoticon.groupName, onTap: update)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    let name = newGroupName.trimmingCharacters(in: .whitespaces)
                    
                    Button("수정하기") {
                        update(name)
                    }
                    .disabled(EmoticonSample.allGroupNames.contains(name))
                    .disabled(name == emoticon.groupName)
                    .disabled(name.count == 0)
                }
                
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("취소", role: .cancel) {
//                        groupAlert.toggle()
//                    }
//                }
            }
        }
    }
    
    private func update(_ name: String) {
        Task {
            await emoticon.update(groupName: name)
            await store.fetchEmoticons()
            dismiss()
        }
    }
}

struct EmoticonGroupListView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    let groupName: String
    let onTap: (String) -> Void
    
    private var groupNames: [String] {
        store.groupNames
    }
    
    var body: some View {
        Section("그룹 선택") {
            ForEach(groupNames, id: \.self) { name in
                Button(name) {
                    onTap(name)
                }
                .disabled(EmoticonSample.allGroupNames.contains(name))
                .disabled(name == groupName)
            }
        }
        .task { await store.fetchEmoticons() }
    }
}

@available(iOS, deprecated: 16.4, message: "iOS 16.4이상의 버전에서는 presentationBackground 메소드를 사용해주세요.")
struct BackgroundBlurView: UIViewRepresentable {
    let color: Color
    
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = UIColor(color)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct EmoticonEditView: View {
    @EnvironmentObject private var store: EmoticonStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPresented: Bool = false
    @State private var groupAlert: Bool = false
    @State private var presentDeleteAlert: Bool = false
    @State private var emoticon: Emoticon
    
    let emoticons: [Emoticon]
    
    init(emoticon: Emoticon, of emoticons: [Emoticon]) {
        self._emoticon = State(initialValue: emoticon)
        self.emoticons = emoticons
    }
    
    var body: some View {
        VStack {
            TabView(selection: $emoticon) {
                ForEach(emoticons) { emoticon in
                    VStack(alignment: .leading) {
                        WebImage(url: emoticon.url)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            if let tag = emoticon.tag {
                                Button(action: {
                                    // TODO: 태그 수정하기
                                }) {
                                    Text("# \(tag)")
                                        .modifier(TagModifier(color: .black))
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button(action: {
                                    // TODO: 태그 추가하기
                                }) {
                                    Text("+ 태그 추가하기")
                                        .modifier(TagModifier(color: .gray))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding()
                    .tag(emoticon)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .onAppear {
                withAnimation(.easeOut) {
                    isPresented.toggle()
                }
            }
            
            ZStack {
                confirmationButtonsView
                    .hidden()
                
                if isPresented {
                    confirmationButtonsView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(Color.black.opacity(0.8))
    }
    
    private var confirmationButtonsView: some View {
        VStack {
            VStack(spacing: 0) {
//                Button("자랑하기 👏") {
//                    model.uploadToCommunity(image: image)
//                }
//
//                Divider()
                
                if !emoticon.isSample {
                    Button("그룹 수정") {
                        groupAlert.toggle()
                    }
                    .sheet(isPresented: $groupAlert) {
                        EmoticonChangeGroupView(emoticon: emoticon)
                    }
                    
                    Divider()
                }
                
                Button("삭제", role: .destructive) {
                    presentDeleteAlert.toggle()
                }
                .alert("삭제하시겠습니까?", isPresented: $presentDeleteAlert) {
                    Button("삭제", role: .destructive) {
                        Task {
                            await emoticon.delete()
                            await store.fetchEmoticons()
                            dismiss()
                        }
                    }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("삭제된 파일은 복구할 수 없습니다.")
                }
            }
            .background(Color.systemGray3)
            .clipShape(.rect(cornerRadius: 12))
            
            Button("취소", role: .cancel) { dismiss() }
                .background(.white)
                .clipShape(.rect(cornerRadius: 12))
        }
        .padding(.horizontal, 8)
        .buttonStyle(ConfirmationButtonStyle())
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

private struct TagModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .clipShape(.capsule)
    }
}

private struct ConfirmationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(configuration.role == .destructive ? .red : .blue)
            .bold(configuration.role == .cancel)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .contentShape(.rect)
            .background(configuration.isPressed ? configuration.role == .cancel ? Color.systemGray5 : Color.systemGray2 : .clear)
    }
}

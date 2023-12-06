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
    
    let groupName: String
    
    var group: EmoticonGroup? {
        store.emoticonGroup(name: groupName)
    }
    
    var body: some View {
        ScrollView {
            if let group {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 16), count: 3), spacing: 16) {
                    ForEach(group.emoticons) { emoticon in
                        EmoticonView(emoticon: emoticon)
                    }
                }
                .padding()
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
    @EnvironmentObject private var store: EmoticonStore
    
    @State private var presentActionAlert: Bool = false
    @State private var groupAlert: Bool = false
    @State private var presentDeleteAlert: Bool = false
    
    let emoticon: Emoticon
    
    var body: some View {
        WebImage(url: emoticon.url)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture { /* SCROLLABLE WITH LONG PRESS GESTURE */ }
            .onLongPressGesture {
                presentActionAlert = true
            }
            .confirmationDialog("", isPresented: $presentActionAlert) {
//                Button("자랑하기 👏") {
//                    model.uploadToCommunity(image: image)
//                }
                
                Button("그룹 수정") {
                    groupAlert.toggle()
                }
                
                Button("삭제", role: .destructive) {
                    presentDeleteAlert.toggle()
                }
                
                Button("취소", role: .cancel) { }
            }
            .alert("삭제하시겠습니까?", isPresented: $presentDeleteAlert) {
                Button("삭제", role: .destructive) {
                    Task {
                        await emoticon.delete()
                        await store.fetchEmoticons()
                    }
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("삭제된 파일은 복구할 수 없습니다.")
            }
            .sheet(isPresented: $groupAlert) {
                EmoticonChangeGroupView(emoticon: emoticon)
            }
    }
}

struct EmoticonChangeGroupView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var newGroupName: String = ""
    
    @FocusState private var fieldIsFocused: Bool
    
    let emoticon: Emoticon
    
    private var groupNames: [String] {
        store.groupNames
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("새 그룹명", text: $newGroupName)
                    .focused($fieldIsFocused)
                    .onAppear {
                        fieldIsFocused = true
                    }
                
                Section("그룹 선택") {
                    ForEach(groupNames, id: \.self) { name in
                        Button(name) {
                            update(name)
                        }
                        .disabled(name == emoticon.groupName)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    let name = newGroupName.trimmingCharacters(in: .whitespaces)
                    
                    Button("수정하기") {
                        update(name)
                    }
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

//
//  TagManagement.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/06.
//

import SwiftUI

struct ItemTagManagementButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            Image(systemName: "number")
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $isPresented) {
            TagManagementView(isPresented: $isPresented)
        }
    }
}

private struct TagManagementView: View {
    @EnvironmentObject private var emoticonStore: EmoticonStore
    @EnvironmentObject private var tagStore: TagStore
    
    @Environment(\.emoticon) private var emoticon
    
    @State private var newTagName: String = ""
    
    @FocusState private var fieldIsFocused: Bool
    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("새 태그", text: $newTagName.max(10))
                        .focused($fieldIsFocused)
                        .onAppear {
                            fieldIsFocused = true
                        }
                } footer: {
                    if let tag = emoticon?.tag {
                        Button(action: {
                            Task {
                                await emoticon?.update(tagName: nil)
                                await emoticonStore.fetchEmoticons()
                                isPresented = false
                            }
                        }) {
                            Text("# \(tag)")
                                .modifier(TagModifier())
                        }
                    }
                }
                
                TagManagementListView(onTap: update)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    let name = newTagName.trimmingCharacters(in: .whitespaces)
                    
                    Button("수정하기") {
                        update(name)
                    }
                    .disabled(name == emoticon?.tag)
                    .disabled(name.count == 0)
                    .disabled(name.count > 10)
                }
            }
        }
    }
    
    private func update(_ name: String) {
        Task {
            await tagStore.upsert(id: name)
            await emoticon?.update(tagName: name)
            await emoticonStore.fetchEmoticons()
            isPresented = false
        }
    }
}

private struct TagManagementListView: View {
    @EnvironmentObject private var store: TagStore

    @Environment(\.emoticon) private var emoticon
    
    @State private var tags: [Tag] = []
    
    let onTap: (String) -> Void
    
    var body: some View {
        Section("추천 태그") {
            FlowLayout(alignment: .leading) {
                ForEach(tags, id: \.self) { tag in
                    Button(action: {
                        onTap(tag.name)
                    }) {
                        Text(tag.name)
                            .modifier(TagModifier(color: .primary))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .task {
            await store.fetchTags()
            var displayedTags = store.tags.shuffled()
            if let currentTag = emoticon?.tag {
                displayedTags = displayedTags.filter { $0.name != currentTag }
            }
            tags = Array(displayedTags.prefix(30))
        }
    }
}

#Preview {
    struct Wrapper: View {
        @State private var isPresented: Bool = false
        var body: some View {
            ItemTagManagementButton(isPresented: $isPresented)
        }
    }
    
    return Wrapper()
}

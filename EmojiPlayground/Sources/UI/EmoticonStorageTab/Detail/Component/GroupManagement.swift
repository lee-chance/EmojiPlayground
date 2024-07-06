//
//  GroupManagement.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/06.
//

import SwiftUI

struct ItemGroupManagementButton: View {
    @State private var isPresented = false
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            Image(systemName: "rectangle.inset.filled.on.rectangle")
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $isPresented) {
            EmoticonChangeGroupView(isPresented: $isPresented)
        }
    }
}

private struct EmoticonChangeGroupView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @Environment(\.emoticon) private var emoticon
    
    @State private var newGroupName: String = ""
    
    @FocusState private var fieldIsFocused: Bool
    
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                TextField("새 그룹명", text: $newGroupName)
                    .focused($fieldIsFocused)
                    .onAppear {
                        fieldIsFocused = true
                    }
                
                EmoticonGroupListView(onTap: update)
            }
            .navigationTitle("그룹 옮기기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    let name = newGroupName.trimmingCharacters(in: .whitespaces)
                    
                    Button("수정하기") {
                        update(name)
                    }
                    .disabled(EmoticonSample.allGroupNames.contains(name))
                    .disabled(name == emoticon?.groupName)
                    .disabled(name.count == 0)
                }
            }
        }
    }
    
    private func update(_ name: String) {
        Task {
            await emoticon?.update(groupName: name)
            await store.fetchEmoticons()
            isPresented = false
        }
    }
}

struct EmoticonGroupListView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @Environment(\.emoticon) private var emoticon
    
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
                .disabled(name == emoticon?.groupName)
            }
        }
        .task { await store.fetchEmoticons() }
    }
}

#Preview {
    ItemGroupManagementButton()
}

//
//  DeleteButton.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/06.
//

import SwiftUI

struct ItemDeleteButton: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @Environment(\.emoticon) private var emoticon
    
    @State private var isPresented = false
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            Image(systemName: "trash")
        }
        .frame(maxWidth: .infinity)
        .alert("삭제하시겠습니까?", isPresented: $isPresented) {
            Button("삭제", role: .destructive, action: deleteAction)
            
            Button("취소", role: .cancel) { }
        } message: {
            Text("삭제된 파일은 복구할 수 없습니다.")
        }
    }
    
    private func deleteAction() {
        Task {
            await emoticon?.delete()
            await store.fetchEmoticons()
        }
    }
}

#Preview {
    ItemDeleteButton()
}

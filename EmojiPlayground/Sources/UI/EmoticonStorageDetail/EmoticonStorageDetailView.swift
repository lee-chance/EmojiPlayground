//
//  EmoticonStorageDetailView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/05/28.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageDetailView: View {
    @StateObject private var model: EmoticonStorageDetail
    
    init(groupName: String) {
        self._model = StateObject(wrappedValue: EmoticonStorageDetail(name: groupName))
    }
    
    var body: some View {
        List {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(model.images) { image in
                    EmoticonView(model: model, image: image)
                }
            }
        }
        .navigationTitle(model.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EmoticonView: View {
    @State private var presentActionAlert: Bool = false
    
    @StateObject var model: EmoticonStorageDetail
    
    let image: MessageImage
    
    var body: some View {
        WebImage(url: image.asset.fileURL)
            .resizable()
            .scaledToFit()
            .onTapGesture { /* SCROLLABLE WITH LONG PRESS GESTURE */ }
            .onLongPressGesture {
                presentActionAlert = true
            }
            .confirmationDialog("", isPresented: $presentActionAlert) {
//                Button("자랑하기 👏") {
//                    model.uploadToCommunity(image: image)
//                }
                
                Button("그룹 이동") {
                    model.update(image: image, groupName: "뉴 그룹")
                }
                
                Button("메시지 삭제", role: .destructive) {
                    model.delete(image: image)
                }
                
                Button("취소", role: .cancel) { }
            }
    }
}

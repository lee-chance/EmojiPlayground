//
//  EmoticonStorageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/08.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageView: View {
    @StateObject private var model = EmoticonStorage()
    
    @State private var isLoading: Bool = false
    
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(), count: 3)
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            Form {
                if isLoading {
                    loadingView
                } else {
                    gridView
                }
            }
        }
        .navigationTitle("보관함")
        .task {
            isLoading = true
            await model.fetchImages()
            isLoading = false
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity)
    }
    
    private var gridView: some View {
        LazyVGrid(columns: gridItems) {
            ForEach(model.images) { image in
                EmoticonView(model: model, image: image)
            }
        }
    }
}

struct EmoticonView: View {
    @State private var presentAlert: Bool = false
    
    @StateObject var model: EmoticonStorage
    
    let image: MessageImage
    
    var body: some View {
        WebImage(url: image.asset.fileURL)
            .resizable()
            .scaledToFit()
            .onTapGesture { /* SCROLLABLE WITH LONG PRESS GESTURE */ }
            .onLongPressGesture {
                presentAlert = true
            }
            .confirmationDialog("", isPresented: $presentAlert) {
                Button("자랑하기 👏") {
                    model.uploadToCommunity(image: image)
                }
                
                Button("메시지 삭제", role: .destructive) {
                    model.delete(image: image)
                }
                
                Button("취소", role: .cancel) { }
            }
    }
}

struct EmoticonStorageView_Previews: PreviewProvider {
    static var previews: some View {
        EmoticonStorageView()
    }
}

//
//  EmoticonStorageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/08.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageView: View {
    @State private var images: [MessageImage] = []
    
    var gridItems: [GridItem] {
        Array(repeating: GridItem(), count: 3)
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(images) { image in
                        WebImage(url: image.image.fileURL)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("보관함")
        .task {
            do {
                images = try await MessageImage.all()
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
}

struct EmoticonStorageView_Previews: PreviewProvider {
    static var previews: some View {
        EmoticonStorageView()
    }
}

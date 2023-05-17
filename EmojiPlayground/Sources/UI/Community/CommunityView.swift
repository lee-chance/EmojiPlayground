//
//  CommunityView.swift
//  EmojiPlayground
//
//  Created by 이창수 on 2023/05/17.
//

import SwiftUI
import SDWebImageSwiftUI

struct CommunityView: View {
    @StateObject private var model = Community()
    
    var body: some View {
        Form {
            ForEach(model.images) { image in
                WebImage(url: image.asset.fileURL)
                    .resizable()
                    .scaledToFit()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("커뮤니티")
        .task {
            await model.fetchImages()
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

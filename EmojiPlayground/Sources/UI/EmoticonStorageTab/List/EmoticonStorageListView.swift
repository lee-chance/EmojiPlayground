//
//  EmoticonStorageListView.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/03.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageListView: View {
    let emoticons: [Emoticon]
    let selectEmoticon: (Emoticon) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 16), count: 3), spacing: 16) {
                ForEach(emoticons) { emoticon in
                    EmoticonView(emoticon: emoticon)
                        .onTapGesture {
                            selectEmoticon(emoticon)
                        }
                }
            }
            .padding()
        }
        .background(Color.systemGray6)
    }
}

extension EmoticonStorageListView: Equatable {
    static func == (lhs: EmoticonStorageListView, rhs: EmoticonStorageListView) -> Bool {
        lhs.emoticons == rhs.emoticons
    }
}

struct EmoticonView: View {
    let emoticon: Emoticon
    
    var body: some View {
        ImageView(url: emoticon.url)
            .overlay(alignment: .bottomTrailing) {
                if let tag = emoticon.tag {
                    Text("# \(tag)")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black)
                        .clipShape(.capsule)
                        .padding(2)
                }
            }
    }
}

//#Preview {
//    EmoticonStorageListView()
//}

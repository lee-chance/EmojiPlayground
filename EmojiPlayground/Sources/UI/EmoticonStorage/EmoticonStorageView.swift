//
//  EmoticonStorageView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/08.
//

import SwiftUI

struct EmoticonStorageView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(0...5, id: \.self) { i in
                    Text("\(i)")
                        .frame(width: 50, height: 50)
                        .border(Color.red)
                }
            }
            .padding()
        }
        .navigationTitle("보관함")
    }
}

struct EmoticonStorageView_Previews: PreviewProvider {
    static var previews: some View {
        EmoticonStorageView()
    }
}

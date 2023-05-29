//
//  DetailColumn.swift
//  EmojiPlayground
//
//  Created by 이창수 on 2023/05/15.
//

import SwiftUI

struct DetailColumn: View {
    @Binding var selection: Panel?
    
    var body: some View {
        switch selection ?? .home {
        case .home:
            HomeView(navigationSelection: $selection)
        case .emoticonStorage:
            EmoticonStorageMainView()
        case .community:
            CommunityView()
        case .settings:
            Text("Settings")
        }
    }
}

struct DetailColumn_Previews: PreviewProvider {
    struct Preview: View {
        @State private var selection: Panel? = .home

        var body: some View {
            DetailColumn(selection: $selection)
        }
    }

    static var previews: some View {
        Preview()
    }
}

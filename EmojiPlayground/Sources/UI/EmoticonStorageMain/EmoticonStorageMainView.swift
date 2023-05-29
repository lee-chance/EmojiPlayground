//
//  EmoticonStorageMainView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/08.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupedImage: Identifiable, Hashable {
    let name: String
    let images: [MessageImage]
    
    var id: String { name }
}

struct EmoticonStorageMainView: View {
    @StateObject private var model = EmoticonStorageMain()
    
    @State private var isLoading: Bool = false
    
    private var groupedImages: [GroupedImage] {
        Dictionary(grouping: model.images, by: { $0.groupName ?? " " })
            .sorted(by: { $0.key > $1.key })
            .map { GroupedImage(name: $0.key, images: $0.value) }
    }
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 200), alignment: .top)]
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                if isLoading {
                    loadingView
                } else {
                    gridView
                }
            }
        }
        .navigationTitle("보관함")
        .navigationDestination(for: GroupedImage.self) { group in
            EmoticonStorageDetailView(groupName: group.name)
        }
//        .toolbar {
//            ToolbarItemGroup {
//                toolbarItems
//            }
//        }
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
        LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
            ForEach(groupedImages) { item in
                NavigationLink(value: item) {
                    VStack {
                        EmoticonGroupView(images: item.images)
                        
                        Text(item.name)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
    
//    @ViewBuilder
//    private var toolbarItems: some View {
//        Menu {
//            Picker("Layout", selection: $layout) {
//                ForEach(BrowserLayout.allCases) { option in
//                    Label(option.title, systemImage: option.imageName)
//                        .tag(option)
//                }
//            }
//            .pickerStyle(.inline)
//        } label: {
//            Label("Layout Options", systemImage: layout.imageName)
//                .labelStyle(.iconOnly)
//        }
//    }
}

struct EmoticonGroupView: View {
    let images: [MessageImage]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(0..<4, id: \.self
            ) { index in
                ZStack {
                    thumbnail(of: index)
                    
                    if index == 3, images.count > 4 {
                        Color.black
                            .opacity(0.5)
                            .overlay(
                                Text("+\(images.count - 3)")
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
        .padding(8)
        .background(.ultraThickMaterial)
        .cornerRadius(8)
    }
    
    @ViewBuilder
    func thumbnail(of index: Int) -> some View {
        if 0 <= index && index < images.count {
            let image = images[index]
            
            WebImage(url: image.asset.fileURL)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        } else {
            Rectangle()
                .aspectRatio(1, contentMode: .fit)
                .opacity(0)
        }
    }
}

struct EmoticonStorageMainView_Previews: PreviewProvider {
    static var previews: some View {
        EmoticonStorageMainView()
    }
}

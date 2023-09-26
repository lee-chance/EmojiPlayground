//
//  EmoticonStorageMainView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/08.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageMainView: View {
    @EnvironmentObject private var storage: EmoticonStorage
    
    @State private var isLoading: Bool = false
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 200), alignment: .top)]
    }
    
    var body: some View {
        GeometryReader { geometry in // 이거로 loadingView, emptyView를 화면 중앙에 두기
            ScrollView {
                if isLoading, storage.images.isEmpty {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else if storage.images.isEmpty {
                    Text("사용할 수 있는 이모티콘이 없어요! 🥲")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    VStack(alignment: .leading) {
                        Text("이모티콘은 1:1 비율의 사이즈를 권장합니다.")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        gridView
                    }
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
            await storage.fetchImages()
            isLoading = false
        }
    }
    
    private var gridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
            ForEach(storage.groupedImages()) { item in
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
                .cornerRadius(4)
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

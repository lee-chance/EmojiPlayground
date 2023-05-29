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
                ForEach(model.groupImages) { image in
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
    @State private var groupAlert: Bool = false
    @State private var newGroupName: String = ""
    
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
                
                Button("그룹 수정") {
                    groupAlert.toggle()
                }
                
                Button("메시지 삭제", role: .destructive) {
                    model.delete(image: image)
                }
                
                Button("취소", role: .cancel) { }
            }
            .sheet(isPresented: $groupAlert) {
                NavigationView {
                    Form {
                        TextField("새 그룹명", text: $newGroupName)
                        
                        Section("그룹 선택") {
                            ForEach(model.groups, id: \.self) { name in
                                Button(name) {
                                    model.update(image: image, groupName: name)
                                    groupAlert.toggle()
                                }
                                .disabled(name == image.groupName)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            let name = newGroupName.trimmingCharacters(in: .whitespaces)
                            
                            Button("수정하기") {
                                model.update(image: image, groupName: name)
                                groupAlert.toggle()
                            }
                            .disabled(name == image.groupName)
                            .disabled(name.count == 0)
                        }
                        
//                        ToolbarItem(placement: .cancellationAction) {
//                            Button("취소", role: .cancel) {
//                                groupAlert.toggle()
//                            }
//                        }
                    }
                }
            }
    }
}

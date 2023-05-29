//
//  EmoticonStorageDetailView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/05/28.
//

import SwiftUI
import SDWebImageSwiftUI

struct EmoticonStorageDetailView: View {
    @EnvironmentObject private var storage: EmoticonStorage
    
    let groupName: String
    
    var body: some View {
        List {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                ForEach(storage.groupImages(groupName: groupName)) { image in
                    EmoticonView(image: image)
                }
            }
        }
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EmoticonView: View {
    @EnvironmentObject private var storage: EmoticonStorage
    
    @State private var presentActionAlert: Bool = false
    @State private var groupAlert: Bool = false
    @State private var newGroupName: String = ""
    
    let image: MessageImage
    
    var body: some View {
        WebImage(url: image.asset.fileURL)
            .resizable()
            .customLoopCount(4)
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
                    storage.delete(image: image)
                }
                
                Button("취소", role: .cancel) { }
            }
            .sheet(isPresented: $groupAlert) {
                NavigationView {
                    Form {
                        TextField("새 그룹명", text: $newGroupName)
                        
                        Section("그룹 선택") {
                            ForEach(storage.groupNames, id: \.self) { name in
                                Button(name) {
                                    storage.update(image: image, groupName: name)
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
                                storage.update(image: image, groupName: name)
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

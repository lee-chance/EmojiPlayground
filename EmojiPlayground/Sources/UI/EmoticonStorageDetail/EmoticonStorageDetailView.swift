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
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 16), count: 3), spacing: 16) {
                ForEach(storage.groupImages(groupName: groupName)) { image in
                    EmoticonView(image: image)
                }
            }
            .padding()
        }
        .background(Color.systemGray6)
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EmoticonView: View {
    @EnvironmentObject private var storage: EmoticonStorage
    
    @State private var presentActionAlert: Bool = false
    @State private var groupAlert: Bool = false
    @State private var newGroupName: String = ""
    @State private var presentDeleteAlert: Bool = false
    
    let image: MessageImage
    
    var body: some View {
        WebImage(url: image.asset.fileURL)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
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
                
                Button("삭제", role: .destructive) {
                    presentDeleteAlert.toggle()
                }
                
                Button("취소", role: .cancel) { }
            }
            .alert("삭제하시겠습니까?", isPresented: $presentDeleteAlert) {
                Button("삭제", role: .destructive) { storage.delete(image: image) }
                Button("취소", role: .cancel) { }
            } message: {
                Text("삭제된 파일은 복구할 수 없습니다.")
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

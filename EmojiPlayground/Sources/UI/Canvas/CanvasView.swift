//
//  CanvasView.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/14.
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    @EnvironmentObject private var navigation: NavigationManager
    @EnvironmentObject private var store: EmoticonStore
    
    @State private var isDrawing: Bool = false
    @State private var rect: CGRect = .zero
    @State private var imageData: IdentifiableData?
    @State private var selectedGroup: String?
    @State private var isSuccessfullySaved: Bool = false
    @State private var presentSuccessAlert: Bool = false
    @State private var scale: CGFloat = 1
    
    private let canvas: PKCanvasView = PKCanvasView()
    private let toolPicker: PKToolPicker = PKToolPicker()
    
    private let toolPickerHeight: CGFloat = 78
    
    var body: some View {
        VStack {
            Canvas(canvas: canvas, toolPicker: toolPicker)
                .background(
                    Color.white
                        .shadow(.drop(radius: 8))
                )
                .padding(16)
                .aspectRatio(1, contentMode: .fit)
                .scaleEffect(scale)
                .onAppear {
                    isDrawing.toggle()
                }
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                rect = geometry.frame(in: .local)
                            }
                    }
                }
            
            Slider(value: $scale, in: 0.3...1)
                .padding(.horizontal)
            
//            ColorPicker("배경", selection: $selectedBackgroundColor)
//                .fixedSize()
//
//            Button("툴픽커 열기/닫기") {
//                isDrawing.toggle()
//            }
        }
        .padding(.bottom, toolPickerHeight)
        .navigationTitle("캔버스")
        .toolbar {
            Button("저장") {
                let image = canvas.drawing.image(from: rect, scale: 1)
                guard let pngData = image.pngData() else { return }
                
                imageData = IdentifiableData(pngData)
            }
        }
        .sheet(item: $imageData, onDismiss: {
            if isSuccessfullySaved {
                isSuccessfullySaved = false
                presentSuccessAlert = true
            }
        }) { data in
            AddEmoticonSheet(data: data.rawValue) { groupName in
                selectedGroup = groupName
                isSuccessfullySaved = true
                imageData = nil
            }
        }
        .alert("저장완료", isPresented: $presentSuccessAlert, actions: {
            Button("확인") {
//                if let imageData, let uiImage = UIImage(data: imageData) {
//                    ImageSaver().writeToPhotoAlbum(image: uiImage)
//                }
                
                Task {
                    await store.fetchEmoticons()
                    navigation.path.append(Panel.emoticonStorage)
                    if let selectedGroup {
                        // Group name으로 EmoticonStorageTabView를 보여준다.
                        navigation.path.append(EmoticonGroup(name: selectedGroup, emoticons: []))
                    }
                }
            }
        }, message: {
            Text("내 이모티콘이 보관함에 저장되었습니다.")
        })
    }
}

#Preview {
    NavigationView {
        CanvasView()
    }
}

struct AddEmoticonSheet: View {
    @EnvironmentObject private var tagStore: TagStore
    
    @State private var newTagName: String = ""
    @State private var tag: String? = nil
    @State private var presentAddGroup: Bool = false
    
    @State private var newGroupName: String = ""
    @State private var isProcessing: Bool = false
    
    @FocusState private var fieldIsFocused: Bool
    
    let data: Data
    let onSave: (String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("새 태그", text: $newTagName.max(10))
                        .focused($fieldIsFocused)
                        .onAppear {
                            fieldIsFocused = true
                        }
                } footer: {
                    if let tag {
                        Button(action: {
                            self.tag = nil
                        }) {
                            Text("# \(tag)")
                                .modifier(TagModifier())
                        }
                    }
                }
                
                TagManagementListView(onTap: perform)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("건너뛰기") {
                        perform(nil)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    let name = newTagName.trimmingCharacters(in: .whitespaces)
                    
                    Button("추가하기") {
                        perform(name)
                    }
                    .disabled(name.count == 0)
                    .disabled(name.count > 10)
                }
            }
            .navigationDestination(isPresented: $presentAddGroup) {
                Form {
                    TextField("새 그룹명", text: $newGroupName)
                        .focused($fieldIsFocused)
                        .onAppear {
                            fieldIsFocused = true
                        }
                    
                    EmoticonGroupListView(onTap: update)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        let name = newGroupName.trimmingCharacters(in: .whitespaces)
                        
                        Button("추가하기") {
                            update(name)
                        }
                        .disabled(EmoticonSample.allGroupNames.contains(name))
                        .disabled(name.count == 0)
                    }
                }
            }
        }
        .disabled(isProcessing)
    }
    
    private func perform(_ tag: String?) {
        presentAddGroup = true
        self.tag = tag
        self.newTagName = ""
    }
    
    private func update(_ groupName: String) {
        isProcessing = true
        Task {
            guard let url = await FirebaseStorageManager.upload(data: data, to: "private/\(UserStore.shared.userID)")
            else {
                isProcessing = false
                return
            }
            
            let message = Message(imageURLString: url.absoluteString, sender: .to)
            await message.setEmoticon(groupName: groupName, tag: tag)
            
            if let tag {
                await tagStore.upsert(id: tag)
            }
            
            onSave(groupName)
        }
    }
}

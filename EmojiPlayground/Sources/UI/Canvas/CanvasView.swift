//
//  CanvasView.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/14.
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    @State private var isDrawing: Bool = false
    @State private var groupAlert: Bool = false
    @State private var rect: CGRect = .zero
    @State private var imageData: IdentifiableData?
    @State private var presentSuccessAlert: Bool = false
    
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
                .onAppear {
                    isDrawing.toggle()
                }
                .padding(.bottom, toolPickerHeight)
                .background {
                    Color.clear
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        rect = geometry.frame(in: .local)
                                    }
                            }
                        )
                }
            
//            ColorPicker("배경", selection: $selectedBackgroundColor)
//                .fixedSize()
//
//            Button("툴픽커 열기/닫기") {
//                isDrawing.toggle()
//            }
        }
        .navigationTitle("캔버스")
        .toolbar {
            Button("저장") {
                let image = canvas.drawing.image(from: rect, scale: 1)
                guard let imageData = image.pngData() else { return }
                
                self.imageData = IdentifiableData(imageData)
            }
        }
        .sheet(item: $imageData, content: { imageData in
            EmoticonAddGroupView(data: imageData.rawValue) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                    presentSuccessAlert = true
                }
            }
        })
        .alert("저장완료", isPresented: $presentSuccessAlert, actions: {
            Button("확인") {}
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

struct EmoticonAddGroupView: View {
    @EnvironmentObject private var store: EmoticonStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var newGroupName: String = ""
    @State private var isProcessing: Bool = false
    
    @FocusState private var fieldIsFocused: Bool
    
    let data: Data
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("새 그룹명", text: $newGroupName)
                    .focused($fieldIsFocused)
                    .onAppear {
                        fieldIsFocused = true
                    }
                
                EmoticonGroupListView(groupName: "", onTap: update)
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
                
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("취소", role: .cancel) {
//                        groupAlert.toggle()
//                    }
//                }
            }
        }
        .disabled(isProcessing)
    }
    
    private func update(_ name: String) {
        isProcessing = true
        Task {
            guard let url = await FirebaseStorageManager.upload(data: data, to: "private/\(UserStore.shared.userID)") else {
                isProcessing = false
                return
            }
            
            let message = Message(imageURLString: url.absoluteString, sender: .to)
            await message.setEmoticon(groupName: name)
            
            dismiss()
            onSave()
        }
    }
}

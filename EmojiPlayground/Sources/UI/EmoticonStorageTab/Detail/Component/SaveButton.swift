//
//  SaveButton.swift
//  Emote
//
//  Created by Changsu Lee on 2024/03/11.
//

import SwiftUI

struct SaveButton: View {
    @State private var isPresented = false
    @State private var isSuccessfullySaved = false
    
    let uiImage: UIImage
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            Image(systemName: "square.and.arrow.down")
        }
        .frame(maxWidth: .infinity)
        .alert("이모티콘을 앨범에 저장하시겠습니까?", isPresented: $isPresented) {
            Button("저장", action: saveAction)
            
            Button("취소", role: .cancel) { }
        } message: {
            Text("내 기기의 사진앱에 저장됩니다.")
        }
        .alert("저장완료", isPresented: $isSuccessfullySaved) {
            Button("확인") { }
        } message: {
            Text("이모티콘이 앨범에 저장되었습니다.")
        }
    }
    
    private func saveAction() {
        ImageSaver().writeToPhotoAlbum(image: uiImage)
        isSuccessfullySaved = true
    }
}

#Preview {
    SaveButton(uiImage: UIImage())
}

//
//  CanvasView.swift
//  Emote
//
//  Created by Changsu Lee on 2023/10/02.
//

import SwiftUI

struct CanvasView: View {
    var body: some View {
        VStack {
            Canvas()
                .border(Color.black)
                .padding(16)
                .padding(.bottom, 32)
                .aspectRatio(1, contentMode: .fit)
            
            Text("저장")
            Text("배경 색")
            Text("이미지 추가")
            Text("글씨 쓰기")
            Text("아마도 툴픽커 열기/닫기")
        }
        .navigationTitle("캔버스")
    }
    
//    private func toolPickerToggle() {
//        toolPicker.setVisible(!toolPicker.isVisible, forFirstResponder: canvas)
//        showsToolPicker = toolPicker.isVisible
//    }
}

#Preview {
    CanvasView()
}

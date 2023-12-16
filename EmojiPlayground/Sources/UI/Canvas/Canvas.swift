//
//  Canvas.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/14.
//

import SwiftUI
import PencilKit

struct Canvas: UIViewRepresentable {
    let canvas: PKCanvasView
    let toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .default
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}

//#Preview {
//    Canvas(isDrawing: .constant(false))
//}

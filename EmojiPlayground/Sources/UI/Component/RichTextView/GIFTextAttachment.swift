//
//  GIFTextAttachment.swift
//  Emote
//
//  Created by Changsu Lee on 6/19/24.
//

import UIKit
import FLAnimatedImage

class GIFTextAttachment: NSTextAttachment {
    var gifData: Data
    
    override class var supportsSecureCoding: Bool {
        true
    }
    
    private func initialize(data: Data, fontSize: CGFloat) {
        self.bounds = CGRect(x: 0, y: 0, width: fontSize, height: fontSize)
        self.image = UIImage()
    }
    
    init(data: Data, fontSize: CGFloat) {
        self.gifData = data
        super.init(data: nil, ofType: nil)
        
        initialize(data: data, fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        // gifData를 디코딩합니다.
        guard 
            let gifData = coder.decodeObject(forKey: "gifData") as? Data,
            let fontSize = coder.decodeObject(forKey: "fontSize") as? CGFloat
        else {
            return nil
        }
        
        self.gifData = gifData
        super.init(data: nil, ofType: nil)
        
        initialize(data: gifData, fontSize: fontSize)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        // gifData를 인코딩합니다.
        coder.encode(gifData, forKey: "gifData")
        coder.encode(bounds.height, forKey: "fontSize")
    }
    
    func createAnimatedImageView() -> FLAnimatedImageView {
        let imageView = FLAnimatedImageView()
        imageView.animatedImage = FLAnimatedImage(animatedGIFData: gifData)
        imageView.frame = bounds
//        imageView.backgroundColor = .cyan
        return imageView
    }
}

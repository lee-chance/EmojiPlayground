//
//  IMGTextAttachment.swift
//  Emote
//
//  Created by Changsu Lee on 6/27/24.
//

import UIKit

class IMGTextAttachment: NSTextAttachment {
    var imgData: Data
    
    override class var supportsSecureCoding: Bool {
        true
    }
    
    private func initialize(data: Data, fontSize: CGFloat) {
        self.bounds = CGRect(x: 0, y: 0, width: fontSize, height: fontSize)
        self.image = UIImage()
    }
    
    init(data: Data, fontSize: CGFloat) {
        self.imgData = data
        super.init(data: nil, ofType: nil)
        
        initialize(data: data, fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        // gifData를 디코딩합니다.
        guard
            let imgData = coder.decodeObject(forKey: "imgData") as? Data,
            let fontSize = coder.decodeObject(forKey: "fontSize") as? CGFloat
        else {
            return nil
        }
        
        self.imgData = imgData
        super.init(data: nil, ofType: nil)
        
        initialize(data: imgData, fontSize: fontSize)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        // gifData를 인코딩합니다.
        coder.encode(imgData, forKey: "imgData")
        coder.encode(bounds.height, forKey: "fontSize")
    }
    
    func createImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(data: imgData))
        imageView.frame = bounds
        imageView.backgroundColor = .red
        return imageView
    }
}

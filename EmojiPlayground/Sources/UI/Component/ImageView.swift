//
//  ImageView.swift
//  Emote
//
//  Created by Changsu Lee on 6/30/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageView: View {
    @EnvironmentObject private var settings: Settings
    
    let url: URL?
    let size: Size
    
    enum Size {
        case large, middle, small, custom(_ size: CGFloat)
        
        var length: CGFloat {
            switch self {
            case .large:
                160
            case .middle:
                80
            case .small:
                50
            case .custom(let length):
                length
            }
        }
        
        var radius: CGFloat {
            switch self {
            case .large, .middle:
                12
            case .small, .custom:
                0
            }
        }
        
        var isCustom: Bool {
            switch self {
            case .custom: true
            default: false
            }
        }
    }
    
    var body: some View {
        WebImage(url: url)
            .resizable()
            .placeholder {
                if let cachedImage = CachedImage.shared.load(forKey: url) {
                    Image(uiImage: cachedImage)
                        .resizable()
                        .modifier(ImageViewModifier(size: size))
                } else {
                    Rectangle()
                        .foregroundStyle(.black.opacity(0.3))
                        .clipShape(.rect(cornerRadius: size.radius, style: .circular))
                }
            }
            .onSuccess { image, _, _ in
                guard let url else { return }
                CachedImage.shared.save(image, forKey: url)
            }
            .modifier(ImageViewModifier(size: size))
            .background {
                Rectangle()
                    .foregroundStyle(settings.imageBackgroundColor)
                    .clipShape(.rect(cornerRadius: size.radius, style: .circular))
            }
    }
    
    private struct ImageViewModifier: ViewModifier {
        @EnvironmentObject private var settings: Settings
        
        let size: Size
        
        func body(content: Content) -> some View {
            content
                .aspectRatio(settings.imageRatioType.ratio, contentMode: .fit)
                .frame(width: size.length, height: size.length)
        }
    }
}

#Preview {
    ImageView(url: URL(string: "https://www.easygifanimator.net/images/samples/eglite.gif"), size: .large)
        .environmentObject(Settings())
}

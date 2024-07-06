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
    
    private let url: URL?
    private let size: Size
    
    init(url: URL?, size: Size = .custom(nil)) {
        self.url = url
        self.size = size
    }
    
    enum Size {
        case large, middle, small, custom(_ size: CGFloat?)
        
        var length: CGFloat? {
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
            case .large:
                12
            case .middle:
                8
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
        
        var isDynamic: Bool {
            switch self {
            case .custom(let length):
                length == nil
            default:
                false
            }
        }
    }
    
    private var coreImageView: some View {
        WebImage(url: url)
            .resizable()
            .placeholder {
                if let cachedImage = CachedImage.shared.load(forKey: url) {
                    Image(uiImage: cachedImage)
                        .resizable()
                } else {
                    Color.clear
                }
            }
            .onSuccess { image, _, _ in
                guard let url else { return }
                CachedImage.shared.save(image, forKey: url)
            }
            .modifier(ImageViewModifier(ratio: settings.imageRatioType.ratio, length: size.length))
    }
    
    var body: some View {
        if size.isDynamic {
            Rectangle()
                .foregroundStyle(settings.imageBackgroundColor)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    coreImageView
                )
        } else {
            coreImageView
                .background {
                    Rectangle()
                        .foregroundStyle(settings.imageBackgroundColor)
                        .clipShape(.rect(cornerRadius: size.radius, style: .circular))
                }
        }
    }
    
    private struct ImageViewModifier: ViewModifier {
        let ratio: CGFloat?
        let length: CGFloat?
        
        func body(content: Content) -> some View {
            content
                .aspectRatio(ratio, contentMode: .fit)
                .frame(width: length, height: length)
        }
    }
}

#Preview {
    let settings = Settings()
    settings.imageRatioType = .original
    settings.imageIsClearBackgroundColor = false
    settings.imageBackgroundColor = .red
    
    return ScrollView {
        ImageView(url: URL(string: "https://www.easygifanimator.net/images/samples/eglite.gif"), size: .large)
        
        ImageView(url: URL(string: "https://www.easygifanimator.net/images/samples/eglite.gif"), size: .middle)
        
        ImageView(url: URL(string: "https://www.easygifanimator.net/images/samples/eglite.gif"), size: .small)
        
        ImageView(url: URL(string: "https://www.easygifanimator.net/images/samples/eglite.gif"), size: .custom(16))
        
        ImageView(url: URL(string: "https://www.easygifanimator.net/images/samples/eglite.gif"), size: .custom(nil))
            .frame(maxWidth: 200)
    }
    .scaleEffect(2, anchor: .top)
    .environmentObject(settings)
}

//
//  Settings.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/11.
//

import SwiftUI

@MainActor
public class Settings: ObservableObject {
    private enum SettingsKey {
        case selectedTheme
        case roomBackgoundColor
        case myMessageBubbleColor
        case myMessageFontColor
        case otherMessageBubbleColor
        case otherMessageFontColor
        case imageRatioType
        case imageIsClearBackgroundColor
        case imageBackgroundColor
        
        var key: String {
            switch self {
            case .selectedTheme:
                return "THEME_SELECTED_THEME_NAME"
            case .roomBackgoundColor:
                return "THEME_ROOM_BACKGROUND_COLOR"
            case .myMessageBubbleColor:
                return "THEME_MY_MESSAGE_BUBBLE_COLOR"
            case .myMessageFontColor:
                return "THEME_MY_MESSAGE_FONT_COLOR"
            case .otherMessageBubbleColor:
                return "THEME_OTHER_MESSAGE_BUBBLE_COLOR"
            case .otherMessageFontColor:
                return "THEME_OTHER_MESSAGE_FONT_COLOR"
            case .imageRatioType:
                return "IMAGE_RATIO_TYPE"
            case .imageIsClearBackgroundColor:
                return "IMAGE_IS_Clear_BACKGROUND_COLOR"
            case .imageBackgroundColor:
                return "IMAGE_BACKGROUND_COLOR"
            }
        }
    }
    
    @AppStorage(SettingsKey.selectedTheme.key) public var selectedThemeName: ThemeName = .cocoa {
        didSet {
            switch selectedThemeName {
            case .cocoa:
                roomBackgoundColor = .cacaoRoomBackground
                myMessageBubbleColor = .cacaoMyBubble
                myMessageFontColor = .cacaoFont
                otherMessageBubbleColor = .cacaoOtherBubble
                otherMessageFontColor = .cacaoFont
            case .lime:
                roomBackgoundColor = .limeRoomBackground
                myMessageBubbleColor = .limeMyBubble
                myMessageFontColor = .limeFont
                otherMessageBubbleColor = .limeOtherBubble
                otherMessageFontColor = .limeFont
            case .dark:
                roomBackgoundColor = Color(white: 43 / 255)
                myMessageBubbleColor = .white
                myMessageFontColor = .black
                otherMessageBubbleColor = Color(white: 69 / 255)
                otherMessageFontColor = .white
            case .custom:
                break
            }
        }
    }
    @AppStorage(SettingsKey.roomBackgoundColor.key) public var roomBackgoundColor: Color = .cacaoRoomBackground
    @AppStorage(SettingsKey.myMessageBubbleColor.key) public var myMessageBubbleColor: Color = .cacaoMyBubble
    @AppStorage(SettingsKey.myMessageFontColor.key) public var myMessageFontColor: Color = .cacaoFont
    @AppStorage(SettingsKey.otherMessageBubbleColor.key) public var otherMessageBubbleColor: Color = .cacaoOtherBubble
    @AppStorage(SettingsKey.otherMessageFontColor.key) public var otherMessageFontColor: Color = .cacaoFont
    
    @AppStorage(SettingsKey.imageRatioType.key) public var imageRatioType: ImageRatioType = .square {
        didSet {
            switch imageRatioType {
            case .original:
                imageIsClearBackgroundColor = false
            case .square:
                imageIsClearBackgroundColor = true
            }
        }
    }
    @AppStorage(SettingsKey.imageIsClearBackgroundColor.key) public var imageIsClearBackgroundColor: Bool = false {
        didSet {
            imageBackgroundColor = imageIsClearBackgroundColor ? .clear : .defaultImageBackgroundColor
        }
    }
    @AppStorage(SettingsKey.imageBackgroundColor.key) public var imageBackgroundColor: Color = .clear
}

public enum ThemeName: String, CaseIterable {
    case cocoa
    case lime
    case dark
    case custom
    
    var displayedName: String {
        switch self {
        case .cocoa:
            return "코코아"
        case .lime:
            return "라임"
        case .dark:
            return "다크"
        case .custom:
            return "커스텀"
        }
    }
}

protocol ThemeStyle {
    var name: ThemeName { get }
    var roomBackgroundColor: Color { get set }
    var myBubbleColor: Color { get set }
    var myFontColor: Color { get set }
    var otherBubbleColor: Color { get set }
    var otherFontColor: Color { get set }
}

struct CocoaTheme: ThemeStyle {
    let name: ThemeName = .cocoa
    var roomBackgroundColor: Color = .cacaoRoomBackground
    var myBubbleColor: Color = .cacaoMyBubble
    var myFontColor: Color = .cacaoFont
    var otherBubbleColor: Color = .cacaoOtherBubble
    var otherFontColor: Color = .cacaoFont
}

struct LimeTheme: ThemeStyle {
    let name: ThemeName = .lime
    var roomBackgroundColor: Color = .limeRoomBackground
    var myBubbleColor: Color = .limeMyBubble
    var myFontColor: Color = .limeFont
    var otherBubbleColor: Color = .limeOtherBubble
    var otherFontColor: Color = .limeFont
}

public enum ImageRatioType: String, CaseIterable {
    case original
    case square
    
    var displayedName: String {
        switch self {
        case .original:
            "원본"
        case .square:
            "1:1"
        }
    }
    
    var ratio: CGFloat? {
        self == .square ? 1 : nil
    }
}

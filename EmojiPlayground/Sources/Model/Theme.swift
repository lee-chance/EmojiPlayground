//
//  Theme.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/12/11.
//

import SwiftUI

public class Theme: ObservableObject {
    enum ThemeKey {
        case selectedTheme
        case roomBackgoundColor
        case myMessageBubbleColor
        case myMessageFontColor
        case otherMessageBubbleColor
        case otherMessageFontColor
        
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
            }
        }
    }
    
    @AppStorage(ThemeKey.selectedTheme.key) public var selectedThemeName: ThemeName = .cocoa {
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
            case .custom:
                break
            }
        }
    }
    @AppStorage(ThemeKey.roomBackgoundColor.key) public var roomBackgoundColor: Color = .cacaoRoomBackground
    @AppStorage(ThemeKey.myMessageBubbleColor.key) public var myMessageBubbleColor: Color = .cacaoMyBubble
    @AppStorage(ThemeKey.myMessageFontColor.key) public var myMessageFontColor: Color = .cacaoFont
    @AppStorage(ThemeKey.otherMessageBubbleColor.key) public var otherMessageBubbleColor: Color = .cacaoOtherBubble
    @AppStorage(ThemeKey.otherMessageFontColor.key) public var otherMessageFontColor: Color = .cacaoFont
    
    public static let shared = Theme()
    
    private init() { }
}

public enum ThemeName: String, CaseIterable {
    case cocoa
    case lime
    case custom
    
    var displayedName: String {
        switch self {
        case .cocoa:
            return "코코아"
        case .lime:
            return "라임"
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

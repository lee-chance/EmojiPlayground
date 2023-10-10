//
//  AppInfo.swift
//  Emote
//
//  Created by Changsu Lee on 2023/10/08.
//

import Foundation

struct AppInfo {
    static let appStoreAppleID = "6468904559"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
}

//
//  OSLogExtension.swift
//  Emote
//
//  Created by Changsu Lee on 2023/09/10.
//

import OSLog

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let ui = OSLog(subsystem: subsystem, category: "UI")
    static let data = OSLog(subsystem: subsystem, category: "Data")
}

//
//  Version.swift
//  Emote
//
//  Created by Changsu Lee on 2023/10/07.
//

import Foundation

struct Version {
    private let major: Int
    private let minor: Int
    private let fetch: Int
    
    init(_ major: Int, _ minor: Int, _ fetch: Int) {
        self.major = major
        self.minor = minor
        self.fetch = fetch
    }
    
    init(major: Int, minor: Int, fetch: Int = 0) {
        self.init(major, minor, fetch)
    }
    
    init(string: String) {
        let splited = string.split(separator: ".").map { Int($0) ?? 0 }
        
        self.init(splited[0], splited[1], splited.count > 2 ? splited[2] : 0)
    }
}

extension Version: Comparable {
    static func < (lhs: Version, rhs: Version) -> Bool {
        if let bool = compare(lhs.major, rhs.major) {
            return bool
        }
        
        if let bool = compare(lhs.minor, rhs.minor) {
            return bool
        }
        
        return lhs.fetch < rhs.fetch
    }
    
    private static func compare(_ lhs: Int, _ rhs: Int) -> Bool? {
        if lhs == rhs {
            return nil
        }
        
        return lhs < rhs
    }
}

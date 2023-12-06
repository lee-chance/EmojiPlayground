//
//  User.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/06.
//

import Foundation

struct User: Codable {
    let uid: String
    let displayName: String?
    let email: String?
    let isGuest: Bool
    let isEmailVerified: Bool
    let phoneNumber: String?
    let photoURL: URL?
    let creationDate: Date?
    let lastSignInDate: Date?
    
    var expiredDate: Date? {
        guard
            isGuest,
            let creationDate,
            let creationDateAfter2Weeks = Calendar.current.date(byAdding: .day, value: 15, to: creationDate)
        else { return nil }
        
        let expiredDate = Calendar.current.startOfDay(for: creationDateAfter2Weeks)
        return expiredDate
    }
    
    var dayOfExpiredDate: Int? {
        guard
            isGuest,
            let expiredDate
        else { return nil }
        
        let day = Calendar.current.dateComponents([.day], from: Date(), to: expiredDate).day
        return day
    }
    
    init(
        uid: String,
        displayName: String?,
        email: String?,
        isGuest: Bool,
        isEmailVerified: Bool,
        phoneNumber: String?,
        photoURL: URL?,
        creationDate: Date?,
        lastSignInDate: Date?
    ) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.isGuest = isGuest
        self.isEmailVerified = isEmailVerified
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }
    
    init(_ user: FirebaseAuthUser) {
        self.uid = user.uid
        self.displayName = user.displayName
        self.email = user.email
        self.isGuest = user.isAnonymous
        self.isEmailVerified = user.isEmailVerified
        self.phoneNumber = user.phoneNumber
        self.photoURL = user.photoURL
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}

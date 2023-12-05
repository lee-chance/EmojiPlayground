//
//  UserStore.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/02.
//

import SwiftUI

@MainActor
final class UserStore: ObservableObject {
    static var shared = UserStore()
    
    private init() { }
    
    @Published private(set) var user: User?
    
    var userID: String {
        user?.uid ?? "-"
    }
    
    var presentLoginSheet: Bool {
        user?.isAnonymous ?? false
    }
    
    func autoLogin() async {
        guard let user = FirebaseAuthManager.fetchUser() else {
            await loginAnonymous()
            return
        }
        
        await login(user)
    }
    
    func linkWithGoogle() async {
        guard let user = await FirebaseAuthManager.linkWithGoogle() else { return }
        
        await login(user)
    }
    
    func linkWithApple(_ authResult: AppleAuthResult) async throws {
        let user = try await FirebaseAuthManager.linkWithApple(authResult)
        
        await login(user)
    }
    
    func loginWithApple(_ authResult: AppleAuthResult) async throws {
        let user = try await FirebaseAuthManager.loginWithApple(authResult)
        
        await login(user)
    }
    
    func loginAnonymous() async {
        guard let user = await FirebaseAuthManager.loginAnonymous() else { return }
        
        await login(user)
    }
    
    func login(_ user: User) async {
        self.user = user
        
        await FirestoreManager
            .reference(path: .users)
            .reference(path: user.uid)
            .setData(from: EncodableUser(user))
    }
    
    func logout() {
        FirebaseAuthManager.signOut()
        
        self.user = nil
    }
    
    func signout() async throws {
        try await FirebaseAuthManager.delete()
        
        self.user = nil
    }
}

private struct EncodableUser: Encodable {
    let providerID: String
    let uid: String
    let displayName: String?
    let email: String?
    let isAnonymous: Bool
    let isEmailVerified: Bool
    let phoneNumber: String?
    let photoURL: URL?
    let refreshToken: String?
    let tenantID: String?
    let creationDate: Date?
    let lastSignInDate: Date?
    
    init(_ user: User) {
        self.providerID = user.providerID
        self.uid = user.uid
        self.displayName = user.displayName
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.isEmailVerified = user.isEmailVerified
        self.phoneNumber = user.phoneNumber
        self.photoURL = user.photoURL
        self.refreshToken = user.refreshToken
        self.tenantID = user.tenantID
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
}

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
        user?.isGuest ?? false
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
        
        Task(priority: .background) {
            inputEmoticons()
        }
    }
    
    func login(_ firebaseAuthUser: FirebaseAuthUser) async {
        let user = User(firebaseAuthUser)
        
        self.user = user
        
        await FirestoreManager
            .reference(path: .users)
            .reference(path: user.uid)
            .setData(from: user)
    }
    
    func inputEmoticons() {
        guard let user else { return }
        
        FirestoreManager
            .batch(completion: { batch in
                let collection = FirestoreManager
                    .reference(path: .users)
                    .reference(path: user.uid)
                    .reference(path: .emoticons)
                
                for sampleEmoticon in EmoticonSample.allCases {
                    for emoticon in sampleEmoticon.emoticons {
                        batch.setDataEncodable(from: emoticon, forDocument: collection.document())
                    }
                }
            })
    }
    
    func logout() {
        FirebaseAuthManager.signOut()
        
        self.user = nil
    }
    
    func signout() async throws {
        try await FirebaseAuthManager.delete()
        
        self.user = nil
    }
    
    func reauthenticate(_ authResult: AppleAuthResult) async throws {
        try await FirebaseAuthManager.reauthenticate(authResult)
    }
}

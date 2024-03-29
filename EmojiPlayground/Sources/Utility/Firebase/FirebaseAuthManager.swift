//
//  FirebaseAuthManager.swift
//  Emote
//
//  Created by Changsu Lee on 2023/12/02.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

typealias FirebaseAuthUser = FirebaseAuth.User

@MainActor
final class FirebaseAuthManager {
    private static let auth = Auth.auth()
    
    static func fetchUser() -> FirebaseAuthUser? {
        auth.currentUser
    }
    
    static func signOut() {
        do {
            try auth.signOut()
        } catch {
            print("error: \(error)")
        }
    }
    
    static func delete() async throws {
        guard let user = auth.currentUser else { throw AuthError.notLoggedIn }
        
        do {
            try await user.delete()
        } catch AuthErrorCode.requiresRecentLogin {
            throw AuthError.requiresRecentLogin
        } catch {
            throw AuthError.unknown(error)
        }
    }
}


// MARK: - Error (s)
enum AuthError: Error {
    case notLoggedIn
    case providerAlreadyLinked
    case credentialAlreadyInUse
    case operationNotAllowed
    case invalidCredential
    case invalidEmail
    case emailAlreadyInUse
    case userDisabled
    case wrongPassword
    case requiresRecentLogin
    case userMismatch
    case unknown(Error)
}


// MARK: - Auth Method (s)
// MARK: Anonymous
extension FirebaseAuthManager {
    static func loginAnonymous() async -> FirebaseAuthUser? {
        do {
            let result = try await auth.signInAnonymously()
            
            return result.user
        } catch {
            print("error: \(error)")
            return nil
        }
    }
}

// MARK: Apple
extension FirebaseAuthManager {
    static func linkWithApple(_ authResult: AppleAuthResult) async throws -> FirebaseAuthUser {
        let credential = makeCredential(authResult)
        
        guard let user = auth.currentUser else { throw AuthError.notLoggedIn }
        
        do {
            let result = try await user.link(with: credential)
            
            return result.user
        } catch AuthErrorCode.providerAlreadyLinked {
            throw AuthError.providerAlreadyLinked
        } catch AuthErrorCode.credentialAlreadyInUse {
            throw AuthError.credentialAlreadyInUse
        } catch AuthErrorCode.operationNotAllowed {
            throw AuthError.operationNotAllowed
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    static func loginWithApple(_ authResult: AppleAuthResult) async throws -> FirebaseAuthUser {
        let credential = makeCredential(authResult)
        
        do {
            let result = try await auth.signIn(with: credential)
            
            return result.user
        } catch AuthErrorCode.invalidCredential {
            throw AuthError.invalidCredential
        } catch AuthErrorCode.invalidEmail {
            throw AuthError.invalidEmail
        } catch AuthErrorCode.operationNotAllowed {
            throw AuthError.operationNotAllowed
        } catch AuthErrorCode.emailAlreadyInUse {
            throw AuthError.emailAlreadyInUse
        } catch AuthErrorCode.userDisabled {
            throw AuthError.userDisabled
        } catch AuthErrorCode.wrongPassword {
            throw AuthError.wrongPassword
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    static func reauthenticate(_ authResult: AppleAuthResult) async throws {
        let credential = makeCredential(authResult)
        
        guard let user = auth.currentUser else { throw AuthError.notLoggedIn }
        
        do {
            try await user.reauthenticate(with: credential)
        } catch AuthErrorCode.invalidCredential {
            throw AuthError.invalidCredential
        } catch AuthErrorCode.invalidEmail {
            throw AuthError.invalidEmail
        } catch AuthErrorCode.wrongPassword {
            throw AuthError.wrongPassword
        } catch AuthErrorCode.userMismatch {
            throw AuthError.userMismatch
        } catch AuthErrorCode.operationNotAllowed {
            throw AuthError.operationNotAllowed
        } catch AuthErrorCode.emailAlreadyInUse {
            throw AuthError.emailAlreadyInUse
        } catch AuthErrorCode.userDisabled {
            throw AuthError.userDisabled
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    private static func makeCredential(_ authResult: AppleAuthResult) -> OAuthCredential {
        OAuthProvider.credential(withProviderID: authResult.providerID, idToken: authResult.idToken, rawNonce: authResult.rawNonce)
    }
}

// MARK: Google
extension FirebaseAuthManager {
    static func linkWithGoogle() async -> FirebaseAuthUser? {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return nil }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let viewController = UIApplication.shared.window?.rootViewController else { return nil }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            let user = userAuthentication.user
            let accessToken = user.accessToken.tokenString
            
            guard let idToken = user.idToken?.tokenString else {
                return nil
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            guard let user = auth.currentUser else { return nil }
            
            let result = try await user.link(with: credential)
            
            return result.user
        } catch {
            print("error: \(error)")
            return nil
        }
    }
    
    static func loginWithGoogle(withIDToken idToken: String, accessToken: String) async -> FirebaseAuthUser? {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        do {
            let result = try await auth.signIn(with: credential)
            
            return result.user
        } catch {
            print("error: \(error)")
            return nil
        }
    }
}

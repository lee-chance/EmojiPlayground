//
//  FirestoreManager.swift
//
//
//  Created by Changsu Lee on 2023/03/02.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirestoreManager {
    private static let db = Firestore.firestore()
    
    static let timestamp = Timestamp()
    
    static var listenerByLabel: [String: ListenerRegistration] = [:]
    
    static func reference(path collection: FirestoreManager.Collection) -> CollectionReference {
        db.collection(collection.name)
    }
}

extension CollectionReference {
    func reference(path: String) -> DocumentReference {
        document(path)
    }
}

extension DocumentReference {
    func reference(path collection: FirestoreManager.Collection) -> CollectionReference {
        self.collection(collection.name)
    }
    
    func setData(model: Encodable) {
        do {
            try self.setData(from: model)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
}



// MARK: FirestoreManager + EmojiPlayground
extension FirestoreManager {
    enum Collection {
        case images
        
        var name: String {
            switch self {
            case .images:
                return "images"
            }
        }
    }
}

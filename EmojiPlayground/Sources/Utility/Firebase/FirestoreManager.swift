//
//  FirestoreManager.swift
//  Emote
//
//  Created by Changsu Lee on 2023/11/26.
//

import Foundation
import FirebaseFirestore

typealias FirestoreListener = ListenerRegistration

final class FirestoreManager {
    private static let db = Firestore.firestore()
    
    static let timestamp = Timestamp()
    
    static var listenerByLabel: [String: ListenerRegistration] = [:]
    
    static func reference(path collection: FirestoreManager.Collection) -> CollectionReference {
        db.collection(collection.rawValue)
    }
    
    static func batch(completion: @escaping (WriteBatch) -> Void) {
        let batch = db.batch()
        completion(batch)
        batch.commit()
    }
}

extension Query {
    func get<T: Decodable>(type: T.Type) async -> [T] {
        do {
            let snapshot = try await getDocuments()
            
            let documents = snapshot.documents.compactMap { try? $0.data(as: type) }
            
            return documents
        } catch {
            print("error: \(error)")
            return []
        }
    }
}

extension WriteBatch {
    func setDataEncodable<T: Encodable>(from: T, forDocument document: DocumentReference, merge: Bool = false) {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(from)
            setData(data, forDocument: document, merge: merge)
        } catch {
            print("error")
        }
    }
}

extension CollectionReference {
    func reference(path: String) -> DocumentReference {
        document(path)
    }
    
    func setData<T: Encodable>(from: T, merge: Bool = false) async {
        await document().setData(from: from, merge: merge)
    }
}

extension DocumentReference {
    func reference(path collection: FirestoreManager.Collection) -> CollectionReference {
        self.collection(collection.rawValue)
    }
    
    func get<T: Decodable>(type: T.Type) async -> T? {
        do {
            let document = try await getDocument()
            
            guard document.exists else {
                throw NSError(domain: "Not exists", code: -1000)
            }
            
            let data = try document.data(as: type)
            
            return data
        } catch {
            print("error")
            return nil
        }
    }
    
    func setData<T: Encodable>(from: T, merge: Bool = false) async {
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(from)
            try await setData(data, merge: merge)
        } catch {
            print("error")
        }
    }
    
    func remove() async {
        do {
            try await delete()
        } catch {
            print("error")
        }
    }
    
    func update(_ fields: [AnyHashable : Any]) async {
        do {
            try await updateData(fields)
        } catch {
            print("error")
        }
    }
}



// MARK: FirestoreManager + EmojiPlaygournd
extension FirestoreManager {
    enum Collection: String {
        case users
        case samples
        case tags
        
        case rooms
        case emoticons
        case groups
        case messages
    }
}

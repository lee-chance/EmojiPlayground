//
//  CloudKitUtility+AsyncAwait.swift
//
//
//  Created by Changsu Lee
//

import Foundation
import CloudKit

// MARK: - USER FUNCTIONS (Async Await)

extension CloudKitUtility {
    static func getiCloudStatus() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            getiCloudStatus { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    static func requestApplicationPermission() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            requestApplicationPermission { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    static func discoverUserIdentity() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            discoverUserIdentity { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
}


// MARK: - CRUD FUNCTIONS (Async Await)

extension CloudKitUtility {
    func fetch<T: CKRecordable>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) async -> [T] {
        await withCheckedContinuation { continuation in
            fetch(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit) { items in
                continuation.resume(returning: items)
            }
        }
    }
    
    @discardableResult
    func add<T: CKRecordable>(item: T) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            add(item: item) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    func update<T: CKRecordable>(item: T) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            update(item: item) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
    
    func delete<T: CKRecordable>(item: T) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            delete(item: item) { result in
                switch result {
                case .success(let success):
                    continuation.resume(returning: success)
                case .failure(let failure):
                    continuation.resume(throwing: failure)
                }
            }
        }
    }
}

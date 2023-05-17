//
//  CloudKitUtility.swift
//
//
//  Created by Changsu Lee
//

import Foundation
import CloudKit

protocol CKRecordable {
    var record: CKRecord { get }
    static var recordType: CKRecord.RecordType { get }
    
    init?(record: CKRecord)
}

final class CloudKitUtility {
    static let `public` = CloudKitUtility(database: container.publicCloudDatabase)
    static let `private` = CloudKitUtility(database: container.privateCloudDatabase)
    
    private init(database: CKDatabase) {
        self.database = database
    }
    
    private static let container: CKContainer = CKContainer.default()
    private let database: CKDatabase
    
    static var isLoggedIn: Bool = false
    
    enum CloudKitError: String, LocalizedError {
        case iCouldAccountNotFound
        case iCouldAccountNotDetermined
        case iCouldAccountRestricted
        case iCouldAccountTemporarilyUnavailable
        case iCouldAccountUnknown
        case iColudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }
}


// MARK: - USER FUNCTIONS (Completion)

extension CloudKitUtility {
    static func getiCloudStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
        container.accountStatus { status, error in
            isLoggedIn = false
            switch status {
            case .available:
                isLoggedIn = true
                completion(.success(true))
            case .couldNotDetermine:
                completion(.failure(CloudKitError.iCouldAccountNotDetermined))
            case .restricted:
                completion(.failure(CloudKitError.iCouldAccountRestricted))
            case .noAccount:
                completion(.failure(CloudKitError.iCouldAccountNotFound))
            case .temporarilyUnavailable:
                completion(.failure(CloudKitError.iCouldAccountTemporarilyUnavailable))
            @unknown default:
                completion(.failure(CloudKitError.iCouldAccountUnknown))
            }
        }
    }
    
    static func requestApplicationPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
        container.requestApplicationPermission([.userDiscoverability]) { status, error in
            if status == .granted {
                completion(.success(true))
            } else {
                completion(.failure(CloudKitError.iColudApplicationPermissionNotGranted))
            }
        }
    }
    
    static func fetchUserRecodeID(completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        container.fetchUserRecordID { id, error in
            if let id {
                completion(.success(id))
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
    
    static func discoverUserIdentity(id: CKRecord.ID, completion: @escaping (Result<String, Error>) -> Void) {
        container.discoverUserIdentity(withUserRecordID: id) { identity, error in
            if let name = identity?.nameComponents?.givenName {
                completion(.success(name))
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
            }
        }
    }
    
    static func discoverUserIdentity(completion: @escaping (Result<String, Error>) -> Void) {
        fetchUserRecodeID { fetchCompletion in
            switch fetchCompletion {
            case .success(let recoredID):
                discoverUserIdentity(id: recoredID, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


// MARK: - CRUD FUNCTIONS (Completion)

extension CloudKitUtility {
    func fetch<T: CKRecordable>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        completion: @escaping (_ items: [T]) -> Void
    ) {
        // Create operation
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit)
        
        // Get items in query
        var returendItems: [T] = []
        addRecordMatchedBlock(operation: operation) { item in
            returendItems.append(item)
        }
        
        // Query completion
        addQueryResultBlock(operation: operation) { finished in
            completion(returendItems)
        }
        
        // Excute operation
        add(operation: operation)
    }
    
    func add<T: CKRecordable>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Get record
        let record = item.record
        
        // Save to cloudKit
        save(record: record, completion: completion)
    }
    
    func update<T: CKRecordable>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        add(item: item, completion: completion)
    }
    
    func delete<T: CKRecordable>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        delete(record: item.record, completion: completion)
    }
}

// MARK: CRUD FUNCTIONS Private (Completion)
private extension CloudKitUtility {
    private func createOperation(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> CKQueryOperation {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptions
        let queryOperation = CKQueryOperation(query: query)
        if let resultsLimit {
            queryOperation.resultsLimit = resultsLimit
        }
        return queryOperation
    }
    
    private func addRecordMatchedBlock<T: CKRecordable>(operation: CKQueryOperation, completion: @escaping (_ item: T) -> Void) {
        if #available(iOS 15.0, *) {
            operation.recordMatchedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    guard let item = T(record: record) else { return }
                    completion(item)
                case .failure:
                    break
                }
            }
        } else {
            operation.recordFetchedBlock = { record in
                guard let item = T(record: record) else { return }
                completion(item)
            }
        }
    }
    
    private func addQueryResultBlock(operation: CKQueryOperation, completion: @escaping (_ finished: Bool) -> Void) {
        if #available(iOS 15.0, *) {
            operation.queryResultBlock = { result in
                completion(true)
            }
        } else {
            operation.queryCompletionBlock = { cursor, error in
                completion(true)
            }
        }
    }
    
    private func add(operation: CKDatabaseOperation) {
        database.add(operation)
    }
    
    private func save(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> Void) {
        database.save(record) { record, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    private func delete(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> Void) {
        database.delete(withRecordID: record.recordID) { recordID, error in
            if let error {
                print("error: \(error)")
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}

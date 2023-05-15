//
//  CloudKitUtility+Combine.swift
//  
//
//  Created by Changsu Lee
//

import Foundation
import Combine
import CloudKit

// MARK: - USER FUNCTIONS (Combine)

extension CloudKitUtility {
    static func getiCloudStatus() -> Future<Bool, Error> {
        Future { promise in
            getiCloudStatus { result in
                promise(result)
            }
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future { promise in
            requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    static func discoverUserIdentity() -> Future<String, Error> {
        Future { promise in
            discoverUserIdentity(completion: promise)
        }
    }
}


// MARK: - CRUD FUNCTIONS (Combine)

extension CloudKitUtility {
    func fetch<T: CKRecordable>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> Future<[T], Error> {
        Future { [weak self] promise in
            self?.fetch(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit) { (items: [T]) in
                promise(.success(items))
            }
        }
    }
    
    func add<T: CKRecordable>(item: T) -> Future<Bool, Error> {
        Future { [weak self] promise in
            self?.add(item: item, completion: promise)
        }
    }
    
    func update<T: CKRecordable>(item: T) -> Future<Bool, Error> {
        Future { [weak self] promise in
            self?.update(item: item, completion: promise)
        }
    }
    
    func delete<T: CKRecordable>(item: T) -> Future<Bool, Error> {
        Future { [weak self] promise in
            self?.delete(item: item, completion: promise)
        }
    }
}

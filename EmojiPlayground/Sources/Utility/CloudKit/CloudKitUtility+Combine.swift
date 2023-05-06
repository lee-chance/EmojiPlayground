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
            CloudKitUtility.getiCloudStatus { result in
                promise(result)
            }
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    static func discoverUserIdentity() -> Future<String, Error> {
        Future { promise in
            CloudKitUtility.discoverUserIdentity(completion: promise)
        }
    }
}


// MARK: - CRUD FUNCTIONS (Combine)

extension CloudKitUtility {
    static func fetch<T: CKRecordable>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptions: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> Future<[T], Error> {
        Future { promise in
            CloudKitUtility.fetch(predicate: predicate, recordType: recordType, sortDescriptions: sortDescriptions, resultsLimit: resultsLimit) { (items: [T]) in
                promise(.success(items))
            }
        }
    }
    
    static func add<T: CKRecordable>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.add(item: item, completion: promise)
        }
    }
    
    static func update<T: CKRecordable>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.update(item: item, completion: promise)
        }
    }
    
    static func delete<T: CKRecordable>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.delete(item: item, completion: promise)
        }
    }
}

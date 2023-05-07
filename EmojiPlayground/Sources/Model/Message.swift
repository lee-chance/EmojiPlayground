//
//  Message.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/19.
//

import SwiftUI
import CoreData

public final class Message: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date.now, forKey: "timestamp")
    }
}

extension Message {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var contentValue: String
    @NSManaged public var imageData: Data?
    @NSManaged private var contentTypeValue: Int16
    @NSManaged private var senderValue: Int16
    @NSManaged public var timestamp: Date
    @NSManaged public var room: Room?
    
    public var sender: MessageSender {
        get { MessageSender(rawValue: senderValue) ?? .me }
        set { senderValue = newValue.rawValue }
    }
    
    public var contentType: MessageContentType {
        get { MessageContentType(rawValue: contentTypeValue) ?? .plainText }
        set { contentTypeValue = newValue.rawValue }
    }
    
    static func all() -> NSFetchRequest<Message> {
        let request: NSFetchRequest<Message> = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)
        ]
        return request
    }
    
    static func all(of room: Room) -> NSFetchRequest<Message> {
        let request: NSFetchRequest<Message> = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)
        ]
        
        let filter = NSPredicate(format: "room == %@", room)
        request.predicate = filter
        
        return request
    }
}

extension Message: Identifiable { }

#if canImport(CloudKit)
import CloudKit

enum ImageLoadError: Error {
    case noAsset
}

extension Message {
    func getAsset() async throws -> CKAsset {
        let cachedKey = NSString(string: contentValue)

        if let cachedAsset = ImageCacheManager.shared.object(forKey: cachedKey) {
            return cachedAsset
        }

        let record = try await getRecord()

        guard let asset = record["ckAsset"] as? CKAsset else {
            throw ImageLoadError.noAsset
        }

        ImageCacheManager.shared.setObject(asset, forKey: cachedKey)
        return asset
    }
    
    func getRecord() async throws -> CKRecord {
        try await withCheckedThrowingContinuation { continuation in
            let query = CKQuery(
                recordType: "MessageImage",
                predicate: .init(format: "id == %@", contentValue)
            )
            
            let operation = CKQueryOperation(query: query)
            operation.qualityOfService = .userInitiated
            var returendRecord: CKRecord?
            
            operation.recordMatchedBlock = { id, result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let record):
                    returendRecord = record
                }
            }
            
            operation.queryResultBlock = { result in
                switch result {
                case.success:
                    if let returendRecord {
                        continuation.resume(returning: returendRecord)
                    } else {
                        continuation.resume(throwing: ImageLoadError.noAsset)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            let database = CKContainer.default().privateCloudDatabase
            database.add(operation)
        }
    }
}
#endif

public enum MessageSender: Int16 {
    case me = 1
    case other = 2
    
    var messageAlignment: Alignment {
        switch self {
        case .me: return .trailing
        case .other: return .leading
        }
    }
}

public enum MessageContentType: Int16 {
    case plainText = 1
    case localImage = 2
    case storageImage = 3
    
    var isPlainText: Bool {
        self == .plainText
    }
    
    var isLocalImage: Bool {
        self == .localImage
    }
    
    var isStorageImage: Bool {
        self == .storageImage
    }
    
    var isImage: Bool {
        isLocalImage || isStorageImage
    }
}

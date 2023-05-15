//
//  Persistence.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    private let container: NSPersistentContainer
    
    var context: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentCloudKitContainer(name: "EmojiPlayground")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        do {
            try context.save()
            print("Saved.")
        } catch {
            print("Error saving. \(error.localizedDescription)")
        }
    }
    
    func fetch<T: NSFetchRequestResult>(request: NSFetchRequest<T>) -> [T] {
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching. \(error.localizedDescription)")
            return []
        }
    }
}

extension PersistenceController {
    func addRoom(name: String) {
        let newRoom = Room(context: context)
        
        newRoom.name = name
        
        save()
    }
    
    func delete(_ room: Room) {
        context.delete(room)
        
        save()
    }
}

extension PersistenceController {
    func addMessage(type: MessageContentType, value: String, sender: MessageSender, in room: Room) {
        let newMessage = Message(context: context)
        
        newMessage.contentType = type
        newMessage.contentValue = value
        newMessage.sender = sender
        newMessage.room = room
        
        save()
    }
    
    func addMessage(type: MessageContentType, imageData: Data, sender: MessageSender, in room: Room) {
        let newMessage = Message(context: context)
        
        newMessage.contentType = type
        newMessage.imageData = imageData
        newMessage.sender = sender
        newMessage.room = room
        
        save()
    }
    
    func update(message: Message, type: MessageContentType? = nil, value: String? = nil, sender: MessageSender? = nil, in room: Room? = nil) {
        if let type { message.contentType = type }
        if let value { message.contentValue = value }
        if let sender { message.sender = sender }
        if let room { message.room = room }
        
        save()
    }
    
    func delete(_ message: Message) {
        context.delete(message)
        
        save()
    }
}

#if canImport(CloudKit)
import CloudKit

extension PersistenceController {
    func addImageMessage(type: MessageContentType, imageURL: URL, sender: MessageSender, in room: Room) {
        let messageImageID = UUID().uuidString
        let asset = CKAsset(fileURL: imageURL)
        let messageImage = MessageImage(id: messageImageID, asset: asset)
        
        Task {
            do {
                guard let messageImage else { return }
                let isAdded = try await CloudKitUtility.private.add(item: messageImage)
                
                if isAdded {
                    addMessage(type: type, value: messageImageID, sender: sender, in: room)
                }
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
    
    func deleteImageMessage(_ message: Message) {
        Task {
            do {
                let messageImage = try await message.getMessageImage()
                let isDeleted = try await CloudKitUtility.private.delete(item: messageImage)
                
                if isDeleted {
                    delete(message)
                }
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
}

struct MessageImage: CKRecordable, Identifiable {
    let id: String
    let image: CKAsset
    let record: CKRecord
    
    private static var recordType: String { "MessageImage" }
    
    init?(record: CKRecord) {
        guard
            let id = record["id"] as? String,
            let image = record["ckAsset"] as? CKAsset
        else { return nil }
        
        self.id = id
        self.image = image
        self.record = record
    }
    
    init?(id: String, asset: CKAsset) {
        let record = CKRecord(recordType: Self.recordType)
        record["id"] = id
        record["ckAsset"] = asset
        
        self.init(record: record)
    }
}

extension MessageImage {
    static func all() async throws -> [MessageImage] {
        let images: [MessageImage] = await CloudKitUtility.private.fetch(
            predicate: NSPredicate(value: true),
            recordType: "MessageImage"
        )
        
        return images
    }
}
#endif

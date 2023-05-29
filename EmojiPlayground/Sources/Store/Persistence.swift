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
    
    func addMessage(type: MessageContentType, value: String, imageData: Data, sender: MessageSender, in room: Room) {
        let newMessage = Message(context: context)
        
        newMessage.contentType = type
        newMessage.contentValue = value
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
        let messageImage = MessageImage(id: messageImageID, asset: asset, memo: nil, groupName: nil)
        
        Task {
            do {
                guard let messageImage else { return }
                let isAdded = try await CloudKitUtility.private.add(item: messageImage)
                
                if isAdded {
                    if let imageData = try? Data(contentsOf: imageURL) {
                        addMessage(type: type, value: messageImageID, imageData: imageData, sender: sender, in: room)
                    }
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
            } catch ImageLoadError.noAsset {
                print("cslog error: noAsset")
                delete(message)
            } catch {
                print("cslog error: \(error)")
            }
        }
    }
}

struct MessageImage: CKRecordable, Identifiable, Hashable {
    let id: String
    let asset: CKAsset
    let memo: String?
    let groupName: String?
    let record: CKRecord
    
    static var recordType: String { "MessageImage" }
    
    init?(record: CKRecord) {
        guard
            let id = record["id"] as? String,
            let asset = record["ckAsset"] as? CKAsset
        else { return nil }
        
        self.id = id
        self.asset = asset
        self.memo = record["memo"] as? String
        self.groupName = record["groupName"] as? String
        self.record = record
    }
    
    init?(id: String, asset: CKAsset, memo: String?, groupName: String?) {
        let record = CKRecord(recordType: Self.recordType)
        record["id"] = id
        record["ckAsset"] = asset
        record["memo"] = memo
        record["groupName"] = groupName
        
        self.init(record: record)
    }
    
    func clone(id: String? = nil, memo: String? = nil, groupName: String? = nil) -> MessageImage? {
        guard
            let fileURL = asset.fileURL,
            let image = MessageImage(id: id ?? self.id, asset: CKAsset(fileURL: fileURL), memo: memo ?? self.memo, groupName: groupName ?? self.groupName)
        else { return nil }
        
        return image
    }
}

extension MessageImage {
    static func all() async throws -> [MessageImage] {
        let images: [MessageImage] = await CloudKitUtility.private.fetch(
            predicate: NSPredicate(value: true),
            sortDescriptions: [NSSortDescriptor(key: "creationDate", ascending: false)]
        )
        
        return images
    }
    
    static func allPublic() async throws -> [MessageImage] {
        let images: [MessageImage] = await CloudKitUtility.public.fetch(
            predicate: NSPredicate(value: true),
            sortDescriptions: [NSSortDescriptor(key: "creationDate", ascending: false)]
        )
        
        return images
    }
}
#endif

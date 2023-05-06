//
//  Room.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/04/21.
//

import CoreData

public class Room: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date.now, forKey: "timestamp")
    }
}

extension Room {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var timestamp: Date
    @NSManaged public var messages: NSOrderedSet?
    
    static func all() -> NSFetchRequest<Room> {
        let request: NSFetchRequest<Room> = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Room.timestamp, ascending: true)
        ]
        return request
    }
    
    static func all(id: UUID) -> NSFetchRequest<Room> {
        let request: NSFetchRequest<Room> = fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Room.timestamp, ascending: true)
        ]
        let filter = NSPredicate(format: "id == %@", id.uuidString)
        request.predicate = filter
        return request
    }
}

// MARK: Generated accessors for messages
extension Room {
    @objc(insertObject:inMessagesAtIndex:)
    @NSManaged public func insertIntoMessages(_ value: Message, at idx: Int)
    
    @objc(removeObjectFromMessagesAtIndex:)
    @NSManaged public func removeFromMessages(at idx: Int)
    
    @objc(insertMessages:atIndexes:)
    @NSManaged public func insertIntoMessages(_ values: [Message], at indexes: NSIndexSet)
    
    @objc(removeMessagesAtIndexes:)
    @NSManaged public func removeFromMessages(at indexes: NSIndexSet)
    
    @objc(replaceObjectInMessagesAtIndex:withObject:)
    @NSManaged public func replaceMessages(at idx: Int, with value: Message)
    
    @objc(replaceMessagesAtIndexes:withMessages:)
    @NSManaged public func replaceMessages(at indexes: NSIndexSet, with values: [Message])
    
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)
    
    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)
    
    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSOrderedSet)
    
    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSOrderedSet)
}

extension Room: Identifiable {

}

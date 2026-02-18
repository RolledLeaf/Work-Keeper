import CoreData

final class PendingDeleteStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func enqueue(objectName: String, remoteId: UUID, debug: Bool = false) {
        // не добавляем дубликаты
        if contains(objectName: objectName, remoteId: remoteId) {
            if debug { print("🪦 Tombstone already exists:", objectName, remoteId) }
            return
        }

        let t = PendingDelete(context: context)
        t.id = UUID()
        t.objectName = objectName
        t.remoteId = remoteId
        t.createdAt = Date()
        t.needsSync = true
        t.deletedAt = Date()
        do { try context.save() }
        catch { print("❌ Tombstone enqueue save error:", error) }
    }

    func enqueue(_ objectName: PendingDeleteObjectName, remoteId: UUID, debug: Bool = false) {
        enqueue(objectName: objectName.rawValue, remoteId: remoteId, debug: debug)
    }

    func contains(objectName: String, remoteId: UUID) -> Bool {
        let req: NSFetchRequest<PendingDelete> = PendingDelete.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "objectName == %@", objectName),
            NSPredicate(format: "remoteId == %@", remoteId as CVarArg)
        ])
        let c = (try? context.count(for: req)) ?? 0
        return c > 0
    }

    func fetchPending() -> [PendingDelete] {
        let req: NSFetchRequest<PendingDelete> = PendingDelete.fetchRequest()
        req.predicate = NSPredicate(format: "needsSync == YES")
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return (try? context.fetch(req)) ?? []
    }

    func markSynced(_ t: PendingDelete) {
        t.needsSync = false
        context.delete(t) // можно сразу удалять
        do { try context.save() }
        catch { print("❌ Tombstone markSynced save error:", error) }
    }

    func allRemoteIds(for objectName: String) -> Set<UUID> {
        let req: NSFetchRequest<PendingDelete> = PendingDelete.fetchRequest()
        req.predicate = NSPredicate(format: "objectName == %@ AND needsSync == YES", objectName)
        let arr = (try? context.fetch(req)) ?? []
        return Set(arr.compactMap { $0.remoteId })
    }
}

enum PendingDeleteObjectName: String {
    case clients, addresses, tasks, streets
}

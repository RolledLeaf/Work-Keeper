import CoreData

final class AddressStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    
    func createAddress(house: String,
                       apartment: String?,
                       entrance: String?,
                       floor: String,
                       isPrivateHouse: Bool,
                       street: Street,
                       roomType: String,
                           entranceType: String,
                       note: String?
    ) -> Address {
        let address = Address(context: context)
        address.house = house.trimmingCharacters(in: .whitespacesAndNewlines)
        address.apartment = apartment?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.entrance = entrance?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.floor = floor.trimmingCharacters(in: .whitespacesAndNewlines)
        address.isPrivateHouse = isPrivateHouse
        address.street = street
        address.roomType = roomType.trimmingCharacters(in: .whitespacesAndNewlines)
        address.entranceType = entranceType.trimmingCharacters(in: .whitespacesAndNewlines)
        address.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Sync fields
        address.remoteId = nil
        address.deletedAt = nil
        address.updatedAt = Date()
        address.needsSync = true
        
        return address
    }
    
    
    
    func createOrFetchAddress(
        house: String,
        apartment: String?,
        entrance: String?,
        floor: String,
        isPrivateHouse: Bool,
        street: Street,
        client: Client,
        isPrimary: Bool,
        roomType: String,
        entranceType: String,
        note: String?
    ) -> Address {

        let request: NSFetchRequest<Address> = Address.fetchRequest()
        
        let trimmedHouse = house.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApt = (apartment ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEntrance = (entrance ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFloor = floor.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRoomType = roomType.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEntranceType = entranceType.trimmingCharacters(in: .whitespacesAndNewlines)

        // Match a specific address for this client by all identity fields
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "client == %@", client),
            NSPredicate(format: "street == %@", street),
            NSPredicate(format: "house == %@", trimmedHouse),
            NSPredicate(format: "(apartment == %@ OR (apartment == nil AND %@ == ''))", trimmedApt, trimmedApt),
            NSPredicate(format: "(entrance == %@ OR (entrance == nil AND %@ == ''))", trimmedEntrance, trimmedEntrance),
            NSPredicate(format: "floor == %@", trimmedFloor),
            NSPredicate(format: "roomType == %@", trimmedRoomType),
            NSPredicate(format: "entranceType == %@", trimmedEntranceType),
            NSPredicate(format: "isPrivateHouse == %@", NSNumber(value: isPrivateHouse)),
            NSPredicate(format: "deletedAt == nil")
        ])
        
        request.fetchLimit = 1

        do {
            if let existing = try context.fetch(request).first {
                return existing
            } else {
                let address = createAddress(
                    house: house,
                    apartment: apartment,
                    entrance: entrance,
                    floor: floor,
                    isPrivateHouse: isPrivateHouse,
                    street: street,
                    roomType: roomType,
                    entranceType: entranceType,
                    note: note
                )
                address.client = client
                address.isPrimary = isPrimary
                address.remoteId = nil
                address.deletedAt = nil
                address.updatedAt = Date()
                address.needsSync = true

                if isPrimary {
                    if let addresses = client.address as? Set<Address> {
                        for addr in addresses where addr != address {
                            if addr.isPrimary {
                                addr.isPrimary = false
                                addr.updatedAt = Date()
                                addr.needsSync = true
                            }
                        }
                    }
                }

                return address
            }
        } catch {
            print("Error in createOrFetchAddress: \(error)")
            let address = createAddress(
                house: house,
                apartment: apartment,
                entrance: entrance,
                floor: floor,
                isPrivateHouse: isPrivateHouse,
                street: street,
                roomType: roomType,
                entranceType: entranceType,
                note: note
            )
            address.client = client
            address.isPrimary = isPrimary

            return address
        }
    }
    
    func updateAddress(_ address: Address,
                     house: String,
                     apartment: String?,
                     entrance: String?,
                     floor: String,
                     isPrivateHouse: Bool,
                       roomType: String,
                           entranceType: String,
                       note: String?
    ) {
        address.house = house.trimmingCharacters(in: .whitespacesAndNewlines)
        address.apartment = apartment?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.entrance = entrance?.trimmingCharacters(in: .whitespacesAndNewlines)
        address.floor = floor.trimmingCharacters(in: .whitespacesAndNewlines)
        address.isPrivateHouse = isPrivateHouse
        address.entranceType = entranceType.trimmingCharacters(in: .whitespacesAndNewlines)
        address.roomType = roomType.trimmingCharacters(in: .whitespacesAndNewlines)
        address.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)

        // Sync fields
        address.updatedAt = Date()
        address.needsSync = true
        
        do {
            try context.save()
        } catch {
            print("Error updating address: \(error)")
        }
    }
    
 
    func deleteAddress(_ address: Address) {
        // Soft delete for sync
        address.deletedAt = Date()
        address.updatedAt = Date()
        address.needsSync = true
        do {
            try context.save()
        } catch {
            print("Error soft-deleting address: \(error)")
        }
    }

    /// Permanent delete (debug / cleanup only)
    func purgeAddress(_ address: Address) {
        context.delete(address)
        do {
            try context.save()
        } catch {
            print("Error purging address: \(error)")
        }
    }
    
    func fetchAddresses() -> [Address] {
        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "deletedAt == nil")
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching addresses: \(error)")
            return []
        }
    }
    
}

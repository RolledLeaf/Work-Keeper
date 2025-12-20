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
                           entranceType: String
    ) -> Address {
        let address = Address(context: context)
        address.house = house
        address.apartment = apartment
        address.entrance = entrance
        address.floor = floor
        address.isPrivateHouse = isPrivateHouse
        address.street = street
        address.roomType = roomType
        address.entranceType = entranceType
        
        // Sync fields
        address.remoteId = nil
        address.deletedAt = nil
        address.updatedAt = Date()
        
        
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
        entranceType: String
    ) -> Address {

        let request: NSFetchRequest<Address> = Address.fetchRequest()
        
        // Ищем адрес только внутри адресов ЭТОГО клиента и этой улицы/дома
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "client == %@", client),
            NSPredicate(format: "street == %@", street),
            NSPredicate(format: "house == %@", house),
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
                    entranceType: entranceType
                )
                address.client = client
                address.isPrimary = isPrimary

                // Sync fields
                address.remoteId = nil
                address.deletedAt = nil
                address.updatedAt = Date()

                if isPrimary {
                    if let addresses = client.address as? Set<Address> {
                        for addr in addresses where addr != address {
                            addr.isPrimary = false
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
                entranceType: entranceType
            )
            address.client = client
            address.isPrimary = isPrimary

            // Sync fields
            address.remoteId = nil
            address.deletedAt = nil
            address.updatedAt = Date()
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
                           entranceType: String
    ) {
        address.house = house
        address.apartment = apartment
        address.entrance = entrance
        address.floor = floor
        address.isPrivateHouse = isPrivateHouse
        address.entranceType = entranceType
        address.roomType = roomType
        
        // Sync fields
        address.deletedAt = nil
        address.updatedAt = Date()
        
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

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
        
        
        return address
    }
    
    
    
    func createOrFetchAddress(house: String,
                              apartment: String?,
                              entrance: String?,
                              floor: String,
                              isPrivateHouse: Bool,
                              street: Street,
                              client: Client,
                              isPrimary: Bool,
                              roomType: String,
                                  entranceType: String) -> Address {
        
        let request: NSFetchRequest<Address> = Address.fetchRequest()
        request.predicate = NSPredicate(format: "street.name == %@ AND house == %@", street.name ?? "", house)
        request.fetchLimit = 1

        do {
            if let existing = try context.fetch(request).first {
                return existing
            } else {
                let address = createAddress(house: house,
                                            apartment: apartment,
                                            entrance: entrance,
                                            floor: floor,
                                            isPrivateHouse: isPrivateHouse,
                                            street: street,
                                            roomType: roomType, entranceType: entranceType
                )
                address.client = client
                address.isPrimary = isPrimary

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
            let address = createAddress(house: house,
                                        apartment: apartment,
                                        entrance: entrance,
                                        floor: floor,
                                        isPrivateHouse: isPrivateHouse,
                                        street: street,
                                        roomType: roomType,
                                        entranceType: entranceType)
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
                           entranceType: String
    ) {
        address.house = house
        address.apartment = apartment
        address.entrance = entrance
        address.floor = floor
        address.isPrivateHouse = isPrivateHouse
        address.entranceType = entranceType
        address.roomType = roomType
        
        do {
            try context.save()
        } catch {
            print("Error updating address: \(error)")
        }
    }
    
    // redundunt methods
    func deleteAddress(_ address: Address) {
        context.delete(address)
        do {
            try context.save()
        } catch {
            print("Error deleting address: \(error)")
        }
    }
    
    func fetchAddresses() -> [Address] {
        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching addresses: \(error)")
            return []
        }
    }
    
}

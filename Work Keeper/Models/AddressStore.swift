import CoreData

final class AddressStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    
    func createAddress(house: String,
                       apartment: String?,
                       entrance: String?,
                       floor: Int,
                       isPrivateHouse: Bool,
                       street: Street
    ) -> Address {
        let address = Address(context: context)
        address.house = house
        address.apartment = apartment
        address.entrance = entrance
        address.floor = Int16(floor)
        address.isPrivateHouse = isPrivateHouse
        address.street = street
        do {
            try context.save()
        } catch {
            print("Error creating address: \(error)")
        }
        return address
    }
    
    func updateAddress(_ address: Address,
                     house: String,
                     apartment: String?,
                     entrance: String?,
                     floor: Int,
                     isPrivateHouse: Bool
    ) {
        address.house = house
        address.apartment = apartment
        address.entrance = entrance
        address.floor = Int16(floor)
        address.isPrivateHouse = isPrivateHouse
        
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





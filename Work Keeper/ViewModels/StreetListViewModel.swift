

import Foundation
import Combine

final class StreetListViewModel: ObservableObject {
    @Published var streets: [Street] = []

    private let store = StreetStore()

    init() {
        loadStreets()
    }

    func loadStreets() {
        streets = store.fetchStreets()
    }
    
    func addStreet(_ name: String) {
        guard !name.isBlank else { return }
        store.createStreet(name: name)
    }
    
    func update(_ street: Street, name: String) {
        guard !name.isBlank else { return }
        store.updateStreet(street: street, name: name)
        loadStreets()
    }
    
    func delete(_ street: Street) {
        store.deleteStreet(street: street)
        loadStreets()
    }
}

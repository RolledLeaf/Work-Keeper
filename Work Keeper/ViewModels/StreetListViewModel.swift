import Foundation
import Combine





@MainActor
final class StreetListViewModel: ObservableObject {
    @Published var streets: [Street] = []
    @Published var selectedStreet: Street?
    

    private let store = StreetStore()
  

    init() {
        loadStreets()
    }

    func loadStreets() {
        streets = store.fetchStreets()
    }
    
    func pickStreet(_ street: Street) {
        selectedStreet = street
    }
    
    func addStreet(_ name: String) {
        guard !name.isBlank else { return }
        store.createStreet(name: name)
        loadStreets()
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


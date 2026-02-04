import Foundation
import Combine



@MainActor
final class StreetListViewModel: ObservableObject {
    @Published var streets: [Street] = []
    @Published var selectedStreet: Street?
    @Published var lastAddedStreetName: String = ""
    @Published var lastDeletedStreetName: String = ""
    @Published var lastEditedStreetName: String = ""
    @Published var previousStreetName: String = ""
    @Published var searchText: String = ""
    @Published var streetWasDeleted = false
    @Published var streetWasEdited = false
    
    private var cancellables = Set<AnyCancellable>()
    private let store = StreetStore()
  

    init() {
        loadStreets()
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self ] _ in
                guard let self = self else { return }
                self.applySearch()
            }
            .store(in: &cancellables)
        
        
    }

    func applySearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            loadStreets()
            return
        }
        streets = store.fetchStreets(matching: searchText)
    }
    
    func loadStreets() {
        streets = store.fetchStreets()
    }
    
    func loadSortedStreets(ascending: Bool) {
        streets = store.fetchStreets(ascending: ascending)
    }
    
    func pickStreet(_ street: Street) {
        selectedStreet = street
    }
    
    func streetAlreadyExists(_ name: String) -> Bool {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return store.fetchStreets(matching: n).count > 0
       
    }
    
    func addStreet(_ name: String) {
        guard !name.isBlank else { return }
        
         let street = store.createOrFetchStreet(name: name)
        
        selectedStreet = street
        lastAddedStreetName = street?.name ?? name
        
    }
    
    func update(_ street: Street, name: String) {
        guard !name.isBlank else { return }
        store.updateStreet(street: street, name: name)
        loadStreets()
        lastEditedStreetName = name
       
    }
    
    func delete(_ street: Street, name: String) {
        store.deleteStreet(street: street)
        loadStreets()
        lastDeletedStreetName = name
    }
    
    
}


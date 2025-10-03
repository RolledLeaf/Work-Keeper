import SwiftUI
import CoreData


struct ClientClientsStatRow: View {
    @ObservedObject var viewModel: ClientsListViewModel
    
    let year: Int
    
    let monthIndex: Int
    
    private func title() -> String {
        Self.months[monthIndex]
    }

    
    static let months: [String] = ["За год", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    
    var body: some View {
        
        
        
    }
}

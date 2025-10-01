import Foundation
import CoreData


@MainActor
final class IncomeViewModel: ObservableObject {
    @Published var total: Decimal = 0

    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) { self.context = context }

    func loadTotal() {
        total = totalIncomeAllTime(context: context, onlyCompleted: true)
    }
}

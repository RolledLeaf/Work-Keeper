import Foundation
import CoreData


@MainActor
final class IncomeViewModel: ObservableObject {
    @Published var total: Decimal = 0

    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) { self.context = context }

    func loadTotal() {
        print("[IncomeViewModel] loadTotal() called")
        total = totalIncomeAllTime(context: context, onlyCompleted: true)
        print("[IncomeViewModel] loadTotal() called")
    }
}

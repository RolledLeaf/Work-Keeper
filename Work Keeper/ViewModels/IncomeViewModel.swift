import Foundation
import CoreData


@MainActor
final class IncomeViewModel: ObservableObject {
    @Published var total: Decimal = 0
    @Published var yearIncome: Decimal = 0
    @Published var monthIncome: Decimal = 0
    @Published var monthlyIncome: [Decimal] = Array(repeating: 0, count: 12)

    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) { self.context = context }

    func loadTotal() {
        print("[IncomeViewModel] loadTotal() called")
        total = totalIncomeAllTime(context: context, onlyCompleted: true)
        print("[IncomeViewModel] loadTotal() called")
    }
    
    func loadYearIncome(year: Int) {
        print("[IncomeViewModel] loadYearIncome(\(year)) called")
        monthIncome = totalIncome(
            context: context,
            year: year,
            month: nil,
            onlyCompleted: true,
            debug: false
        )
    }
    
    func loadMonthlyIncome(year: Int) {
        print("[IncomeViewModel] loadMonthlyIncome(\(year)) called")
        var temp: [Decimal] = []
        for month in 1...12 {
            let income = totalIncome(
                context: context,
                year: year,
                month: month,
                onlyCompleted: true,
                debug: false
            )
            temp.append(income)
        }
        monthlyIncome = temp
    }
  
}

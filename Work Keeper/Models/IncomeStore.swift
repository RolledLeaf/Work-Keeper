import CoreData


@MainActor
func totalIncomeAllTime(
    context: NSManagedObjectContext,
    onlyCompleted: Bool = true,
    debug: Bool = true
) -> Decimal {

    guard context.persistentStoreCoordinator != nil else {
        print("[IncomeStore] ERROR: context has no persistentStoreCoordinator")
        return 0
    }

    let request = NSFetchRequest<NSDictionary>(entityName: "TaskEntity")
    request.resultType = .dictionaryResultType

    // Сумма
    let sumExpression = NSExpression(
        forFunction: "sum:",
        arguments: [NSExpression(forKeyPath: "totalAmount")]
    )

    let sumDesc = NSExpressionDescription()
    sumDesc.name = "totalIncome"
    sumDesc.expression = sumExpression
    sumDesc.expressionResultType = .doubleAttributeType

    request.propertiesToFetch = [sumDesc]

    // --- Предикаты ---
    var predicates: [NSPredicate] = [
        NSPredicate(format: "deletedAt == nil")
    ]

    if onlyCompleted {
        predicates.append(
            NSPredicate(format: "statusString == %@", "completed")
        )
    }

    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

    if debug {
        print("[IncomeStore] totalIncomeAllTime — onlyCompleted=\(onlyCompleted)")
        print("[IncomeStore] Predicate:", request.predicate?.predicateFormat ?? "<none>")
    }

    do {
        let result = try context.fetch(request).first
        if let number = result?["totalIncome"] as? NSNumber {
            return Decimal(number.doubleValue)
        }
        return 0
    } catch {
        print("[IncomeStore] Sum fetch error:", error)
        return 0
    }
}

@MainActor
func totalIncome( //Actual
    context: NSManagedObjectContext,
    year: Int,
    month: Int? = nil,               // 1...12; nil => весь год
    onlyCompleted: Bool = true,
    dateKey: String = "scheduledAt", // ключ атрибута даты в Core Data (подстрой при необходимости)
    debug: Bool = false
) -> Decimal {
    guard context.persistentStoreCoordinator != nil else {
        if debug { print("[IncomeStore] ERROR: context has no persistentStoreCoordinator") }
        return 0
    }

    let request = NSFetchRequest<NSDictionary>(entityName: "TaskEntity")
    request.resultType = .dictionaryResultType

    // Сумма по totalAmount
    let sumExpression = NSExpression(forFunction: "sum:",
                                     arguments: [NSExpression(forKeyPath: "totalAmount")])
    let sumDesc = NSExpressionDescription()
    sumDesc.name = "totalIncome"
    sumDesc.expression = sumExpression
    sumDesc.expressionResultType = .doubleAttributeType // поменяй на .decimalAttributeType если totalAmount = Decimal
    request.propertiesToFetch = [sumDesc]

    // Дата-диапазон
    var cal = Calendar.current
    cal.timeZone = .current

    var startComponents = DateComponents()
    startComponents.year = year
    startComponents.month = month ?? 1
    startComponents.day = 1

    var endComponents = DateComponents()
    endComponents.year = (month == nil) ? (year + 1) : year
    endComponents.month = (month == nil) ? 1 : (month! + 1)
    endComponents.day = 1

    guard let startDate = cal.date(from: startComponents),
          let endDate = cal.date(from: endComponents) else {
        if debug { print("[IncomeStore] ERROR: failed to build date range for year=\(year) month=\(String(describing: month))") }
        return 0
    }

    var predicates: [NSPredicate] = [
        NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate), NSPredicate(format: "deletedAt == nil") // income from actual tasks
    ]
    if onlyCompleted {
        predicates.append(NSPredicate(format: "statusString == %@", "completed"))
    }
    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    

    if debug {
        print("[IncomeStore] totalIncome(year: \(year), month: \(String(describing: month)))")
        print("[IncomeStore] Predicate:", request.predicate?.predicateFormat ?? "<none>")
    }

    do {
        let result = try context.fetch(request).first
        if debug { print("[IncomeStore] Aggregate:", result as Any) }
        if let number = result?[("totalIncome")] as? NSNumber {
            return Decimal(number.doubleValue)
        }
        return 0
    } catch {
        if debug { print("[IncomeStore] Sum fetch error:", error) }
        return 0
    }
}



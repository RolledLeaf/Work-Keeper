import CoreData


@MainActor
func totalIncomeAllTime(context: NSManagedObjectContext,
                        onlyCompleted: Bool = true,
                        debug: Bool = true) -> Decimal {
    guard context.persistentStoreCoordinator != nil else {
        print("[IncomeStore] ERROR: context has no persistentStoreCoordinator")
        return 0
    }
    let request = NSFetchRequest<NSDictionary>(entityName: "TaskEntity")
    request.resultType = .dictionaryResultType

  
    let sumExpression = NSExpression(forFunction: "sum:",
                                     arguments: [NSExpression(forKeyPath: "totalAmount")])

    let sumDesc = NSExpressionDescription()
    sumDesc.name = "totalIncome"
    sumDesc.expression = sumExpression
   
    sumDesc.expressionResultType = .doubleAttributeType
   

    request.propertiesToFetch = [sumDesc]

    // DEBUG: Preflight checks
    if debug {
        do {
            let allReq = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
            let allCount = try context.count(for: allReq)

            let completedReq = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
            completedReq.predicate = NSPredicate(format: "statusString == %@", "completed")
            let completedCount = try context.count(for: completedReq)

            print("[IncomeStore] totalIncomeAllTime — onlyCompleted=\(onlyCompleted)")
            print("[IncomeStore] Tasks total count: \(allCount), completed count: \(completedCount)")
           

            // Peek first 5 completed tasks to verify totalAmount values
            let sampleReq = NSFetchRequest<NSManagedObject>(entityName: "TaskEntity")
            sampleReq.fetchLimit = 5
            sampleReq.predicate = onlyCompleted ? NSPredicate(format: "statusString == %@", "completed") : nil
            sampleReq.propertiesToFetch = ["totalAmount", "statusString"]
            sampleReq.includesPropertyValues = true
            let sample = try context.fetch(sampleReq)
            let sampleAmounts: [String] = sample.compactMap { obj in
                let amount = obj.value(forKey: "totalAmount")
                let status = obj.value(forKey: "statusString") as? String ?? "?"
                if let d = amount as? NSDecimalNumber { return "(\(status)) \(d)" }
                if let n = amount as? NSNumber { return "(\(status)) \(n)" }
                return "(\(status)) <nil>"
            }
            print("[IncomeStore] Sample totalAmount values:", sampleAmounts)
        } catch {
            print("[IncomeStore] Debug preflight error:", error)
        }
    }

   
    if onlyCompleted {
        request.predicate = NSPredicate(format: "statusString == %@", "completed")
   
    }
    if debug {
        print("[IncomeStore] Predicate used:", request.predicate?.predicateFormat ?? "<none>")
    }
   

    do {
        let result = try context.fetch(request).first
        if debug {
            print("[IncomeStore] Aggregate result dict:", result as Any)
            print("[IncomeStore] expressionResultType: doubleAttributeType (consider .decimalAttributeType if totalAmount is Decimal)")
        }
        if let number = result?["totalIncome"] as? NSNumber {
            return Decimal(number.doubleValue)
        }
       
        return 0
    } catch {
        print("Sum fetch error:", error)
        return 0
    }
}

@MainActor
func totalIncome(
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
        NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate)
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

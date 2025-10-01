import CoreData


@MainActor
func totalIncomeAllTime(context: NSManagedObjectContext,
                        onlyCompleted: Bool = true) -> Decimal {
    let request = NSFetchRequest<NSDictionary>(entityName: "Task")
    request.resultType = .dictionaryResultType

    // Суммируем по атрибуту totalAmount
    let sumExpression = NSExpression(forFunction: "sum:",
                                     arguments: [NSExpression(forKeyPath: "totalAmount")])

    let sumDesc = NSExpressionDescription()
    sumDesc.name = "totalIncome"
    sumDesc.expression = sumExpression
   
    sumDesc.expressionResultType = .doubleAttributeType
   

    request.propertiesToFetch = [sumDesc]

    // Фильтры (например, только выполненные)
    if onlyCompleted {
        request.predicate = NSPredicate(format: "status == %@", "completed")
        // или если статус — enum/int:
        // NSPredicate(format: "statusRaw == %d", TaskStatus.completed.rawValue)
    }

    // Пример — ограничить период датами:
    // request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)

    do {
        let result = try context.fetch(request).first
        if let number = result?["totalIncome"] as? NSNumber {
            return Decimal(number.doubleValue)
        }
        // Если указал .doubleAttributeType:
        // if let number = result?["totalIncome"] as? NSNumber { return Decimal(number.doubleValue) }
        return 0
    } catch {
        print("Sum fetch error:", error)
        return 0
    }
}

import CoreData


@MainActor
func totalIncomeAllTime(context: NSManagedObjectContext,
                        onlyCompleted: Bool = true,
                        debug: Bool = true) -> Decimal {
    guard context.persistentStoreCoordinator != nil else {
        print("[IncomeStore] ERROR: context has no persistentStoreCoordinator")
        return 0
    }
    let request = NSFetchRequest<NSDictionary>(entityName: "Task")
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
            let allReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
            let allCount = try context.count(for: allReq)

            let completedReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
            completedReq.predicate = NSPredicate(format: "statusString == %@", "completed")
            let completedCount = try context.count(for: completedReq)

            print("[IncomeStore] totalIncomeAllTime — onlyCompleted=\(onlyCompleted)")
            print("[IncomeStore] Tasks total count: \(allCount), completed count: \(completedCount)")
           

            // Peek first 5 completed tasks to verify totalAmount values
            let sampleReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
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

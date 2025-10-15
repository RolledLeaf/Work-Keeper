
extension String {
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


extension String {
    func formattedAsPhone() -> String {
        // Удаляем всё, кроме цифр
        let digits = self.filter { $0.isNumber }

        // Проверяем, достаточно ли цифр
        guard digits.count >= 11 else { return self }

        // Берём последние 10 цифр (на случай +7 и 8)
        let core = String(digits.suffix(10))

        let area = core.prefix(3)
        let middle = core.dropFirst(3).prefix(3)
        let last2 = core.dropFirst(6).prefix(2)
        let last2end = core.dropFirst(8).prefix(2)

        return "+7(\(area))\(middle)-\(last2)-\(last2end)"
    }
    
    func clearText() -> String {
        return ""
    }
}

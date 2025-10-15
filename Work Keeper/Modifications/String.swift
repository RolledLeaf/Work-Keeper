import SwiftUI

func highlighted(_ text: String, query: String, highlightColor: Color = .yellow) -> AttributedString {
    // Если пустой запрос — просто вернуть обычную AttributedString
    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return AttributedString(text)
    }

    // Защита от спецсимволов regex
    // Разбиваем query на токены (по пробелам) и ищем каждую "токен" альтернатива (OR)
    let tokens = query
        .split(separator: " ")
        .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    guard !tokens.isEmpty else { return AttributedString(text) }

    // Построим регулярное выражение вида: (tok1|tok2|tok3)
    let escaped = tokens.map { NSRegularExpression.escapedPattern(for: $0) }
    let pattern = "(" + escaped.joined(separator: "|") + ")"

    // Компилируем регулярку с флагами (регистро- и диакритико- нечувств.)
    let options: NSRegularExpression.Options = []
    let matchingOptions: NSRegularExpression.MatchingOptions = []
    let regex: NSRegularExpression
    do {
        regex = try NSRegularExpression(pattern: pattern, options: options)
    } catch {
        // На всякий случай — если regex упал, возвращаем plain
        return AttributedString(text)
    }

    // Создаём AttributedString из исходного текста
    var attr = AttributedString(text)
    // Сохраним базовый стиль (опционально)
    // let baseFont = UIFont.preferredFont(forTextStyle: .body)
    // attr.font = Font(baseFont)

    let nsText = text as NSString
    let fullRange = NSRange(location: 0, length: nsText.length)

    // Найдём все совпадения
    regex.enumerateMatches(in: text, options: matchingOptions, range: fullRange) { match, _, _ in
        guard let match = match else { return }
        let matchRange = match.range(at: 1) // первая захватывающая группа
        if let range = Range(matchRange, in: text) {
            // Конвертация Range<String.Index> -> Range<AttributedString.Index>
            if let attrRange = attr.range(of: String(text[range])) {
                // Применяем стиль к совпадению
                // цвет текста
                attr[attrRange].foregroundColor = .black
                // фон подсветки
                attr[attrRange].backgroundColor = highlightColor
                // можно ещё изменить шрифт/жирность:
                // attr[attrRange].font = .system(size: 14, weight: .semibold)
            }
        }
    }

    return attr
}


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

import SwiftUI

struct MathExpressionView: View {
    let expression: String
    
    private func formatMathExpression(_ input: String) -> AttributedString {
        var text = input
        
        // Handle LaTeX-style escapes first
        text = text.replacingOccurrences(of: "\\{", with: "{")
        text = text.replacingOccurrences(of: "\\}", with: "}")
        text = text.replacingOccurrences(of: "\\text{", with: "")
        text = text.replacingOccurrences(of: "}", with: "")
        
        // Replace basic operators
        let replacements: [String: String] = [
            "^": "²³⁴⁵⁶⁷⁸⁹",  // Will handle one digit superscripts
            "/": "⁄",         // Fraction slash
            "sqrt": "√",
            "<=": "≤",
            ">=": "≥",
            "!=": "≠",
            "pi": "π",
            "\\frac": "/"    // Convert \frac to regular division
        ]
        
        // Handle superscripts first
        if let caretIndex = text.firstIndex(of: "^") {
            let afterIndex = text.index(after: caretIndex)
            if afterIndex < text.endIndex {
                let digit = text[afterIndex]
                if let num = Int(String(digit)), num >= 1 && num <= 9 {
                    let superscript = replacements["^"]!.map(String.init)[num-1]
                    text.replaceSubrange(caretIndex...afterIndex, with: superscript)
                }
            }
        }
        
        // Replace other symbols
        for (key, value) in replacements {
            if key != "^" {  // Already handled above
                text = text.replacingOccurrences(of: key, with: value)
            }
        }
        
        var attributed = AttributedString(text)
        attributed.font = .system(size: 17, weight: .regular, design: .serif)
        return attributed
    }
    
    var body: some View {
        Text(formatMathExpression(expression))
    }
}

#Preview {
    VStack(spacing: 20) {
        MathExpressionView(expression: "x^2 + 2x + 1")
        MathExpressionView(expression: "2/3 + sqrt(4)")
        MathExpressionView(expression: "pi * r^2")
        MathExpressionView(expression: "\\{2, 5, 7, 8, 10\\}")
        MathExpressionView(expression: "\\frac{3}{4}")
    }
} 
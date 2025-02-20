import SwiftUI

struct MathView: View {
    let content: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text(attributedContent)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var attributedContent: AttributedString {
        var text = content
        
        // Convert LaTeX-style math to formatted text
        text = formatLatexMath(text)
        
        // Create attributed string
        var attributedString = AttributedString(text)
        
        // Apply styling
        attributedString.font = .system(size: 16)
        attributedString.foregroundColor = colorScheme == .dark ? .white : .black
        
        return attributedString
    }
    
    private func formatLatexMath(_ text: String) -> String {
        var formattedText = text
        
        // Remove MathML tags if present
        formattedText = formattedText.replacingOccurrences(of: "<math>", with: "")
        formattedText = formattedText.replacingOccurrences(of: "</math>", with: "")
        
        // Handle fractions (e.g., \frac{1}{2})
        while let fracStart = formattedText.range(of: "\\frac{"),
              let firstCloseBrace = formattedText[fracStart.upperBound...].firstRange(of: "}"),
              let secondOpenBrace = formattedText[firstCloseBrace.upperBound...].firstRange(of: "{"),
              let secondCloseBrace = formattedText[secondOpenBrace.upperBound...].firstRange(of: "}") {
            
            let numerator = String(formattedText[fracStart.upperBound..<firstCloseBrace.lowerBound])
            let denominator = String(formattedText[secondOpenBrace.upperBound..<secondCloseBrace.lowerBound])
            
            formattedText.replaceSubrange(fracStart.lowerBound..<secondCloseBrace.upperBound,
                               with: "(\(numerator)/\(denominator))")
        }
        
        // Handle superscripts (e.g., x^2)
        while let powerStart = formattedText.range(of: "^{"),
              let powerEnd = formattedText[powerStart.upperBound...].firstRange(of: "}") {
            let power = String(formattedText[powerStart.upperBound..<powerEnd.lowerBound])
            formattedText.replaceSubrange(powerStart.lowerBound..<powerEnd.upperBound,
                               with: "^(\(power))")
        }
        
        // Handle subscripts (e.g., x_n)
        while let subStart = formattedText.range(of: "_{"),
              let subEnd = formattedText[subStart.upperBound...].firstRange(of: "}") {
            let sub = String(formattedText[subStart.upperBound..<subEnd.lowerBound])
            formattedText.replaceSubrange(subStart.lowerBound..<subEnd.upperBound,
                               with: "_(\(sub))")
        }
        
        // Handle square roots (e.g., \sqrt{x})
        while let sqrtStart = formattedText.range(of: "\\sqrt{"),
              let sqrtEnd = formattedText[sqrtStart.upperBound...].firstRange(of: "}") {
            let content = String(formattedText[sqrtStart.upperBound..<sqrtEnd.lowerBound])
            formattedText.replaceSubrange(sqrtStart.lowerBound..<sqrtEnd.upperBound,
                               with: "√(\(content))")
        }
        
        // Handle common mathematical symbols
        let symbols = [
            "\\times": "×",
            "\\div": "÷",
            "\\pm": "±",
            "\\leq": "≤",
            "\\geq": "≥",
            "\\neq": "≠",
            "\\approx": "≈",
            "\\pi": "π",
            "\\theta": "θ",
            "\\alpha": "α",
            "\\beta": "β",
            "\\sum": "Σ",
            "\\prod": "∏",
            "\\infty": "∞",
            "\\rightarrow": "→",
            "\\leftarrow": "←",
            "\\therefore": "∴",
            "\\because": "∵"
        ]
        
        for (latex, symbol) in symbols {
            formattedText = formattedText.replacingOccurrences(of: latex, with: symbol)
        }
        
        // Clean up any remaining LaTeX commands
        formattedText = formattedText.replacingOccurrences(of: "\\[", with: "")
        formattedText = formattedText.replacingOccurrences(of: "\\]", with: "")
        formattedText = formattedText.replacingOccurrences(of: "\\(", with: "")
        formattedText = formattedText.replacingOccurrences(of: "\\)", with: "")
        
        return formattedText
    }
}

// Preview provider for testing
struct MathView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MathView(content: "\\frac{1}{2} + x^2")
            MathView(content: "\\sqrt{16} = 4")
            MathView(content: "a \\times b \\leq c")
            MathView(content: "\\sum_{i=1}^{n} x_i")
        }
    }
} 
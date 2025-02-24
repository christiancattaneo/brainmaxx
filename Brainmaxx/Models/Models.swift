import Foundation
import SwiftUI

// MARK: - Enums
enum Difficulty: String, Codable, CaseIterable {
    case easy = "E"
    case medium = "M"
    case hard = "H"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return Color(red: 1.0, green: 0.9, blue: 0.4) // Slightly yellow
        case .medium: return Color.orange
        case .hard: return Color.red
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        
        // Handle both full names and single letters
        switch rawString.lowercased().prefix(1) {
        case "e": self = .easy
        case "m": self = .medium
        case "h": self = .hard
        default: self = .medium  // Default to medium if unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)  // Encode using the raw value (E, M, H)
    }
}

// MARK: - Models
struct Subject: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    private var topics: [String: [Question]]
    private var questionsByDifficulty: [Difficulty: [Question]] = [:]
    
    var totalQuestions: Int {
        topics.values.reduce(0) { $0 + $1.count }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, iconName, topics
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        iconName = try container.decode(String.self, forKey: .iconName)
        topics = try container.decode([String: [Question]].self, forKey: .topics)
        updateQuestionsByDifficulty()
    }
    
    init(id: String, name: String, description: String, iconName: String, topics: [String: [Question]]) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.topics = topics
        updateQuestionsByDifficulty()
    }
    
    // Factory method for creating AI subjects
    static func createAISubject(id: String, name: String, description: String, iconName: String) -> Subject {
        Subject(
            id: id,
            name: name,
            description: description,
            iconName: iconName,
            topics: ["Generated": []]
        )
    }
    
    private mutating func updateQuestionsByDifficulty() {
        questionsByDifficulty.removeAll()
        for questions in topics.values {
            for question in questions {
                questionsByDifficulty[question.difficulty, default: []].append(question)
            }
        }
    }
    
    func getQuestions(forDifficulty difficulty: Difficulty) -> [Question] {
        return questionsByDifficulty[difficulty] ?? []
    }
    
    mutating func updateTopics(_ newTopics: [String: [Question]]) {
        self.topics = newTopics
        updateQuestionsByDifficulty()
    }
    
    func getTopics() -> [String: [Question]] {
        return topics
    }
}

struct Question: Identifiable, Codable {
    let id: String
    let type: String?
    let subject: String
    let topic: String
    let skill: String
    let difficulty: Difficulty
    let lesson: String?
    
    struct OptionContent: Codable {
        let id: String
        let content: String
    }
    
    struct Content: Codable {
        let text: String?  // Made optional
        let originalMath: String?
        private let options: [OptionContent]?  // Unified options field
        let correctAnswers: [String]
        
        // Computed property to handle both formats
        var displayOptions: [String] {
            if let options = options {
                return options.map { $0.content }
            }
            return []
        }
        
        // Computed property to handle nullable text with fallback
        var displayText: String {
            if let text = text {
                return text
            }
            // If text is null but we have originalMath, use that
            if let math = originalMath {
                return math
            }
            // Default fallback
            return "Question text not available"
        }
        
        enum CodingKeys: String, CodingKey {
            case text = "text"
            case originalMath = "original_math"
            case options = "options"
            case correctAnswers = "correct_answers"
        }
        
        // Custom decoder to handle nullable fields and different option formats
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Decode optional fields
            text = try container.decodeIfPresent(String.self, forKey: .text)
            originalMath = try container.decodeIfPresent(String.self, forKey: .originalMath)
            
            // Try to decode options as either OptionContent array or String array
            if let optionContents = try? container.decode([OptionContent].self, forKey: .options) {
                options = optionContents
            } else if let stringOptions = try? container.decode([String].self, forKey: .options) {
                // Convert string options to OptionContent
                options = stringOptions.map { OptionContent(id: UUID().uuidString, content: $0) }
            } else {
                options = nil
            }
            
            // Handle correct answers - try both array and single string
            if let answers = try? container.decode([String].self, forKey: .correctAnswers) {
                correctAnswers = answers
            } else if let answer = try? container.decode(String.self, forKey: .correctAnswers) {
                correctAnswers = [answer]
            } else {
                correctAnswers = []  // Fallback to empty array if no correct answer found
            }
        }
        
        // Convenience initializer for previews
        init(text: String?, originalMath: String?, mathOptions: [String]? = nil, englishOptions: [OptionContent]? = nil, correctAnswers: [String]) {
            self.text = text
            self.originalMath = originalMath
            if let mathOptions = mathOptions {
                self.options = mathOptions.map { OptionContent(id: UUID().uuidString, content: $0) }
            } else {
                self.options = englishOptions
            }
            self.correctAnswers = correctAnswers
        }
    }
    
    struct Explanation: Codable {
        let text: String?  // Made optional
        let originalMath: String?
        
        enum CodingKeys: String, CodingKey {
            case text = "text"
            case originalMath = "original_math"
        }
        
        // Custom decoder to handle nullable fields
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Decode optional fields
            text = try container.decodeIfPresent(String.self, forKey: .text)
            originalMath = try container.decodeIfPresent(String.self, forKey: .originalMath)
        }
        
        // Computed property to handle nullable text with fallback
        var displayText: String {
            if let text = text {
                return text
            }
            // If text is null but we have originalMath, use that
            if let math = originalMath {
                return math
            }
            // Default fallback
            return "No explanation available"
        }
        
        // Convenience initializer for previews
        init(text: String?, originalMath: String?) {
            self.text = text
            self.originalMath = originalMath
        }
    }
    
    let question: Content
    let explanation: Explanation
    let images: [String]
    
    // For tracking question state
    var selectedOptionIndex: Int?
    
    // Computed properties
    var isAnswered: Bool { selectedOptionIndex != nil }
    var isCorrect: Bool {
        guard let selected = selectedOptionIndex,
              selected < question.displayOptions.count,
              let correctAnswer = question.correctAnswers.first else { return false }
        return question.displayOptions[selected] == correctAnswer
    }
    
    var points: Int {
        isCorrect ? 1 : 0
    }
}

struct QuizResult {
    let subject: Subject
    let difficulty: Difficulty
    let answeredQuestions: [Question]
    let totalQuestions: Int
    let totalPoints: Int
    
    var score: Int {
        answeredQuestions.count  // Number of correct questions
    }
    
    var percentageCorrect: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(totalPoints) / Double(totalQuestions * 20) * 100
    }
    
    var grade: String {
        switch percentageCorrect {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

// MARK: - Question Loading Models
struct QuestionManifest: Codable {
    let subjects: [String]
    let total_questions: Int
}

struct SubjectQuestions: Codable {
    let subject: String
    let topics: [String: [Question]]
} 

import Foundation
import OpenAI

class QuestionSimplifier {
    private let client: OpenAI
    
    init() {
        // Get API key from environment
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OpenAI API key not found in environment")
        }
        self.client = OpenAI(apiKey: apiKey)
    }
    
    func simplifyQuestion(_ question: Question) async throws -> Question {
        let prompt = """
        Given this SAT math question:
        Question: \(question.question.text ?? "")
        Math Expression: \(question.question.originalMath ?? "")
        Options: \(question.question.displayOptions.joined(separator: ", "))
        Correct Answer: \(question.question.correctAnswers.first ?? "")
        
        Create a simpler version of this question that tests the same concept but is easier to understand.
        Return ONLY a JSON object in this exact format:
        {
            "text": "The simplified question text",
            "math": "The simplified math expression if needed",
            "options": ["option1", "option2", "option3", "option4"],
            "correct_answer": "the correct option",
            "explanation": "A clear explanation of the solution"
        }
        """
        
        let query = Chat.Query(model: .gpt4_turbo_preview, messages: [
            .init(role: .system, content: "You are an AI that simplifies complex SAT math questions into easier versions while maintaining the core concept."),
            .init(role: .user, content: prompt)
        ])
        
        let result = try await client.chats(query: query)
        guard let content = result.choices.first?.message.content else {
            throw NSError(domain: "QuestionSimplifier", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response from OpenAI"])
        }
        
        // Parse the JSON response
        let decoder = JSONDecoder()
        guard let jsonData = content.data(using: .utf8),
              let simplified = try? decoder.decode(SimplifiedQuestion.self, from: jsonData) else {
            throw NSError(domain: "QuestionSimplifier", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse OpenAI response"])
        }
        
        // Convert SimplifiedQuestion to Question
        return Question(
            id: question.id + "_simplified",
            type: question.type,
            subject: question.subject,
            topic: question.topic,
            skill: question.skill,
            difficulty: .easy,
            question: Question.Content(
                text: simplified.text,
                originalMath: simplified.math,
                mathOptions: simplified.options,
                correctAnswers: [simplified.correct_answer]
            ),
            explanation: Question.Explanation(
                text: simplified.explanation,
                originalMath: nil
            ),
            images: []
        )
    }
}

// Structure to decode OpenAI response
private struct SimplifiedQuestion: Codable {
    let text: String
    let math: String?
    let options: [String]
    let correct_answer: String
    let explanation: String
} 
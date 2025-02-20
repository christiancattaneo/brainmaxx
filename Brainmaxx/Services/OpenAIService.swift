import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    private let apiKey: String
    
    enum OpenAIError: Error {
        case missingAPIKey
        case invalidAPIKey
        case networkError(String)
        case parsingError(String)
    }
    
    private init() {
        // Load API key from Configuration.plist
        if let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["OpenAIKey"] as? String,
           key != "YOUR_API_KEY_HERE" && !key.isEmpty {
            self.apiKey = key
        } else {
            self.apiKey = ""
            print("⚠️ Invalid or missing OpenAI API key in Configuration.plist")
        }
    }
    
    func generateQuestion(subject: String, difficulty: Difficulty) async throws -> Question? {
        guard !apiKey.isEmpty else {
            print("❌ No valid API key available")
            throw OpenAIError.missingAPIKey
        }
        
        if apiKey == "YOUR_API_KEY_HERE" {
            print("❌ Using placeholder API key")
            throw OpenAIError.invalidAPIKey
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set a longer timeout
        request.timeoutInterval = 30
        
        let systemPrompt = """
        You are an AI that generates SAT practice questions.
        Generate one SAT-style multiple choice question that matches these criteria:
        - Subject: \(subject)
        - Difficulty: \(difficulty.displayName)
        - Format: Multiple choice with 4 options
        - Include detailed explanations for correct and incorrect answers

        Return the response in this exact JSON format:
        {
            "question": "The question text here",
            "options": [
                "First option text",
                "Second option text",
                "Third option text",
                "Fourth option text"
            ],
            "correct_answer": "A",
            "explanations": {
                "A": "Explanation for first option",
                "B": "Explanation for second option",
                "C": "Explanation for third option",
                "D": "Explanation for fourth option"
            }
        }

        Important formatting rules:
        1. Options must be a simple array of strings without letter prefixes
        2. Correct answer must be a single uppercase letter (A, B, C, or D)
        3. Explanations must use uppercase letters as keys
        4. All text fields must be plain strings without formatting
        """
        
        let userPrompt = "Generate a question and return it in the specified JSON format only, with no additional text or formatting."
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo-preview",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7
        ]
        
        print("🌐 Making OpenAI API request...")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                return nil
            }
            
            print("📡 API Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ API Error: \(errorString)")
                    throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorString])
                } else {
                    throw NSError(domain: "OpenAI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                }
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            print("✅ Successfully decoded API response")
            
            guard let content = openAIResponse.choices.first?.message.content else {
                print("❌ No content in API response")
                return nil
            }
            
            print("📝 Raw API Response Content: \(content)")
            
            guard let questionData = content.data(using: .utf8) else {
                print("❌ Failed to encode content as UTF-8")
                throw OpenAIError.parsingError("Failed to encode content as UTF-8")
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: questionData) as? [String: Any] else {
                    print("❌ Failed to parse JSON")
                    throw OpenAIError.parsingError("Failed to parse JSON structure")
                }
                
                // Extract options from either array or dictionary format
                var options: [String] = []
                if let optionsDict = json["options"] as? [String: String] {
                    // Sort options by key, normalizing to uppercase for consistent sorting
                    options = optionsDict.sorted { $0.key.uppercased() < $1.key.uppercased() }.map { $0.value }
                    print("✅ Parsed options dictionary: \(optionsDict)")
                } else if let optionsArray = json["options"] as? [String] {
                    // Remove letter prefixes (A), B), etc.) from options
                    options = optionsArray.map { option in
                        option.replacingOccurrences(of: "^[A-D]\\)\\s*", with: "", options: .regularExpression)
                    }
                    print("✅ Parsed options array: \(options)")
                } else {
                    print("❌ Invalid options format")
                    throw OpenAIError.parsingError("Invalid options format")
                }
                
                // Extract correct answer, handling both uppercase and lowercase
                let correctAnswer = (json["correct_answer"] as? String ?? "").uppercased()
                let correctAnswerLetter = correctAnswer.first?.description ?? "A"
                print("✅ Raw correct answer: \(correctAnswer)")
                print("✅ Correct answer letter: \(correctAnswerLetter)")
                
                // Calculate index (A=0, B=1, etc.)
                let index = Int(UnicodeScalar(correctAnswerLetter)?.value ?? 65) - 65
                guard index >= 0 && index < options.count else {
                    print("❌ Invalid correct answer index: \(index)")
                    throw OpenAIError.parsingError("Invalid correct answer index")
                }
                
                let correctAnswerText = options[index]
                print("✅ Parsed options: \(options)")
                print("✅ Correct answer text: \(correctAnswerText)")
                
                // Get explanation for the correct answer
                let explanation: String
                if let explanationsDict = json["explanations"] as? [String: String] {
                    // Try various formats of the correct answer key
                    let possibleKeys = [
                        correctAnswerLetter,                    // "A"
                        correctAnswerLetter.lowercased(),       // "a"
                        "\(correctAnswerLetter))",              // "A)"
                        correctAnswer,                          // Full answer
                        String(correctAnswer.prefix(1))         // First letter
                    ]
                    
                    explanation = possibleKeys.lazy
                        .compactMap { explanationsDict[$0] }
                        .first ?? "No explanation provided."
                    
                    print("✅ Found explanation for key: \(possibleKeys.first(where: { explanationsDict[$0] != nil } ) ?? "none")")
                } else {
                    explanation = "No explanation provided."
                }
                
                // Create the Question object
                return Question(
                    id: UUID().uuidString,
                    type: "multiple-choice",
                    subject: subject.lowercased(),
                    topic: "Generated",
                    skill: "Generated",
                    difficulty: difficulty,
                    question: Question.Content(
                        text: json["question"] as? String ?? "",
                        originalMath: nil,
                        mathOptions: options,
                        correctAnswers: [correctAnswerText]
                    ),
                    explanation: Question.Explanation(
                        text: explanation,
                        originalMath: nil
                    ),
                    images: []
                )
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                throw OpenAIError.parsingError("Failed to parse question data: \(error.localizedDescription)")
            }
        } catch {
            print("❌ API Request failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - OpenAI Response Models
private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
} 
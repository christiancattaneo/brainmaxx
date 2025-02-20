import Foundation
import SwiftUI

// MARK: - DataService
class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var subjects: [Subject] = []
    @Published var currentSubject: Subject?
    @Published var currentDifficulty: Difficulty = .medium
    @Published var loadingError: String?
    
    private init() {
        loadQuestions()
    }
    
    private func loadQuestions() {
        // Load sample data directly
        self.subjects = SampleData.subjects
        print("✅ Loaded \(SampleData.manifest.total_questions) sample questions")
        print("\n📊 Sample Data Stats:")
        
        // Print stats for Math subject
        if let mathSubject = subjects.first(where: { $0.id == "math" }) {
            let easyCount = mathSubject.getQuestions(forDifficulty: .easy).count
            let mediumCount = mathSubject.getQuestions(forDifficulty: .medium).count
            let hardCount = mathSubject.getQuestions(forDifficulty: .hard).count
            print("  📚 Math Questions:")
            print("    Easy: \(easyCount)")
            print("    Medium: \(mediumCount)")
            print("    Hard: \(hardCount)")
            print("    Total: \(easyCount + mediumCount + hardCount)")
        }
        
        // Print stats for English subject
        if let englishSubject = subjects.first(where: { $0.id == "english" }) {
            let easyCount = englishSubject.getQuestions(forDifficulty: .easy).count
            let mediumCount = englishSubject.getQuestions(forDifficulty: .medium).count
            let hardCount = englishSubject.getQuestions(forDifficulty: .hard).count
            print("  📖 English Questions:")
            print("    Easy: \(easyCount)")
            print("    Medium: \(mediumCount)")
            print("    Hard: \(hardCount)")
            print("    Total: \(easyCount + mediumCount + hardCount)")
        }
        
        print("  🎯 Total Subjects: \(subjects.count)")
        
        // Print sample question details for verification
        if let mathSubject = subjects.first(where: { $0.id == "math" }),
           let firstMathQuestion = mathSubject.getQuestions(forDifficulty: .medium).first {
            print("\n📝 Sample Math Question:")
            print("  ID: \(firstMathQuestion.id)")
            print("  Text: \(firstMathQuestion.question.displayText)")
            print("  Options: \(firstMathQuestion.question.displayOptions)")
            print("  Correct Answer: \(firstMathQuestion.question.correctAnswers)")
        }
    }
    
    func selectSubject(_ subject: Subject?) {
        currentSubject = subject
    }
    
    func setDifficulty(_ difficulty: Difficulty) {
        currentDifficulty = difficulty
    }
    
    func getQuestionsForCurrentSelection() -> [Question] {
        guard let subject = currentSubject else {
            print("❌ No subject selected")
            return []
        }
        
        print("\n🔍 Getting questions for \(subject.name) at \(currentDifficulty.displayName) difficulty")
        
        // Get questions for the selected difficulty
        var selectedQuestions = subject.getQuestions(forDifficulty: currentDifficulty)
        print("✅ Found \(selectedQuestions.count) questions at \(currentDifficulty.displayName) difficulty")
        
        // If we don't have enough questions at the exact difficulty
        if selectedQuestions.count < 10 {
            print("⚠️ Only found \(selectedQuestions.count) questions at \(currentDifficulty.displayName) difficulty. Including adjacent difficulties...")
            
            // Calculate how many more questions we need
            let remainingNeeded = 10 - selectedQuestions.count
            
            switch currentDifficulty {
            case .easy:
                // If easy, include some medium questions
                let mediumQuestions = subject.getQuestions(forDifficulty: .medium)
                selectedQuestions += mediumQuestions.shuffled().prefix(remainingNeeded)
                
            case .medium:
                // If medium, include a balanced mix of easy and hard
                let easyQuestions = subject.getQuestions(forDifficulty: .easy)
                let hardQuestions = subject.getQuestions(forDifficulty: .hard)
                
                // Try to get half from each
                let halfNeeded = remainingNeeded / 2
                let extraNeeded = remainingNeeded % 2
                
                // Add easy questions
                selectedQuestions += easyQuestions.shuffled().prefix(halfNeeded + extraNeeded)
                
                // Add hard questions
                selectedQuestions += hardQuestions.shuffled().prefix(halfNeeded)
                
            case .hard:
                // If hard, include some medium questions
                let mediumQuestions = subject.getQuestions(forDifficulty: .medium)
                selectedQuestions += mediumQuestions.shuffled().prefix(remainingNeeded)
            }
        }
        
        // Shuffle and ensure we have exactly 10 questions
        selectedQuestions.shuffle()
        let finalQuestions = Array(selectedQuestions.prefix(10))
        
        // Log the difficulty distribution of the final selection
        let difficultyDistribution = Dictionary(grouping: finalQuestions, by: { $0.difficulty })
            .mapValues { $0.count }
        
        print("\n📊 Final Question Distribution:")
        print("  Easy: \(difficultyDistribution[.easy] ?? 0)")
        print("  Medium: \(difficultyDistribution[.medium] ?? 0)")
        print("  Hard: \(difficultyDistribution[.hard] ?? 0)")
        
        return finalQuestions
    }
    
    func reloadQuestions() {
        loadQuestions()
    }
}

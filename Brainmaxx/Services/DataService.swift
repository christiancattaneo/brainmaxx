import Foundation
import SwiftUI

// MARK: - DataService
class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var subjects: [Subject] = []
    @Published var currentSubject: Subject?
    @Published var currentDifficulty: Difficulty = .medium
    @Published var loadingError: String?
    @Published var isGeneratingQuestions = false
    
    private let aiSubjectsKey = "ai_subjects"
    private let questionsKey = "cached_questions"
    private let cacheFileName = "questions_cache.json"
    
    private var cacheURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(cacheFileName)
    }
    
    private init() {
        loadQuestions()
    }
    
    private func loadQuestions() {
        // First try to load from cache
        if let cachedSubjects = loadFromCache() {
            self.subjects = cachedSubjects
            print("✅ Loaded \(subjects.reduce(0) { $0 + $1.totalQuestions }) questions from cache")
        } else {
            // If no cache, load sample data
            var allSubjects = SampleData.subjects
            
            // Load saved AI subjects
            if let savedSubjects = loadAISubjects() {
                allSubjects.append(contentsOf: savedSubjects)
            }
            
            self.subjects = allSubjects
            
            // Save to cache for next time
            saveToCache(subjects: allSubjects)
            print("✅ Created new cache with \(subjects.reduce(0) { $0 + $1.totalQuestions }) questions")
        }
        
        // Print stats
        print("\n📊 Questions Stats:")
        for subject in subjects {
            let easyCount = subject.getQuestions(forDifficulty: .easy).count
            let mediumCount = subject.getQuestions(forDifficulty: .medium).count
            let hardCount = subject.getQuestions(forDifficulty: .hard).count
            print("  📚 \(subject.name) Questions:")
            print("    Easy: \(easyCount)")
            print("    Medium: \(mediumCount)")
            print("    Hard: \(hardCount)")
            print("    Total: \(easyCount + mediumCount + hardCount)")
        }
    }
    
    private func loadFromCache() -> [Subject]? {
        do {
            let data = try Data(contentsOf: cacheURL)
            let subjects = try JSONDecoder().decode([Subject].self, from: data)
            print("✅ Successfully loaded cache from \(cacheFileName)")
            return subjects
        } catch {
            print("ℹ️ No cache found or failed to load: \(error)")
            return nil
        }
    }
    
    private func saveToCache(subjects: [Subject]) {
        do {
            let data = try JSONEncoder().encode(subjects)
            try data.write(to: cacheURL)
            print("✅ Successfully saved cache to \(cacheFileName)")
        } catch {
            print("❌ Failed to save cache: \(error)")
        }
    }
    
    func selectSubject(_ subject: Subject?) {
        if let subject = subject {
            print("📊 DataService: Setting subject to \(subject.name)")
        } else {
            print("📊 DataService: Clearing selected subject")
        }
        currentSubject = subject
    }
    
    func setDifficulty(_ difficulty: Difficulty) {
        print("📊 DataService: Setting difficulty to \(difficulty.displayName)")
        currentDifficulty = difficulty
    }
    
    func getQuestionsForCurrentSelection() async -> [Question] {
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
            print("⚠️ Only found \(selectedQuestions.count) questions at \(currentDifficulty.displayName) difficulty.")
            
            // If we have no questions and it's hard difficulty English, try to generate some
            if selectedQuestions.isEmpty && currentDifficulty == .hard && subject.name.lowercased() == "english" {
                print("🤖 Attempting to generate a question using OpenAI...")
                print("📍 Current state - Subject: \(subject.name), Difficulty: \(currentDifficulty.displayName), Questions: \(selectedQuestions.count)")
                
                // Update UI state on main thread
                await MainActor.run {
                    isGeneratingQuestions = true
                    loadingError = nil
                }
                
                do {
                    if let generatedQuestion = try await OpenAIService.shared.generateQuestion(
                        subject: subject.name,
                        difficulty: currentDifficulty
                    ) {
                        selectedQuestions.append(generatedQuestion)
                        print("✅ Successfully generated a question. New count: \(selectedQuestions.count)")
                    } else {
                        print("⚠️ OpenAI returned nil for generated question")
                        await MainActor.run {
                            loadingError = "Failed to generate question. Please try again."
                        }
                    }
                } catch OpenAIService.OpenAIError.missingAPIKey {
                    await MainActor.run {
                        loadingError = "OpenAI API key is missing. Please add your API key to Configuration.plist"
                    }
                } catch OpenAIService.OpenAIError.invalidAPIKey {
                    await MainActor.run {
                        loadingError = "Invalid API key. Please update your API key in Configuration.plist"
                    }
                } catch {
                    print("❌ Failed to generate question: \(error.localizedDescription)")
                    print("🔍 Error details: \(error)")
                    await MainActor.run {
                        loadingError = "Failed to connect to OpenAI. Please check your internet connection and try again."
                    }
                }
                
                // Update UI state on main thread
                await MainActor.run {
                    isGeneratingQuestions = false
                }
            } else {
                print("Including adjacent difficulties...")
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
    
    // MARK: - AI Subjects
    
    private func loadAISubjects() -> [Subject]? {
        guard let data = UserDefaults.standard.data(forKey: aiSubjectsKey) else {
            return nil
        }
        
        do {
            let subjects = try JSONDecoder().decode([Subject].self, from: data)
            print("✅ Loaded \(subjects.count) AI subjects from storage")
            return subjects
        } catch {
            print("❌ Failed to load AI subjects: \(error)")
            return nil
        }
    }
    
    func addOrUpdateAISubject(_ subject: Subject) {
        // Load existing AI subjects
        var aiSubjects = loadAISubjects() ?? []
        
        // Create the AI subject with the custom icon
        var aiSubject = Subject(
            id: subject.id,
            name: subject.name,
            description: subject.description,
            iconName: subject.iconName,  // Preserve the custom icon
            topics: ["Generated": []]    // Initialize with empty topics
        )
        
        // Update the topics using the public method
        aiSubject.updateTopics(subject.getTopics())
        
        // Remove existing subject with same ID if exists
        aiSubjects.removeAll { $0.id == subject.id }
        
        // Add new subject
        aiSubjects.append(aiSubject)
        
        // Save updated list to UserDefaults
        do {
            let data = try JSONEncoder().encode(aiSubjects)
            UserDefaults.standard.set(data, forKey: aiSubjectsKey)
            print("✅ Saved \(aiSubjects.count) AI subjects to storage")
        } catch {
            print("❌ Failed to save AI subjects: \(error)")
        }
        
        // Update current subjects list
        DispatchQueue.main.async {
            self.subjects.removeAll { $0.id == subject.id }
            self.subjects.append(aiSubject)
            // Update cache with new data
            self.saveToCache(subjects: self.subjects)
        }
        
        print("✅ Added/Updated AI subject: \(subject.name) with icon: \(subject.iconName)")
    }
}

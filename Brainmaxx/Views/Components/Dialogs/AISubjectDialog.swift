import SwiftUI

struct AISubjectDialog: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSubject: String
    let difficulty: Difficulty
    @Binding var navigationPath: NavigationPath
    @State private var subjectInput = ""
    @State private var selectedSymbol = "sparkles.rectangle.stack"
    @State private var showCurriculumGeneration = false
    @FocusState private var isInputFocused: Bool
    
    // Common subject symbols
    private let subjectSymbols = [
        "sparkles.rectangle.stack",  // Default AI/Learning
        "book.fill",              // General education
        "function",               // Math
        "textformat",             // Language
        "atom",                   // Science
        "globe.americas.fill",    // Geography
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: selectedSymbol)
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("What would you like to learn?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("Enter any subject and create a personalized curriculum!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)
            
            // Subject Input
            TextField("e.g. Quantum Physics, World History, Poetry...", text: $subjectInput)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .onSubmit {
                    if !subjectInput.isEmpty {
                        createSubject()
                    }
                }
                .padding(.horizontal)
            
            // Icon Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(subjectSymbols, id: \.self) { symbol in
                        Button {
                            selectedSymbol = symbol
                        } label: {
                            Image(systemName: symbol)
                                .font(.system(size: 24))
                                .foregroundColor(selectedSymbol == symbol ? .white : .blue)
                                .frame(width: 44, height: 44)
                                .background(
                                    selectedSymbol == symbol ? 
                                        Color.blue : 
                                        Color.blue.opacity(0.1)
                                )
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Generate Button
            Button {
                createSubject()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Questions")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(subjectInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal)
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            isInputFocused = true
        }
        .fullScreenCover(isPresented: $showCurriculumGeneration) {
            CurriculumGenerationView(
                subject: Subject.createAISubject(
                    id: "ai-\(subjectInput.lowercased().replacingOccurrences(of: " ", with: "-"))",
                    name: subjectInput,
                    description: "AI-generated \(subjectInput) curriculum",
                    iconName: selectedSymbol
                ),
                difficulty: difficulty,
                navigationPath: $navigationPath
            )
        }
    }
    
    private func createSubject() {
        let trimmedInput = subjectInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        showCurriculumGeneration = true
    }
}

#Preview {
    NavigationStack {
        AISubjectDialog(
            selectedSubject: .constant(""),
            difficulty: .medium,
            navigationPath: .constant(NavigationPath())
        )
    }
} 
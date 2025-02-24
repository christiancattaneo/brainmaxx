import SwiftUI

struct SubjectCard: View {
    let subject: Subject
    let difficulty: Difficulty
    
    private var isAISection: Bool {
        subject.id == "ai"
    }
    
    private var cardGradient: LinearGradient {
        if isAISection {
            return LinearGradient(
                colors: [
                    Color.blue.opacity(0.7),
                    Color.purple.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var iconBackground: Color {
        if isAISection {
            return .white.opacity(0.2)
        } else {
            return Color.blue.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        isAISection ? .white : .primary
    }
    
    private var secondaryTextColor: Color {
        isAISection ? .white.opacity(0.8) : .secondary
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: subject.iconName)
                .font(.system(size: 32))
                .foregroundColor(isAISection ? .white : .blue)
                .frame(width: 56, height: 56)
                .background(iconBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isAISection ? .white.opacity(0.3) : .clear, lineWidth: 1)
                )
                .padding(.top, 8)
            
            // Title
            Text(subject.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
            
            // Description
            Text(subject.description)
                .font(.system(size: 14))
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            
            // Question count or AI badge
            Group {
                if isAISection {
                    Label("AI Generated", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                } else {
                    Text("\(subject.getQuestions(forDifficulty: difficulty).count) questions")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }
            }
            .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardGradient)
                .shadow(radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isAISection ? .white.opacity(0.2) : Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .overlay(
            Group {
                if isAISection {
                    // Animated sparkles effect
                    SparklesOverlay()
                }
            }
        )
    }
}

#Preview {
    SubjectCard(
        subject: Subject.createAISubject(
            id: "preview",
            name: "Preview Subject",
            description: "A preview description that might be a bit longer to test multiline",
            iconName: "sparkles.rectangle.stack"
        ),
        difficulty: .medium
    )
    .frame(width: 200)
    .padding()
} 
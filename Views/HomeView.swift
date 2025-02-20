import SwiftUI

struct HomeView: View {
    @StateObject private var dataService = DataService.shared
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) {
                // Title and Description
                HStack(spacing: 16) {
                    Group {
                        if let image = UIImage(named: "app-logo") {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        } else if let bundleImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "newlogo", ofType: "png") ?? "") {
                            Image(uiImage: bundleImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "brain.head.profile")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                    
                    Text("Brainmaxx")
                        .font(.system(size: 36, weight: .bold))
                }
                .padding(.top, 16)
                
                Text("Choose a subject to begin your SAT prep journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Difficulty Selector
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.displayName)
                            .tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedDifficulty) { _, newDifficulty in
                    dataService.setDifficulty(newDifficulty)
                }
                
                // Subjects Grid or Error
                if let error = dataService.loadingError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            dataService.reloadQuestions()
                        } label: {
                            Label("Reload", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if dataService.subjects.isEmpty {
                    // Loading state
                    ProgressView("Loading subjects...")
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(dataService.subjects) { subject in
                                NavigationLink {
                                    FeedView(
                                        navigationPath: $navigationPath,
                                        subject: subject,
                                        difficulty: selectedDifficulty
                                    )
                                } label: {
                                    SubjectCard(subject: subject, difficulty: selectedDifficulty)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
                
                Spacer()
                
                // Question count
                if !dataService.subjects.isEmpty {
                    Text("\(dataService.subjects.reduce(0) { $0 + $1.getQuestions(forDifficulty: selectedDifficulty).count }) questions at \(selectedDifficulty.displayName) difficulty")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .returnToHome)) { _ in
                print("🏠 HomeView: Received returnToHome notification")
                // Reset state in the correct order
                withAnimation {
                    // First reset the data service
                    dataService.selectSubject(nil)
                    // Then reset difficulty
                    selectedDifficulty = .medium
                    // Finally clear navigation
                    navigationPath = NavigationPath()
                }
            }
        }
    }
}

struct SubjectCard: View {
    let subject: Subject
    let difficulty: Difficulty
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: subject.iconName)
                .font(.system(size: 32))
                .foregroundColor(.blue)
                .frame(width: 56, height: 56)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
                .padding(.top, 8)
            
            // Title
            Text(subject.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Description
            Text(subject.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            
            // Question count for selected difficulty
            Text("\(subject.getQuestions(forDifficulty: difficulty).count) questions")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView()
} 

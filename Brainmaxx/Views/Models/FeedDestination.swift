import SwiftUI

struct FeedDestination: Hashable {
    let subject: Subject
    let difficulty: Difficulty
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(subject.id)
        hasher.combine(difficulty)
    }
    
    static func == (lhs: FeedDestination, rhs: FeedDestination) -> Bool {
        lhs.subject.id == rhs.subject.id && lhs.difficulty == rhs.difficulty
    }
} 
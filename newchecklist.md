# FeedView Improvements Checklist

## 1. Manual Scrolling Implementation
- [ ] Remove auto-scroll after answering questions
- [ ] Enable manual scrolling in ScrollView
- [ ] Add visual indicator that user can scroll to next question
- [ ] Implement scroll lock until current question is answered correctly
- [ ] Add smooth animation when manually scrolling

## 2. Upward Scrolling Navigation ✅
- [x] Reverse question order in the feed (newest at bottom)
- [x] Update scroll gesture to detect upward swipes
- [x] Adjust scroll anchors for upward navigation
- [x] Add visual indicator for scroll direction (up arrow)
- [x] Implement smooth transition animations

## 3. Progress Header Implementation (Next Priority)
- [ ] Create new ProgressHeader component
  - [ ] Design compact layout for:
    - [ ] Current points (animated counter)
    - [ ] Estimated IQ score
    - [ ] Projected salary
  - [ ] Add progress animations
  - [ ] Implement sticky positioning
- [ ] Implement real-time updates:
  - [ ] Calculate running totals
  - [ ] Smooth value transitions
  - [ ] Visual feedback for increases
- [ ] Style and layout:
  - [ ] Glassmorphism effect
  - [ ] Compact yet readable design
  - [ ] Responsive layout
- [ ] Add persistence between sessions

## 4. Question Set Expansion
- [ ] Update SampleData.swift to include 10 questions per difficulty level
- [ ] Add more Math questions:
  - [ ] 10 Easy algebra/geometry questions
  - [ ] 10 Medium algebra/geometry questions
  - [ ] 10 Hard algebra/geometry questions
- [ ] Add more English questions:
  - [ ] 10 Easy reading/grammar questions
  - [ ] 10 Medium reading/grammar questions
  - [ ] 10 Hard reading/grammar questions
- [ ] Ensure proper difficulty distribution
- [ ] Add variety in question types and topics

## 5. OpenAI Integration for Question Simplification
- [ ] Add OpenAI API configuration
  - [ ] Create OpenAIService
  - [ ] Add API key configuration
  - [ ] Implement error handling
- [ ] Create question simplification prompt template
- [ ] Implement question simplification logic:
  - [ ] Track wrong attempts
  - [ ] Generate simplified versions
  - [ ] Handle math notation in simplified versions
- [ ] Add UI for simplified questions:
  - [ ] Show simplified version after wrong answer
  - [ ] Add toggle between original/simplified
  - [ ] Include visual indicator for simplified questions

## 6. UI/UX Improvements
- [x] Add scroll indicator animation
- [ ] Add haptic feedback for:
  - [ ] Correct answers
  - [ ] Wrong answers
  - [ ] Scroll transitions
- [ ] Improve error handling
- [ ] Add session recovery
- [ ] Improve accessibility

## 7. Performance Optimization
- [ ] Implement lazy loading
- [ ] Optimize animations
- [ ] Cache simplified questions
- [ ] Minimize API calls
- [ ] Add request debouncing

## 8. Testing
- [ ] Unit tests for scoring
- [ ] Integration tests for OpenAI
- [ ] UI tests for scrolling
- [ ] Performance testing
- [ ] Edge case handling

## Current Status
✅ Completed:
- Upward scrolling navigation
- Basic scroll indicator
- Question transition animations

🔄 In Progress:
- Progress header implementation (Next priority)

⏭️ Next Steps:
1. Implement progress header
2. Add haptic feedback
3. Expand question set
4. Integrate OpenAI

## Notes
- Each feature should be tested thoroughly before moving to the next
- Consider adding loading states between questions
- Maintain smooth animations throughout
- Keep performance in mind with real-time calculations 
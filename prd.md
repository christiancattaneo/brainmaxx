Below is a draft of a Technical Product Requirements Document (PRD) for **Brainmaxx**, a gamified SAT-prep app. It covers the scope, user flows, system architecture, feature requirements, and discussion on backend options. Please review and let me know if anything needs clarification or adjustment—and feel free to answer the open questions at the end!

---

## 1. Overview

**Product Name:** Brainmaxx  
**Objective:** Provide an engaging, gamified SAT-prep experience via short-form videos and interactive quizzes.  

### 1.1 Goals and Key Features

1. **Video Feed**: Users scroll through educational videos (vertical feed) related to SAT subjects.  
2. **Interactive Q&A**: Each video has multiple-choice questions shown underneath it.  
3. **Progress Tracking**: A points or progress bar is shown on the right side as users answer questions and scroll upward.  
4. **Final Results**: Upon reaching the top of the feed, users get a fun, approximate readout of:
   - Estimated SAT score  
   - Estimated IQ score  
   - Estimated annual salary (based on hypothetical correlation)  
5. **Subject & Difficulty Selection**: Users can choose from multiple subjects (e.g., History, Literature, Chemistry, Languages) and difficulty levels (Low, Medium, High).  
6. **No Sign-in**: MVP does not require user authentication or personalized profiles.

---

## 2. User Stories & Flows

### 2.1 High-Level User Story

> **As a user** interested in SAT preparation, **I want** to scroll through short educational videos and answer related multiple-choice questions so that **I can** learn in a fun, gamified way and see my estimated SAT score at the end.

### 2.2 Detailed User Flow

1. **App Launch**  
   - User opens the Brainmaxx app (built in SwiftUI).  
   - Splash screen or landing screen with minimal branding.  
2. **Subject & Difficulty Selection**  
   - User chooses a subject (History, Literature, Chemistry, or Languages) and a difficulty level (Low, Medium, High).  
   - The app loads an appropriate set of videos and questions.  
3. **Video Feed**  
   - The user sees the first video at the bottom of the screen (or center).  
   - Under the video, a multiple-choice question (with 3-5 possible answers) is displayed.  
4. **Answering Questions**  
   - As the user selects an answer, the user’s progress (points) is updated in real time.  
   - Correct answers might yield more points (exact scoring logic can be tuned later).  
5. **Scrolling Behavior**  
   - The user swipes/scrolls upward to move to the next video+question.  
   - A visual progress bar on the right side moves upward with each question completed or video viewed.  
6. **Completion & Score Calculation**  
   - Once the user reaches the top of the video list (end of feed), the app displays an overlay with the user’s:  
     - Estimated SAT score (simple formula)  
     - Estimated IQ score (for fun)  
     - Estimated annual salary (for fun)  
7. **Optional Restart or Subject Change**  
   - The user can tap a button to go back to the home screen to either retake or select a new subject/difficulty.

---

## 3. Functional Requirements

1. **Video Player**  
   - Smooth vertical scroll-based UI in SwiftUI.  
   - Videos can be embedded natively (AVKit) or hosted externally (YouTube/Vimeo embed) depending on content ownership.  
2. **Multiple-Choice Questions**  
   - Display question text, 3–5 options, and track user selection.  
   - Provide immediate feedback (optional) or accumulate results to show at the end.  
3. **Progress Bar**  
   - Clearly visible on the right side of the screen.  
   - Fills or extends upward as users progress.  
4. **End-of-Feed Results**  
   - Show final readout (SAT, IQ, Salary).  
   - Possibly store or cache ephemeral session data for future expansions.  
5. **Subject & Difficulty Filtering**  
   - Adjust which videos + questions are loaded.  
6. **No Authentication**  
   - No need for sign-in screens or secure backends.  
7. **Points & Scoring Mechanism**  
   - Simple points calculation; can be expanded in the future.  

---

## 4. Non-Functional Requirements

1. **Performance**  
   - The video feed should load quickly (prefetch next video if possible).  
   - SwiftUI transitions should be smooth (60 FPS if feasible).  
2. **Scalability**  
   - For MVP, minimal concurrency is required (likely single user at a time for a demo).  
   - Future expansions might require a more robust backend.  
3. **Maintainability**  
   - Clear code structure in SwiftUI for feed, quiz, progress.  
   - Simple backend or local data store for quick iteration.  
4. **Reliability**  
   - Offline behavior: If the videos are hosted online, the app will require a network connection.  
   - The Q&A logic should handle partial connectivity gracefully.

---

## 5. Technical Architecture

### 5.1 Frontend (iOS)

- **Language/Framework**: Swift + SwiftUI
- **Components**:
  - **FeedView**: 
    - Handles vertical scrolling of the videos.  
    - Renders a `VideoCard` + `QuestionView`.  
  - **QuestionView**: 
    - Displays MCQ text and answers.  
    - Triggers actions to update user’s progress state.  
  - **ProgressBarView**: 
    - Positioned on the right edge.  
    - Animates upward as user completes questions.  
  - **ResultsView**: 
    - Presented after user completes the feed.  
    - Displays SAT, IQ, salary.  
  - **HomeView**: 
    - Lets user pick subject/difficulty and start the feed.

### 5.2 Backend Options Discussion

**Requirement**: Minimal complexity, read operations for videos/questions, no user accounts or real-time concurrency.  

1. **Local Database (Core Data, SQLite, or JSON file)**  
   - **Pros**: Easiest to bundle question+video metadata directly into the app; no network needed for a demo.  
   - **Cons**: Limited if you want to update content over the air.  

2. **Simple Hosted Database (PostgreSQL on a small server)**  
   - **Pros**: Easy to scale in future if you decide to add more data or user profiles.  
   - **Cons**: Requires some DevOps overhead (server setup), not strictly necessary for an MVP with no login.  

3. **Firebase (Firestore)**  
   - **Pros**: Quick integration in Swift, easy for future user authentication if needed.  
   - **Cons**: Overkill if you just have a static dataset for a short MVP.

4. **Serverless / GitHub Pages (for static JSON)**  
   - **Pros**: Ultra-simple distribution, store JSON files for questions, free/low-cost.  
   - **Cons**: Harder to secure if you want updates (but we have no user data anyway).  

### **Recommended Approach for MVP**  
- **Local Storage** (JSON or Core Data) for the question bank, possibly local video files if the video set is small. This eliminates dependency on network for a demo, ensuring maximum reliability.  
- If you have many large videos, host them on a simple CDN or a public cloud storage (e.g., AWS S3, Firebase Storage) and reference the URLs in your local data.  

---

## 6. Data Model

**Example JSON structure** (subject to refinement):

```json
{
  "subject": "History",
  "difficulty": "Medium",
  "videos": [
    {
      "videoId": "history-01",
      "videoURL": "https://path.to/history01.mp4",
      "question": {
        "text": "Who was the first President of the United States?",
        "options": ["George Washington", "Abraham Lincoln", "Thomas Jefferson"],
        "correctOptionIndex": 0
      }
    },
    {
      "videoId": "history-02",
      "videoURL": "https://path.to/history02.mp4",
      "question": {
        "text": "What year did WWII end?",
        "options": ["1942", "1945", "1948"],
        "correctOptionIndex": 1
      }
    }
  ]
}
```

- **Subject**: String indicating subject category (History, Chemistry, etc.).  
- **Difficulty**: String or integer to filter (Low, Medium, High).  
- **Videos**: Array of objects with:  
  - `videoId` (String)  
  - `videoURL` (String)  
  - `question` object: `text`, `options` (array), `correctOptionIndex` (int).  

---

## 7. Scoring & Gamification

- **Points**: 
  - Increment the user’s total for each correct answer.  
  - Could be a simple `+1` for correct, `+0` for incorrect, or more elaborate weighting by difficulty.  

- **Final Calculation**:  
  - An approximate SAT score can be derived from the total points *some weighting formula*.  
  - IQ and annual salary can be arbitrarily or humorously derived from the total correct answers or percentage correct.  

*(Exact formulas to be implemented by the dev team later.)*

---

## 8. Timeline & Milestones

1. **Week 1**:  
   - Create SwiftUI project structure (HomeView, FeedView, ResultsView).  
   - Implement local JSON parsing for Q&A data.  
2. **Week 2**:  
   - Integrate simple video player in SwiftUI.  
   - Connect Q&A logic with progress bar.  
3. **Week 3**:  
   - Implement end-of-feed results overlay.  
   - Add subject/difficulty selection screens.  
4. **Week 4**:  
   - Polish UI/UX, add animations to progress bar and transitions.  
   - Add final “score” calculation.  

---

## 9. Potential Risks & Mitigations

1. **Video Hosting**  
   - Risk: large file sizes or slow streaming.  
   - Mitigation: compress videos or host them in a CDN with good bandwidth.  
2. **Data Growth**  
   - Risk: a large question bank might be cumbersome to store locally.  
   - Mitigation: consider a lightweight backend or a serverless JSON host if it gets too large.  
3. **Scoring Accuracy**  
   - Risk: user might be confused if the “estimated” SAT score isn’t explained.  
   - Mitigation: clarify the formula is approximate and purely for fun.

---

## 10. Testing & QA

1. **Unit Tests**  
   - Validate question retrieval and correctness checking.  
2. **UI Tests**  
   - Ensure SwiftUI feed scrolls smoothly.  
   - Confirm that the progress bar updates correctly.  
3. **Integration Tests**  
   - If using local JSON, test that the data loads and videos play without crashing.  
4. **User Acceptance Testing**  
   - Demo to small user group or internal testers for usability feedback.

---

## 11. Open Questions

1. **Video Source**: 
   - Are you planning to host videos locally within the app bundle, or do you have an external video hosting service in mind?  
2. **Content Volume**: 
   - Approximately how many total videos/questions do you foresee for the MVP?  
3. **Question Bank Expansion**: 
   - Do you plan to frequently update the question bank, or is it a static set for the MVP?  
4. **Scoring & Feedback**: 
   - Should the user see correct/incorrect feedback immediately or only at the end of the feed?  
5. **Exact Score Formulas**: 
   - How do you plan to derive the SAT, IQ, and annual salary metrics (roughly)?  

---

### Next Steps

- Finalize the approach for video hosting and data storage.  
- Confirm the data model and how you’d like to parse it in SwiftUI.  
- Address any open questions above.  
- Begin implementation per the proposed timeline.

---

**Please let me know if you have any preferences or if additional details are needed on any sections**—particularly around the data model, scoring logic, or the hosting approach for videos.
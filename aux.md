Team: JaPanama
Members:
- Saki Hamoto
- Chihiro Iwata
- Kelvin Kung
Selected track: 2 (Hack connected everywhere)

|Criteria|Percentage|description|
|---|---|---|
|Impact|(25%)|Social value and user impact|
|Innovation|(20%)|Creativity and originality|
|Feasibility|(20%)|Practicality and implementation potential|
|Technical Quality|(20%)|Technical excellence and development quality|
|Presentation|(15%)|Storytelling and communication

# First day (sept 25)

Topic selection
options
- Cooking helper
- shared study with friends
- foreign language exchage with tutor/companion mate
- english education helper for japanese students
- body posture system
- information sorting for AI
- Cultural helper app
  - social manners guide
- tool sorting for engineer?

Selected idea: **Cultural helper app**

```
Act as an expert Full-Stack Mobile & Web Developer, UI/UX Designer, and Systems Architect. Your task is to build a fully functional, production-ready MVP of a mobile-first cultural learning Progressive Web App (PWA) with a companion Web Desktop presentation mode. The entire app must be optimized for deployment on **GitHub Pages** (pure client-side: HTML5, Tailwind CSS via CDN, Alpine.js or Vanilla JS, and LocalStorage).

### 📱 Core Architecture & Constraints
1. **Mobile-First Design**: The default viewport must mimic a sleek mobile device frame (max-width: 430px) centered on desktop screens, or scale fluidly to mobile screens.
2. **Local-Only Data & Sync Simulation**: 
   - All user profiles, flashcards, Q&A posts, and settings must be stored locally using `localStorage`.
   - Include a "Desktop Presentation Mode" toggle. When activated, it opens a split-screen or secondary view that pulls data dynamically from the mobile instance via `BroadcastChannel` or `localStorage` events to mirror the session live, destroying the session data upon closing.
3. **Mock Data**: Pre-populate robust JSON datasets for at least 3 countries (e.g., Japan, Malaysia, Panama, Korea, ) with scenarios, images (using Unsplash placeholders), and localized flashcards to allow immediate end-to-end testing.

---

### 🖥️ Screen-by-Screen Specifications

#### 1. Default Screen (Home / Flashcards)
- **Country Selector**: A dropdown or horizontal scrollable pill selector at the top (e.g., Japan, Malaysia, Panama, Korea).
- **Flashcard Deck**: Displays 5 to 10 interactive flashcards based on the selected country, featuring basic cultural info and common phrases (e.g., Hello, Thank you, Excuse me).
- **Card Design**: Each card must feature an evocative Unsplash image, the foreign phrase, pronunciation guide, and English translation on the flip side or clear bottom text.

#### 2. Screen 1: Scenarios Grid
- **Grid Layout**: A responsive grid showing common cultural situations (e.g., *At School*, *During Commuting*, *Convenience Store*, *Asking Directions*, *Sakura Season*).
- **Interaction**: Clicking a scenario filters or dynamically customizes the Default Screen's flashcard deck to match that specific context, updating local state.

#### 3. Screen 2: Community Q&A
- **Platform**: A minimalist forum feed where users can post culture-related questions.
- **Auto-AI Fallback**: If a user submits a question, check if local mock data has an answer. If unassigned, simulate an instant "Auto-AI Answer" generator using pre-configured contextual templates to ensure zero empty states during testing.

#### 4. Screen 3: Personalization & Profile Builder
- **Questionnaire**: A multi-step or card-based interactive questionnaire gathering user preferences (e.g., proficiency level, travel intent, cultural interests).
- **Dynamic Tagging**: Based on answers, build a local user persona object stored in `localStorage` that applies keyword tags to tailor and rank future flashcard and Q&A visibility.

---

### 💻 Companion Web Desktop Presentation Mode
- Add a floating button: "Launch Desktop Presentation View".
- Opens a wide-screen dashboard layout that reads live data updates from the mobile app state, visualizing user progress, active country stats, and Q&A logs in real-time. Include a "Destroy Session" button that wipes the presentation view data cleanly.

### 🛠️ Deliverables
Provide the complete, single-file or cleanly modularized source code (`index.html` with embedded Tailwind CSS and JavaScript) so it can be committed directly to a GitHub repository and instantly hosted via GitHub Pages without complex build steps.
```
advances: mobile app done with gemini and antigravity 

```
Act as an expert full-stack web developer and GitHub Pages deployment specialist. I want to build a complete, production-ready, fully responsive web application hosted on GitHub Pages that supports up to 100 users, auto-translates to the user's browser language, and includes a persistent chat interface that saves messages directly to a repository file named `messages.json`.

Please generate all the necessary files with clean, modern code, complete instructions, and setup details. Here are the core specifications:

1. ARCHITECTURE & REPOSITORY STRUCTURE:
Provide the full code for a multi-file setup:
- index.html: The responsive frontend layout containing the chat interface, header, and language localization logic.
- style.css: Modern, clean CSS using CSS variables and Flexbox/Grid designed to resize seamlessly across mobile phones, tablets, and desktop computers.
- app.js: The frontend logic handling dynamic UI translation based on navigator.language, fetching messages.json, rendering chats, and sending messages.
- messages.json: A starter JSON file containing a few initial sample message objects (e.g., [{"user": "System", "text": "Welcome to the chat!"}]).
- README.md: Clear, step-by-step instructions on how to enable GitHub Pages in the repository settings.

2. CHAT STORAGE WORKFLOW (SAVING TO GITHUB):
Since GitHub Pages is static and cannot write files natively without a backend, design the solution using one of two clean approaches (explain which one you implement):
- Approach A (GitHub Action Webhook / Serverless Proxy): A lightweight configuration where frontend chat submissions trigger a secure backend action or webhook that commits the new message directly into `messages.json` in the GitHub repo.

Provide the exact configuration code or scripts required to make this functional.

3. RESPONSIVE DESIGN & MOBILE FRIENDLINESS:
- The UI must look exceptional and function smoothly on small mobile screens as well as large desktop displays (using CSS media queries and relative units).

4. BROWSER LANGUAGE LOCALIZATION:
- Automatically check navigator.language (or navigator.userLanguage).
- Implement a lightweight translation dictionary supporting at least English (default), Spanish, and French, falling back gracefully for other languages.

Provide all the code blocks clearly labeled by filename so I can copy, paste, and push them straight to my GitHub repository.
```

## Website readme information 
Global GitHub Chat Application

A complete, production-ready, fully responsive web application hosted on GitHub Pages that supports up to 100 users, features automatic browser language localization (English, Spanish, French), and persists messages directly to messages.json using the GitHub REST API workflow.

Repository Setup Instructions

Web Files: Upload or push the following files to the main branch:

- [index.html](./index.html)
- [style.css](./style.css)
- [app.js](./app.js)
- [messages.json](./messages.json)

# AI Taro Oppa - Tarot Reading Flutter Web App

### Overview
AI Taro Oppa (타로오빠) is a multi-language tarot card reading application built with Flutter Web and a FastAPI backend. The app provides personalized tarot readings through 5 unique international characters powered by OpenAI GPT-4o-mini. The project's vision is to offer an engaging and personalized digital tarot experience with a focus on diverse character interactions and multi-language support.

### Recent Changes (October 2025)
- **Card Layout Optimization**: Adjusted card selection fan layout with flatter angle (maxAngle: 45°) and lower vertical position (0.8 of viewport height) for better visual balance and accessibility
- **Dynamic Card Count**: Implemented fortune category-specific card counts (3-5 cards) - General/Marriage use 5 cards, Wealth/Career/Health/Relationship use 4 cards, Love/Education use 3 cards
- **Enhanced GPT Responses**: Upgraded prompts to include extended greetings (200-300 chars) with character introduction and welcome, detailed card imagery descriptions using visual_elements data, reversed card explanations when applicable, and increased minimum response length to 1200+ characters
- **Ad Page UX Refinement**: Independent countdown and loading states with clear visual indicators (spinner during loading, skip button after countdown completion)
- **Deployment Optimization (Oct 8)**: Configured backend to use absolute paths with REPL_HOME for deployment compatibility; fixed autoscale port configuration by adding --port 5000 to uvicorn run command to match .replit localPort setting
- **Markdown Rendering & UI Enhancement (Oct 8)**: Added flutter_markdown package to render GPT responses with text formatting (bold, italic); expanded fortune categories to 8 items (added Relationship/인간관계운); redesigned category selection page with 4x2 grid layout for improved organization and visual clarity
- **Character Image System (Oct 8)**: Integrated 33 character images across 5 characters (루시앙 9개, 린화 8개, 이졸데 4개, 청운 5개, 팀블 7개) with random selection and duplicate prevention system. Images display on CharacterSelectPage, FortuneCategoryPage, QuestionPage, and CardSelectionPage with transparent background CircleAvatars. ResultPage shows up to 3 unique images: one above GPT response (200x200) and two interspersed within the reading text (150x150). Implemented usedImages tracking across entire navigation flow to prevent image repetition within a single session.

### User Preferences
- **Communication Style**: I prefer simple language and detailed explanations.
- **Workflow Preferences**: I want iterative development.
- **Interaction Preferences**: Ask before making major changes.
- **Coding Style Preferences**: I prefer clean, readable code with good documentation.
- **General Working Preferences**: I prefer that all markdown headers (##, ###) are removed from GPT responses, and structured labels (e.g., "첫 번째 카드:", "종합 해석:") are eliminated. I prefer a flowing narrative style matching each character's personality. When optimizing loading, the GPT API should be called *during* ad viewing for parallel processing. Results should be pre-loaded before the ad countdown ends, allowing instant navigation when skip is pressed. For conversation continuity, the full conversation history must be maintained, leading to context-aware AI responses that remember previous exchanges.

### System Architecture
The application uses a unified server design where a single FastAPI server on port 5000 serves both the API endpoint (`/api/tarot`) and the static Flutter web application files. This eliminates CORS issues and ensures seamless operation across development and production environments. The frontend is built with Flutter Web, providing a responsive and interactive user interface. The backend uses FastAPI for efficient request handling and integration with the OpenAI GPT-4o-mini model.

**Key Features:**
- **5 International Characters**: Lucien Voss, Isolde Hartmann, Cheongun Seonin, Linhua, and Thimble Oakroot, each with distinct personalities and speaking styles.
- **Multi-language Support**: Korean, English, Chinese, and Thai.
- **8 Fortune Categories**: General, Wealth, Love, Marriage, Career, Education, Health, and Relationships.
- **User Flow**: Includes language selection, character selection, fortune category selection, question input, 3-5 card selection from 16 displayed cards, a 3D animated card reveal, an advertisement gate, AI-generated tarot reading with markdown formatting, and interactive follow-up questions with ad integration.
- **UI/UX Decisions**:
    - **Fortune Category Selection Page**: 4x2 grid layout using `GridView.builder` for 8 categories, featuring gradient backgrounds, soft borders, and subtle shadows with responsive spacing.
    - **Card Selection Page**: Fan-shaped layout for 16 cards, with hover and selection effects (lift, color change, thicker border, enhanced shadow) animated using `MouseRegion` and `AnimatedContainer`.
    - **Card Reveal Animation**: Sequential 3D flip animation (`Transform.rotateY`) for cards, displaying card name, orientation badge, keywords, and detailed meaning. Counter-rotation logic keeps text upright during the flip.
    - **Optimized Loading**: GPT API calls are made during ad display to pre-load results, enabling instant navigation upon ad skip.
    - **Natural Conversation Mode**: GPT responses are formatted as flowing narratives without markdown headers or structured labels, tailored to each character's personality.
    - **Interactive Follow-up System**: Features a "추가 질문하기" (Ask Additional Questions) button that transitions to "광고보고 추가질문하기" (Watch Ad to Ask Additional Questions), with a chat input field and full conversation history maintained for context-aware AI responses.

**Technical Implementations:**
- **Frontend (Flutter)**: Utilizes `TarotCard`, `SelectedCard`, `FortuneCategory` models, and dedicated pages for each step of the user flow (`FortuneCategoryPage`, `QuestionPage`, `CardSelectionPage`, `CardRevealPage`, `AdPlaceholderPage`, `ResultPage`). JSON assets are loaded for tarot card data, and random shuffling with orientation assignment is implemented. Uses `flutter_markdown` package to render GPT responses with text formatting (bold, italic) via `MarkdownBody` widget.
- **Backend (FastAPI)**: Employs `SelectedCardData` and `TarotRequest` Pydantic models for robust data validation. System prompts are enhanced for character tone enforcement, explicit provision of card meanings to GPT, and injection of fortune category context. A `/api/tarot/followup` endpoint is implemented for conversational continuity. Category-specific focus includes all 8 fortune categories (general, wealth, love, marriage, career, education, health, relationship).
- **Deployment**: Configured for autoscale deployment with `flutter build web --release` and `uvicorn ai_taro_oppa.backend.main:app --host 0.0.0.0 --port 5000`.

### External Dependencies
- **OpenAI**: GPT-4o-mini model for personalized tarot readings. The API key is managed via Replit Secrets (`OPENAI_API_KEY`).
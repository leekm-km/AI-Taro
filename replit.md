# AI Taro Oppa - Tarot Reading Flutter Web App

### Overview
AI Taro Oppa (타로오빠) is a multi-language tarot card reading application built with Flutter Web and a FastAPI backend. The app provides personalized tarot readings through 5 unique international characters powered by OpenAI GPT-4o-mini. The project's vision is to offer an engaging and personalized digital tarot experience with a focus on diverse character interactions and multi-language support.

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
- **7 Fortune Categories**: General, Wealth, Love, Marriage, Career, Education, and Health.
- **User Flow**: Includes language selection, character selection, fortune category selection, question input, 3-card selection from 16 displayed cards, a 3D animated card reveal, an advertisement gate, AI-generated tarot reading, and interactive follow-up questions with ad integration.
- **UI/UX Decisions**:
    - **Fortune Category Selection Page**: Compact, responsive single-row layout with `Expanded` widgets for perfect fit on various screen sizes, featuring gradient backgrounds, soft borders, and subtle shadows.
    - **Card Selection Page**: Fan-shaped layout for 16 cards, with hover and selection effects (lift, color change, thicker border, enhanced shadow) animated using `MouseRegion` and `AnimatedContainer`.
    - **Card Reveal Animation**: Sequential 3D flip animation (`Transform.rotateY`) for cards, displaying card name, orientation badge, keywords, and detailed meaning. Counter-rotation logic keeps text upright during the flip.
    - **Optimized Loading**: GPT API calls are made during ad display to pre-load results, enabling instant navigation upon ad skip.
    - **Natural Conversation Mode**: GPT responses are formatted as flowing narratives without markdown headers or structured labels, tailored to each character's personality.
    - **Interactive Follow-up System**: Features a "추가 질문하기" (Ask Additional Questions) button that transitions to "광고보고 추가질문하기" (Watch Ad to Ask Additional Questions), with a chat input field and full conversation history maintained for context-aware AI responses.

**Technical Implementations:**
- **Frontend (Flutter)**: Utilizes `TarotCard`, `SelectedCard`, `FortuneCategory` models, and dedicated pages for each step of the user flow (`FortuneCategoryPage`, `QuestionPage`, `CardSelectionPage`, `CardRevealPage`, `AdPlaceholderPage`, `ResultPage`). JSON assets are loaded for tarot card data, and random shuffling with orientation assignment is implemented.
- **Backend (FastAPI)**: Employs `SelectedCardData` and `TarotRequest` Pydantic models for robust data validation. System prompts are enhanced for character tone enforcement, explicit provision of card meanings to GPT, and injection of fortune category context. A `/api/tarot/followup` endpoint is implemented for conversational continuity.
- **Deployment**: Configured for autoscale deployment with `flutter build web --release` and `uvicorn ai_taro_oppa.backend.main:app --host 0.0.0.0 --port 5000`.

### External Dependencies
- **OpenAI**: GPT-4o-mini model for personalized tarot readings. The API key is managed via Replit Secrets (`OPENAI_API_KEY`).
# AI Taro Oppa - Tarot Reading Flutter Web App

## Project Overview
AI Taro Oppa (타로오빠) is a multi-language tarot card reading application built with Flutter Web and FastAPI backend. The app provides personalized tarot readings through 5 unique international characters powered by OpenAI GPT-4o-mini.

## Tech Stack
- **Frontend**: Flutter Web (Dart 3.8.0)
- **Backend**: FastAPI (Python 3.12) with OpenAI integration
- **AI**: OpenAI GPT-4o-mini for personalized tarot readings
- **Server**: Single unified server on port 5000

## Project Structure
```
.
├── ai_taro_oppa/          # Main Flutter application
│   ├── lib/               # Flutter source code
│   │   └── main.dart      # Main application entry point
│   ├── web/               # Web-specific files
│   ├── build/web/         # Built web application (served by FastAPI)
│   ├── backend/           # FastAPI backend
│   │   ├── main.py        # FastAPI server + OpenAI integration
│   │   └── requirements.txt
│   └── pubspec.yaml       # Flutter dependencies
├── .gitignore
└── replit.md             # This file
```

## Features

### 5 International Characters
1. **Lucien Voss** (루시앙 보스) - Cold, analytical astrologer
2. **Isolde Hartmann** (이졸데 하르트만) - Poetic, emotional prophet  
3. **Cheongun Seonin** (청운 선인) - Contemplative, relaxed Taoist sage
4. **Linhua** (린화) - Playful, mysterious fortune teller
5. **Thimble Oakroot** (팀블 오크루트) - Warm, witty naturalist

### Multi-language Support
- Korean (한국어)
- English
- Chinese (中文)
- Thai (ไทย)

### 7 Fortune Categories
- 종합운 (General Fortune)
- 재물운 (Wealth)
- 연애운 (Love)
- 결혼운 (Marriage)
- 직업운 (Career)
- 학업운 (Education)
- 건강운 (Health)

### User Flow
1. **Language Selection** - Choose preferred language
2. **Character Selection** - Pick one of 5 tarot readers
3. **Question Input** - Enter question and select fortune category
4. **Tarot Reading** - Receive personalized AI-generated reading

## Architecture

### Unified Server Design
- **Single FastAPI server** on port 5000 serves both:
  - API endpoint: `/api/tarot` (POST) - Handles tarot reading requests
  - Static files: Flutter web app (index.html, main.dart.js, etc.)
  - Health check: `/health` (GET)

### API Integration
- Flutter app uses **relative URL** `/api/tarot` to call backend
- No CORS issues since frontend and backend share same domain
- Works seamlessly in both development and production

### OpenAI Integration
- Uses GPT-4o-mini model for tarot readings
- API key managed via Replit Secrets (OPENAI_API_KEY)
- Personalized prompts based on character style and language

## Development Setup

### Running the App
The app runs automatically via workflow:
```bash
cd ai_taro_oppa/backend && uvicorn main:app --host 0.0.0.0 --port 5000
```

### Manual Build
To rebuild the Flutter web app:
```bash
cd ai_taro_oppa
flutter build web --release
```

### Backend Dependencies
```bash
cd ai_taro_oppa/backend
pip install -r requirements.txt
```

## Deployment
The app is configured for **autoscale deployment**:
- **Build**: `cd ai_taro_oppa && flutter build web --release`
- **Run**: `uvicorn ai_taro_oppa.backend.main:app --host 0.0.0.0 --port 5000`
- **Type**: Autoscale (stateless web application)
- **Port**: 5000 (mapped to external port 80)

## Environment Variables
- `OPENAI_API_KEY` - Required for AI-powered tarot readings (stored in Replit Secrets)

## Current Status
✅ Flutter SDK installed (v3.32.0)
✅ Dependencies installed (Flutter + Python)
✅ Unified server architecture implemented
✅ API endpoint with relative URL (`/api/tarot`)
✅ 5 international characters integrated
✅ OpenAI GPT-4o-mini integration complete
✅ Multi-language support (4 languages)
✅ App tested and verified working
✅ Deployment configured

## Recent Changes (October 7, 2025)

### Major Feature: Interactive Card Selection & Character Personalities

**New Features Added:**

1. **Card Selection Page**:
   - Users now select 3 cards from 16 displayed cards before getting a reading
   - Beautiful left-to-right staggered animation (0.04s delay per card)
   - Interactive card selection with visual feedback
   - Selected card information passed to AI for personalized readings

2. **Character Greetings**:
   - Each of the 5 characters has unique greeting messages in all 4 languages
   - Greetings displayed on card selection page
   - Messages reflect each character's unique personality:
     * **Lucien Voss**: "별들이 당신의 운명을 드러낼 준비가 되었소..."
     * **Isolde Hartmann**: "당신의 영혼이 이끄는 대로..."
     * **Cheongun Seonin**: "음양의 이치가 카드 속에..."
     * **Linhua**: "후후~ 어떤 카드가 당신을 부르고 있을까요?"
     * **Thimble Oakroot**: "숲의 지혜가 카드에 깃들어..."

3. **Enhanced AI Personalities**:
   - Detailed character tone definitions added to backend
   - Specific speech patterns for each character:
     * **Lucien**: "~하시오", cold/analytical, astrologer tone
     * **Isolde**: "~주세요", poetic/emotional, metaphorical
     * **Cheongun**: "~하시게", proverb-style, yin-yang references
     * **Linhua**: "~요", playful ("후후~", "어머~"), intuitive
     * **Thimble**: "~답니다", nature metaphors, warm/practical
   - Improved system prompts ensure consistent character voice in AI responses

**Updated User Flow:**
1. Language Selection
2. Character Selection
3. **Card Selection** (NEW) - Pick 3 from 16 cards with animation
4. Question Input
5. Tarot Reading

### Technical Implementation
- Flutter: Added `CardSelectionPage` with AnimationController
- Backend: Enhanced `PERSONAS` with tone/example fields
- API: Added `selected_cards` field to `TarotRequest`
- Prompt engineering: Character-specific tone enforcement

### Previous Bug Fix: Production URL Architecture
- Unified server on port 5000 serving both API and static files
- Relative URL `/api/tarot` instead of hardcoded localhost
- OpenAI upgraded to 2.2.0 for httpx compatibility

## Notes
- WebGL may fall back to CPU rendering in some environments (normal behavior)
- App uses release build for better performance
- All 4 languages are active and functional
- Character personas have distinct AI personalities and speaking styles

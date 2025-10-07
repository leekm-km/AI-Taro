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

### 🎴 Major Overhaul: Full 78-Card Tarot System with Enhanced Workflow

**New User Flow:**
1. Language Selection (한국어/English/中文/ไทย)
2. Character Selection (5 unique personas)
3. **Fortune Category Selection** (NEW) - Choose from 7 categories
4. **Card Selection** (NEW) - Pick 3 from 16 displayed cards
5. Question Input
6. AI-Powered Tarot Reading

---

### ✨ Key Features Implemented

#### 1. **Full 78-Card Tarot Deck**
- **22 Major Arcana**: The Fool, The Magician, The High Priestess, ... The World
- **56 Minor Arcana**: 
  - Wands (완드) - Fire, Creativity, Action
  - Cups (컵) - Water, Emotions, Relationships
  - Swords (소드) - Air, Thoughts, Conflicts
  - Pentacles (펜타클) - Earth, Material, Achievement
- Each card includes:
  - Korean & English names
  - Keywords & visual elements
  - **Upright meaning** (정방향 해석)
  - **Reversed meaning** (역방향 해석)

#### 2. **Fortune Category Selection Page**
- 7 distinct fortune categories with multilingual support:
  - 종합운 (General Fortune) ⭐
  - 재물운 (Wealth) 💰
  - 연애운 (Love) ❤️
  - 결혼운 (Marriage) 💍
  - 직업운 (Career) 💼
  - 학업운 (Education) 📚
  - 건강운 (Health) 🏥
- Beautiful grid layout with icons
- Localized names for all 4 languages

#### 3. **Intelligent Card Selection System**
- **78-card shuffle**: Full deck randomized at page load
- **16-card display**: First 16 cards shown face-down
- **3-card pick**: User selects 3 cards for reading
- **Orientation assignment**: Each card randomly assigned upright/reversed (50% chance)
- **Real mapping**: Display indices map to actual 78-card deck positions
- Smooth left-to-right animation for card spread

#### 4. **Enhanced Character Personalities**
Dramatically strengthened GPT prompt engineering:
- **Lucien Voss** (루시앙 보스): "~하시오" - Cold, analytical astrologer
- **Isolde Hartmann** (이졸데 하르트만): "~주세요" - Poetic, emotional prophet
- **Cheongun Seonin** (청운 선인): "~하시게" - Proverb-style Taoist sage
- **Linhua** (린화): "후후~", "어머~" - Playful, mysterious fortune teller
- **Thimble Oakroot** (팀블 오크루트): "~답니다" - Warm naturalist with practical wisdom

#### 5. **Backend API Enhancements**
- **SelectedCardData model**: Receives full card information
  - Card ID, name (English + Korean)
  - Orientation (upright/reversed)
  - Meaning (context-aware based on orientation)
  - Keywords
- **Category-focused prompts**: Each fortune category has specific AI focus
- **Strict tone enforcement**: System prompts force consistent character speech patterns
- **Detailed card interpretation**: AI receives actual card meanings, not just positions

---

### 🛠 Technical Implementation

**Frontend (Flutter):**
- `TarotCard` model: Full card data structure with fromJson factory
- `SelectedCard` model: Combines card + orientation (isReversed bool)
- `FortuneCategory` model: Multilingual category data
- `FortuneCategoryPage`: New page between character and card selection
- JSON asset loading: rootBundle.loadString('assets/tarot_cards.json')
- Shuffle logic: Random().shuffle() on full 78-card deck
- Orientation randomization: Random().nextBool() for each selected card

**Backend (FastAPI):**
- `SelectedCardData` Pydantic model validates incoming card data
- Category focus mapping: 7 categories with specific reading angles
- Enhanced system prompts:
  - Character tone enforcement (3 levels of emphasis)
  - Card meanings explicitly provided to GPT
  - Fortune category context injection
  - Example phrases for each character

**Data Structure:**
```
assets/
  └── tarot_cards.json (78 cards, ~15KB)
      ├── Major Arcana (0-21)
      └── Minor Arcana
          ├── Wands (Ace-King, 14 cards)
          ├── Cups (Ace-King, 14 cards)
          ├── Swords (Ace-King, 14 cards)
          └── Pentacles (Ace-King, 14 cards)
```

---

### 🎯 User Experience Improvements

1. **Structured Fortune-Telling Flow**: Clear progression through categories before cards
2. **Authentic Tarot Experience**: Real 78-card deck with proper upright/reversed interpretations
3. **Personalized Readings**: AI receives actual card meanings for contextual responses
4. **Character Differentiation**: Each persona now has distinctly recognizable speech patterns
5. **Visual Clarity**: Card information displayed with orientation badges

---

### Previous Updates

#### Interactive Card Selection & Character Greetings (Earlier v1)
- Card selection page with staggered animations
- Character-specific greetings on card page
- Initial persona tone definitions

#### Production URL Architecture Fix
- Unified server on port 5000 serving both API and static files
- Relative URL `/api/tarot` for cross-environment compatibility
- OpenAI upgraded to 2.2.0 for httpx compatibility

## Notes
- WebGL may fall back to CPU rendering in some environments (normal behavior)
- App uses release build for better performance
- All 4 languages are active and functional
- Character personas have distinct AI personalities and speaking styles

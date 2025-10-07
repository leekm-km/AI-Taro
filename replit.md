# AI Taro Oppa - Tarot Reading Flutter Web App

## Project Overview
AI Taro Oppa (타로오빠) is a multi-language tarot card reading application built with Flutter. The app provides an interactive tarot card reading experience with support for Korean, English, Chinese, and Thai languages.

## Tech Stack
- **Frontend**: Flutter Web (Dart 3.8.0)
- **Backend Tools**: Python 3.12 with FastAPI and OpenAI for image generation
- **Web Server**: Python HTTP Server for serving built Flutter web app

## Project Structure
```
.
├── ai_taro_oppa/          # Main Flutter application
│   ├── lib/               # Flutter source code
│   │   └── main.dart      # Main application entry point
│   ├── web/               # Web-specific files
│   ├── build/web/         # Built web application (served in production)
│   ├── backend/           # Python backend for AI image generation
│   │   └── requirements.txt
│   ├── tools/             # Image generation tools
│   │   ├── gen_card_images.py
│   │   └── prompts.yaml
│   └── pubspec.yaml       # Flutter dependencies
├── .gitignore
└── replit.md             # This file
```

## Features
- **Multi-language Support**: Korean (한국어), English, Chinese (中文), Thai (ไทย)
- **Interactive Card Selection**: Beautiful fan-style card selection UI
- **Tarot Reading Categories**: Fortune, Love, Career, Health, Education
- **AI-Generated Card Images**: Uses OpenAI to generate tarot card artwork

## Development Setup

### Running the App
The app is configured to run automatically via the workflow. The workflow:
1. Serves the pre-built Flutter web application on port 5000
2. Uses Python's HTTP server to serve static files
3. Binds to 0.0.0.0 to work with Replit's proxy

### Manual Build
To rebuild the Flutter web app:
```bash
cd ai_taro_oppa
flutter build web --release
```

### Backend Setup (Image Generation)
The backend requires OpenAI API credentials for generating tarot card images:
```bash
cd ai_taro_oppa/backend
pip install -r requirements.txt
# Create .env file with OPENAI_API_KEY
python ../tools/gen_card_images.py
```

## Deployment
The app is configured for autoscale deployment in `.replit`:
- **Build**: `cd ai_taro_oppa && flutter build web --release`
- **Run**: `python -m http.server 5000 --bind 0.0.0.0 --directory ai_taro_oppa/build/web`
- **Type**: Autoscale (stateless web application)
- **Port**: 5000 (mapped to external port 80)

The workflow "Flutter Web Server" automatically starts when running the project.

## Current Status
✅ Flutter SDK installed (v3.32.0)
✅ Dependencies installed
✅ Web app built and running on port 5000
✅ Deployment configured
✅ App tested and verified working

## Notes
- Currently only Korean language is enabled in the app (others are disabled)
- The app uses a release build for better performance in Replit
- WebGL may fall back to CPU rendering in some environments (this is normal)

## Recent Changes (October 7, 2025)
- Installed Flutter and Dart via Nix system dependencies
- Updated Dart SDK requirement to support installed version (3.8.0)
- Built Flutter web app in release mode for better Replit compatibility
- Configured workflow to serve built app via Python HTTP server
- Set up autoscale deployment configuration
- Updated .gitignore with Flutter and Python patterns

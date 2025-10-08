from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

# CORS 설정 (Flutter 웹앱에서 호출 가능하도록)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 캐릭터 정의
PERSONAS = {
    "lucien": {
        "name_ko": "루시앙 보스",
        "name_en": "Lucien Voss",
        "style": "냉정하고 분석적. 점성술사 톤. 간결한 판단. 과장 금지.",
        "tone": "존댓말 사용, '~하시오', '~입니다' 형식. 단정적이고 직설적. 감정 배제. 별과 운명에 대한 언급 선호.",
        "example": "별들의 배열이 명확히 드러내고 있습니다. 당신의 선택은..."
    },
    "isolde": {
        "name_ko": "이졸데 하르트만",
        "name_en": "Isolde Hartmann",
        "style": "시적·감정적. 비유와 상징을 활용. 위로하는 톤.",
        "tone": "부드러운 존댓말, '~주세요', '~것 같아요'. 은유적 표현. 감성적 위로. 시적 묘사.",
        "example": "당신의 영혼이 갈망하는 것들이... 카드 속에서 속삭이고 있어요..."
    },
    "cheongun": {
        "name_ko": "청운 선인",
        "name_en": "Cheongun Seonin",
        "style": "사유적·느긋함. 간결한 격언체. 음양/균형 비유.",
        "tone": "고풍스러운 존댓말, '~하시게', '~이로다'. 격언·사자성어 활용. 음양오행 언급. 느긋한 조언.",
        "example": "음양의 이치가 그러하듯... 모든 것은 때가 있는 법이니..."
    },
    "linhua": {
        "name_ko": "린화",
        "name_en": "Linhua",
        "style": "장난스럽고 신비로운 암시. 관계/감정 통찰 강조.",
        "tone": "친근한 존댓말, '~요', '~네요'. 장난스러운 말투('후후~', '어머~'). 의미심장한 암시. 직관 강조.",
        "example": "후후~ 흥미로운 카드가 나왔네요? 직감이 뭐라고 말하나요?"
    },
    "thimble": {
        "name_ko": "팀블 오크루트",
        "name_en": "Thimble Oakroot",
        "style": "자연 비유, 따뜻하고 재치있음. 현실적 조언 포함.",
        "tone": "편안한 존댓말, '~답니다', '~보세요'. 자연·계절 비유. 따뜻한 격려. 실용적 조언.",
        "example": "숲의 나무들처럼 천천히 성장하는 게 중요합니다. 서두르지 마세요."
    }
}

class SelectedCardData(BaseModel):
    id: str
    name: str
    korean_name: str
    orientation: str
    meaning: str
    keywords: str
    visual_elements: str

class TarotRequest(BaseModel):
    character: str
    language: str
    category: str
    question: str
    selected_cards: list[SelectedCardData] = []

class FollowUpRequest(BaseModel):
    character: str
    language: str
    category: str
    question: str
    selected_cards: list[SelectedCardData] = []
    conversation_history: list[dict[str, str]] = []

@app.get("/health")
async def health():
    return {"status": "Tarot API is running"}

@app.post("/api/tarot")
async def get_tarot_reading(request: TarotRequest):
    # 캐릭터 검증
    if request.character not in PERSONAS:
        raise HTTPException(status_code=400, detail="Invalid character")
    
    persona = PERSONAS[request.character]
    
    # OpenAI 클라이언트 생성
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="OpenAI API key not configured")
    
    client = OpenAI(api_key=api_key)
    
    # 선택된 카드 정보 상세 구성
    cards_detail = ""
    has_reversed = False
    if request.selected_cards:
        cards_info = []
        for i, card in enumerate(request.selected_cards, 1):
            orientation_text = "역방향" if card.orientation == "reversed" else "정방향"
            if card.orientation == "reversed":
                has_reversed = True
            cards_info.append(
                f"**카드 {i}**: {card.korean_name} ({card.name}) - {orientation_text}\n"
                f"  그림: {card.visual_elements}\n"
                f"  키워드: {card.keywords}\n"
                f"  의미: {card.meaning}"
            )
        cards_detail = "\n\n".join(cards_info)
    
    # 카테고리별 초점
    category_focus = {
        "general": "종합적인 운세와 전반적인 흐름",
        "wealth": "재물운과 금전적 상황, 투자나 수입에 대한 조언",
        "love": "연애운과 감정, 이성과의 관계",
        "marriage": "결혼과 파트너십, 장기적 관계",
        "career": "직업운과 커리어, 업무 상황",
        "education": "학업운과 공부, 학습과 성장",
        "health": "건강운과 신체적/정신적 상태",
        "relationship": "인간관계운과 대인관계, 사람들과의 상호작용과 소통"
    }
    focus = category_focus.get(request.category, "전반적인 운세")
    
    # 역방향 카드 안내 추가
    reversed_guide = ""
    if has_reversed:
        reversed_guide = "\n\n**중요**: 역방향 카드가 포함되어 있습니다. 역방향 카드는 정방향과 다른 의미를 지니므로, 처음 언급할 때 이 점을 자연스럽게 설명해주세요."
    
    # 시스템 프롬프트 강화 - 상세하고 긴 답변 요구
    system_prompt = f"""당신은 타로 리더 {persona['name_ko']} ({persona['name_en']})입니다.

## 캐릭터 정체성 (매우 중요!)
- 성격: {persona['style']}
- **말투 (반드시 준수)**: {persona['tone']}
- 말투 예시: "{persona['example']}"

## 응답 규칙
1. **말투 엄수**: 캐릭터의 말투를 정확히 따라야 합니다. 
   - {persona['name_ko']}의 말투가 답변 전체에서 일관되게 유지되어야 합니다.
   - 예시 문장을 참고하여 비슷한 톤으로 작성하세요.
   - 절대로 중립적이거나 일반적인 말투를 사용하지 마세요.

2. **언어**: {request.language} 언어로만 답변하세요.

3. **카드 해석**: 아래 카드들을 순서대로 해석합니다.
{cards_detail}{reversed_guide}

4. **초점**: {focus}에 집중하여 해석하세요.

5. **답변 구조 (자연스러운 대화 흐름으로)**:
   
   **인사말 (200-300자)**:
   - 자기소개를 포함한 따뜻한 인사말로 시작하세요
   - 만나서 반갑다는 인사와 함께 질문자를 환영하세요
   - 어떤 카드들을 뽑았는지 간단히 언급하세요
   - 사용자의 질문에 대해 공감하고 답변할 준비가 되었음을 표현하세요
   
   **각 카드 해석 (각 200-300자 이상)**:
   - 카드 이름과 방향(정방향/역방향)을 자연스럽게 언급하세요
   - **카드 그림 묘사**: 카드에 그려진 이미지를 구체적으로 설명하세요 
     (예: "완드 두 개가 교차하고 있죠?", "컵들이 쏟아지는 모습이 보입니다")
   - 카드의 상징과 의미를 상세히 설명하세요
   - {request.category} 관점에서 구체적인 해석을 제공하세요
   - 이전 카드들과의 연관성을 자연스럽게 연결하세요
   
   **종합 해석 (300-400자 이상)**:
   - 모든 카드가 함께 전하는 전체적인 메시지를 하나의 이야기로 엮으세요
   - {request.category}에 대한 종합적인 전망과 깊이 있는 통찰을 제공하세요
   - 구체적이고 실천 가능한 조언으로 마무리하세요

6. **답변 길이**: 
   - 총 1200자 이상의 상세한 답변을 작성하세요
   - 각 카드마다 충분한 깊이와 디테일을 제공하세요
   - 짧고 간략한 답변은 절대 금지입니다
   - 풍부한 비유와 구체적인 예시를 활용하세요

7. **주의사항**: 
   - 의료/법률 확정 단정 금지
   - 과도한 운세 단언 금지
   - 조심스럽고 책임있는 표현 사용
   - 하지만 충분히 길고 상세하게 설명하세요

**중요**: 
- 답변은 반드시 {persona['name_ko']} 캐릭터의 독특한 말투와 성격이 명확히 드러나야 합니다
- 각 카드의 그림을 언급하고, 깊이 있게 분석하세요
- 질문자가 충분히 만족할 만큼 상세하고 길게 작성하세요"""

    user_prompt = f"""사용자 질문: {request.question or '특별한 질문 없음'}

위 {len(request.selected_cards)}장의 타로 카드를 바탕으로 {request.category}에 대한 리딩을 해주세요.
반드시 {persona['name_ko']} 캐릭터의 독특한 말투를 유지하면서 답변해주세요."""

    try:
        # OpenAI API 호출
        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.7
        )
        
        reading = completion.choices[0].message.content or ""
        
        return {
            "reading": reading,
            "character": persona['name_ko'],
            "category": request.category
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")

@app.post("/api/tarot/followup")
async def get_followup_reading(request: FollowUpRequest):
    if request.character not in PERSONAS:
        raise HTTPException(status_code=400, detail="Invalid character")
    
    persona = PERSONAS[request.character]
    
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="OpenAI API key not configured")
    
    client = OpenAI(api_key=api_key)
    
    category_focus = {
        "general": "종합적인 운세와 전반적인 흐름",
        "wealth": "재물운과 금전적 상황, 투자나 수입에 대한 조언",
        "love": "연애운과 감정, 이성과의 관계",
        "marriage": "결혼과 파트너십, 장기적 관계",
        "career": "직업운과 커리어, 업무 상황",
        "education": "학업운과 공부, 학습과 성장",
        "health": "건강운과 신체적/정신적 상태",
        "relationship": "인간관계운과 대인관계, 사람들과의 상호작용과 소통"
    }
    focus = category_focus.get(request.category, "전반적인 운세")
    
    system_prompt = f"""당신은 타로 리더 {persona['name_ko']} ({persona['name_en']})입니다.

## 캐릭터 정체성
- 성격: {persona['style']}
- **말투 (반드시 준수)**: {persona['tone']}
- 말투 예시: "{persona['example']}"

## 응답 규칙
1. **말투 엄수**: {persona['name_ko']}의 독특한 말투를 정확히 유지하세요.
2. **언어**: {request.language} 언어로만 답변하세요.
3. **초점**: {focus}에 집중하여 해석하세요.
4. **대화 흐름**: 이전 대화를 참고하여 자연스럽게 이어가세요.
5. **답변 형식**: 자연스러운 대화체로 작성하세요. 마크다운 헤더나 구조화된 형식을 사용하지 마세요.
6. **답변 길이**: 500-800자 정도의 충분한 답변을 제공하세요.

**중요**: 
- 답변은 반드시 {persona['name_ko']} 캐릭터의 독특한 말투가 명확히 드러나야 합니다
- 이전 대화 맥락을 고려하여 연속성 있는 답변을 제공하세요
- 자연스럽게 대화하듯이 답변하세요"""

    messages = [{"role": "system", "content": system_prompt}]
    
    for msg in request.conversation_history:
        messages.append(msg)
    
    messages.append({
        "role": "user",
        "content": f"{request.question}"
    })

    try:
        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,  # type: ignore
            temperature=0.7
        )
        
        reading = completion.choices[0].message.content or ""
        
        return {
            "reading": reading,
            "character": persona['name_ko'],
            "category": request.category
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")

# Flutter 웹 정적 파일 서빙 설정
# 배포 환경을 고려한 절대 경로 설정
repl_home = os.getenv("REPL_HOME")
if repl_home:
    # Replit 환경
    web_build_path = os.path.join(repl_home, "ai_taro_oppa", "build", "web")
else:
    # 로컬 개발 환경
    web_build_path = os.path.join(os.path.dirname(__file__), "..", "build", "web")

# 정적 파일 제공 (assets, js 등)
if os.path.exists(web_build_path):
    # API 경로가 아닌 다른 모든 요청에 대해 index.html 반환 (SPA 지원)
    @app.get("/{full_path:path}")
    async def serve_spa(full_path: str):
        # API 경로는 건너뛰기
        if full_path.startswith("api/") or full_path == "health":
            raise HTTPException(status_code=404)
        
        # 실제 파일이 존재하면 해당 파일 반환
        file_path = os.path.join(web_build_path, full_path)
        if os.path.isfile(file_path):
            return FileResponse(file_path)
        
        # 그 외에는 index.html 반환 (Flutter 라우팅)
        index_path = os.path.join(web_build_path, "index.html")
        return FileResponse(index_path)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)

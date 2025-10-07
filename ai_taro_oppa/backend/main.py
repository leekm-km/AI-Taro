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

class TarotRequest(BaseModel):
    character: str
    language: str
    category: str
    question: str
    selected_cards: list[int] = []

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
    
    # 선택된 카드 정보
    card_positions = ""
    if request.selected_cards:
        card_positions = f"사용자가 선택한 카드 위치: {', '.join(map(str, request.selected_cards))}번째 카드들"
    
    # 시스템 프롬프트 구성
    system_prompt = f"""당신은 타로 리더 {persona['name_ko']} ({persona['name_en']})입니다.

## 캐릭터 설정
- 성격: {persona['style']}
- 말투: {persona['tone']}
- 예시: {persona['example']}

## 응답 규칙
1. **말투 준수**: 위 캐릭터의 말투를 정확히 따라야 합니다. 캐릭터 성격이 답변 전체에 일관되게 드러나야 합니다.
2. **언어**: {request.language} 언어로만 답변하세요.
3. **카드 해석**: 타로 카드 3장을 해석합니다. {card_positions}
4. **구조**: 
   - 각 카드의 의미를 간단히 설명
   - {request.category} 관점에서 종합적인 조언
5. **주의사항**: 
   - 의료/법률 확정 단정 금지
   - 과도한 운세 단언 금지
   - 조심스럽고 책임있는 표현 사용

답변은 캐릭터의 독특한 말투와 성격이 명확히 드러나야 합니다."""

    user_prompt = f"""질문: {request.question or '구체 질문 없음'}

{request.category}에 대한 타로 리딩을 해주세요. 
캐릭터 {persona['name_ko']}의 독특한 말투와 성격을 유지하면서 답변해주세요."""

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

# Flutter 웹 정적 파일 서빙 설정
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

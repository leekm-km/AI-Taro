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
        "style": "냉정하고 분석적. 점성술사 톤. 간결한 판단. 과장 금지."
    },
    "isolde": {
        "name_ko": "이졸데 하르트만",
        "name_en": "Isolde Hartmann",
        "style": "시적·감정적. 비유와 상징을 활용. 위로하는 톤."
    },
    "cheongun": {
        "name_ko": "청운 선인",
        "name_en": "Cheongun Seonin",
        "style": "사유적·느긋함. 간결한 격언체. 음양/균형 비유."
    },
    "linhua": {
        "name_ko": "린화",
        "name_en": "Linhua",
        "style": "장난스럽고 신비로운 암시. 관계/감정 통찰 강조."
    },
    "thimble": {
        "name_ko": "팀블 오크루트",
        "name_en": "Thimble Oakroot",
        "style": "자연 비유, 따뜻하고 재치있음. 현실적 조언 포함."
    }
}

class TarotRequest(BaseModel):
    character: str
    language: str
    category: str
    question: str

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
    
    # 시스템 프롬프트 구성
    system_prompt = f"""당신은 타로 리더 AI입니다. 캐릭터: {persona['name_ko']} ({persona['name_en']}).
말투 지침: {persona['style']}
출력 언어: {request.language} (요청 언어로만 답변).
점사 주제: {request.category}.
카드 구성: 3장 가정(메이저/마이너 임의). 각 카드 의미→종합 조언.
금지: 의료/법률 확정 단정, 과도한 운세 단언. 조심스러운 표현."""

    user_prompt = f"""질문: {request.question or '구체 질문 없음'}
상황에 맞게 {request.category} 관점에 초점을 맞춰주세요."""

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

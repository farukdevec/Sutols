import json
import logging
from typing import Optional

import httpx
from duckduckgo_search import DDGS
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("sutol-ai")

OLLAMA_BASE = "http://localhost:11434"
OLLAMA_MODEL = "llama3.2"

app = FastAPI(title="Sutol AI Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class GenerateRequest(BaseModel):
    prompt: str
    system: Optional[str] = None
    temperature: float = 0.3
    max_tokens: int = 2048


class GenerateResponse(BaseModel):
    text: str


class ResearchRequest(BaseModel):
    topic: str
    max_results: int = 5


class ResearchResult(BaseModel):
    title: str
    snippet: str
    url: str


class ResearchResponse(BaseModel):
    results: list[ResearchResult]
    summary: str


class SlideContent(BaseModel):
    title: str
    body: str
    speaker_notes: str = ""


class GenerateSlidesRequest(BaseModel):
    topic: str
    slide_count: int = 5
    language: str = "turkish"


class GenerateSlidesResponse(BaseModel):
    slides: list[SlideContent]


class AnalyzeRequest(BaseModel):
    topic: str
    language: str = "turkish"


class AnalysisItem(BaseModel):
    title: str
    content: str


class AnalyzeResponse(BaseModel):
    swot: list[AnalysisItem]
    key_statistics: list[AnalysisItem]
    trends: list[AnalysisItem]
    recommendations: list[AnalysisItem]
    summary: str


def _ollama_generate(prompt: str, system: Optional[str] = None, temperature: float = 0.3, max_tokens: int = 2048) -> str:
    payload = {
        "model": OLLAMA_MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": temperature,
            "num_predict": max_tokens,
        },
    }
    if system:
        payload["system"] = system

    try:
        resp = httpx.post(f"{OLLAMA_BASE}/api/generate", json=payload, timeout=120)
        resp.raise_for_status()
        data = resp.json()
        return data.get("response", "").strip()
    except httpx.RequestError as e:
        log.error(f"Ollama hatasi: {e}")
        raise HTTPException(status_code=503, detail=f"Ollama'ya baglanilamadi: {e}")


def _ollama_chat(messages: list[dict], temperature: float = 0.3, max_tokens: int = 2048) -> str:
    payload = {
        "model": OLLAMA_MODEL,
        "messages": messages,
        "stream": False,
        "options": {
            "temperature": temperature,
            "num_predict": max_tokens,
        },
    }
    try:
        resp = httpx.post(f"{OLLAMA_BASE}/api/chat", json=payload, timeout=120)
        resp.raise_for_status()
        data = resp.json()
        return data.get("message", {}).get("content", "").strip()
    except httpx.RequestError as e:
        log.error(f"Ollama chat hatasi: {e}")
        raise HTTPException(status_code=503, detail=f"Ollama'ya baglanilamadi: {e}")


def _web_search(query: str, max_results: int = 5) -> list[ResearchResult]:
    try:
        with DDGS() as ddgs:
            results = list(ddgs.text(query, max_results=max_results))
            return [
                ResearchResult(
                    title=r.get("title", ""),
                    snippet=r.get("body", ""),
                    url=r.get("href", ""),
                )
                for r in results
            ]
    except Exception as e:
        log.warning(f"Arama hatasi: {e}")
        return []


@app.get("/health")
def health():
    try:
        resp = httpx.get(f"{OLLAMA_BASE}/api/tags", timeout=5)
        models = resp.json().get("models", [])
        model_names = [m["name"] for m in models]
        return {"status": "ok", "ollama_connected": True, "models": model_names}
    except Exception:
        return {"status": "ok", "ollama_connected": False, "models": []}


@app.post("/api/generate", response_model=GenerateResponse)
def generate(req: GenerateRequest):
    text = _ollama_generate(
        prompt=req.prompt,
        system=req.system,
        temperature=req.temperature,
        max_tokens=req.max_tokens,
    )
    return GenerateResponse(text=text)


@app.post("/api/research", response_model=ResearchResponse)
def research(req: ResearchRequest):
    results = _web_search(req.topic, max_results=max(req.max_results, 5))

    context = "\n\n".join(
        f"Baslik: {r.title}\nIcerik: {r.snippet}\nKaynak: {r.url}" for r in results[:5]
    )

    summary_prompt = f"""Asagidaki web arama sonuclarina gore "{req.topic}" konusunu detayli ozetle.
    Ozet en az 3 paragraf, bilgilendirici ve madde madde olsun.
    Her bilgiyi verirken kaynagini da belirt.

    ARAMA SONUCLARI:
    {context}
    """
    summary = _ollama_generate(summary_prompt, temperature=0.2)

    return ResearchResponse(results=results, summary=summary)


@app.post("/api/generate-slides", response_model=GenerateSlidesResponse)
def generate_slides(req: GenerateSlidesRequest):
    lang_instruction = {
        "turkish": "Türkçe",
        "english": "English",
    }.get(req.language, "Türkçe")

    system_prompt = f"""Sen bir sunum slayti icerik ureticisisin.
    Verilen konu hakkinda {lang_instruction} olarak slayt icerigi uret.
    Her slayt icin:
    - title: Slayt basligi (kisa, dikkat cekici)
    - body: Slayt icerigi (2-3 paragraf, bilgilendirici)
    - speaker_notes: Sunucu notlari (istege bagli, detayli aciklama)

    JSON formatinda {req.slide_count} slayt uret.
    """

    user_prompt = f"""Konu: {req.topic}
    Slayt sayisi: {req.slide_count}

    Once web'den bu konu hakkinda guncel bilgi topla, sonra slaytlari olustur.
    Slayt icerigi bilimsel ve dogru olmali.

    JSON formatinda yanit ver:
    {{
        "slides": [
            {{"title": "...", "body": "...", "speaker_notes": "..."}}
        ]
    }}
    """

    search_results = _web_search(req.topic, max_results=3)
    if search_results:
        context = "\n".join(f"- {r.title}: {r.snippet}" for r in search_results)
        user_prompt = f"""Konu: {req.topic}
    Slayt sayisi: {req.slide_count}

    WEB ARAMA SONUCLARI:
    {context}

    Yukaridaki bilgilere dayanarak {lang_instruction} slayt icerigi olustur.
    Slayt icerigi akademik duzeyde ve bilgilendirici olsun.

    JSON formatinda yanit ver:
    {{
        "slides": [
            {{"title": "...", "body": "...", "speaker_notes": "..."}}
        ]
    }}
    """

    response = _ollama_chat(
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        temperature=0.4,
        max_tokens=4096,
    )

    try:
        json_str = response
        if "```json" in json_str:
            json_str = json_str.split("```json")[1].split("```")[0].strip()
        elif "```" in json_str:
            json_str = json_str.split("```")[1].split("```")[0].strip()

        data = json.loads(json_str)
        slides = [SlideContent(**s) for s in data.get("slides", [])]
        if not slides:
            raise ValueError("Slayt listesi bos")
        return GenerateSlidesResponse(slides=slides)
    except (json.JSONDecodeError, ValueError, TypeError) as e:
        log.warning(f"JSON ayristirma hatasi, fallback kullaniliyor: {e}")
        slides = _fallback_slides(req.topic, req.slide_count, response)
        return GenerateSlidesResponse(slides=slides)


def _fallback_slides(topic: str, count: int, raw: str) -> list[SlideContent]:
    lines = raw.split("\n")
    slides = []
    current_title = ""
    current_body_parts = []
    current_notes = ""

    for line in lines:
        line = line.strip()
        if not line:
            continue
        if line.startswith("**") and line.endswith("**"):
            if current_title:
                slides.append(SlideContent(
                    title=current_title,
                    body="\n".join(current_body_parts),
                    speaker_notes=current_notes,
                ))
                current_body_parts = []
                current_notes = ""
            current_title = line.strip("*")
        elif line.startswith("Baslik") or line.startswith("Title") or line.startswith("- **"):
            if current_title:
                slides.append(SlideContent(
                    title=current_title,
                    body="\n".join(current_body_parts),
                    speaker_notes=current_notes,
                ))
                current_body_parts = []
                current_notes = ""
            current_title = line.split(":", 1)[-1].strip().strip("*").strip()
        elif line.startswith("Not") or line.startswith("Speaker"):
            current_notes = line.split(":", 1)[-1].strip() if ":" in line else line
        else:
            current_body_parts.append(line)

    if current_title:
        slides.append(SlideContent(
            title=current_title,
            body="\n".join(current_body_parts),
            speaker_notes=current_notes,
        ))

    while len(slides) < count:
        slides.append(SlideContent(
            title=f"{topic} - Bolum {len(slides) + 1}",
            body=f"{topic} konusu ile ilgili detayli bilgiler burada yer alacaktir.",
        ))

    return slides[:count]


@app.post("/api/generate-content", response_model=GenerateResponse)
def generate_content(req: GenerateRequest):
    text = _ollama_chat(
        messages=[
            {"role": "system", "content": req.system or "Sen yardimci bir asistansin."},
            {"role": "user", "content": req.prompt},
        ],
        temperature=req.temperature,
        max_tokens=req.max_tokens,
    )
    return GenerateResponse(text=text)


@app.post("/api/analyze", response_model=AnalyzeResponse)
def analyze(req: AnalyzeRequest):
    lang = "Türkçe" if req.language == "turkish" else "English"

    search_results = _web_search(req.topic, max_results=5)
    context = "\n".join(f"- {r.title}: {r.snippet}" for r in search_results[:5]) if search_results else ""

    system_prompt = f"""Sen profesyonel bir stratejik analistsin.
    Verilen konu hakkinda {lang} olarak detayli analiz yap.
    Yanit her zaman gecerli JSON formatinda olmali."""

    user_prompt = f"""Konu: {req.topic}

WEB ARAMA SONUCLARI:
{context}

Yukaridaki bilgilere dayanarak asagidaki JSON yapisinda analiz uret:

{{
    "swot": [
        {{"title": "Guclu Yon", "content": "..."}},
        {{"title": "Zayif Yon", "content": "..."}},
        {{"title": "Firsat", "content": "..."}},
        {{"title": "Tehdit", "content": "..."}}
    ],
    "key_statistics": [
        {{"title": "Istatistik Basligi", "content": "Rakamsal veri ve aciklamasi"}}
    ],
    "trends": [
        {{"title": "Trend Basligi", "content": "Trend aciklamasi"}}
    ],
    "recommendations": [
        {{"title": "Tavsiye Basligi", "content": "Detayli oneri"}}
    ],
    "summary": "Kapsamli bir ozet paragrafi"
}}

Her bolumde en az 2, en fazla 4 madde olsun.
Rakamsal verileri ve somut bilgileri tercih et.
"""

    response = _ollama_chat(
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        temperature=0.3,
        max_tokens=4096,
    )

    try:
        json_str = response
        if "```json" in json_str:
            json_str = json_str.split("```json")[1].split("```")[0].strip()
        elif "```" in json_str:
            json_str = json_str.split("```")[1].split("```")[0].strip()

        data = json.loads(json_str)
        return AnalyzeResponse(
            swot=[AnalysisItem(**i) for i in data.get("swot", [])],
            key_statistics=[AnalysisItem(**i) for i in data.get("key_statistics", [])],
            trends=[AnalysisItem(**i) for i in data.get("trends", [])],
            recommendations=[AnalysisItem(**i) for i in data.get("recommendations", [])],
            summary=data.get("summary", ""),
        )
    except (json.JSONDecodeError, ValueError, TypeError) as e:
        log.warning(f"Analiz JSON ayristirma hatasi, fallback: {e}")
        return AnalyzeResponse(
            swot=[AnalysisItem(title="Genel Degerlendirme", content=response[:500])],
            key_statistics=[],
            trends=[],
            recommendations=[],
            summary=response[:500],
        )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8765)

"""
Sutols Yük Testi Senaryoları (Scenarios)
Farklı sistem bileşenlerini ve gerçek kullanıcı davranışlarını simüle eder.
"""

import json
import random
from typing import Dict, List, Tuple

TOPICS_POOL = [
    "Yapay Zeka ve Geleceğin Meslekleri",
    "Sürdürülebilir Enerji ve Karbon Ayak İzi",
    "Finansal Okuryazarlık ve Yatırım Stratejileri",
    "Dijital Pazarlama ve Büyüme Hackleri",
    "Kuantum Hesaplama ve Kriptografi",
    "Girişimcilikte Ürün-Pazar Uyumu",
    "Biyoteknoloji ve Gen Tedavisi",
    "Uzay Madenciliği ve Mars Kolonizasyonu",
    "Modern Web Mimarileri ve Mikroservisler",
    "Siber Güvenlikte Sıfır Güven (Zero Trust) Modeli",
    "Bulut Bilişim ve Sunucusuz (Serverless) Mimariler",
    "Agile ve Scrum Proje Yönetimi",
    "Müşteri Deneyimi (CX) ve Sadakat Programları",
    "Elektrikli Araçlar ve Batarya Teknolojileri",
    "E-Ticarette Dönüşüm Oranı Optimizasyonu (CRO)",
    "Nörobilim ve Öğrenme Teknikleri",
    "Blokzincir ve Akıllı Sözleşmeler",
    "Tedarik Zinciri ve Lojistik Yönetimi",
    "Kurumsal Risk Yönetimi ve Kriz İletişimi",
    "Veri Analitiği ve Büyük Veri Stratejileri"
]

SAMPLE_THUMBNAILS = [
    "thumbnails/01_SWOT_Analiz_Kupu.webp",
    "thumbnails/110_megafon.webp",
    "thumbnails/06_Risk_Matrisi.webp",
    "thumbnails/02_PESTEL_Carki.webp",
    "thumbnails/03_Is_Modeli_Kanvasi.webp",
    "thumbnails/04_Buyume_Matrisi.webp",
    "thumbnails/05_Proje_Ucgeni.webp",
    "thumbnails/07_Oncelik_Matrisi.webp",
    "thumbnails/08_Hedef_Agaci.webp",
    "thumbnails/09_Etki_Efor_Matrisi.webp"
]

SYSTEM_INSTRUCTION = """Sen akademik ve kurumsal standartlarda sunum içeriği üreten uzman bir asistansın.

TEMEL PLANLAMA VE ANLATI KURALLARI:
- Sunumu baştan sona tek bir ana tez ve mantıksal anlatı doğrultusunda yapılandır.
- Akışı temelden ayrıntıya; açıklamadan örnek ve uygulamaya; değerlendirmeden sonuca ilerlet.
- Başlıkların tamamı birbirinden farklı, kısa ve konuya özgü olsun.
- Her slayt içeriğinde 3-5 ayrı detaylı açıklama maddesi (toplam 35-65 kelime) bulundur.
- Her maddede somut bilgi, mekanizma, örnek veya karşılaştırma ver.
- Aynı cümleyi, cümle kalıbını veya bilgiyi birden fazla slaytta tekrarlama.
- "Bu sunumda...", "Bu slaytta...", "Konuya genel bakış" gibi dolgu ifadeler KESİNLİKLE KULLANMA.
- ARAYÜZ VE SİSTEM METNİ YAZMA: Slaytlara "sürükleme kolu", "drag_handle", "sahne kartı", "seçili sayfa" gibi yazılım talimatları ekleme.

ÇIKTI FORMATI:
- Yanıtı istenen dilde, Türkçe ise ç, ğ, ı, ö, ş, ü karakterlerine dikkat ederek ver.
- Slayt içerik maddeleri satır başında "- " ile başlamalıdır.
- Slayt anahtar kelimeleri (keywords), 3B modeller ve fiziksel nesnelerle doğrudan eşleşebilecek 3-8 somut nesne, araç veya yapı adı içermelidir."""


def build_ai_payload(topic: str = None, slide_count: int = 5) -> Dict:
    selected_topic = topic or random.choice(TOPICS_POOL)
    user_prompt = f"Konu: {selected_topic}\nSlayt Sayısı: {slide_count}\nÇıktı Dili: turkish"
    max_tokens = min(4096, max(300, slide_count * 180 + 200))
    
    return {
        "model": "meta/llama-3.1-8b-instruct",
        "messages": [
            {
                "role": "system",
                "content": f"{SYSTEM_INSTRUCTION}\n\nİstenen sunumu KESİNLİKLE VE YALNIZCA TEK BİR GEÇERLİ JSON NESNESİ OLARAK DÖNDÜR. "
                           f"JSON Şeması: {{\"slides\": [{{\"title\": \"Slayt Başlığı\", \"content\": \"- Açıklama 1\\n- Açıklama 2\", \"keywords\": [\"nesne1\", \"nesne2\"]}}]}}. "
                           f"Yanıtında asla ekstra metin, açıklama veya markdown kod bloğu yazma."
            },
            {
                "role": "user",
                "content": user_prompt
            }
        ],
        "temperature": 0.65,
        "max_tokens": max_tokens,
        "stream": False
    }


def get_frontend_endpoints() -> List[str]:
    return [
        "https://sutols.com/",
        "https://sutols.com/flutter_bootstrap.js",
        "https://sutols.com/version.json",
        "https://sutols.com/favicon.png",
        "https://sutols.com/manifest.json"
    ]


def get_asset_endpoints() -> List[str]:
    return [f"https://assets.sutols.com/{thumb}" for thumb in SAMPLE_THUMBNAILS]

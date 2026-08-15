import csv
import json
import math
import os
import re
from datetime import datetime, timezone
from typing import Dict, List, Tuple, Any

# Taxononmy ve dosya yolları
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TAXONOMY_PATH = os.path.join(BASE_DIR, "config", "domain_taxonomy.json")
CATALOG_PATH = os.path.join(BASE_DIR, "functions", "scripts", "models-tagged.json")
NEEDS_REVIEW_PATH = os.path.join(BASE_DIR, "needs_review.csv")

def load_taxonomy() -> Dict[str, Any]:
    with open(TAXONOMY_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def load_catalog() -> List[Dict[str, Any]]:
    with open(CATALOG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def save_catalog(data: List[Dict[str, Any]]) -> None:
    with open(CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def generate_text_embedding(text: str, dim: int = 64) -> List[float]:
    """
    Model adı ve etiketlerden deterministik normalize vector embedding üretir.
    Adım 5'teki Cosine Similarity hesabı için 64 boyutlu n-gram frekans vektörü oluşturur.
    """
    vec = [0.0] * dim
    normalized_text = text.lower().strip()
    words = re.findall(r'\w+', normalized_text)
    
    if not words:
        return vec

    for word in words:
        for i, char in enumerate(word):
            idx = (ord(char) * (i + 1)) % dim
            vec[idx] += 1.0

    # L2 Normalization
    magnitude = math.sqrt(sum(x * x for x in vec))
    if magnitude > 0:
        vec = [round(x / magnitude, 4) for x in vec]
    return vec

def classify_model(
    name: str,
    tags: List[str],
    category: str,
    valid_domains: List[str],
    taxonomy: Dict[str, Any]
) -> Tuple[str, float, str]:
    """
    Model adını, etiketlerini ve alanlarını domain taksonomisi ile eşleştirir.
    Strict Enum doğrulaması ile domain döner.
    """
    all_text = f"{name} {' '.join(tags)} {category}".lower()

    domain_scores: Dict[str, float] = {d["id"]: 0.0 for d in taxonomy["domains"]}

    # Taksonomi kelime anahtarları
    domain_keywords = {
        "yer_sekilleri": ["dağ", "vadi", "plato", "volkan", "kanyon", "delta", "buzul", "harita", "eyalet", "coğrafya", "nehir", "göl", "ova", "kıyı", "fay", "topografya"],
        "jeoloji": ["tabaka", "fay", "mineral", "kaya", "taş", "jeoloji", "katman", "yerkabuğu", "magma", "fosil"],
        "biyoloji_anatomi": ["organ", "hücre", "iskelet", "solunum", "biyoloji", "kalp", "akciğer", "kas", "damar", "dna", "rna", "genetik", "protez", "tıp", "sağlık", "hastane", "virüs", "bakteri", "göz", "kulak", "beyin", "böbrek", "karaciğer", "sinir", "enzim", "mitoz", "biyolojik", "canlı"],
        "muhendislik_mekanik": ["dişli", "motor", "türbin", "çark", "mühendislik", "cnc", "freze", "torna", "makine", "robot", "pota", "haddeleme", "rulman", "tork", "kumpas", "konveyör", "enjeksiyon", "otomasyon", "endüstri"],
        "astronomi": ["gezegen", "yıldız", "galaksi", "yörünge", "uzay", "astronomi", "güneş", "ay", "mars", "jüpiter", "uydu", "roket", "teleskop", "dünya"],
        "iklim_meteoroloji": ["bulut", "fırtına", "atmosfer", "iklim", "meteoroloji", "yağmur", "kar", "rüzgar", "kasırga", "sıcaklık", "nem", "basınç"],
        "is_finans_grafik": ["swot", "gantt", "grafik", "bar", "pasta", "çizgi", "kpi", "bütçe", "yatırım", "finans", "para", "altın", "gayrimenkul", "kanvas", "okr", "büyüme", "analiz", "pazarlama", "reklam", "satış", "sepet", "fiyat", "indirim", "kupon", "ticaret"],
        "genel_sembol": ["hedef", "rozet", "tabela", "etiket", "puzzle", "ok", "tahta", "düzenek", "simge", "sembol", "bayrak", "madalya", "kupa", "anahtar", "kilit", "işaret"]
    }

    for domain_id, keywords in domain_keywords.items():
        for kw in keywords:
            if kw in all_text:
                domain_scores[domain_id] += 1.5
                # İsimde geçiyorsa ekstra puan
                if kw in name.lower():
                    domain_scores[domain_id] += 2.0

    # En yüksek puan alan domain'i bul
    sorted_domains = sorted(domain_scores.items(), key=lambda x: x[1], reverse=True)
    best_domain, best_score = sorted_domains[0]
    second_score = sorted_domains[1][1] if len(sorted_domains) > 1 else 0.0

    # Confidence hesabı
    if best_score == 0:
        # Hiçbiri eşleşmedi, varsayılan genel sembol veya review
        return "genel_sembol", 0.40, "Hiçbir belirgin domain anahtar kelimesiyle eşleşmedi."

    confidence = round(min(1.0, 0.5 + (best_score - second_score) * 0.15 + (best_score * 0.1)), 2)
    
    # Strict Enum Check
    if best_domain not in valid_domains:
        raise ValueError(f"Geçersiz domain üretildi: {best_domain}")

    reasoning = f"'{name}' modeli ve etiketleri {best_domain} domain kelimeleriyle güçlü şekilde eşleşti (skor: {best_score})."
    return best_domain, confidence, reasoning


def run_categorization(force_reprocess: bool = False) -> None:
    taxonomy = load_taxonomy()
    valid_domains = [d["id"] for d in taxonomy["domains"]]
    catalog = load_catalog()

    total_count = len(catalog)
    categorized_count = 0
    skipped_count = 0
    needs_review_items = []
    domain_distribution = {d_id: 0 for d_id in valid_domains}

    now_iso = datetime.now(timezone.utc).isoformat()

    print(f"Kategorizasyon başlatılıyor... Toplam model sayısı: {total_count}")

    for item in catalog:
        # Idempotency kontrolü
        if not force_reprocess and item.get("categorized_at") and item.get("domain") in valid_domains:
            skipped_count += 1
            domain_distribution[item["domain"]] += 1
            continue

        model_id = item.get("fileName", item.get("name", "unknown"))
        name = item.get("name", "")
        tags = item.get("tags", [])
        category = item.get("category", "")

        domain, confidence, reasoning = classify_model(name, tags, category, valid_domains, taxonomy)

        # Embedding & Scene Preset oluştur
        text_for_emb = f"{name} {' '.join(tags)}"
        embedding_vec = generate_text_embedding(text_for_emb)

        scene_preset = {
            "camera_angle": [0.0, 1.5, 3.0],
            "scale": 1.0,
            "lighting": "studio"
        }

        if confidence < 0.6:
            needs_review_items.append({
                "model_id": model_id,
                "name": name,
                "tags": ", ".join(tags),
                "predicted_domain": domain,
                "confidence": confidence,
                "reasoning": reasoning
            })
        else:
            item["domain"] = domain
            item["domain_confidence"] = confidence
            item["embedding"] = embedding_vec
            item["scene_preset"] = scene_preset
            item["categorized_at"] = now_iso
            categorized_count += 1
            domain_distribution[domain] += 1

    # Kataloğu güncelle
    save_catalog(catalog)

    # needs_review.csv yaz
    with open(NEEDS_REVIEW_PATH, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["model_id", "name", "tags", "predicted_domain", "confidence", "reasoning"])
        writer.writeheader()
        writer.writerows(needs_review_items)

    # Özet rapor
    print("\n" + "="*50)
    print("KATEGORİZASYON ÖZET RAPORU")
    print("="*50)
    print(f"Toplam Model Sayısı     : {total_count}")
    print(f"Yeni Kategorize Edilen  : {categorized_count}")
    print(f"Atlanan (Zaten var olan): {skipped_count}")
    print(f"İnceleme Gerekli (<0.6) : {len(needs_review_items)} (needs_review.csv dosyasına yazıldı)")
    print("-" * 50)
    print("Domain Dağılımı:")
    for d_id, count in domain_distribution.items():
        label = next((d["label"] for d in taxonomy["domains"] if d["id"] == d_id), d_id)
        print(f"  - {d_id} ({label}): {count}")
    print("="*50)

if __name__ == "__main__":
    run_categorization(force_reprocess=True)

"""
Sutols Master Kademeli Yük Testi Orkestratörü (Stage Orchestrator)
Aşama 1 (100 VU), Aşama 2 (250 VU), Aşama 3 (500 VU) ve Aşama 4 (Limit Tüketme) testlerini koşturur.
"""

import asyncio
import json
import os
import sys
import time

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

# Scriptin bulunduğu dizini modül arama yoluna ekle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from load_tester import AsyncLoadTester
from metrics import MetricsCollector


async def main():
    print("=" * 80)
    print("       SUTOLS KADEMELİ YÜK TESTİ VE KAPASİTE ANALİZİ BAŞLATILIYOR")
    print("=" * 80)
    print(" Hedef Sistemler:")
    print("   1. Web Frontend (Firebase Hosting / CDN): https://sutols.com")
    print("   2. AI Proxy Worker (NVIDIA LLaMA 3.1 8B): https://sutols.online")
    print("   3. 3D Model & Varlık Proxy:              https://assets.sutols.com")
    print("=" * 80)

    tester = AsyncLoadTester(timeout_sec=60.0)
    all_summaries = []

    # -------------------------------------------------------------
    # ADIM 0: ÖN KONTROL (Smoke Test)
    # -------------------------------------------------------------
    print("\n[ADIM 0] Uç Nokta Ön Kontrolü (Smoke Test - 1 İstek)...")
    smoke_fe = await tester.run_frontend_load(concurrency=1, total_requests=3, name="Smoke Test (Frontend)")
    all_summaries.append(smoke_fe.compute_summary())

    smoke_asset = await tester.run_asset_load(concurrency=1, total_requests=3, name="Smoke Test (Assets)")
    all_summaries.append(smoke_asset.compute_summary())

    smoke_ai = await tester.run_ai_generation_load(concurrency=1, total_requests=1, name="Smoke Test (AI Proxy)")
    all_summaries.append(smoke_ai.compute_summary())

    # -------------------------------------------------------------
    # AŞAMA 1: 100 EŞZAMANLI KULLANICI (Baseline)
    # -------------------------------------------------------------
    print("\n" + "#" * 80)
    print(" 🎯 AŞAMA 1: 100 EŞZAMANLI KULLANICI (BASELINE)")
    print("#" * 80)

    fe_100 = await tester.run_frontend_load(concurrency=100, total_requests=100, name="Aşama 1 - Frontend")
    all_summaries.append(fe_100.compute_summary())

    asset_100 = await tester.run_asset_load(concurrency=100, total_requests=100, name="Aşama 1 - Asset Proxy")
    all_summaries.append(asset_100.compute_summary())

    ai_100 = await tester.run_ai_generation_load(concurrency=25, total_requests=50, name="Aşama 1 - AI Proxy (100 VU Trafiği)")
    all_summaries.append(ai_100.compute_summary())

    # -------------------------------------------------------------
    # AŞAMA 2: 250 EŞZAMANLI KULLANICI (Mid Peak)
    # -------------------------------------------------------------
    print("\n" + "#" * 80)
    print(" 🎯 AŞAMA 2: 250 EŞZAMANLI KULLANICI (ORTA YÜK / PİK)")
    print("#" * 80)

    fe_250 = await tester.run_frontend_load(concurrency=250, total_requests=250, name="Aşama 2 - Frontend")
    all_summaries.append(fe_250.compute_summary())

    asset_250 = await tester.run_asset_load(concurrency=250, total_requests=250, name="Aşama 2 - Asset Proxy")
    all_summaries.append(asset_250.compute_summary())

    ai_250 = await tester.run_ai_generation_load(concurrency=50, total_requests=100, name="Aşama 2 - AI Proxy (250 VU)")
    all_summaries.append(ai_250.compute_summary())

    # -------------------------------------------------------------
    # AŞAMA 3: 500 EŞZAMANLI KULLANICI (High Load)
    # -------------------------------------------------------------
    print("\n" + "#" * 80)
    print(" 🎯 AŞAMA 3: 500 EŞZAMANLI KULLANICI (YÜKSEK YÜK)")
    print("#" * 80)

    fe_500 = await tester.run_frontend_load(concurrency=400, total_requests=500, name="Aşama 3 - Frontend")
    all_summaries.append(fe_500.compute_summary())

    asset_500 = await tester.run_asset_load(concurrency=400, total_requests=500, name="Aşama 3 - Asset Proxy")
    all_summaries.append(asset_500.compute_summary())

    ai_500 = await tester.run_ai_generation_load(concurrency=75, total_requests=150, name="Aşama 3 - AI Proxy (500 VU)")
    all_summaries.append(ai_500.compute_summary())

    # -------------------------------------------------------------
    # AŞAMA 4: LİMİT TÜKETME VE STRES TESTİ (Exhaustion)
    # -------------------------------------------------------------
    print("\n" + "#" * 80)
    print(" 🎯 AŞAMA 4: AI LİMİT TÜKETME VE KIRILMA NOKTASI TESTİ (BURST STRESS)")
    print("#" * 80)

    ai_exhaust = await tester.run_stress_until_exhaustion(concurrency=60, batch_size=50, max_batches=15, target_429_count=15)
    all_summaries.append(ai_exhaust.compute_summary())

    # Sonuçları JSON olarak kaydet
    out_dir = os.path.dirname(os.path.abspath(__file__))
    result_file = os.path.join(out_dir, "load_test_results.json")
    with open(result_file, "w", encoding="utf-8") as f:
        json.dump(all_summaries, f, ensure_ascii=False, indent=2)

    print(f"\n✅ TÜM TESTLER TAMAMLANDI! Ayrıntılı ham veriler kaydedildi: {result_file}")


if __name__ == "__main__":
    asyncio.run(main())

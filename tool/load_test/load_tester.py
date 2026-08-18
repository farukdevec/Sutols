"""
Asenkron Yük Testi Motoru (Async Load Tester Engine)
httpx ve asyncio ile yüksek eşzamanlı HTTP istekleri yönetir.
"""

import asyncio
import json
import sys
import time
from typing import Callable, List, Optional
import httpx

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

from metrics import MetricsCollector, RequestResult
from scenarios import (
    build_ai_payload,
    get_frontend_endpoints,
    get_asset_endpoints,
    SAMPLE_THUMBNAILS,
    TOPICS_POOL
)


class AsyncLoadTester:
    def __init__(self, timeout_sec: float = 60.0):
        self.timeout = httpx.Timeout(timeout_sec, connect=15.0)
        self.limits = httpx.Limits(max_keepalive_connections=300, max_connections=600)

    async def _execute_single_request(
        self,
        client: httpx.AsyncClient,
        method: str,
        url: str,
        headers: dict,
        scenario: str,
        collector: MetricsCollector,
        semaphore: asyncio.Semaphore,
        json_body: Optional[dict] = None,
    ) -> RequestResult:
        async with semaphore:
            start = time.perf_counter()
            status_code = 0
            success = False
            error_msg = None
            resp_bytes = 0

            try:
                if method == "GET":
                    resp = await client.get(url, headers=headers)
                elif method == "POST":
                    resp = await client.post(url, headers=headers, json=json_body)
                else:
                    raise ValueError(f"Desteklenmeyen metod: {method}")

                status_code = resp.status_code
                resp_bytes = len(resp.content)
                duration_ms = (time.perf_counter() - start) * 1000.0

                if 200 <= status_code < 400:
                    success = True
                elif status_code == 429:
                    success = False
                    error_msg = "429 Too Many Requests (Rate Limit / Quota Exceeded)"
                elif status_code >= 500:
                    success = False
                    error_msg = f"HTTP {status_code} Server Error"
                else:
                    success = False
                    error_msg = f"HTTP {status_code}"

            except httpx.TimeoutException:
                duration_ms = (time.perf_counter() - start) * 1000.0
                status_code = 504
                error_msg = "Timeout (>{}s)".format(self.timeout.read)
            except httpx.ConnectError as e:
                duration_ms = (time.perf_counter() - start) * 1000.0
                status_code = 502
                error_msg = f"ConnectError: {str(e)[:40]}"
            except Exception as e:
                duration_ms = (time.perf_counter() - start) * 1000.0
                status_code = 500
                error_msg = f"{type(e).__name__}: {str(e)[:40]}"

            res = RequestResult(
                scenario=scenario,
                endpoint=url,
                status_code=status_code,
                duration_ms=duration_ms,
                success=success,
                error_message=error_msg,
                response_bytes=resp_bytes
            )
            collector.record(res)
            return res

    async def run_frontend_load(
        self,
        concurrency: int,
        total_requests: int,
        name: str = "Frontend Statik Yük Testi"
    ) -> MetricsCollector:
        collector = MetricsCollector(f"{name} ({concurrency} Eşzamanlı Kullanıcı)")
        endpoints = get_frontend_endpoints()
        semaphore = asyncio.Semaphore(concurrency)
        headers = {"User-Agent": "SutolsLoadTester/1.0", "Accept": "*/*"}

        print(f"\n🚀 [{collector.name}] Başlatılıyor: {total_requests} istek, {concurrency} eşzamanlı bağlantı...")
        collector.start()

        async with httpx.AsyncClient(timeout=self.timeout, limits=self.limits, follow_redirects=True) as client:
            tasks = []
            for i in range(total_requests):
                url = endpoints[i % len(endpoints)]
                t = asyncio.create_task(
                    self._execute_single_request(
                        client=client,
                        method="GET",
                        url=url,
                        headers=headers,
                        scenario="Frontend",
                        collector=collector,
                        semaphore=semaphore
                    )
                )
                tasks.append(t)
            await asyncio.gather(*tasks)

        collector.stop()
        collector.print_report()
        return collector

    async def run_ai_generation_load(
        self,
        concurrency: int,
        total_requests: int,
        name: str = "AI Model Proxy Yük Testi"
    ) -> MetricsCollector:
        collector = MetricsCollector(f"{name} ({concurrency} Eşzamanlı İstek)")
        url = "https://sutols.online/"
        semaphore = asyncio.Semaphore(concurrency)
        headers = {
            "Content-Type": "application/json",
            "Origin": "https://sutols.com",
            "User-Agent": "SutolsLoadTester/1.0"
        }

        print(f"\n🧠 [{collector.name}] Başlatılıyor: {total_requests} AI isteği, {concurrency} eşzamanlı...")
        collector.start()

        async with httpx.AsyncClient(timeout=self.timeout, limits=self.limits) as client:
            tasks = []
            for i in range(total_requests):
                payload = build_ai_payload(slide_count=5)
                t = asyncio.create_task(
                    self._execute_single_request(
                        client=client,
                        method="POST",
                        url=url,
                        headers=headers,
                        scenario="AI Proxy",
                        collector=collector,
                        semaphore=semaphore,
                        json_body=payload
                    )
                )
                tasks.append(t)
            await asyncio.gather(*tasks)

        collector.stop()
        collector.print_report()
        return collector

    async def run_asset_load(
        self,
        concurrency: int,
        total_requests: int,
        name: str = "3D Asset & Thumbnail Proxy Yük Testi"
    ) -> MetricsCollector:
        collector = MetricsCollector(f"{name} ({concurrency} Eşzamanlı Kullanıcı)")
        endpoints = get_asset_endpoints()
        semaphore = asyncio.Semaphore(concurrency)
        headers = {
            "Origin": "https://sutols.com",
            "User-Agent": "SutolsLoadTester/1.0"
        }

        print(f"\n📦 [{collector.name}] Başlatılıyor: {total_requests} varlık isteği, {concurrency} eşzamanlı...")
        collector.start()

        async with httpx.AsyncClient(timeout=self.timeout, limits=self.limits) as client:
            tasks = []
            for i in range(total_requests):
                url = endpoints[i % len(endpoints)]
                t = asyncio.create_task(
                    self._execute_single_request(
                        client=client,
                        method="GET",
                        url=url,
                        headers=headers,
                        scenario="AssetProxy",
                        collector=collector,
                        semaphore=semaphore
                    )
                )
                tasks.append(t)
            await asyncio.gather(*tasks)

        collector.stop()
        collector.print_report()
        return collector

    async def run_stress_until_exhaustion(
        self,
        concurrency: int = 50,
        batch_size: int = 50,
        max_batches: int = 20,
        target_429_count: int = 10
    ) -> MetricsCollector:
        collector = MetricsCollector(f"AI Limit Tüketme & Stres Testi (Burst Stress)")
        url = "https://sutols.online/"
        headers = {
            "Content-Type": "application/json",
            "Origin": "https://sutols.com",
            "User-Agent": "SutolsLoadTester/1.0"
        }

        print(f"\n⚡ [{collector.name}] Başlatılıyor: Limit tükenene veya {target_429_count} adet 429 alınana kadar aralıksız istek...")
        collector.start()

        rate_limit_hits = 0
        total_batches_run = 0

        async with httpx.AsyncClient(timeout=self.timeout, limits=self.limits) as client:
            semaphore = asyncio.Semaphore(concurrency)

            for b in range(1, max_batches + 1):
                total_batches_run = b
                print(f"   🔥 Dalga {b}/{max_batches} ({batch_size} istek gönderiliyor)...")
                tasks = []
                for _ in range(batch_size):
                    payload = build_ai_payload(slide_count=5)
                    t = asyncio.create_task(
                        self._execute_single_request(
                            client=client,
                            method="POST",
                            url=url,
                            headers=headers,
                            scenario="AI Stress",
                            collector=collector,
                            semaphore=semaphore,
                            json_body=payload
                        )
                    )
                    tasks.append(t)

                batch_results = await asyncio.gather(*tasks)
                batch_429s = sum(1 for r in batch_results if r.status_code == 429)
                rate_limit_hits += batch_429s

                print(f"      -> Dalga {b} bitti: {batch_429s} adet 429 Rate Limit yakalandı. (Kümülatif 429: {rate_limit_hits})")

                if rate_limit_hits >= target_429_count:
                    print(f"\n🛑 HEDEF KOTA LİMİTİ TÜKENDİ! Toplam {rate_limit_hits} adet 429 Too Many Requests yanıtı alındı.")
                    break

        collector.stop()
        collector.print_report()
        return collector

"""
Metrik ve İstatistik Toplayıcı (Metrics Engine)
Yük testi sırasında yapılan tüm isteklerin gecikme, durum kodu ve hata verilerini toplar.
"""

import math
import sys
import time
from dataclasses import dataclass, field
from typing import Dict, List, Optional

if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass


@dataclass
class RequestResult:
    scenario: str
    endpoint: str
    status_code: int
    duration_ms: float
    success: bool
    error_message: Optional[str] = None
    response_bytes: int = 0
    timestamp: float = field(default_factory=time.time)


class MetricsCollector:
    def __init__(self, name: str):
        self.name = name
        self.results: List[RequestResult] = []
        self.start_time: float = 0.0
        self.end_time: float = 0.0

    def start(self):
        self.start_time = time.time()

    def stop(self):
        self.end_time = time.time()

    def record(self, result: RequestResult):
        self.results.append(result)

    @property
    def total_duration(self) -> float:
        if self.end_time > self.start_time:
            return self.end_time - self.start_time
        return max(0.001, time.time() - self.start_time)

    def compute_summary(self) -> Dict:
        if not self.results:
            return {"total_requests": 0}

        total_requests = len(self.results)
        successful_requests = sum(1 for r in self.results if r.success)
        failed_requests = total_requests - successful_requests

        status_counts: Dict[int, int] = {}
        error_types: Dict[str, int] = {}
        latencies: List[float] = []
        total_bytes = 0

        for r in self.results:
            status_counts[r.status_code] = status_counts.get(r.status_code, 0) + 1
            if not r.success and r.error_message:
                error_types[r.error_message] = error_types.get(r.error_message, 0) + 1
            latencies.append(r.duration_ms)
            total_bytes += r.response_bytes

        latencies.sort()
        duration_sec = self.total_duration
        rps = total_requests / duration_sec if duration_sec > 0 else 0

        def percentile(p: float) -> float:
            if not latencies:
                return 0.0
            idx = int(math.ceil((p / 100.0) * len(latencies))) - 1
            return latencies[max(0, min(idx, len(latencies) - 1))]

        avg_lat = sum(latencies) / len(latencies) if latencies else 0.0
        variance = sum((x - avg_lat) ** 2 for x in latencies) / len(latencies) if latencies else 0.0
        std_dev = math.sqrt(variance)

        return {
            "name": self.name,
            "total_requests": total_requests,
            "successful_requests": successful_requests,
            "failed_requests": failed_requests,
            "success_rate_pct": (successful_requests / total_requests) * 100 if total_requests else 0,
            "duration_sec": duration_sec,
            "rps": rps,
            "total_kb": total_bytes / 1024,
            "latency_ms": {
                "min": latencies[0] if latencies else 0.0,
                "median": percentile(50),
                "avg": avg_lat,
                "p90": percentile(90),
                "p95": percentile(95),
                "p99": percentile(99),
                "max": latencies[-1] if latencies else 0.0,
                "std_dev": std_dev,
            },
            "status_codes": status_counts,
            "errors": error_types,
        }

    def print_report(self):
        s = self.compute_summary()
        if s.get("total_requests", 0) == 0:
            print(f"[{self.name}] Hiç istek kaydı bulunamadı.")
            return

        print("\n" + "=" * 70)
        print(f" 📊 YÜK TESTİ RAPORU: {s['name']}")
        print("=" * 70)
        print(f" Toplam İstek:        {s['total_requests']:>6}  |  Süre: {s['duration_sec']:.2f} sn  |  RPS: {s['rps']:.2f} req/s")
        print(f" Başarılı:            {s['successful_requests']:>6} ({s['success_rate_pct']:.1f}%)")
        print(f" Başarısız / Hata:    {s['failed_requests']:>6} ({100 - s['success_rate_pct']:.1f}%)")
        print(f" Toplam Veri Akışı:   {s['total_kb']:.1f} KB")
        print("-" * 70)
        print(" Gecikme Dağılımı (Latency):")
        lat = s['latency_ms']
        print(f"   Min:    {lat['min']:>8.1f} ms  |  Medyan: {lat['median']:>8.1f} ms  |  Ortalama: {lat['avg']:>8.1f} ms")
        print(f"   p90:    {lat['p90']:>8.1f} ms  |  p95:    {lat['p95']:>8.1f} ms  |  p99:      {lat['p99']:>8.1f} ms")
        print(f"   Max:    {lat['max']:>8.1f} ms  |  StdDev: {lat['std_dev']:>8.1f} ms")
        print("-" * 70)
        print(" HTTP Durum Kodları:")
        for code, count in sorted(s['status_codes'].items()):
            pct = (count / s['total_requests']) * 100
            print(f"   HTTP {code}: {count:>5} (%{pct:.1f})")
        
        if s['errors']:
            print("-" * 70)
            print(" Hata Dağılımı:")
            for err, count in s['errors'].items():
                print(f"   - {err}: {count} adet")
        print("=" * 70 + "\n")

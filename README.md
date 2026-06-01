# 디지털 도어락 FSM 프로젝트

FPGA 기반 비밀번호 잠금 장치 — Cyclone II (EP2C8Q208C8) / Quartus II 13.0 SP1

> 명세서 기준: `도어락_FSM_명세서_v2.pdf`

---

## 모듈 구조

```
TACT_SW[12:0]
    └── top_module (키 디코딩)
            └── fsm_module (메인 FSM)
                    ├── unlock_on / alarm_on
                    ├── key_led / state[2:0]
                    └── input_count_led[3:0]
                            └── LEDR[7:0]
```

---

## 파일 목록

| 파일 | 설명 |
|---|---|
| `top_module.v` | 최상위 모듈 — TACT_SW 디코딩 후 FSM 연결 |
| `fsm_module.v` | 메인 FSM (6-state) |
| `fsm_module_tb.v` | FSM 시뮬레이션 테스트벤치 |
| `input_manager.qsf` | Quartus 프로젝트 설정 및 핀 배정 |

---

## 포트 인터페이스 (top_module)

| 포트 | 방향 | 비트 | 설명 |
|---|---|---|---|
| `clk_1khz` | in | 1 | 1 kHz 시스템 클럭 |
| `rst` | in | 1 | 비동기 리셋 (active-high) — ALARM 해제 유일 경로 |
| `TACT_SW[12:0]` | in | 13 | 택트 스위치 입력 |
| `LEDR[7:0]` | out | 8 | 상태 표시 LED |

---

## 스위치 매핑 (TACT_SW)

| 스위치 | 신호 | 역할 |
|---|---|---|
| `TACT_SW[0]~[9]` | `digit_in` / `key_valid` | 숫자 0~9 (우선순위: 낮은 번호 우선) |
| `TACT_SW[10]` | `enter` | 입력 완료 / 확정 |
| `TACT_SW[11]` | `change` | 비밀번호 변경 모드 (UNLOCK 상태에서만 유효) |
| `TACT_SW[12]` | `auto_open` | 내부 버튼 — 즉시 잠금 해제 |

---

## LED 매핑 (LEDR)

| LED | 신호 | 의미 |
|---|---|---|
| `LEDR[3:0]` | `input_count_led` | 입력 자릿수 (온도계: 0001→0011→0111→1111) |
| `LEDR[4]` | `key_led` | 키 입력 시 1클럭 펄스 |
| `LEDR[5]` | `unlock_on` | 잠금 해제 표시 |
| `LEDR[6]` | `alarm_on` | 경보 표시 |
| `LEDR[7]` | `auto_open` | 내부 버튼 입력 표시 |

---

## FSM 상태 (6-state · 3-bit)

| 상태 | 인코딩 | 설명 |
|---|---|---|
| `IDLE` | 3'd0 | 대기 — 숫자 키 또는 auto_open 대기 |
| `INPUT` | 3'd1 | 비밀번호 입력 중 |
| `CHECK` | 3'd2 | 입력값 비교 (1클럭 경유) |
| `UNLOCK` | 3'd3 | 잠금 해제 — enter=재잠금, change=변경모드 |
| `ALARM` | 3'd4 | 3회 실패 시 진입 — rst로만 해제 |
| `CHANGE` | 3'd5 | 새 비밀번호 입력 — enter 시 즉시 저장 후 IDLE |

---

## 주요 동작

- **기본 비밀번호**: `1234` (전원 인가 시 initial 블록으로 보장, rst 시 재초기화)
- **실패 정책**: 1·2회 실패 → IDLE 복귀, 3회째 → ALARM
- **경보 해제**: `rst` 버튼만 가능 (PIN_206)
- **비밀번호 변경**: UNLOCK 상태에서 `change` → 새 번호 입력 → `enter`
- **자동 잠금**: 미구현 (UNLOCK에서 `enter`로 수동 재잠금)

---

## 핀 배정 요약

| 신호 | PIN |
|---|---|
| `clk_1khz` | PIN_132 |
| `rst` | PIN_206 |
| `TACT_SW[0~12]` | PIN_110, 112~116, 101, 104, 103, 105~107, 95 |
| `LEDR[0~7]` | PIN_63, 60, 58, 56, 48, 46, 44, 41 |

---

## 시뮬레이션 (iverilog)

```bash
iverilog -o fsm_tb.vvp fsm_module.v fsm_module_tb.v
vvp fsm_tb.vvp
```

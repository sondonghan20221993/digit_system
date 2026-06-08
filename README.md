# 디지털 도어락 FSM 프로젝트

FPGA 기반 비밀번호 잠금 장치 — Cyclone II (EP2C8Q208C8) / Quartus II 13.0 SP1

> 명세서 기준: `도어락_FSM_명세서_v2.pdf`

---

## 모듈 구조

```
TACT_SW[12:0]
    └── top_module
            ├── input_manager (디바운싱 + 입력 lock)
            │       └── button_debounce × 13
            ├── fsm_module (메인 FSM, 6-state)
            │       ├── auto_lock_timer (UNLOCK 자동잠금)
            │       └── auto_lock_timer (INPUT/CHANGE 타임아웃)
            ├── fnd_team_adapter (FND 출력)
            ├── led_controller (16-LED 출력)
            └── piezo_alarm (경보음)
```

---

## 파일 목록

| 파일 | 설명 |
|---|---|
| `top_module.v` | 최상위 모듈 — 서브모듈 연결 및 blink 생성 |
| `fsm_module.v` | 메인 FSM (6-state) + 타이머 |
| `input_manager.v` | 디바운싱 + 입력 lock 게이팅 |
| `button_debounce.v` | 단일 버튼 디바운서 |
| `fsm_module_tb.v` | FSM 시뮬레이션 테스트벤치 |
| `lock_tb.v` | 입력 lock 기능 검증 테스트벤치 |
| `도어락_FSM_명세서_v2.pdf` | 팀 통합 명세서 |

---

## 포트 인터페이스 (top_module)

| 포트 | 방향 | 비트 | 설명 |
|---|---|---|---|
| `clk_1khz` | in | 1 | 1 kHz 시스템 클럭 |
| `RESET_N` | in | 1 | 비동기 리셋 (active-low) — ALARM 해제 유일 경로 |
| `TACT_SW[12:0]` | in | 13 | 택트 스위치 입력 |
| `LEDR[15:0]` | out | 16 | 상태 표시 LED |
| `FND_SEG[7:0]` | out | 8 | FND 세그먼트 |
| `FND_COM[3:0]` | out | 4 | FND 자리 선택 |
| `piezo` | out | 1 | 경보 부저 |

---

## 스위치 매핑 (TACT_SW)

| 스위치 | 신호 | 역할 |
|---|---|---|
| `TACT_SW[0]~[9]` | `digit_in` / `key_valid` | 숫자 0~9 (우선순위: 낮은 번호 우선) |
| `TACT_SW[10]` | `enter` | 입력 완료 / 확정 |
| `TACT_SW[11]` | `change` | 비밀번호 변경 모드 (UNLOCK 상태에서만 유효) |
| `TACT_SW[12]` | `auto_open` | 내부 버튼 — 즉시 잠금 해제 |

---

## FSM 상태 (6-state · 3-bit)

| 상태 | 인코딩 | 설명 |
|---|---|---|
| `IDLE` | 3'd0 | 대기 — 숫자 키 또는 auto_open 대기 |
| `INPUT` | 3'd1 | 비밀번호 입력 중 (10초 비활동 시 IDLE 복귀) |
| `CHECK` | 3'd2 | 입력값 비교 (1클럭 경유) |
| `UNLOCK` | 3'd3 | 잠금 해제 — 10초 후 자동 재잠금 또는 enter로 수동 재잠금 |
| `ALARM` | 3'd4 | 3회 실패 시 진입 — RESET_N으로만 해제, **모든 입력 차단** |
| `CHANGE` | 3'd5 | 새 비밀번호 입력 — enter 시 즉시 저장 후 IDLE |

---

## 주요 동작

- **기본 비밀번호**: `1234` (rst 시 재초기화)
- **실패 정책**: 1·2회 실패 → IDLE 복귀, 3회째 → ALARM
- **경보 해제**: `RESET_N` 버튼만 가능
- **입력 lock**: ALARM 상태에서 `input_manager`가 모든 키 입력을 차단 (`alarm_on → lock`)
- **자동 잠금**: UNLOCK 상태 10초 경과 시 IDLE 복귀
- **입력 타임아웃**: INPUT/CHANGE 상태에서 10초 비활동 시 IDLE 복귀
- **비밀번호 변경**: UNLOCK 상태에서 `change` → 4자리 입력 → `enter`

---

## 핀 배정 요약

| 신호 | PIN |
|---|---|
| `clk_1khz` | PIN_132 |
| `RESET_N` | PIN_206 |
| `TACT_SW[0~12]` | PIN_110, 112~116, 101, 104, 103, 105~107, 95 |
| `LEDR[0~7]` | PIN_63, 60, 58, 56, 48, 46, 44, 41 |

---

## 시뮬레이션 (ModelSim ASE)

```bash
# FSM 동작 테스트
vlog button_debounce.v input_manager.v fsm_module.v fsm_module_tb.v
vsim -c -do "run -all; quit" fsm_module_tb

# 입력 lock 기능 테스트
vlog button_debounce.v input_manager.v fsm_module.v lock_tb.v
vsim -c -do "run -all; quit" lock_tb
```

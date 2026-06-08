# 입력부 구조 정리

이 문서는 디지털 도어락 프로젝트에서 입력 담당 모듈의 구조와 키 매핑을 정리한 문서입니다.

## 모듈 구조

```text
top_module
└── input_manager
        └── button_debounce × 13
```

key_encoder, input_buffer 서브모듈은 제거됨. 인코딩과 버퍼 관리는 각각 input_manager(assign)와 fsm_module로 이전.

## 입력 신호 흐름

```text
tact_sw[12:0]
-> button_debounce × 13
-> btn_state[12:0]
-> (lock=0일 때) key_valid, digit_in, enter, change, auto_open
-> fsm_module
```

lock=1(ALARM 상태)이면 key_valid / enter / change / auto_open 이 모두 0으로 차단됨.

## 키 매핑

| 스위치 | 역할 | 출력 신호 |
|---|---|---|
| `tact_sw[0]` | 숫자 0 | `key_valid=1`, `digit_in=0` |
| `tact_sw[1]` | 숫자 1 | `key_valid=1`, `digit_in=1` |
| `tact_sw[2]` | 숫자 2 | `key_valid=1`, `digit_in=2` |
| `tact_sw[3]` | 숫자 3 | `key_valid=1`, `digit_in=3` |
| `tact_sw[4]` | 숫자 4 | `key_valid=1`, `digit_in=4` |
| `tact_sw[5]` | 숫자 5 | `key_valid=1`, `digit_in=5` |
| `tact_sw[6]` | 숫자 6 | `key_valid=1`, `digit_in=6` |
| `tact_sw[7]` | 숫자 7 | `key_valid=1`, `digit_in=7` |
| `tact_sw[8]` | 숫자 8 | `key_valid=1`, `digit_in=8` |
| `tact_sw[9]` | 숫자 9 | `key_valid=1`, `digit_in=9` |
| `tact_sw[10]` | 입력 완료 (ENTER) | `enter=1` |
| `tact_sw[11]` | 비밀번호 변경 (CHANGE) | `change=1` |
| `tact_sw[12]` | 내부 잠금 해제 (AUTO_OPEN) | `auto_open=1` |

## FSM으로 전달되는 신호

| 신호명 | 비트 | 설명 |
|---|---|---|
| `key_valid` | 1 | 숫자 키 입력 발생 (lock=1이면 강제 0) |
| `digit_in` | 4 | 입력된 숫자 값 0~9 |
| `enter` | 1 | 입력 완료 확정 (lock=1이면 강제 0) |
| `change` | 1 | 비밀번호 변경 모드 진입 (lock=1이면 강제 0) |
| `auto_open` | 1 | 내부 즉시 잠금 해제 (lock=1이면 강제 0) |

## 입력 lock 설명

`lock` 포트는 ALARM 상태에서 모든 키 입력을 소스 레벨에서 차단합니다.

```text
fsm_module.alarm_on
-> top_module: .lock(alarm_on)
-> input_manager.lock
-> key_valid / enter / change / auto_open = 0 (강제 차단)
```

RESET_N은 input_manager를 거치지 않는 하드웨어 신호이므로 lock과 무관하게 동작합니다.

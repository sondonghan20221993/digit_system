# 입력부 구조 정리

이 문서는 디지털 도어락 프로젝트에서 입력 담당 모듈의 구조와 키 매핑을 정리한 문서입니다.

## 모듈 구조

```text
top
+-- input_manager
    +-- button_debounce
    +-- key_encoder
    +-- input_buffer
```

## 입력 신호 흐름

```text
button_in[15:0]
-> button_debounce
-> btn_pulse[15:0]
-> key_encoder
-> key_valid, key_data, hash_key, admin_key, clear_key, inside_unlock_btn
-> input_buffer
-> input_count, pass_buffer
```

## 키 매핑

| 버튼 입력 | 역할 | 출력 신호 |
| --- | --- | --- |
| `button_in[0]` | 숫자 0 | `key_valid=1`, `key_data=0` |
| `button_in[1]` | 숫자 1 | `key_valid=1`, `key_data=1` |
| `button_in[2]` | 숫자 2 | `key_valid=1`, `key_data=2` |
| `button_in[3]` | 숫자 3 | `key_valid=1`, `key_data=3` |
| `button_in[4]` | 숫자 4 | `key_valid=1`, `key_data=4` |
| `button_in[5]` | 숫자 5 | `key_valid=1`, `key_data=5` |
| `button_in[6]` | 숫자 6 | `key_valid=1`, `key_data=6` |
| `button_in[7]` | 숫자 7 | `key_valid=1`, `key_data=7` |
| `button_in[8]` | 숫자 8 | `key_valid=1`, `key_data=8` |
| `button_in[9]` | 숫자 9 | `key_valid=1`, `key_data=9` |
| `button_in[10]` | # / 입력 완료 | `hash_key=1` |
| `button_in[11]` | 관리자 모드 / A 버튼 | `admin_key=1` |
| `button_in[12]` | 입력 초기화 | `clear_key=1` |
| `button_in[13]` | 내부 잠금 해제 버튼 | `inside_unlock_btn=1` |
| `button_in[14]` | 미사용 | 없음 |
| `button_in[15]` | 미사용 | 없음 |

## FSM으로 전달 가능한 신호

입력부에서 도어락 FSM으로 넘길 수 있는 신호는 다음과 같습니다.

| 신호명 | 비트 | 설명 |
| --- | --- | --- |
| `key_valid` | 1비트 | 키 입력이 발생했음을 알리는 펄스 신호 |
| `key_data` | 4비트 | 입력된 숫자 값, 0~9 |
| `hash_key` | 1비트 | # 버튼, 비밀번호 입력 완료 |
| `admin_key` | 1비트 | 관리자 모드 진입 버튼 |
| `inside_unlock_btn` | 1비트 | 내부에서 비밀번호 없이 잠금 해제하는 버튼 |
| `input_count` | 3비트 | 현재 입력된 비밀번호 자리 수 |
| `pass_buffer` | 16비트 | 현재까지 입력된 4자리 비밀번호 버퍼 |

## clear_key 설명

`clear_key`는 FSM 명세서에는 없는 신호입니다.
하지만 기존 입력부에서 이미 검증된 기능이므로 유지합니다.

역할은 `input_buffer` 내부에서 현재 입력된 값을 지우는 것입니다.

```text
clear_key=1
-> input_count 초기화
-> pass_buffer 초기화
```

## inside_unlock_btn 설명

`inside_unlock_btn`은 명세서에 있는 입력 신호입니다.
문 안쪽에서 누르는 잠금 해제 버튼 역할입니다.

비밀번호 입력 없이 바로 잠금 해제를 요청하는 신호이며, 현재는 `button_in[13]`에 연결되어 있습니다.

```text
button_in[13]
-> inside_unlock_btn=1
```

## 정리

- 기존 입력부 동작은 유지했습니다.
- `clear_key`는 기존 입력 초기화 기능으로 그대로 둡니다.
- `inside_unlock_btn`은 새 신호로 추가했습니다.
- 현재 `inside_unlock_btn`은 `button_in[13]`에 배정되어 있습니다.

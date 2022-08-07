;

PIN_UART   = 3
MASK_UART  = 1<<(PIN_UART)

BAD_DATA = 1
NEW_DATA = 0

.macro uart_init
	mov a, #MASK_UART
	mov paph, a
	clear wait_count
	clear bit_count
	clear data
	clear data_flag
	clear new_data
.endm

;
; UART STATE MACHINE
;
; .__________________. <-----------------------------------.
; |                  | <-.                                 |
; |    uart idle     |   | no start bit                    |
; |_________.________|---'                                 |
;           |                                              |
;           | wait_count = 33                              |
; ._________V________. <-------------------------------.   |
; |                  | <-.                             |   |
; |  uart countdown  |   | 1.) while ( --wait_count )  |   |
; |___.______________|---'                             |   |
;     |             `-----------------------.          |   |
;  2. | while (--bit_count)        3.) else |          |   |
; .___V______________.                      |          |   |
; |                  |                      |          |   |
; |   uart sample    | wait_count = 22      |          |   |
; |__________________|----------------------|----------'   |
;                                  .________V_________.    |
;                               .->|                  |    |
;                      bad bit  |  |  uart stop bit   |    |
;                               '--|__________________|    |
;                                           |              |
;                                  .________V_________.    |
;                                  |                  |    |
;                                  |    uart read     |----'
;                                  |__________________|    
;
; prereq: wait_count = 0 ; bit_count = 0
;

.macro uart_idle out_idle, out_countdown, ?l1, ?l2
	t0sn pa, #PIN_UART      ; 0 + 1
	goto l1                 ; 1 + 1 | 2 --.
	mov a, #18              ; 2 + 1       |
	mov wait_count, a       ; 3 + 1       |  [ wait_count = 17 ]
	mov a, #9               ; 4 + 1       |
	mov bit_count, a        ; 5 + 1       |  [ bit_count = 9 ]
	goto out_countdown      ; 6 + 2 = 8   |
l1:	goto l2                 ; 3 + 2     <-'
l2:	nop                     ; 5 + 1
	goto out_idle           ; 6 + 2 = 8
.endm

.macro uart_countdown out_countdown, out_sample, out_stop_bit, ?l1, ?l2, ?l3, ?l4
	dzsn wait_count         ; 0 + 1
	goto l1                 ; 1 + 1 | 2   --.
	dzsn bit_count          ; 2 + 1         |
	goto l2                 ; 3 + 1 | 2     |
	goto l3                 ; 4 + 2         |
l3:	goto out_stop_bit       ; 6 + 2 = 8     |
l2:	sr data                 ; 5 + 1         | [ save cycle in uart_sample :-) ]
	goto out_sample         ; 6 + 2 = 8     |
l1:	goto l4                 ; 3 + 2       <-'
l4:	nop                     ; 5 + 1
	goto out_countdown      ; 6 + 2 = 8
.endm

.macro uart_sample out_countdown
;	[ sr data ] in uart_countdown
	t0sn pa, #PIN_UART      ; 0 + 1
	set1 data, #7           ; 1 + 1
	clear data_flag         ; 2 + 1 [ idempotent operation, just needs to be cleared at stop_bit ]
	mov a, #12              ; 3 + 1
	mov wait_count, a       ; 4 + 1      [ wait_count = 12 ]
	nop                     ; 5 + 1
	goto out_countdown      ; 6 + 2 = 8
.endm

.macro uart_stop_bit out_store, out_bad, ?l0, ?l1
	t1sn pa, #PIN_UART         ; 0 + 1
	goto l0                    ; 1 + 1 | 2 --. [ stop bit needs to be high ]
	t1sn data_flag, #BAD_DATA  ; 2 + 1       |
	wdreset                    ; 3 + 1       |
	mov a, #128                ; 4 + 1       |
	mov read_timeout, a        ; 5 + 1       |
	goto out_store             ; 6 + 2 = 8   |
l0: set1 data_flag, #BAD_DATA  ; 3 + 1  <----'
	goto l1                    ; 4 + 2
l1:	goto out_bad               ; 6 + 2 = 8
.endm

.macro uart_store out_idle
	mov a, data                ; 0 + 1
	swap a                     ; 1 + 1
	mov new_data, a            ; 2 + 1
	t1sn data_flag, #BAD_DATA  ; 3 + 1
	set1 data_flag, #NEW_DATA  ; 4 + 1
	clear data                 ; 5 + 1
	goto out_idle              ; 6 + 2
.endm


.macro uart_no_store out_idle
	nop                     ; 0 + 1
	nop                     ; 1 + 1
	nop                     ; 2 + 1
	nop                     ; 3 + 1
	nop                     ; 4 + 1
	clear data              ; 5 + 1
	goto out_idle           ; 6 + 2
.endm



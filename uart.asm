
; bitfield memory:
;
; uart_status
; uart_shift_reg
; uart_state
;
; any memory:
;
; uart_data
; uart_wait
; uart_bit
;


UART_RX_PIN = 3
UART_MASK   = 1<<(UART_RX_PIN)

NEW_DATA = 0 ; don't change, maye be used with dzsn etc

UART_IDLE_LEN=6
UART_START_LEN=4
UART_SAMPLE_LEN=5
UART_NEXT_LEN=4
UART_STOP_LEN=4
UART_STORE_LEN=5

UART_IDLE=1
UART_START=UART_IDLE+UART_IDLE_LEN
UART_SAMPLE=UART_START+UART_START_LEN
UART_NEXT=UART_SAMPLE+UART_SAMPLE_LEN
UART_STOP=UART_NEXT+UART_NEXT_LEN
UART_STORE=UART_STOP+UART_STOP_LEN
UART_WAIT=UART_STORE+UART_STORE_LEN

.macro uart_init
	mov a, #(UART_MASK)
	mov paph, a
	clear uart_status
	mov a, #UART_IDLE
	mov uart_state, a
.endm

;                                        .----------.   .--------.
;  .___.                     .---. .---->|  SAMPLE  |-->|  NEXT  |
;  v   |                     v   | |     '----------'   '--------'
; .--------.  .---------.  .--------.                       |
; |  IDLE  |->|  START  |->|  WAIT  |<----------------------'
; '--------'  '---------'  '--------'            (good)
;    ^                             |     .--------.   .---------.
;    |                             '---->|  STOP  |-->|  STORE  |
;    |--------------<-bad-<--------------'--------'   '---------'
;    |____________________________________________________|


.macro uart ?out, ?write_state_in_2, ?write_state_in_1

;switch( uart_state )
	mov a, uart_state        ; 0 + 1
	pcadd a                  ; 1 + 2

;case UART_IDLE:
	mov a, #UART_START       ; 3 + 1
	t1sn pa, #UART_RX_PIN    ; 4 + 1
	mov uart_state, a        ; 5 + 1
	mov a, #(17+8*11)        ; 6 + 1
	mov uart_bit, a          ; 7 + 1
	goto out                 ; 8 + 2

;case UART_START:
	mov a, #17               ; 3 + 1
	mov uart_wait, a         ; 4 + 1
	mov a, #UART_WAIT        ; 5 + 1
	goto write_state_in_2    ; 6 + 2

;case UART_SAMPLE:
	sr uart_shift_reg        ; 3 + 1
	t0sn pa, #UART_RX_PIN    ; 4 + 1
	set1 uart_shift_reg, #7  ; 5 + 1
	mov a, #UART_NEXT        ; 6 + 1
	goto write_state_in_1    ; 7 + 2

;case UART_NEXT:
	mov a, #11               ; 3 + 1
	mov uart_wait, a         ; 4 + 1
	mov a, #UART_WAIT        ; 5 + 1
	goto write_state_in_2    ; 6 + 2

;case UART_STOP:
	mov a, #UART_STORE       ; 3 + 1
	t1sn pa, #UART_RX_PIN    ; 4 + 1
	mov a, #UART_IDLE        ; 5 + 1
	goto write_state_in_2    ; 6 + 2

;case UART_STORE:
	set1 uart_status, #NEW_DATA ; 3 + 1
	mov a, uart_shift_reg       ; 4 + 1
	mov uart_data, a            ; 5 + 1
 	mov a, #UART_IDLE           ; 6 + 1
	goto write_state_in_1       ; 7 + 2

;case UART_WAIT:
	mov a, #UART_STOP               ; 3 + 1
	dzsn uart_wait                  ; 4 + 1
	add a, #(UART_WAIT-UART_SAMPLE) ; 7 + 1
	dzsn uart_bit                   ; 6 + 1
	sub a, #(UART_STOP-UART_SAMPLE) ; 7 + 1
write_state_in_2:
	nop                      ; 8 + 1
write_state_in_1:
	mov uart_state, a        ; 9 + 1
out:
.endm


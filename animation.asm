
ANI_STATE_0_LEN=(0x81-0x57) ; ex pcadd
ANI_STATE_1_LEN=(0x8e-0x81)
ANI_STATE_2_LEN=(0x93-0x8e)
ANI_STATE_3_LEN=(0x96-0x93)
ANI_STATE_4_LEN=(0x98-0x96)
ANI_STATE_5_LEN=(0x9a-0x98)
ANI_STATE_6_LEN=(0x9c-0x9a)

ANI_STATE_1=1 + ANI_STATE_0_LEN
ANI_STATE_2=ANI_STATE_1 + ANI_STATE_1_LEN
ANI_STATE_3=ANI_STATE_2 + ANI_STATE_2_LEN
ANI_STATE_4=ANI_STATE_3 + ANI_STATE_3_LEN
ANI_STATE_5=ANI_STATE_4 + ANI_STATE_4_LEN
ANI_STATE_6=ANI_STATE_5 + ANI_STATE_5_LEN
ANI_STATE_7=ANI_STATE_6 + ANI_STATE_6_LEN


;

.macro ani_init
	mov a, #2
	mov p_hi, a
	clear p
	clear slowdown
	mov a, #p
	mov sp, a
	mov a, #1
	mov i, a
	mov brightness_lo, a
	mov state, a
	clear new_pa
	clear end_pa
	clear brightness_hi
.endm


.macro ani_high_nibbles out, out_next, out_new_data, ?l1, ?l2, ?l3, ?iter_1_to_7, ?state_and_out, ?nop_state_and_out, ?nop2_state_and_out, ?nop3_check_uart, ?check_uart
	pwm_block brightness_hi     ;  0 + 4
	mov a, state                ;  4 + 1
	pcadd a                     ;  5 + 2
; 0
	mov a, #LED1_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #LED1_HIGH           ;  9 + 1
	goto l1                     ; 10 + 2
; 1
	mov a, #LED2_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #LED2_HIGH           ;  9 + 1
	goto l1                     ; 10 + 2
; 2
	mov a, #LED3_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #LED3_HIGH           ;  9 + 1
	goto l1                     ; 10 + 2
; 3
	mov a, #LED4_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #LED4_HIGH           ;  9 + 1
	goto l1                     ; 10 + 2
; 4
	mov a, #LED5_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #LED5_HIGH           ;  9 + 1
	goto l1                     ; 10 + 2
; 5
	mov a, #LED6_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #LED6_HIGH           ;  9 + 1
	goto l1                     ; 10 + 2
; 6
	mov a, #LED7_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #LED7_HIGH           ;  9 + 1
	goto l1                     ; 10 + 2
; 7
	mov a, #LED0_DIR            ;  7 + 1
	mov new_pac, a              ;  8 + 1
	mov a, #(0xfd)              ;  9 + 1
	mov i, a                    ; 10 + 1
	mov a, #LED0_HIGH           ; 11 + 1
l1:
	mov new_pa, a               ; 12 + 1
	mov a, #ANI_STATE_1         ; 13 + 1
nop_state_and_out:
	wdreset                     ; 14 + 1
state_and_out:
	mov state, a                ; 15 + 1
	pwm_block brightness_hi     ; 16 + 4
	goto out                    ; 20 + 2

;ANI_STATE_1
	mov a, #32                  ;  7 + 1
	add p, a                    ;  8 + 1
	mov a, #4                   ;  9 + 1
	add i, a                    ; 10 + 1
	mov a, #ANI_STATE_2         ; 11 + 1
check_uart:
	t1sn uart_status, #NEW_DATA ; 12 + 1|2
nop2_state_and_out:
	goto state_and_out          ; 13 + 2
	goto l2                     ; 14 + 2
l2:
	pwm_block brightness_hi     ; 16 + 4
	goto out_new_data           ; 20 + 2

;ANI_STATE_2
	dzsn slowdown               ;  7 + 1
	goto l3                     ;  8 + 1|2
	inc p                       ;  9 + 1
l3:
	mov a, #ANI_STATE_3         ; 10 + 1
	goto nop2_state_and_out     ; 11 + 2

;ANI_STATE_3
	mov a, #ANI_STATE_4         ;  7 + 1
	goto nop3_check_uart        ;  8 + 2
nop3_check_uart:
	goto check_uart             ; 10 + 2

;ANI_STATE_4
	mov a, #ANI_STATE_5         ;  7 + 1
	goto nop3_check_uart        ;  8 + 2

;ANI_STATE_5
	mov a, #ANI_STATE_6         ;  7 + 1
	goto nop3_check_uart        ;  8 + 2

;ANI_STATE_6
	mov a, #ANI_STATE_7         ;  7 + 1
	goto nop3_check_uart        ;  8 + 2

;ANI_STATE_7
	mov a, i                    ;  7 + 1
	mov state, a                ;  8 + 1
	ldsptl                      ;  9 + 2
	mov brightness_lo, a        ; 11 + 1
	ldspth                      ; 12 + 2
	mov brightness_hi, a        ; 14 + 1
	ceqsn a, #0                 ; 15 + 1
	mov a, new_pa               ; 16 + 1
	mov end_pa, a               ; 17 + 1
	mov a, new_pac              ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out_next               ; 20 + 1
.endm


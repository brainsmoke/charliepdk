
.include "delay.asm"

ORANGE_BIT = (6)
BLUE_BIT   = (7)
GREEN_BIT  = (0)
PURPLE_BIT = (4)

ORANGE = (1<<6)
BLUE   = (1<<7)
GREEN  = (1<<0)
PURPLE = (1<<4)

; clockwise, starting north

LED0_DIR = (ORANGE|BLUE)
LED1_DIR = (ORANGE|BLUE)
LED2_DIR = (GREEN|BLUE)
LED3_DIR = (GREEN|BLUE)
LED4_DIR = (GREEN|PURPLE)
LED5_DIR = (GREEN|PURPLE)
LED6_DIR = (ORANGE|PURPLE)
LED7_DIR = (ORANGE|PURPLE)

LED0_HIGH = ORANGE
LED1_HIGH = BLUE
LED2_HIGH = GREEN
LED3_HIGH = BLUE
LED4_HIGH = GREEN
LED5_HIGH = PURPLE
LED6_HIGH = ORANGE
LED7_HIGH = PURPLE


LED0_HIGH_BIT = ORANGE_BIT
LED1_HIGH_BIT = BLUE_BIT
LED2_HIGH_BIT = GREEN_BIT
LED3_HIGH_BIT = BLUE_BIT
LED4_HIGH_BIT = GREEN_BIT
LED5_HIGH_BIT = PURPLE_BIT
LED6_HIGH_BIT = ORANGE_BIT
LED7_HIGH_BIT = PURPLE_BIT

;
; CHARLIE PLEXING STATE MACHINE:
;
;

.macro charlie_init

	mov a, #0
	mov pac, a
	clear i_hi
	clear j_hi
	clear new_pa
	clear end_pa
	clear brightness_lo
	clear brightness_hi
	clear new_brightness_hi
	clear data_timeout
.endm

.macro charlie_reset
	mov a, #6
	mov cycle_count, a
	mov a, #1
	mov i, a
	mov brightness_lo, a
	mov a, #buffer
	mov j, a
	clear new_pa
	clear end_pa
	clear brightness_hi
.endm


.macro pwm_block reg ?out
	mov a, #0   ;  0 + 1
	dzsn reg    ;  1 + 1 |
	goto out    ;  2 + 1 V
	mov pa, a   ;  3 + 1 [ pwm falling edge ]
out:
.endm

.macro charlie_low_nibble out ?nop_5c, ?nop_5d, ?nop_4c, ?nop_4d, ?nop_2a, ?nop_2b, ?nop_3a, ?nop_3b, ?nop_4a, ?nop_4b, ?nop_5a, ?nop_5b, ?nop_6a, ?nop_6b, ?nop_7a, ?nop_7b, ?nop_8a, ?nop_9a, ?nop_9b, ?nop_10, ?nop_11, ?nop_8b, ?nop_7c, ?nop_6c, ?nop_3c, ?nop_3d, ?nop_3e, ?nop_2c, ?nop_2d, ?nop_2e, ?cont_1, ?cont_14, ?cont_13, ?cont_12, ?cont_11, ?cont_10, ?cont_9, ?cont_8, ?cont_7, ?cont_6, ?cont_5, ?cont_4, ?cont_3, ?cont_2

	mov a, brightness_lo ;  0 + 1
	pcadd a              ;  1 + 2
; 0
	mov a, #0         ;  3 + 1
	goto cont_13      ;  4 + 2
nop_5c:
	goto nop_5d       ; 10 + 2
nop_5d:
	goto cont_5       ; 12 + 2
;  1
	goto cont_1       ;  3 + 2
nop_4c:
	goto nop_4d       ; 10 + 2
nop_4d:
	nop               ; 12 + 1
	goto cont_4       ; 13 + 2
;  2
	mov a, new_pa     ;  3 + 1
	goto nop_2a       ;  4 + 2
nop_2a:
	goto nop_2b       ;  6 + 2
nop_2b:
	goto nop_2c       ;  8 + 2
;  3
	mov a, new_pa     ;  3 + 1
	goto nop_3a       ;  4 + 2
nop_3a:
	goto nop_3b       ;  6 + 2
nop_3b:
	goto nop_3c       ;  8 + 2
;  4
	mov a, new_pa     ;  3 + 1
	goto nop_4a       ;  4 + 2
nop_4a:
	goto nop_4b       ;  6 + 2
nop_4b:
	goto nop_4c       ;  8 + 2
;  5
	mov a, new_pa     ;  3 + 1
	goto nop_5a       ;  4 + 2
nop_5a:
	goto nop_5b       ;  6 + 2
nop_5b:
	goto nop_5c       ;  8 + 2
;  6
	mov a, new_pa     ;  3 + 1
	goto nop_6a       ;  4 + 2
nop_6a:
	goto nop_6b       ;  6 + 2
nop_6b:
	goto nop_6c       ;  8 + 2

;  7
	mov a, new_pa     ;  3 + 1
	goto nop_7a       ;  4 + 2
nop_7a:
	goto nop_7b       ;  6 + 2
nop_7b:
	goto nop_7c       ;  8 + 2
;  8
	mov a, new_pa     ;  3 + 1
	nop               ;  4 + 1
	goto nop_8a       ;  5 + 2
nop_8a:
	goto nop_8b       ;  7 + 2
;  9
	mov a, new_pa     ;  3 + 1
	goto nop_9a       ;  4 + 2
nop_9a:
	goto nop_9b       ;  6 + 2
nop_9b:
	goto cont_9       ;  8 + 2
; 10
	mov a, new_pa     ;  3 + 1
	nop               ;  4 + 1
	goto nop_10       ;  5 + 2
nop_10:
	goto cont_10      ;  7 + 2
; 11
	mov a, new_pa     ;  3 + 1
	goto nop_11       ;  4 + 2
nop_11:
	goto cont_11      ;  6 + 2
nop_8b:
	goto cont_8       ;  9 + 2
; 12
	mov a, new_pa     ;  3 + 1
	nop               ;  4 + 1
	goto cont_12      ;  5 + 2
nop_7c:
	goto cont_7       ; 10 + 2
; 13
	mov a, new_pa     ;  3 + 1
	goto cont_13      ;  4 + 2
nop_6c:
	nop               ; 10 + 2
	goto cont_6       ; 11 + 2
; 14
	nop               ;  3 + 1
	mov a, new_pa     ;  4 + 1
	mov pa, a         ;  5 + 1
	goto cont_11      ;  6 + 2
; 15
	mov a, new_pa     ;  3 + 1
	mov pa, a         ;  4 + 1  15
	goto cont_12      ;  5 + 2

nop_3c:
	goto nop_3d       ; 10 + 2
nop_3d:
	goto nop_3e       ; 12 + 2
nop_3e:
	goto cont_3       ; 14 + 2

nop_2c:
	goto nop_2d       ; 10 + 2
nop_2d:
	goto nop_2e       ; 12 + 2
nop_2e:
	nop               ; 14 + 1
	goto cont_2       ; 15 + 2

cont_1:
	delay 9                 ;  5 + 9
	mov a, i                ; 14 + 1
	pcadd a                 ; 15 + 2
; 0
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED0_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2
; 1
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED1_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2
; 2
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED2_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2
; 3
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED3_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2
; 4
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED4_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2
; 5
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED5_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2
; 6
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED6_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2
; 7
	mov a, end_pa           ; 17 + 1
	set1 pa, #LED7_HIGH_BIT ; 18 + 1
	mov pa, a               ; 19 + 1
	goto out                ; 20 + 2

cont_14:
	mov pa, a         ;  5 + 1  14
cont_13:
	mov pa, a         ;  6 + 1  13
cont_12:
	mov pa, a         ;  7 + 1  12
cont_11:
	mov pa, a         ;  8 + 1  11
cont_10:
	mov pa, a         ;  9 + 1  10
cont_9:
	mov pa, a         ; 10 + 1   9
cont_8:
	mov pa, a         ; 11 + 1   8
cont_7:
	mov pa, a         ; 12 + 1   7
cont_6:
	mov pa, a         ; 13 + 1   6
cont_5:
	mov pa, a         ; 14 + 1   5
cont_4:
	mov pa, a         ; 15 + 1   4
cont_3:
	mov pa, a         ; 16 + 1   3
cont_2:
	mov pa, a         ; 17 + 1   2
	mov a, end_pa     ; 18 + 1
	mov pa, a         ; 19 + 1
	goto out          ; 20 + 2

.endm


.macro charlie_high_nibbles_0 out, ?l1
	pwm_block brightness_hi     ;  0 + 4

	mov a, i                    ;  4 + 1
	pcadd a                     ;  5 + 2
; 0
	mov a, #LED1_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+1             ;  9 + 1
	goto l1                     ; 10 + 2
; 1
	mov a, #LED2_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+2             ;  9 + 1
	goto l1                     ; 10 + 2
; 2
	mov a, #LED3_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+3             ;  9 + 1
	goto l1                     ; 10 + 2
; 3
	mov a, #LED4_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+4             ;  9 + 1
	goto l1                     ; 10 + 2
; 4
	mov a, #LED5_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+5             ;  9 + 1
	goto l1                     ; 10 + 2
; 5
	mov a, #LED6_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+6             ;  9 + 1
	goto l1                     ; 10 + 2
; 6
	mov a, #LED7_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+7             ;  9 + 1
	goto l1                     ; 10 + 2
; 7
	mov a, #LED0_HIGH           ;  7 + 1
	mov new_pa, a               ;  8 + 1
	mov a, buffer+0             ;  9 + 1
	goto l1                     ; 10 + 2
l1:
	mov brightness_lo, a        ; 12 + 1
	and a, #0xf0                ; 13 + 1
	xor brightness_lo, a        ; 14 + 1
	mov new_brightness_hi, a    ; 15 + 1

	pwm_block brightness_hi     ; 16 + 4
	goto out                    ; 20 + 2
.endm

.macro charlie_high_nibbles_1_to_6 out, out_next, ?l1,?l2, ?l3, ?no_framereset, ?iter_1_to_5, ?no_new_data
	pwm_block brightness_hi     ;  0 + 4
	dzsn cycle_count            ;  4 + 1
	goto iter_1_to_5            ;  5 + 2|1

; high nibbles round 6
	ceqsn a, new_brightness_hi  ;  6 + 1   [ a == 0 ]
	mov a, new_pa               ;  7 + 1
	mov end_pa, a               ;  8 + 1   [ new_brightness_hi == 0 ? 0 : new_pa ]
	mov a, #buffer              ;  9 + 1
	dzsn data_timeout           ; 10 + 1
	goto no_framereset          ; 11 + 1|2
	mov j, a                    ; 12 + 1
no_framereset:
	set0 data_timeout, #7       ; 13 + 1  (reduce timeout)
	set0 data_timeout, #6       ; 14 + 1
	nop                         ; 15 + 1
l1:
	pwm_block brightness_hi     ; 16 + 4
	goto out_next               ; 20 + 2
	
iter_1_to_5:
	dzsn uart_status            ;  7 + 1 [ (1<<NEW_DATA) == 1 ]
	goto no_new_data            ;  8 + 2|1
	clear data_timeout          ;  9 + 1
	mov a, uart_data            ; 10 + 1
	idxm j, a                   ; 11 + 2
	inc j                       ; 13 + 1
	set0 j, #3                  ; 14 + 1
	wdreset                     ; 15 + 1
l2:
	pwm_block brightness_hi     ; 16 + 4
	goto out                    ; 20 + 2

no_new_data:
	clear uart_status           ; 10 + 1 [ uart_status = -1 due to dzsn, restore to 0 ]
	goto l3                     ; 11 + 2
l3:
	nop                         ; 13 + 1
	goto l2                     ; 14 + 2
.endm

.macro charlie_high_nibbles_7 out
	pwm_block brightness_hi     ;  0 + 4
	mov a, #6                   ;  4 + 1
	mov cycle_count, a          ;  5 + 1
	mov a, new_brightness_hi    ;  6 + 1
	swap a                      ;  7 + 1
	mov brightness_hi, a        ;  8 + 1
	sl brightness_lo            ;  9 + 1
	sl brightness_lo            ; 10 + 1
	inc brightness_lo           ; 11 + 1
	mov a, #4                   ; 12 + 1
	add a, i                    ; 13 + 1
	and a, #(0x1f)              ; 14 + 1
	pcadd a                     ; 15 + 2
; 0
	mov i, a                    ; 17 + 1
	mov a, #LED0_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
; 1
	mov i, a                    ; 17 + 1
	mov a, #LED1_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
; 2
	mov i, a                    ; 17 + 1
	mov a, #LED2_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
; 3
	mov i, a                    ; 17 + 1
	mov a, #LED3_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
; 4
	mov i, a                    ; 17 + 1
	mov a, #LED4_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
; 5
	mov i, a                    ; 17 + 1
	mov a, #LED5_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
; 6
	mov i, a                    ; 17 + 1
	mov a, #LED6_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
; 7
	mov i, a                    ; 17 + 1
	mov a, #LED7_DIR            ; 18 + 1
	mov pac, a                  ; 19 + 1
	goto out                    ; 20 + 2
.endm


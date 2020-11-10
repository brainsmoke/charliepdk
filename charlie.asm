
.include "pwm.asm"

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


;
; CHARLIE PLEXING STATE MACHINE:
;
;

.macro charlie_init

	mov a, #LED0_DIR
	mov led_dir+0, a
	mov led_dir+3, a
	mov a, #LED2_DIR
	mov led_dir+6, a
	mov led_dir+9, a
	mov a, #LED4_DIR
	mov led_dir+12, a
	mov led_dir+15, a
	mov a, #LED6_DIR
	mov led_dir+18, a
	mov led_dir+21, a

	mov a, #LED0_HIGH
	mov led_high+0, a
	mov a, #LED1_HIGH
	mov led_high+3, a
	mov a, #LED2_HIGH
	mov led_high+6, a
	mov a, #LED3_HIGH
	mov led_high+9, a
	mov a, #LED4_HIGH
	mov led_high+12, a
	mov a, #LED5_HIGH
	mov led_high+15, a
	mov a, #LED6_HIGH
	mov led_high+18, a
	mov a, #LED7_HIGH
	mov led_high+21, a

	mov a, #led_brightness;[0]
	mov j, a

	clear i_hi
	clear j_hi

	mov a, #(bufstart+3)
	mov i, a
	mov a, #0
	mov pac, a
	clear new_pa
	clear brightness_lo
	clear brightness_hi
.endm

.macro charlie_reset
	mov a, #7
	mov cycle_countdown, a
	mov a, #(bufstart+3)
	mov i, a
	clear data_flag
	clear brightness_lo
	clear brightness_hi
.endm


.macro charlie_short_pulse
	pwm_4bit_24cycles brightness_lo, new_pa, 0
.endm

.macro charlie_long_pulse
	pwm_4bit_24cycles brightness_lo, new_pa, 1
.endm

.macro charlie_high_nibble_first ?l1, ?l2

	idxm a, i                   ;  0 + 2
	mov new_pac, a              ;  2 + 1
	inc i                       ;  3 + 1

	mov a, #0                   ;  4 + 1 |
	dzsn brightness_hi          ;  5 + 1 |
	goto l1                     ;  6 + 1 V
	mov pa, a                   ;  7 + 1 [ pwm falling edge ]
l1:

	idxm a, i                   ;  8 + 2
	mov new_pa, a               ; 10 + 1
	inc i                       ; 11 + 1
	idxm a, i                   ; 12 + 2
	mov brightness_lo, a        ; 14 + 1
	and a, #0xf                 ; 15 + 1
	sub brightness_lo, a        ; 16 + 1
	mov new_brightness_hi, a    ; 17 + 1
	inc i                       ; 18 + 1
	nop                         ; 19 + 1

	mov a, #0                   ; 20 + 1 |
	dzsn brightness_hi          ; 21 + 1 |
	goto l2                     ; 22 + 1 V
	mov pa, a                   ; 23 + 1 [ pwm falling edge ]
l2:
.endm

.macro charlie_high_nibble out_next_cycle_short, out_next_cycle_long, ?l0, ?l1, ?l2, ?l3, ?l4, ?l5, ?l6, ?lx, ?ly, ?lz, ?lq

	dzsn cycle_countdown        ;  0 + 1
	goto l2                     ;  1 + 2
;
; the last iteration
;
	mov a, #7                   ;  2 + 1
	mov cycle_countdown, a      ;  3 + 1

	mov a, #0                   ;  4 + 1 |
	dzsn brightness_hi          ;  5 + 1 |
	goto l0                     ;  6 + 1 V
	mov pa, a                   ;  7 + 1 [ (latest possible) pwm falling edge ]
l0:
	nop                         ;  8 + 1
	mov a, new_brightness_hi    ;  9 + 1
	mov brightness_hi, a        ; 10 + 1

	mov a, i                    ; 11 + 1
	ceqsn a, #bufend            ; 12 + 1
	add a,   #(bufend-bufstart) ; 13 + 1
	sub a,   #(bufend-bufstart) ; 14 + 1
	mov i, a                    ; 15 + 1

	mov a, #0                   ; 16 + 1

	ceqsn a, new_brightness_hi  ; 17 + 1
	goto l1                     ; 18 + 1|2
	nop                         ; 19 + 1

	mov a, new_pac              ; 20 + 1
	mov pac, a                  ; 21 + 1
	goto out_next_cycle_short   ; 22 + 2


l1:	mov a, new_pac              ; 20 + 1
	mov pac, a                  ; 21 + 1 [ set data dir on the right charlieplexed ports ]
	goto out_next_cycle_long    ; 22 + 2


;
; all but the last loop iteration
;

l2:	nop                         ;  3 + 1

	mov a, #0                   ;  4 + 1 |
	dzsn brightness_hi          ;  5 + 1 |
	goto l3                     ;  6 + 1 V
	mov pa, a                   ;  7 + 1 [ pwm falling edge ]
l3:

	t0sn data_flag, #NEW_DATA   ;  8 + 1
	goto l4                     ;  9 + 1

	dzsn cycle_countdown        ; 10 + 1
	goto lx                     ; 11 + 1|2

	inc cycle_countdown         ; 12 + 1
	mov a, #led_brightness      ; 13 + 1
	dzsn read_timeout           ; 14 + 1
	goto ly                     ; 15 + 1|2
	mov j, a                    ; 16 + 1
ly: nop                         ; 17 + 1
	goto l5                     ; 18 + 1

lx: inc cycle_countdown         ; 13 + 1
	goto lz                     ; 14 + 1
lz:	goto lq                     ; 16 + 1
lq:	goto l5                     ; 18 + 1

l4:	clear data_flag             ; 11 + 1
	mov a, new_data             ; 12 + 1
	idxm j, a                   ; 13 + 2
	mov a, j                    ; 15 + 1
	ceqsn a,#(led_brightness+3*7);16 + 1
	add a, #(3*8)               ; 17 + 1
	sub a, #(3*7)               ; 18 + 1
	mov j, a                    ; 19 + 1
l5:
	mov a, #0                   ; 20 + 1 |
	dzsn brightness_hi          ; 21 + 1 |
	goto l6                     ; 22 + 1 V
	mov pa, a                   ; 23 + 1 [ pwm falling edge ]
l6:
.endm


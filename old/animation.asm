;
;

;.macro ani_init
;.macro ani_short_pulse
;.macro ani_long_pulse
;.macro ani_high_nibble_first
;.macro ani_high_nibble out_next_cycle_short, out_next_cycle_long

.macro ani_init
	mov a, #5
	mov p_hi, a
	clear p
	clear delay
	mov a, #p
	mov sp, a
.endm

.macro ani_short_pulse
	pwm_4bit_24cycles brightness_lo, new_pa, 0
.endm

.macro ani_long_pulse
	pwm_4bit_24cycles brightness_lo, new_pa, 1
.endm

.macro ani_high_nibble_first ?l1, ?l2, ?l3

	idxm a, i                   ;  0 + 2
	mov new_pac, a              ;  2 + 1
	inc i                       ;  3 + 1

	mov a, #0                   ;  4 + 1
	dzsn brightness_hi          ;  5 + 1
	goto l1                     ;  6 + 1
	mov pa, a                   ;  7 + 1
l1:
	idxm a, i                   ;  8 + 2
	mov new_pa, a               ; 10 + 1
	inc i                       ; 11 + 1
	inc i                       ; 12 + 1
	mov a, #32                  ; 13 + 1
	add p, a                    ; 14 + 1
	dzsn delay                  ; 15 + 1
	goto l2                     ; 16 + 1|2
	inc p                       ; 17 + 1
l2:	mov a, #7                   ; 18 + 1
	mov cycle_countdown, a      ; 19 + 1

	mov a, #0                   ; 20 + 1
	dzsn brightness_hi          ; 21 + 1
	goto l3                     ; 22 + 1
	mov pa, a                   ; 23 + 1
l3:
.endm

.macro ani_high_nibble out_next_cycle_short, out_next_cycle_long, ?l0, ?l1, ?l2, ?l3, ?l4, ?l5, ?l6, ?lx, ?ly, ?lz, ?lq

	dzsn cycle_countdown        ;  0 + 1
	goto l2                     ;  1 + 2
	mov a, #7                   ;  2 + 1
	mov cycle_countdown, a      ;  3 + 1

	mov a, #0                   ;  4 + 1
	dzsn brightness_hi          ;  5 + 1
	goto l0                     ;  6 + 1
	mov pa, a                   ;  7 + 1
l0:
	ldsptl                      ;  8 + 2
	mov brightness_lo, a        ;  9 + 1
	and a, #0xf                 ; 10 + 1
	sub brightness_lo, a        ; 11 + 1
	mov brightness_hi, a        ; 12 + 1
	goto lx                     ; 13 + 2
lx:	nop                         ; 15 + 1
	nop                         ; 16 + 1
	ceqsn a, #0                 ; 17 + 1
	goto l1                     ; 18 + 1|2
	nop                         ; 19 + 1
	mov a, new_pac              ; 20 + 1
	mov pac, a                  ; 21 + 1
	goto out_next_cycle_short   ; 22 + 2

l1:	mov a, new_pac              ; 20 + 1
	mov pac, a                  ; 21 + 1
	goto out_next_cycle_long    ; 22 + 2

l2:	wdreset                     ;  3 + 1

	mov a, #0                   ;  4 + 1
	dzsn brightness_hi          ;  5 + 1
	goto l3                     ;  6 + 1|2
	mov pa, a                   ;  7 + 1
l3:
	mov a, i                    ;  8 + 1
	ceqsn a, #bufend            ;  9 + 1
	add a,   #(bufend-bufstart) ; 10 + 1
	sub a,   #(bufend-bufstart) ; 11 + 1
	mov i, a                    ; 12 + 1
	goto ly                     ; 13 + 2
ly:	goto lz                     ; 15 + 2
lz:	goto lq                     ; 17 + 2
lq:	nop                         ; 19 + 1
l5:	mov a, #0                   ; 20 + 1
	dzsn brightness_hi          ; 21 + 1
	goto l6                     ; 22 + 1
	mov pa, a                   ; 23 + 1
l6:
.endm


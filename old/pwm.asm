
BRIGHTNESS_BIT0 = 4
BRIGHTNESS_BIT1 = 5
BRIGHTNESS_BIT2 = 6
BRIGHTNESS_BIT3 = 7


	;
	;  24 cycles
	; 
	;  end_high == 1:
	;               .___________ . . .
	;               |
	;   24-(val&15) |  (val&15)
	;  _____________|
	; 
	;  end_high == 0
	;               .____________.
	;               |            |
	;   24-(val&15) |  (val&15)  |
	;  _____________|            |. . .
	; 
	;
	.macro pwm_4bit_24cycles val, new_pa, end_high, ?l0, ?l1, ?l2, ?l3, ?l4, ?loop, ?wait_11, ?wait_1, ?nonzero_15, ?xxxx0xxx_19, ?xxxx00xx_10, ?xxxx10xx_17, ?xxxx110x_15, ?xxxx100x_11, ?xxxx010x_7, ?xxxx101x_12, ?xxxx011x_8, ?xxxx001x_5, ?xxxx0001_1, ?last_1, ?end

		mov a, new_pa
		;                                 |   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F  |
		;---------------------------------|---------------------------------------------------|
		t1sn val, #BRIGHTNESS_BIT3   ; 22 |   .  .  .  .  .  .  .  .  :  :  :  :  :  :  :  :  |
		goto xxxx0xxx_19             ; 21 |   :  :  :  :  :  :  :  :   )  )  )  )  )  )  )  ) |
		t1sn val, #BRIGHTNESS_BIT2   ; 20 |                           .  .  .  .  :  :  :  :  |
		goto xxxx10xx_17             ; 19 |                           :  :  :  :   )  )  )  ) |
		t1sn val, #BRIGHTNESS_BIT1   ; 18 |                                       .  .  :  :  |
		goto xxxx110x_15             ; 17 |                                       :  :   )  ) |
		t0sn val, #BRIGHTNESS_BIT0   ; 16 |                                             :  .  |
		mov pa, a                    ; 15 |                                              ) F  |
		mov pa, a                    ; 14 |                                             E  F  |
		goto wait_11                 ; 13 |                                             EE FF |
		;---------------------------------|---------------------------------------------------|
	xxxx0xxx_19:
		inc val                      ; 19 |                                                   |
		dzsn val                     ; 18 |                                                   |
		goto nonzero_15              ; 17 |                                                   |
		mov tmp, a                   ; 16
		mov a, #3                    ; 15
		loop:
		dzsn a       ; 2x1+1x2
		goto loop    ; 2x2
		mov a, tmp                   ;  6
		goto l0                      ;  5
		l0:
		.ifeq end_high
		nop                          ;  3
		nop                          ;  2
		goto end                     ;  1
		.else
		nop                          ;  3
		goto last_1                  ;  2
		.endif
		;---------------------------------|---------------------------------------------------|
	nonzero_15:
		goto l1                      ; 15 |                                                   |
	l1:	t1sn val, #BRIGHTNESS_BIT2   ; 13 |                                                   |
		goto xxxx00xx_10             ; 12 |                                                   |
		t0sn val, #BRIGHTNESS_BIT1   ; 11 |                                                   |
		goto xxxx011x_8              ; 10 |                                                   |
		goto xxxx010x_7              ;  9 |                                                   |
		;---------------------------------|---------------------------------------------------|
	xxxx00xx_10:
		goto l2                      ; 10 |                                                   |
	l2:	t0sn val, #BRIGHTNESS_BIT1   ;  8 |                                                   |
		goto xxxx001x_5              ;  7 |                                                   |
		goto l3                      ;  6 |                                                   |
	l3:	nop                          ;  4 |                                                   |
		goto xxxx0001_1              ;  3 |                                                   |
		;---------------------------------|---------------------------------------------------|
	xxxx10xx_17:
		goto l4                      ; 17 |                                                   |
	l4:	t0sn val, #BRIGHTNESS_BIT1   ; 15 |                                                   |
		goto xxxx101x_12             ; 14 |                                                   |
		goto xxxx100x_11             ; 13 |                                                   |
		;---------------------------------|---------------------------------------------------|
	xxxx110x_15:
		nop                          ; 15 |                                                   |
		t0sn val, #BRIGHTNESS_BIT0   ; 14 |                                                   |
		mov pa, a                    ; 13 |                                                   |
		mov pa, a                    ; 12 |                                                   |
	xxxx100x_11:
		nop                          ; 11 |                                                   |
		t0sn val, #BRIGHTNESS_BIT0   ; 10 |                                                   |
		mov pa, a                    ;  9 |                                                   |
		mov pa, a                    ;  8 |                                                   |
	xxxx010x_7:
		nop                          ;  7 |                                                   |
		t0sn val, #BRIGHTNESS_BIT0   ;  6 |                                                   |
		mov pa, a                    ;  5 |                                                   |
		mov pa, a                    ;  4 |                                                   |
		goto wait_1                  ;  3 |                                                   |	
		;---------------------------------|---------------------------------------------------|
	xxxx101x_12:
		t0sn val, #BRIGHTNESS_BIT0   ; 12 |                                                   |
	wait_11:
		mov pa, a                    ; 11 |                                             E  F  |
		mov pa, a                    ; 10 |                                             E  F  |
		nop                          ;  9 |                                             E  F  |
	xxxx011x_8:
		t0sn val, #BRIGHTNESS_BIT0   ;  8 |                                             E  F  |
		mov pa, a                    ;  7 |                                             E  F  |
		mov pa, a                    ;  6 |                                             E  F  |
	xxxx001x_5:
		nop                          ;  5 |                                             E  F  |
		t0sn val, #BRIGHTNESS_BIT0   ;  4 |         :  .                                E  F  |
		mov pa, a                    ;  3 |          ) .                                E  F  |
		mov pa, a                    ;  2 |         .  3                                E  F  |
	xxxx0001_1:
	wait_1:
		mov pa, a                    ;  1 |      .  2  3  4  5  6  7                    E  F  |
	last_1:
		.ifeq end_high
; xor pa, a seems buggy, (seems to be able to put input ports in output mode if they're pulled high(?))
; workaround adds one extra cycle per 288 cycles and stretches the pwm with one extra cycle, we can live with that
; 0 -> 0, 1-15 -> 2-16
		mov a, #0
		mov pa, a                    ;  0 |      1  2  3  4  5  6  7                    _  _  |
;		xor pa, a                    ;  0 |      1  2  3  4  5  6  7                    _  _  |
		.else
		mov pa, a                    ;  0 |   .  1  2  3  4  5  6  7                    E  F  |
nop ; add one extra cycle: 16-255 -> 17->256
		.endif
	end:
	.endm


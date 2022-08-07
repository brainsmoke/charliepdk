
.module charlie

.include "pdk.asm"
.include "uart.asm"
.include "charlie.asm"
;.include "animation.asm"
.include "map.asm"

.area DATA (ABS)

.include "memmap.asm"

tmp: .ds 1

.area CODE (ABS)
.org 0x00

	clock_4mhz
	easypdk_calibrate 4000000, 5000
	
	charlie_init
	uart_init
;	ani_init
	watchdog_enable

;	animation

exit_countdown:
	charlie_reset


mov a, #LED0_DIR
mov pac, a
mov a, #LED0_HIGH
mov new_pa, a
mov a, #1
mov i, a
clear new_pa
clear tmp
dec tmp
l1:
	inc tmp
	mov a, #0xf
	and tmp, a
	mov a, tmp
	mov brightness_lo, a
	sl brightness_lo
	sl brightness_lo
	inc brightness_lo

	t0sn pa, #UART_RX_PIN
	nop
	t0sn pa, #UART_RX_PIN
	nop
	t0sn pa, #UART_RX_PIN
	nop
	t0sn pa, #UART_RX_PIN
	nop
	charlie_low_nibble l2
l2:
	t0sn pa, #UART_RX_PIN
	nop
	t0sn pa, #UART_RX_PIN
	nop
goto l1


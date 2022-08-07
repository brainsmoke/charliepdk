
.module charlie

.include "pdk.asm"
.include "uart.asm"
.include "charlie.asm"
;.include "animation.asm"
.include "map.asm"

.area DATA (ABS)
.org 0x00

.include "memmap.asm"

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

l1:
	uart
goto l1

.org 0x400 ; byte addr ( = 2x addr )
	color_map


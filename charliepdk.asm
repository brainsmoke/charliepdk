
.module charlie

.include "pdk.asm"
.include "uart.asm"
.include "charlie.asm"
.include "animation.asm"
.include "map.asm"

.area DATA (ABS)

.include "memmap.asm"

.area CODE (ABS)
.org 0x00

	clock_4mhz
	easypdk_calibrate 4000000, 5000
	
	charlie_init
	uart_init
	ani_init
	watchdog_enable

a_high_nibbles:
	uart
	ani_high_nibbles a_high_nibbles a_low_nibble exit_countdown
a_low_nibble:
	uart
	charlie_low_nibble a_high_nibbles

;	animation

exit_countdown:
	charlie_reset

l_low_nibble:
	uart
	charlie_low_nibble l_high_nibble_first

.org 0x400 ; byte addr ( = 2x addr )
	color_map

l_high_nibble_first:
	uart
	charlie_high_nibbles_0 l_high_nibble
l_high_nibble:
	uart
	charlie_high_nibbles_1_to_6 l_high_nibble, l_high_nibble_last
l_high_nibble_last:
	uart
	charlie_high_nibbles_7 l_low_nibble



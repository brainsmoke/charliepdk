
.module charlie

.include "pdk.asm"
.include "uart.asm"
.include "charlie.asm"
.include "animation.asm"

.area DATA (ABS)
.org 0x00

i:                  .ds 1
i_hi:               .ds 1
j:                  .ds 1
j_hi:               .ds 1
p:                  .ds 1
p_hi:               .ds 1
delay:              .ds 1
brightness_lo:      .ds 1
brightness_hi:      .ds 1

cycle_countdown:    .ds 1

tmp:                .ds 1
bitstash:           .ds 1
bit_count:          .ds 1
wait_count:         .ds 1

data:               .ds 1
data_flag:          .ds 1
new_data:           .ds 1

new_brightness_hi:  .ds 1
new_pa:             .ds 1
new_pac:            .ds 1

read_timeout:       .ds 1

bufstart:
led_dir:        .ds 1
led_high:       .ds 1
led_brightness: .ds 22
bufend:

.area CODE (ABS)
.org 0x00

	clock_4mhz
	easypdk_calibrate 4000000, 5000
	
	charlie_init
	uart_init

	.macro u_idle charlie_state
		uart_idle charlie_state'__u_idle, charlie_state'__u_countdown
	.endm

	.macro u_countdown charlie_state
		uart_countdown charlie_state'__u_countdown, charlie_state'__u_sample, charlie_state'__u_stop_bit
	.endm

	.macro u_sample charlie_state
		uart_sample charlie_state'__u_countdown
	.endm

	.macro u_stop_bit charlie_state
		uart_stop_bit charlie_state'__u_store, charlie_state'__u_stop_bit
	.endm

	.macro u_store charlie_state
		uart_no_store charlie_state'__u_idle
	.endm

	.macro c_short_pulse uart_state
		c_short_pulse__'uart_state:
		charlie_short_pulse
		uart_state c_high_nibble_first
	.endm

	.macro c_long_pulse uart_state
		c_long_pulse__'uart_state:
		charlie_long_pulse
		uart_state c_high_nibble_first
	.endm

	.macro c_high_nibble_first uart_state
		c_high_nibble_first__'uart_state:
		charlie_high_nibble_first
		uart_state c_high_nibble
	.endm

	.macro c_high_nibble uart_state, ?next_cycle_short, ?next_cycle_long
		c_high_nibble__'uart_state:
		charlie_high_nibble next_cycle_short, next_cycle_long
		uart_state c_high_nibble
		next_cycle_short:
		uart_state c_short_pulse
		next_cycle_long:
		uart_state c_long_pulse
	.endm

	charlie_reset

	c_short_pulse u_idle
	c_short_pulse u_countdown
	c_short_pulse u_sample
	c_short_pulse u_stop_bit
	c_short_pulse u_store

	c_long_pulse u_idle
	c_long_pulse u_countdown
	c_long_pulse u_sample
	c_long_pulse u_stop_bit
	c_long_pulse u_store

	c_high_nibble_first u_idle
	c_high_nibble_first u_countdown
	c_high_nibble_first u_sample
	c_high_nibble_first u_stop_bit
	c_high_nibble_first u_store

.org 0xb00

	c_high_nibble u_idle
	c_high_nibble u_countdown
	c_high_nibble u_sample
	c_high_nibble u_stop_bit
	c_high_nibble u_store



.org 0x00


; bitwise regs / short aligned

j:                  .ds 1
j_hi:               .ds 1

; bitwise regs

uart_state:         .ds 1
uart_status:        .ds 1
uart_shift_reg:     .ds 1

data_timeout:       .ds 1

; other regs

uart_data:          .ds 1
uart_wait:          .ds 1
uart_bit:           .ds 1

new_pa:             .ds 1
end_pa:             .ds 1
new_pac:            .ds 1

brightness_lo:      .ds 1
brightness_hi:      .ds 1
new_brightness_hi:  .ds 1
cycle_count:        .ds 1

.org 0x10

; 0x10 aligned
buffer: .ds 8

; short aligned

i:                  .ds 1
i_hi:               .ds 1

p:                  .ds 1
p_hi:               .ds 1

; other regs

slowdown:           .ds 1
state:              .ds 1




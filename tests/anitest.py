#!/usr/bin/env python3
#
# Copyright (c) 2020 Erik Bosman <erik@minemu.org>
#
# Permission  is  hereby  granted,  free  of  charge,  to  any  person
# obtaining  a copy  of  this  software  and  associated documentation
# files (the "Software"),  to deal in the Software without restriction,
# including  without  limitation  the  rights  to  use,  copy,  modify,
# merge, publish, distribute, sublicense, and/or sell copies of the
# Software,  and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
# The  above  copyright  notice  and this  permission  notice  shall be
# included  in  all  copies  or  substantial portions  of the Software.
#
# THE SOFTWARE  IS  PROVIDED  "AS IS", WITHOUT WARRANTY  OF ANY KIND,
# EXPRESS OR IMPLIED,  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY,  FITNESS  FOR  A  PARTICULAR  PURPOSE  AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING FROM, OUT OF OR IN
# CONNECTION  WITH THE SOFTWARE  OR THE USE  OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# (http://opensource.org/licenses/mit-license.html)
#

import sys

import intelhex, pdk

BIT_UART = (1<<3)

ORANGE = (1<<6)
BLUE   = (1<<7)
GREEN  = (1<<0)
PURPLE = (1<<4)

# clockwise, starting north

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

leds = {
    (LED0_DIR, LED0_HIGH) : 0,
    (LED1_DIR, LED1_HIGH) : 1,
    (LED2_DIR, LED2_HIGH) : 2,
    (LED3_DIR, LED3_HIGH) : 3, 
    (LED4_DIR, LED4_HIGH) : 4,
    (LED5_DIR, LED5_HIGH) : 5,
    (LED6_DIR, LED6_HIGH) : 6,
    (LED7_DIR, LED7_HIGH) : 7,

    (LED0_DIR, 0) : -1,
    (LED2_DIR, 0) : -1,
    (LED4_DIR, 0) : -1,
    (LED6_DIR, 0) : -1,

    (0,0) : -1
}

program = []

with open(sys.argv[1]) as f:
    program = pdk.parse_program(f.read(), arch='pdk14')

def led_out(ctx):
    pa   = pdk.read_io_raw(ctx, 0x10)
    pac  = pdk.read_io_raw(ctx, 0x11)
    return leds[pac, pa]

def led_val(v):
    return 16*(v&15) + (v//16)

ctx = pdk.new_ctx()
pdk.set_pin(ctx, BIT_UART)

last = -1
lastcount = 0
while True:
    led = led_out(ctx)
    if led == -1:
        if last != -1:
            print ( '  {:02x} {}'.format(lastcount, last), end = '\n'[last!=7:])
        lastcount = 0
    else:
        lastcount += 1
    last = led
    pdk.step(program, ctx)


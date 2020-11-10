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

program = []

with open(sys.argv[1]) as f:
    program = pdk.parse_program(f.read(), arch='pdk14')

t = pdk.state_to_tuple(pdk.new_ctx())
last_states = set([t])
n_all = 0
it = 0
x_set = set()

while tuple(last_states) not in x_set:
    if it%100 == 0:
        x_set.add(tuple(last_states))
    it+=1
    next_states = set()
    for e in last_states:
        for pin in range(256):
            ctx = pdk.tuple_to_state(e)
            pdk.set_pin(ctx, pin)
            pdk.step(program, ctx)
            next_states.add(pdk.state_to_tuple(ctx))
            if not pdk.ioread(ctx):
                break
    print ( len(next_states) )
    last_states = next_states


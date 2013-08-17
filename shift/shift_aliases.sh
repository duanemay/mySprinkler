

alias setOutput="gpio export 14 out;gpio export 15 out;gpio export 18 out"

alias latch="gpio -g write  15 1; gpio -g write  15 0"
alias clock="gpio -g write  18 1; gpio -g write  18 0"
alias shift-on="gpio -g write  14 1; clock"
alias shift-off="gpio -g write  14 0; clock"

alias data-0="shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; latch"
alias data-1="shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; shift-on; latch"
alias data-2="shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; shift-on; shift-off; latch"
alias data-4="shift-off; shift-off; shift-off; shift-off; shift-off; shift-on; shift-off; shift-off; latch"
alias data-8="shift-off; shift-off; shift-off; shift-off; shift-on; shift-off; shift-off; shift-off; latch"
alias data-16="shift-off; shift-off; shift-off; shift-on; shift-off; shift-off; shift-off; shift-off; latch"
alias data-32="shift-off; shift-off; shift-on; shift-off; shift-off; shift-off; shift-off; shift-off; latch"
alias data-64="shift-off; shift-on; shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; latch"
alias data-128="shift-on; shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; shift-off; latch"

alias blink-up="data-1; data-2; data-4; data-8; data-16; data-32; data-64; data-128"
alias blink-down="data-128; data-64; data-32; data-16; data-8; data-4; data-2; data-1"

alias knight-rider="while [ true ]; do blink-up; blink-down; done"


setOutput
data-0



alias data="/mnt/Projects/mySprinkler/shift/data"
alias data-0="data 0"
alias data-1="data 1"
alias data-2="data 2"
alias data-4="data 4"
alias data-8="data 8"
alias data-16="data 16"
alias data-32="data 32"
alias data-64="data 64"
alias data-128="data 128"

alias blink-up="data-1; data-2; data-4; data-8; data-16; data-32; data-64; data-128"
alias blink-down="data-128; data-64; data-32; data-16; data-8; data-4; data-2; data-1"

alias knight-rider="while [ true ]; do blink-up; blink-down; data-0; sleep 2; blink-down; blink-up; data-0; sleep 2; done"

data-0

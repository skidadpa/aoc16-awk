#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 0
    FPAT = "([LR])|([[:digit:]]+)"
    LEFT["N"] = "W"
    LEFT["S"] = "E"
    LEFT["E"] = "N"
    LEFT["W"] = "S"
    RIGHT["N"] = "E"
    RIGHT["S"] = "W"
    RIGHT["E"] = "S"
    RIGHT["W"] = "N"
    XMUL["N"] = 0
    XMUL["S"] = 0
    XMUL["E"] = 1
    XMUL["W"] = -1
    YMUL["N"] = -1
    YMUL["S"] = 1
    YMUL["E"] = 0
    YMUL["W"] = 0
}
function abs(x) { return x < 0 ? -x : x }
$0 !~ /^[LR][[:digit:]]+(, [LR][[:digit:]]+)*$/ {
    print "DATA ERROR"
    exit _exit=1
}
{
    dir = "N"
    x = y = 0
    if (DEBUG) { print "start at", x, y, "facing", dir }
    for (t = 1; t < NF; t += 2) {
        d = t + 1
        switch ($t) {
        case "L":
            dir = LEFT[dir]
            break
        case "R":
            dir = RIGHT[dir]
            break
        default:
            print "PROCESSING ERROR:", $t
            exit _exit=1
        }
        x += XMUL[dir] * $d
        y += YMUL[dir] * $d
        if (DEBUG) { print "turn", $t, "and move", $d, "to", x, y, "facing", dir }
    }
    print abs(x) + abs(y)
}
END {
    if (_exit) {
        exit _exit
    }
}

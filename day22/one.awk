#!/usr/bin/env awk -f
BEGIN {
    FPAT = "[[:digit:]]+"
    DEBUG = 1
}
/^Filesystem +Size +Used +Avail +Use%$/ {
    output_started = 1
    next
}
!output_started {
    next
}
(NF != 6) {
    print "DATA ERROR, invalid output, NF=", NF, ":", $0
    exit _exit=1
}
{
    if ($4 + $5 != $3) {
        print "DATA ERROR, sizes don't match:", $0
        exit _exit=1
    }
    SIZE[$1,$2] = $3
    USED[$1,$2] = $4
    AVAIL[$1,$2] = $5
}
END {
    if (_exit) {
        exit _exit
    }
    num_pairs = 0
    for (A in USED) if (USED[A]) {
        for (B in AVAIL) if (B != A) {
            if (USED[A] <= AVAIL[B]) {
                ++num_pairs
            }
        }
    }
    print num_pairs
}

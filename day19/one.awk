#!/usr/bin/env awk -f
BEGIN {
    PROCINFO["sorted_in"] = "@ind_num_asc"
    DEBUG = 0
}
$0 !~ /^[[:digit:]]+$/ {
    print "DATA ERROR: expecting a number, saw", $0
    exit _exit=1
}
{
    for (e = 1; e <= $1; ++e) {
        ELF[e] = 1
    }
    taker = 0
    while (length(ELF) > 1) {
        if (DEBUG) print length(ELF), "elves remain"
        for (e in ELF) {
            if (taker && (taker != e)) {
                ELF[taker] += ELF[e]
                delete ELF[e]
                taker = 0
            } else {
                taker = e
            }
        }
    }
    if (DEBUG) print "Remaining elf at end:"
    for (e in ELF) {
        print e
    }
}
END {
    if (_exit) {
        exit _exit
    }
}

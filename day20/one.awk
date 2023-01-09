#!/usr/bin/env awk -f
BEGIN {
    PROCINFO["sorted_in"] = "@val_num_asc"
    FPAT = "[[:digit:]]+"
    DEBUG = 0
}
(NF != 2) {
    print "DATA ERROR in", $0
    exit _exit=1
}
{
    if ($1 in BLOCKED) {
        print "DATA ERROR duplicate start in:", BLOCKED[$1], $2
        exit _exit=1
    }
    BLOCKED[$1] = $2
}
END {
    if (_exit) {
        exit _exit
    }
    ip = 0
    for (b in BLOCKED) {
        if (int(b) <= ip) {
            if (DEBUG) {
                printf ("%010d in [%010d:%010d]\n", ip, b, BLOCKED[b])
            }
            ip = BLOCKED[b] + 1
        }
    }
    print ip
}

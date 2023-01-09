#!/usr/bin/env awk -f
BEGIN {
    FPAT = "[[:digit:]]+"
    RANGE_END = 4294967296
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
    if (NR == 3) {
        RANGE_END = 10
    }
    num_blocks = length(BLOCKED)
    ip = 0
    num_allowed = 0
    while (length(BLOCKED) > 0) {
        PROCINFO["sorted_in"] = "@val_num_asc"
        for (b in BLOCKED) {
            if (DEBUG) {
                printf("look for blocking in range [%010d:%010d]\n", b, BLOCKED[b])
            }
            if (int(b) <= ip) {
                if (DEBUG) {
                    printf ("%010d blocked by [%010d:%010d]\n", ip, b, BLOCKED[b])
                }
                ip = BLOCKED[b] + 1
            }
        }
        PROCINFO["sorted_in"] = "@ind_num_asc"
        for (b in BLOCKED) {
            if (DEBUG) {
                printf("look for start in range [%010d:%010d]\n", b, BLOCKED[b])
            }
            if (int(b) <= ip) {
                if (DEBUG) {
                    printf("deleting range [%010d:%010d]\n", b, BLOCKED[b])
                }
                delete BLOCKED[b]
            } else {
                if (DEBUG) {
                    printf ("[%010d:%010d) allowed\n", ip, b)
                }
                num_allowed += b - ip
                ip = int(b)
                break
            }
        }
    }
    if (ip < RANGE_END) {
        if (DEBUG) {
            printf ("[%010d:%010d) allowed\n", ip, RANGE_END)
        }
        num_allowed += RANGE_END - ip
    }
    print num_allowed
}

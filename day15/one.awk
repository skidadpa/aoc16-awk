#!/usr/bin/env awk -f
BEGIN {
    FPAT = "[[:digit:]]+"
    LIMIT = 999999999
    DEBUG = 0
}
$0 !~ /^Disc #[[:digit:]]+ has [[:digit:]]+ positions; at time=0, it is at position [[:digit:]]+\.$/ {
    print "DATA ERROR, unrecognized line", $0
    exit _exit=1
}
{
    if ($2 < 2) {
        print "DATA ERROR, illegal disc size", $2, "in", $0
        exit _exit=1
    }
    SIZE[$1] = $2
    POSITION[$1] = ($4 + $1) % $2
    # Also should verify that all SIZES are relatively-prime
    if (DEBUG) {
        print
    }
}
END {
    if (_exit) {
        exit _exit
    }
    time = 0
    while (time <= LIMIT) {
        dt = 1
        disks_left = 0
        for (i in SIZE) {
            if (POSITION[i]) {
                ++disks_left
            } else {
                dt *= SIZE[i]
            }
        }
        if (!disks_left) {
            if (DEBUG) {
                print "found solution at time", time
            }
            break
        }
        time += dt
        for (i in POSITION) {
            POSITION[i] = (POSITION[i] + dt) % SIZE[i]
        }
        if (DEBUG) {
            print disks_left, "disks left at time", time, "advancing time by", dt
        }
    }
    if (disks_left) {
        print "PROCESSING ERROR, no solution found by time", LIMIT
        exit _exit=1
    }
    print time
}

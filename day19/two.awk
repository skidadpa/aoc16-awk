#!/usr/bin/env awk -f
BEGIN {
    DEBUG = 0
}
$0 !~ /^[[:digit:]]+$/ {
    print "DATA ERROR: expecting a number, saw", $0
    exit _exit=1
}
{
    current_num_elves = $1
    for (e = 1; e <= current_num_elves; ++e) {
        ELVES[e] = e
    }
    if (DEBUG) {
        print current_num_elves, "elves at start"
    }
    current_taker = 1
    while (current_num_elves > 1) {
        next_num_elves = current_num_elves
        first_giver = current_taker + int(current_num_elves/2)
        if (first_giver > current_num_elves) {
            first_giver -= current_num_elves
        }
        giver = next_first_taker = first_giver
        if (DEBUG > 3) {
            print "next_first_taker index", next_first_taker, "elf", ELVES[next_first_taker]
        }
        offset = 0
        while (current_taker != first_giver) {
            if (DEBUG > 1) {
                print ELVES[current_taker], "taking from", ELVES[giver]
            }
            if (++current_taker > current_num_elves) {
                current_taker = 1
            }
            delete ELVES[giver]
            if (giver < (next_first_taker + offset)) {
                --next_first_taker
                ++offset
                if (DEBUG > 3) {
                    print "next_first_taker moved to index", next_first_taker, "offset", offset
                }
            }
            if (next_num_elves % 2) {
                giver += 2
            } else {
                ++giver
            }
            if (giver > current_num_elves) {
                giver -= current_num_elves
            }
            --next_num_elves
            if (next_first_taker > next_num_elves) {
                next_first_taker -= next_num_elves
                offset = 0
                if (DEBUG > 4) {
                    print "next_first_taker adjusted to index", next_first_taker, "offset", offset
                }
            }
        }
        current_taker = next_first_taker
        current_num_elves = asort(ELVES, ELVES, "@ind_num_asc")
        if (current_num_elves != next_num_elves) {
            print "PROCESSING ERROR, should be", next_num_elves, "elves left instead of", current_num_elves
            exit _exit=1
        }
        if (DEBUG) {
            print current_num_elves, "elves left, new taker is", ELVES[current_taker]
        }
        if (DEBUG > 2) {
            for (e = 1; e <= current_num_elves; ++e) {
                printf(" %d", ELVES[e])
            }
            printf("\n")
        }
    }
    print ELVES[1]
}
END {
    if (_exit) {
        exit _exit
    }
}

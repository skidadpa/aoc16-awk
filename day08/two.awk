#!/usr/bin/env awk -f
function dump_lcd(   x, y) {
    for (y = 0; y < YMAX; ++y) {
        for (x = 0; x < XMAX; ++x) {
            if ((x,y) in LCD) {
                printf("%c", LCD[x,y])
            } else {
                printf(".")
            }
        }
        printf("\n")
    }
}
BEGIN {
    FPAT = "([[:digit:]]+)"
    XMAX = 50
    YMAX = 6
    DEBUG = 0
    split("", LCD)
    if (DEBUG) {
        print "INITIAL STATE"
        dump_lcd()
    }
}
(NR == 1) && /^SAMPLE_DATA$/ {
    XMAX = 7
    YMAX = 3
    if (DEBUG) {
        print "setting XMAX to", XMAX, "and YMAX to", YMAX
        print "NEW INITIAL STATE"
        dump_lcd()
    }
    next
}
/^rect [[:digit:]]+x[[:digit:]]+$/ {
    for (x = 0; x < $1; ++x) {
        for (y = 0; y < $2; ++y) {
            LCD[x,y] = "#"
        }
    }
    if (DEBUG) {
        print $1, "x", $2, "RECT"
        dump_lcd()
    }
    next
}
/^rotate row y=[[:digit:]]+ by [[:digit:]]+$/ {
    split("", NEW_ROW)
    for (x = 0; x < XMAX; ++x) {
        if ((x,$1) in LCD) {
            NEW_ROW[(x + $2) % XMAX] = LCD[x,$1]
            delete LCD[x,$1]
        }
    }
    for (x in NEW_ROW) {
        LCD[x,$1] = NEW_ROW[x]
    }
    if (DEBUG) {
        print "ROTATE ROW", $1, "by", $2
        dump_lcd()
    }
    next
}
/^rotate column x=[[:digit:]]+ by [[:digit:]]+$/ {
    split("", NEW_COLUMN)
    for (y = 0; y < YMAX; ++y) {
        if (($1,y) in LCD) {
            NEW_COLUMN[(y + $2) % YMAX] = LCD[$1,y]
            delete LCD[$1,y]
        }
    }
    for (y in NEW_COLUMN) {
        LCD[$1,y] = NEW_COLUMN[y]
    }
    if (DEBUG) {
        print "ROTATE COLUMN", $1, "by", $2
        dump_lcd()
    }
    next
}
{
    print "DATA ERROR"
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    for (c in LCD) {
        split(c, COORDS, SUBSEP)
        if ((COORDS[1] < 0) || (COORDS[1] >= XMAX) ||
            (COORDS[2] < 0) || (COORDS[2] >= YMAX)) {
            print "PROCESSING ERROR pixel at", COORDS[1], COORDS[2]
            exit _exit=1
        }
    }
    dump_lcd()
}

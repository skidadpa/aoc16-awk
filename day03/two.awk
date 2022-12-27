#!/usr/bin/env awk -f
BEGIN {
    possible = 0
    corner = 0
    DEBUG = 0
}
$0 !~ /^ *[[:digit:]]+ +[[:digit:]]+ +[[:digit:]]+ *$/ {
    print "DATA ERROR"
    exit _exit=1
}
{
    ++corner
    for (i = 1; i <= 3; ++i) {
        TRIANGLE[i][corner] = $i
    }
    if (corner >= 3) {
        for (i = 1; i <= 3; ++i) {
            if ((TRIANGLE[i][1] < TRIANGLE[i][2] + TRIANGLE[i][3]) &&
                (TRIANGLE[i][2] < TRIANGLE[i][1] + TRIANGLE[i][3]) &&
                (TRIANGLE[i][3] < TRIANGLE[i][1] + TRIANGLE[i][2])) {
                ++possible
                if (DEBUG) {
                    print "possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3]
                    next
                }
            } else if (DEBUG) {
                print "NOT possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3]
            }
        }
        corner = 0
    }
}
END {
    if (_exit) {
        exit _exit
    }
    print possible
}

#!/usr/bin/env awk -f
BEGIN {
    possible = 0
    DEBUG = 0
}
$0 !~ /^ *[[:digit:]]+ +[[:digit:]]+ +[[:digit:]]+ *$/ {
    print "DATA ERROR"
    exit _exit=1
}
{
    if (($1 < $2 + $3) && ($2 < $1 + $3) && ($3 < $1 + $2)) {
        ++possible
        if (DEBUG) {
            print "possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3]
            next
        }
    } else if (DEBUG) {
        print "NOT possible:", TRIANGLE[i][1], TRIANGLE[i][2], TRIANGLE[i][3]
    }
}
END {
    if (_exit) {
        exit _exit
    }
    print possible
}

#!/usr/bin/env awk -f
BEGIN {
    FPAT="[a-z]"
    DEBUG = 0
}
$0 !~ /^[a-z]+$/ {
    print "DATA ERROR"
    exit _exit=1
}
{
    for (i = 1; i <= NF; ++i) {
        ++FREQ[i][$i]
    }
}
END {
    if (_exit) {
        exit _exit
    }
    code = ""
    for (c in FREQ) {
        asorti(FREQ[c], CHAR, "@val_num_desc")
        if (DEBUG) {
            print "CHARACTER", c
            for (i in CHAR) {
                print i, CHAR[i], FREQ[c][CHAR[i]]
            }
        }
        code = code CHAR[1]
    }
    print code
}

#!/usr/bin/env awk -f
BEGIN {
    FPAT="([a-z]+)|([[:digit:]]+)"
    sum = 0
    split("bcdefghijklmnopqrstuvwxyz", CHR, "")
    CHR[0] = "a"
    for (i in CHR) {
        VAL[CHR[i]] = i
    }
    DEBUG = 0
    if (DEBUG > 2) {
        print "CHR:"
        for (i in CHR) {
            print " ", i, CHR[i]
        }
        print "VAL:"
        for (ch in VAL) {
            print " ", ch, VAL[ch]
        }
    }
}
$0 !~ /^([a-z]+-)+[[:digit:]]+\[[a-z]{5}\]$/ {
    print "DATA ERROR"
    exit _exit=1
}
function char_count_compare(i1, v1, i2, v2,   x) {
    if (v1 > v2) {
        return -1
    } else if (v1 < v2) {
        return 1
    } else if (i1 < i2) {
        return -1
    } else if (i1 > i2) {
        return 1
    } else {
        return 0
    }
}
{
    name = ""
    for (i = 1; i <= NF - 2; ++i) {
        name = name $i
    }
    sector_id = $i
    checksum = $NF
    split("", COUNTS)
    split(name, CHARS, "")
    for (ch in CHARS) {
        ++COUNTS[CHARS[ch]]
    }
    asorti(COUNTS, CHECKS, "char_count_compare")
    split(checksum, CHARS, "")
    if (DEBUG > 1) {
        print name, "COUNTS:"
        for (i in COUNTS) {
            print " ", i, COUNTS[i]
        }
        print name, "CHECKS:"
        for (i in CHECKS) {
            print " ", i, CHECKS[i]
        }
        print checksum, "CHARS:"
        for (i in CHARS) {
            print " ", i, CHARS[i]
        }
    }
    for (i in CHARS) {
        if (CHARS[i] != CHECKS[i]) {
            if (DEBUG) {
                print name, sector_id, checksum, "FAILED"
            }
            next
        }
    }
    sum += sector_id
    if (DEBUG) {
        print name, sector_id, checksum, "PASSED"
    }
    gsub(/-[[:digit:]]+\[([a-z]){5}\]$/, "")
    plaintext = ""
    split($0, CHARS, "")
    for (i in CHARS) {
        if (CHARS[i] == "-") {
            plaintext = plaintext " "
            if (DEBUG > 2) {
                print "- becomes SPACE"
            }
        } else {
            plaintext = plaintext CHR[(VAL[CHARS[i]] + sector_id) % 26]
            if (DEBUG > 2) {
                print VAL[CHARS[i]], CHARS[i], "becomes", (VAL[CHARS[i]] + sector_id) % 26, CHR[(VAL[CHARS[i]] + sector_id) % 26]
            }
        }
    }
    if (match(plaintext, /north *pole/)) {
        print sector_id, plaintext
    }
}
END {
    if (_exit) {
        exit _exit
    }
}

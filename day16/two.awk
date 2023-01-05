#!/usr/bin/env awk -f
BEGIN {
    MAP["0"] = "1"
    MAP["1"] = "0"
    DEBUG = 0
}
function one_step(a,   CHARS, n, b, i) {
    n = split(a, CHARS, "")
    b = MAP[CHARS[n]]
    for (i = n - 1; i >= 1; --i) {
        b = b MAP[CHARS[i]]
    }
    return a "0" b
}
function checksum(s,   c, n, i) {
    c = ""
    n = length(s)
    for (i = 1; i < n; i += 2) {
        if (substr(s, i, 1) == substr(s, i+1, 1)) {
            c = c "1"
        } else {
            c = c "0"
        }
    }
    if (length(c) % 2) {
        return c
    } else {
        return checksum(c)
    }
}
{
    a = $2
    if (DEBUG) {
        print "starting from a =", a
    }
    while (length(a) < $3) {
        a = one_step(a)
        if (DEBUG) {
            print "after a step, a =", a
        }
    }
    if (DEBUG) {
        print "keeping", $3, "characters, a =", substr(a, 1, $3)
    }
    print checksum(substr(a, 1, $3))
}

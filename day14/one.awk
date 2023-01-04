#!/usr/bin/env awk -f
@load "./md5"
BEGIN {
    ANY_TRIPLE = "(000)|(111)|(222)|(333)|(444)|(555)|(666)|(777)|(888)|(999)"
    ANY_TRIPLE = ANY_TRIPLE "|(aaa)|(bbb)|(ccc)|(ddd)|(eee)|(fff)"
    LIMIT = 100000

    DEBUG = 0
}
{
    for (idx = 0; idx < LIMIT; ++idx) {
        hash = md5($0 idx)
        found = match(hash, ANY_TRIPLE)
        if (found) {
            pentuple = substr(hash, found, 3) substr(hash, found, 2)
            if (DEBUG) MATCH3[idx] = hash " " pentuple
            for (nxt = idx + 1; nxt <= idx + 1000; ++nxt) {
                hash = md5($0 nxt)
                if (index(hash, pentuple)) {
                    MATCH5[idx] = nxt " " hash
                    if (length(MATCH5) >= 64) {
                        if (DEBUG) {
                            print length(MATCH3), "candidates"
                            print length(MATCH5), "keys found"
                            if (DEBUG > 1) {
                                for (m in MATCH3) {
                                    printf("%04d %s: ", m, MATCH3[m])
                                    if (m in MATCH5) {
                                        printf("%s\n", MATCH5[m])
                                    } else {
                                        printf("no match5\n")
                                    }
                                }
                            }
                        }
                        print idx
                        next
                    }
                }
            }
        }
    }
    print "PROCESSING ERROR, no match found after", LIMIT, "hashes tried"
    if (DEBUG) {
        print length(MATCH3), "candidates"
        print length(MATCH5), "keys found"
        if (DEBUG > 1) {
            for (m in MATCH3) {
                printf("%i %s: ", m, MATCH3[m])
                if (m in MATCH5) {
                    printf("%s\n", MATCH5[m])
                } else {
                    printf("no match5\n")
                }
            }
        }
    }
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
}

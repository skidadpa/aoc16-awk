#!/usr/bin/env awk -f
BEGIN {
    egg_count = 12
    REGISTERS["a"] = egg_count
    REGISTERS["b"] = REGISTERS["c"] = REGISTERS["d"] = 0
    split("CPY ADD JNZ TGL NOP MUL", OPCODES)
    for (o in OPCODES) {
        OPCODE_NUMBER[OPCODES[o]] = o
    }
    DEBUG = 0
}
/^cpy ([abcd]|(-?[[:digit:]]+)) [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["CPY"]
    DST[NR] = $3
    VAL[NR] = $2
    next
}
/^inc [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["ADD"]
    DST[NR] = $2
    VAL[NR] = 1
    next
}
/^dec [abcd]$/ {
    OP[NR] = OPCODE_NUMBER["ADD"]
    DST[NR] = $2
    VAL[NR] = -1
    next
}
/^jnz ([abcd]|(-?[[:digit:]]+)) ([abcd]|(-?[[:digit:]]+))$/ {
    OP[NR] = OPCODE_NUMBER["JNZ"]
    DST[NR] = $3
    VAL[NR] = $2
    next
}
/^tgl ([abcd]|(-?[[:digit:]]+))$/ {
    OP[NR] = OPCODE_NUMBER["TGL"]
    DST[NR] = $2
    VAL[NR] = 1
    next
}
function optimize_ops(   i) {
    split("", FO)
    split("", FV)
    split("", FD)
    if (DEBUG) {
        print "OPTIMIZING:"
    }
    for (i = NR; i >= 1; --i) {
        FO[i] = OP[i]
        FV[i] = VAL[i]
        FD[i] = DST[i]
    }
    for (i = 1; i <= NR; ++i) {
        if (FO[i] == OPCODE_NUMBER["JNZ"]) {
            if ((FD[i] == -2) &&
                (FO[i - 2] == OPCODE_NUMBER["ADD"]) &&
                (FV[i - 2] == 1) &&
                (FO[i - 1] == OPCODE_NUMBER["ADD"]) &&
                (FV[i - 1] == -1) &&
                (FD[i - 1] == FV[i])) {

                if (DEBUG) {
                    print "replacing:"
                    print i-2, OPCODES[FO[i-2]], FV[i-2], FD[i-2]
                    print i-1, OPCODES[FO[i-1]], FV[i-1], FD[i-1]
                    print i, OPCODES[FO[i]], FV[i], FD[i]
                }
                FO[i-1] = OPCODE_NUMBER["ADD"]
                FV[i-1] = FV[i]
                FD[i-1] = FD[i-2]
                FO[i] = OPCODE_NUMBER["CPY"]
                FV[i] = 0
                FD[i] = FV[i-1]
                FO[i-2] = OPCODE_NUMBER["NOP"]
                FV[i-2] = 0
                FD[i-2] = 0
                if (DEBUG) {
                    print "with:"
                    print i-2, OPCODES[FO[i-2]], FV[i-2], FD[i-2]
                    print i-1, OPCODES[FO[i-1]], FV[i-1], FD[i-1]
                    print i, OPCODES[FO[i]], FV[i], FD[i]
                }
            } else if ((FD[i] == -5) &&
                       (FO[i-5] == OPCODE_NUMBER["CPY"]) &&
                       (FD[i-5] == FV[i-3]) &&
                       (FO[i-4] == OPCODE_NUMBER["NOP"]) &&
                       (FO[i-3] == OPCODE_NUMBER["ADD"]) &&
                       (FO[i-2] == OPCODE_NUMBER["CPY"]) &&
                       (FV[i-2] == 0) &&
                       (FD[i-2] == FV[i-3]) &&
                       (FO[i-1] == OPCODE_NUMBER["ADD"]) &&
                       (FV[i-1] == -1) &&
                       (FD[i-1] == FV[i])) {

                if (DEBUG) {
                    print "replacing:"
                    print i-4, OPCODES[FO[i-4]], FV[i-4], FD[i-4]
                    print i-3, OPCODES[FO[i-3]], FV[i-3], FD[i-3]
                    print i-2, OPCODES[FO[i-2]], FV[i-2], FD[i-2]
                    print i-1, OPCODES[FO[i-1]], FV[i-1], FD[i-1]
                    print i, OPCODES[FO[i]], FV[i], FD[i]
                }
                FO[i-4] = OPCODE_NUMBER["MUL"]
                FV[i-4] = FV[i]
                FD[i-4] = FV[i-3]
                FO[i] = OPCODE_NUMBER["CPY"]
                FV[i] = 0
                FD[i] = FV[i-4]
                FO[i-1] = OPCODE_NUMBER["NOP"]
                FV[i-1] = 0
                FD[i-1] = 0
                if (DEBUG) {
                    print "with:"
                    print i-4, OPCODES[FO[i-4]], FV[i-4], FD[i-4]
                    print i-3, OPCODES[FO[i-3]], FV[i-3], FD[i-3]
                    print i-2, OPCODES[FO[i-2]], FV[i-2], FD[i-2]
                    print i-1, OPCODES[FO[i-1]], FV[i-1], FD[i-1]
                    print i, OPCODES[FO[i]], FV[i], FD[i]
                }
            }
        }
    }
}
{
    print "DATA ERROR, unrecognized instruction", $0
    exit _exit=1
}
END {
    if (_exit) {
        exit _exit
    }
    if (DEBUG) {
        print "PROGRAM:"
        for (i = 1; i <= NR; ++i) {
            printf("%02d %s %2s %2s\n", i, OPCODES[OP[i]], VAL[i], DST[i])
        }
        printf("REGISTERS: ")
        print REGISTERS["a"], REGISTERS["b"], REGISTERS["c"], REGISTERS["d"]
        print "EXECUTION:"
    }
    optimize_ops()
    pc = 1
    while (pc <= NR) {
        if (DEBUG && ((++instruction_count % 100000) == 0)) {
            print instruction_count, "instructions executed"
        }
        next_pc = pc + 1
        if (DEBUG > 1) {
            printf("%02d : %s %2s %2s  -> ", pc, OPCODES[FO[pc]], FV[pc], FD[pc])
        }
        switch (FO[pc]) {
        case 1: # CPY
            if (FD[pc] in REGISTERS) {
                val = (FV[pc] in REGISTERS) ? REGISTERS[FV[pc]] : FV[pc]
                REGISTERS[FD[pc]] = val
            }
            break
        case 2: # ADD
            val = (FV[pc] in REGISTERS) ? REGISTERS[FV[pc]] : FV[pc]
            if (FD[pc] in REGISTERS) {
                REGISTERS[FD[pc]] += val
            }
            break
        case 3: # JNZ
            val = (FV[pc] in REGISTERS) ? REGISTERS[FV[pc]] : FV[pc]
            dst = (FD[pc] in REGISTERS) ? REGISTERS[FD[pc]] : FD[pc]
            if (val) {
                next_pc = pc + dst
            }
            break
        case 4: # TGL
            dst = pc + ((FD[pc] in REGISTERS) ? REGISTERS[FD[pc]] : FD[pc])
            if ((dst > NR) || (dst < 1)) {
                if (DEBUG > 1) {
                    printf("%02d OUT OF RANGE  -> ", dst)
                }
                break
            }
            if (DEBUG > 1) {
                printf("%02d %s %2s %2s => ", dst, OPCODES[OP[dst]], VAL[dst], DST[dst])
            }
            switch (OP[dst]) {
            case 1: # CPY
                OP[dst] = OPCODE_NUMBER["JNZ"]
                break
            case 2: # ADD
                VAL[dst] *= -1
                break
            case 3: # JNZ
                OP[dst] = OPCODE_NUMBER["CPY"]
                break
            case 4: # TGL
                OP[dst] = OPCODE_NUMBER["ADD"]
                break
            default:
                print "PROCESSING ERROR, unrecognized OPCODE", OP[dst], "at", dst
                exit _exit=1
            }
            if (DEBUG > 1) {
                printf("%s %2s %2s  -> ", OPCODES[OP[dst]], VAL[dst], DST[dst])
            }
            optimize_ops()
            break
        case 5: # NOP
            break
        case 6: # MUL
            val = (FV[pc] in REGISTERS) ? REGISTERS[FV[pc]] : FV[pc]
            if (FD[pc] in REGISTERS) {
                REGISTERS[FD[pc]] *= val
            }
            break
        default:
            print "PROCESSING ERROR, unrecognized OPCODE", OP[pc], "at pc", pc
            exit _exit=1
        }
        if (DEBUG > 1) {
            print REGISTERS["a"], REGISTERS["b"], REGISTERS["c"], REGISTERS["d"]
        }
        pc = next_pc
    }
    print REGISTERS["a"]
}

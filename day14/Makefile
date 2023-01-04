CFLAGS += $(shell pkg-config --cflags libcrypto) -Wno-deprecated-declarations
LDLIBS += $(shell pkg-config --libs libcrypto)

.PHONY: test clean update

test : expected.txt results.txt
	diff -s expected.txt results.txt

PROGRAMS = one.awk two.awk
LIBRARIES = md5.so
INPUTS = sample.txt input.txt

results.txt : $(PROGRAMS) $(LIBRARIES) $(INPUTS)
	./one.awk sample.txt > $@
	./one.awk input.txt >> $@
	./two.awk sample.txt >> $@
	./two.awk input.txt >> $@
	cat $@

md5.so : md5.c
	$(CC) -o md5.so -shared $(CFLAGS) md5.c $(LDLIBS)

clean:
	$(RM) results.txt $(LIBRARIES)

update: results.txt
	cp $< expected.txt

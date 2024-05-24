.PHONY: run
run: fizzbuzz
	./fizzbuzz

fizzbuzz: fizzbuzz.o
	ld $^ -o $@

fizzbuzz.o: fizzbuzz.nasm
	nasm -felf64 $^

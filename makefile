Bracketmatcher: Bracketmatcher.asm Brackematcher.o
	ld -m elf_i386 Bracketmatcher.o -o Bracketmatcher
Brackematcher.o: Bracketmatcher.asm
	nasm -f elf32 -g -F dwarf Bracketmatcher.asm
clean:
	rm -f Bracketmatcher.o


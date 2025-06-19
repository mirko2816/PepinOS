OBJ=kernel
CC=gcc -m32 -ffreestanding -fno-pic
LD=ld -m elf_i386 --oformat binary -Ttext 0x1000
OBJS=kernel.o screen.o lib.o gdt.o

all: kernel

kernel: $(OBJS)
	$(LD) $(OBJS) -o kernel

%.o: %.c
	$(CC) -c $< -o $@

clean:
	rm -f kernel *.o

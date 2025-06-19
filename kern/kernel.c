#include "types.h"
#include "gdt.h"
#include "screen.h"

int main(void);

void _start(void)
{
	kY = 18;
	kattr = 0x5E;
	print("kernel : loading new gdt...\n");

    /* inicialización de la GDT y de los segmentos */
    init_gdt();

    /* Inicialización del puntero de pila %esp */
    asm("	movw $0x18, %ax \n \
        movw %ax, %ss \n \
        movl $0x20000, %esp");

    main();
}

int main(void)
{
	kattr = 0x4E;
	print("kernel : new gdt loaded !\n");

	while (1);
}

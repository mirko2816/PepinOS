#include "types.h"

#ifdef __SCREEN__

#define RAMSCREEN 0xB8000	/* inicio de la memoria de video */
#define SIZESCREEN 0xFA0	/* 4000, número de bytes de una página de texto */
#define SCREENLIM 0xB8FA0

char kX = 0;			/* posición actual del cursor en pantalla */
char kY = 8;
char kattr = 0x07;		/* atributos de video de los caracteres a mostrar */

#else

extern char kX;
extern char kY;
extern char kattr;

#endif				/* __SCREEN__ */

void scrollup(unsigned int);
void putcar(uchar);
void print(char*);

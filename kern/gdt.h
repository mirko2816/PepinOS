#define GDTBASE    0x0		/* dirección física donde debe residir la gdt */
#define GDTSIZE    0xFF		/* número máximo de descriptores en la tabla */

/* Descriptor de segmento */
struct gdtdesc {
	u16 lim0_15;
	u16 base0_15;
	u8 base16_23;
	u8 acces;
	u8 lim16_19:4;
	u8 other:4;
	u8 base24_31;
} __attribute__ ((packed));

/* Registro GDTR */
struct gdtr {
	u16 limite;
	u32 base;
} __attribute__ ((packed));

void init_gdt_desc(u32, u32, u8, u8, struct gdtdesc *);
void init_gdt(void);

#ifdef __GDT__
	struct gdtdesc kgdt[GDTSIZE];	/* GDT */
	struct gdtr kgdtr;		/* GDTR */
#else
	extern struct gdtdesc kgdt[];
	extern struct gdtr kgdtr;
#endif

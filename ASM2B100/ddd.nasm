mov  ax,dada
push ax
mov  ax,1100
int  2f
pop  dx
retf
  0xB8  0xDA  0xDA                    // :0100 mov ax,0xdada
  0x50                                // :0103 push ax
  0xB8  0x00  0x11                    // :0104 mov ax,0x1100
  0xCD  0x2F                          // :0107 int 0x2f
  0x5A                                // :0109 pop dx
  0xCB                                // :010A retf

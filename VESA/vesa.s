/**************************************************************************

 Vesa.S - Macro for The Semware Editor
 copyright (c) 1994 by Klaus Hartnegg, Kleist-Street 7,
 D-79331 Teningen, Germany

 Displays a menu of all VESA video modes that are available on the used
 VGA VESA graphics card. Activates the selected video mode.

 The status line shows the detected VESA mode and VGA card manufacturer.
 The menu lists of each video mode the mode number, the text resolution
 in characters and the size of the characters in pixels.

**************************************************************************/

BINARY "vesa.bin"
  integer proc GetMemW (integer addr)      : 0  // returns word = 2 bytes
  integer proc GetMemP (integer addr)      : 3  // returns pointer = 4 bytes
  integer proc GetBuf1Addr()               : 6
  integer proc GetBuf2Addr()               : 9
  integer proc _VesaTest ()                :12
  integer proc _VesaInfo (integer mode)    :15
  integer proc _VesaSetMode (integer mode) :18
end


integer proc GetMem (integer adr)       // convert word to byte
   return (GetMemW(adr) & 0ffh)
end



string proc GetMemStr0 (integer adr)    // read 0-terminated string from memory
string t[80]
integer i
   t = ''
   i = GetMem(adr)
   while i <> 0
      t = t + chr(i)
      adr = adr + 1
      i = GetMem(adr)
   endwhile
   return (t)
end



integer proc VesaTest ()
// 0: OK, 1: vga vesa not supported, 2: error
  integer i,j
  string vesa_code[4]

  i = _VesaTest()
  if (i & 0ffh) <> 04fh  i = 1   // vga vesa not supported
  elseif i shr 8 <> 0    i = 2   // error
  else i = 0                     // vesa detected
  endif

  i = GetBuf1Addr()
  vesa_code = ''
  j = 1
  while j <= 4
     vesa_code = vesa_code + chr(GetMem(i+j-1))
     j = j + 1
  endwhile
  i = 0
  if vesa_code <> 'VESA'  i = 1  endif

  return (i)
end



proc VesaMenu()
  integer mem1, mem2
  integer i,j,k
  integer buf, oldbuf


  i = VesaTest()
  case i
     when 1 warn ('VGA VESA not supported')
     when 2 warn ('VGA VESA error')
  endcase
  if i <> 0  return()  endif

  oldbuf = GetBufferId()
  buf = CreateTempBuffer()

  mem1 = GetBuf1Addr()
  mem2 = GetBuf2Addr()
  i = GetMemP(mem1+0Eh)
  j = GetMemW (i)

  while (j <> 0ffffh)
     k = _VesaInfo (j)
     if k <> 04Fh  write (' errcode=',k)  endif

     k = GetMem (mem2)
     if ((k & 16) == 0) & ((k & 2) <> 0)
        AddLine ('mode='+format(j:3)
                    +' '+format(GetMemW(mem2+012h):3)
                    +'x'+format(GetMemW(mem2+014h):2)
                    +' ('+str(GetMem(mem2+016h))+'x'+str(GetMem(mem2+017h))+')')
     endif

     i = i + 2
     j = GetMemW (i)
  endwhile

  // List ('available VESA text modes', 40)
  BegFile()
  message ('VESA Version '+str(GetMem (mem1+4))+'.'+str(GetMem(mem1+5))
          +' ('+GetMemStr0(GetMemP(mem1+6))+')')
  set (y1,5)
  if List ('choose video mode', 23)
     i = val (GetText (6,3))
     _VesaSetMode (i)
     Set (CurrVideoMode,0)
     UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  else
     UpdateDisplay()
  endif

  AbandonFile()

end



Proc Main()
  VesaMenu()
end


// suggested keyboard binding:
<alt f9> <v>  VesaMenu()                      // VGA VESA only
<alt f9> <1>  Set(CurrVideoMode, _25_lines_)  // all cards
<alt f9> <2>  Set(CurrVideoMode, _28_lines_)  // VGA only
<alt f9> <3>  Set(CurrVideoMode, _43_lines_)  // EGA and VGA
<alt f9> <4>  Set(CurrVideoMode, _50_lines_)  // VGA only

<alt f9> <D>  Dos()    // usually previously bound do alt-f9

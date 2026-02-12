/************************************************************************
  Macro:   $Mαι (TSE Edition)

  Author:  Luca SALViNi  (2:332/407.96@Fidonet.org)

  Date:    08/19/93   v1.0

  Description:

  Delirio estivo

  Usage:

  <Crl S> <S>      Toggle symbol mode

  Installation:

  Add Symbol.s into directory tse\ui\

  Add in tse.s the line:

  #include ["symbol.s"]
 ************************************************************************/

integer symbolize   = 0

keydef symbol
       <a>     Inserttext('’')
       <b>     Inserttext('α')
       <c>     Inserttext('›')
       <d>     Inserttext('λ')
       <e>     Inserttext('ξ')
       <f>     Inserttext('')
       <g>     Inserttext('€')
       <h>     Inserttext('Χ')
       <i>     Inserttext('­')
       <j>     Inserttext('υ')
       <k>     Inserttext('K')
       <l>     Inserttext('')
       <m>     Inserttext('M')
       <n>     Inserttext('γ')
       <o>     Inserttext('ι')
       <p>     Inserttext('')
       <q>     Inserttext('ν')
       <r>     Inserttext('η')
       <s>     Inserttext('$')
       <t>     Inserttext('β')
       <u>     Inserttext('ζ')
       <v>     Inserttext('ϋ')
       <w>     Inserttext('W')
       <x>     Inserttext('*')
       <y>     Inserttext('')
       <z>     Inserttext('%')

       <Shift a>     Inserttext('’')
       <Shift b>     Inserttext('α')
       <Shift c>     Inserttext('›')
       <Shift d>     Inserttext('λ')
       <Shift e>     Inserttext('ξ')
       <Shift f>     Inserttext('')
       <Shift g>     Inserttext('€')
       <Shift h>     Inserttext('Χ')
       <Shift i>     Inserttext('­')
       <Shift j>     Inserttext('υ')
       <Shift k>     Inserttext('K')
       <Shift l>     Inserttext('')
       <Shift m>     Inserttext('M')
       <Shift n>     Inserttext('γ')
       <Shift o>     Inserttext('ι')
       <Shift p>     Inserttext('')
       <Shift q>     Inserttext('ν')
       <Shift r>     Inserttext('η')
       <Shift s>     Inserttext('$')
       <Shift t>     Inserttext('β')
       <Shift u>     Inserttext('ζ')
       <Shift v>     Inserttext('ϋ')
       <Shift w>     Inserttext('W')
       <Shift x>     Inserttext('*')
       <Shift y>     Inserttext('')
       <Shift z>     Inserttext('%')
end

proc Sym()
    symbolize = not symbolize
    if symbolize
        Enable(symbol)
    else
        Disable(symbol)
    endif
end

<Ctrl S> <S>  Sym()

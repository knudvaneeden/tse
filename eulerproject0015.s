// euler15.s
// Project Euler Problem 15 - Lattice Paths
// How many routes through a 20x20 grid moving only right or down?
// Uses single-row DP with hi/lo 32-bit split (base 100000)
// Answer: 137846528820
// <version>1.0.0.0.1</version>

proc Main()
    integer h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10
    integer h11,h12,h13,h14,h15,h16,h17,h18,h19,h20
    integer l0,l1,l2,l3,l4,l5,l6,l7,l8,l9,l10
    integer l11,l12,l13,l14,l15,l16,l17,l18,l19,l20
    integer i, carry
    string  lostr[6]

    // initialize: row of 1s (top edge of grid)
    h0=0  h1=0  h2=0  h3=0  h4=0
    h5=0  h6=0  h7=0  h8=0  h9=0  h10=0
    h11=0 h12=0 h13=0 h14=0 h15=0
    h16=0 h17=0 h18=0 h19=0 h20=0
    l0=1  l1=1  l2=1  l3=1  l4=1
    l5=1  l6=1  l7=1  l8=1  l9=1  l10=1
    l11=1 l12=1 l13=1 l14=1 l15=1
    l16=1 l17=1 l18=1 l19=1 l20=1

    // 20 row iterations: row[j] += row[j-1], left to right
    i = 1
    while i <= 20
        l1 = l1 + l0
        carry = l1 / 100000
        l1 = l1 mod 100000
        h1 = h1 + h0 + carry
        l2 = l2 + l1
        carry = l2 / 100000
        l2 = l2 mod 100000
        h2 = h2 + h1 + carry
        l3 = l3 + l2
        carry = l3 / 100000
        l3 = l3 mod 100000
        h3 = h3 + h2 + carry
        l4 = l4 + l3
        carry = l4 / 100000
        l4 = l4 mod 100000
        h4 = h4 + h3 + carry
        l5 = l5 + l4
        carry = l5 / 100000
        l5 = l5 mod 100000
        h5 = h5 + h4 + carry
        l6 = l6 + l5
        carry = l6 / 100000
        l6 = l6 mod 100000
        h6 = h6 + h5 + carry
        l7 = l7 + l6
        carry = l7 / 100000
        l7 = l7 mod 100000
        h7 = h7 + h6 + carry
        l8 = l8 + l7
        carry = l8 / 100000
        l8 = l8 mod 100000
        h8 = h8 + h7 + carry
        l9 = l9 + l8
        carry = l9 / 100000
        l9 = l9 mod 100000
        h9 = h9 + h8 + carry
        l10 = l10 + l9
        carry = l10 / 100000
        l10 = l10 mod 100000
        h10 = h10 + h9 + carry
        l11 = l11 + l10
        carry = l11 / 100000
        l11 = l11 mod 100000
        h11 = h11 + h10 + carry
        l12 = l12 + l11
        carry = l12 / 100000
        l12 = l12 mod 100000
        h12 = h12 + h11 + carry
        l13 = l13 + l12
        carry = l13 / 100000
        l13 = l13 mod 100000
        h13 = h13 + h12 + carry
        l14 = l14 + l13
        carry = l14 / 100000
        l14 = l14 mod 100000
        h14 = h14 + h13 + carry
        l15 = l15 + l14
        carry = l15 / 100000
        l15 = l15 mod 100000
        h15 = h15 + h14 + carry
        l16 = l16 + l15
        carry = l16 / 100000
        l16 = l16 mod 100000
        h16 = h16 + h15 + carry
        l17 = l17 + l16
        carry = l17 / 100000
        l17 = l17 mod 100000
        h17 = h17 + h16 + carry
        l18 = l18 + l17
        carry = l18 / 100000
        l18 = l18 mod 100000
        h18 = h18 + h17 + carry
        l19 = l19 + l18
        carry = l19 / 100000
        l19 = l19 mod 100000
        h19 = h19 + h18 + carry
        l20 = l20 + l19
        carry = l20 / 100000
        l20 = l20 mod 100000
        h20 = h20 + h19 + carry
        i = i + 1
    endwhile

    // display result: h20 * 100000 + l20
    lostr = Str(l20)
    while Length(lostr) < 5
        lostr = "0" + lostr
    endwhile
    Warn("Euler 15 answer: " + Str(h20) + lostr)
end

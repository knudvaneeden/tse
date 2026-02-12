/* Play SB with TSE! */

binary "sb.bin"
integer proc writeaddr(integer data):0
integer proc writedata(integer data):3
end

integer maxreg= 0xf5

integer nOff= 0x000
integer nCd= 0x16b
integer nD=  0x181
integer nDd= 0x198
integer nE=  0x1b0
integer nF=  0x1ca
integer nFd= 0x1e5
integer nG=  0x202
integer nGd= 0x220
integer nA=  0x241
integer nAd= 0x263
integer nB=  0x287
integer nC=  0x2ae

proc sb_reset()
    integer i
    i= 1
    while (i <= maxreg)
        writeaddr(i)
        writedata(0)
        i= i+1
    endwhile
end sb_reset

proc sb_out(integer r, integer d)
// r= register, d= data
    writeaddr(r)
    writedata(d)
end sb_out

proc sb_setup()
    sb_out(0x20, 0x01)
    sb_out(0x40, 0x10)
    sb_out(0x60, 0xF0)
    sb_out(0x80, 0x77)
    sb_out(0xA0, 0x98)
    sb_out(0x23, 0x01)
    sb_out(0x43, 0x00)
    sb_out(0x63, 0xF0)
    sb_out(0x83, 0x77)
    sb_out(0xB0, 0x31)
end sb_setup

proc sb_init()
    sb_reset()
    sb_out(1, 0x10)
    sb_setup()
end sb_init

proc sb_note(integer channel, integer note, integer on)
// channel is from 0 to 15
// note is nD, nCd, etc... nOff to shutoff channel
// on is 1 to play a note
    sb_out(0xa0+channel, note & 0x00ff)
    sb_out(0xb0+channel, (0x20*on) | 0x10 | (note & 0xff00))
end sb_note

proc sb_off()
    sb_init()
    sb_out(1, 0)
    writeaddr(0xb0)
    writedata(0x11)
end sb_off

proc main()
    sb_init()
    sb_note(15, nFd, 1)
    delay(18)
    sb_note(4, nOff, 1)
    delay(18)
    sb_off()
end main


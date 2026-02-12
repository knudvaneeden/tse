//
// This is just to test the binary.  If you fool with the binary, you
// may find this stuff useful.
//

binary ["strstuff.bin"]
    integer proc TestBitSetBit( var string BitSet, integer Which )           :  0
    integer proc SetBitSetBit( var string BitSet, integer Which )     :  2
    integer proc ClrBitSetBit( var string BitSet, integer Which )     :  4
    integer proc FlipBitSetBit( var string BitSet, integer Which )    :  6
    integer proc PlantChar( var string CharStr, integer Where,
                                                integer What )        :  8
    proc ClearBitSet( var string BitSet )                             : 10
end

public proc test()
    string s[32] = "This is a test string."

    while Ask( "Enter something:", s )
        Message( "FlipBitSetBit returned ", FlipBitSetBit( s, 168 ) )
    endwhile
end

proc main()
end

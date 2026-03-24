PROC Main()
 //
 // given fixed test block to sort
 //
 // 3
 // 5a
 // z
 // c
 // C
 // b
 // 10
 // 6
 // ABC
 // ab
 // 6
 // W
 // a
 // 6
 // 0006
 // 6
 // 100
 // 100
 // 100
 // 2
 // 1
 //
 Sort() // sort lexicographical (alphabetical / not-numeric / in ASCII order) and ascending and case-sensitive
 //
 // 0006
 // 1
 // 10
 // 100
 // 100
 // 100
 // 2
 // 3
 // 5a
 // 6
 // 6
 // 6
 // 6
 // ABC
 // C
 // W
 // a
 // ab
 // b
 // c
 // z
 //
 // Sort( _IGNORE_CASE_ ) // sort lexicographical (alphabetical / not-numeric / in ASCII order) and ascending and case-insensitive
 //
 // 0006
 // 1
 // 10
 // 100
 // 100
 // 100
 // 2
 // 3
 // 5a
 // 6
 // 6
 // 6
 // 6
 // a
 // ab
 // ABC
 // b
 // c
 // C
 // W
 // z
 //
 // Sort( _DESCENDING_ ) // sort lexicographical (alphabetical / not-numeric / in ASCII order) and descending and case-sensitive
 //
 // z
 // c
 // b
 // ab
 // a
 // W
 // C
 // ABC
 // 6
 // 6
 // 6
 // 6
 // 5a
 // 3
 // 2
 // 100
 // 100
 // 100
 // 10
 // 1
 // 0006
 //
 // Sort( _DESCENDING_ | _IGNORE_CASE_ ) // sort lexicographical (alphabetical / not-numeric / in ASCII order) and descending and case-insensitive
 //
 // z
 // W
 // c
 // C
 // b
 // ABC
 // ab
 // a
 // 6
 // 6
 // 6
 // 6
 // 5a
 // 3
 // 2
 // 100
 // 100
 // 100
 // 10
 // 1
 // 0006
 //
 // Sort( _DECIMAL_ ) // sort numerical and ascending
 //
 // 3
 // z
 // c
 // C
 // b
 // 6
 // 6
 // W
 // a
 // 6
 // 6
 // 2
 // 1
 // 5a
 // 10
 // ab
 // ABC
 // 100
 // 100
 // 100
 // 0006
 //
 // Sort( _DECIMAL_ | _DESCENDING_ ) // sort numerical and descending
 //
 // 0006
 // ABC
 // 100
 // 100
 // 100
 // 5a
 // 10
 // ab
 // 3
 // z
 // c
 // C
 // b
 // 6
 // 6
 // W
 // a
 // 6
 // 6
 // 2
 // 1
 //
 // ExecMacro( "sort -k" ) // sort unique (=remove any sorted duplicates)
 //
 // 0006
 // 1
 // 10
 // 100
 // 2
 // 3
 // 5a
 // 6
 // ABC
 // C
 // W
 // a
 // ab
 // b
 // c
 // z
 //
 // ExecMacro( "sort -k _DECIMAL_" ) // sort unique (=remove any sorted duplicates) and numerical and ascending
 //
 // 0006
 // 1
 // 10
 // 100
 // 2
 // 3
 // 5a
 // 6
 // ABC
 // C
 // W
 // a
 // ab
 // b
 // c
 // z
 //
 // ExecMacro( "sort -k _DECIMAL_ | _DESCENDING_" ) // sort unique (=remove any sorted duplicates) and numerical and descending
 //
 // 0006
 // 1
 // 10
 // 100
 // 2
 // 3
 // 5a
 // 6
 // ABC
 // C
 // W
 // a
 // ab
 // b
 // c
 // z
 //
END

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
 // Sort() // sort lexicographical (alphabetical / not-numeric / in ASCII order) and ascending and case-sensitive
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
 // Sort( _DECIMAL_ | _IGNORE_CASE_ ) // sort lexicographical (alphabetical / not-numeric / in ASCII order) and ascending and case-omsensitive
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
 // Sort( _DECIMAL_ | _DESCENDING_ | _IGNORE_CASE_ ) // sort numerical and descending and case-insensitive
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
 // ExecMacro( "sort -k" ) // sort unique (=remove any sorted duplicates) and lexicographical and ascending and case-sensitive
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
 // ExecMacro( "sort -k -d" ) // sort unique (=remove any sorted duplicates) and descending and case-sensitive
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
 // 5a
 // 3
 // 2
 // 100
 // 10
 // 1
 // 0006
 //
 // ExecMacro( "sort -k -i" ) // sort unique (=remove any sorted duplicates) and lexicographical and descending and case-ininsensitive
 //
 // 0006
 // 1
 // 10
 // 100
 // 2
 // 3
 // 5a
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
 // ExecMacro( "sort -k -d -i" ) // sort unique (=remove any sorted duplicates) and descending and case insensitive
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
 // 5a
 // 3
 // 2
 // 100
 // 10
 // 1
 // 0006
 //
 ExecMacro( "sort -k _DECIMAL_" ) // sort unique (=remove any sorted duplicates) and numerical and ascending and case-sensitive
 //
// Note: The _DECIMAL_ parameter is thus clearly ignored and not taken into account, because the sort result is the same as 'sort -k', the default.
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
 ExecMacro( "sort -k -d _DECIMAL_" ) // sort unique (=remove any sorted duplicates) and numerical and descending and case-sensitive
 //
 // Note: this _DECIMAL_ parameter is not for the external sort.s TSE macro file, but for the TSE internal sort, so is ignored in this context.
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
 // 5a
 // 3
 // 2
 // 100
 // 10
 // 1
 // 0006
 //
 ExecMacro( "sort -k -d -i _DECIMAL_" ) // sort unique (=remove any sorted duplicates) and numerical and descending and case-insensitive
 //
 // Note: this _DECIMAL_ parameter is not for the external sort.s TSE macro file, but for the TSE internal sort, so is ignored in this context.
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
 // 5a
 // 3
 // 2
 // 100
 // 10
 // 1
 // 0006
 //
END

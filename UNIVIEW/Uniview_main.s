PROC Main()
 ExecMacro( "Status" )
 SetFont( "Courier New", 10, _FONT_BOLD_ )
 ExecMacro( "Unicode" )
 EditFile( "Uniview_Test.txt" )
ExecMacro( "Uniview" )
END

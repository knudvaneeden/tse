// HelpHelp ---------------------------------------------------------------
// Chris Antos, chrisant@microsoft.com

// allows GetHelp macro to handle help inside TSE menus



//#define DEBUG 1



/*	Command Line Options:

Syntax:		[-r] [-h] <topic>

ù "-r" - help topic found in main help file's index
ù "-h" - help topic not found in main help file's index

*/



///////////////////////////////////////////////////////////////////////////
// Variables

integer s_cCalls = 0



///////////////////////////////////////////////////////////////////////////
// Procedures

#ifndef WIN32
string proc QuotePath(string path)
	return(path)
end
#endif


proc Main()
	string cmdline[255] = Query(MacroCmdLine)

	s_cCalls = s_cCalls + 1

	if s_cCalls > 1 or GetGlobalInt("GETHELP_NoHelpHelp")
		// avoid infinite recursion with TSE's Help() command
		goto Out
	endif

	if cmdline[1] <> '-'
		goto Out
	endif

	case cmdline[2]
		when 'r', 'h'						// (handle both cases identically)
			// try to show help
			ExecMacro(Format("gethelp"; "-1"; Trim(cmdline[4:255])))
			if Val(Query(MacroCmdLine))
				// we handled it
				Set(MacroCmdLine, "true")
				#ifdef DEBUG
				Warn("handled")
				#endif
			else
				// we did not handle it, or we handled it but now need to tell
				// Help to display something for us.
				Set(MacroCmdLine, "false")
				#ifdef DEBUG
				Warn("not handled")
				#endif
			endif

		otherwise
			goto Out
	endcase

Out:
	s_cCalls = s_cCalls - 1
end


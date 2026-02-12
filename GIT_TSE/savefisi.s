FORWARD INTEGER PROC FNFileSaveFileVersionControlGitSimplestInitializeB()
FORWARD PROC Main()


// --- MAIN --- //

//
STRING iniFileNameGS[255] = ".\git_tse.ini"
//
PROC Main()
 Message( FNFileSaveFileVersionControlGitSimplestInitializeB() ) // gives e.g. TRUE
END

<F12> Main()

// --- LIBRARY --- //

// library: file: save: file: version: control: git: simplest: initialize <description></description> <version control></version control> <version>1.0.0.0.13</version> <version control></version control> (filenamemacro=savefisi.s) [<Program>] [<Research>] [kn, ri, th, 24-11-2022 00:28:38]
INTEGER PROC FNFileSaveFileVersionControlGitSimplestInitializeB()
 // e.g. //
 // e.g. STRING iniFileNameGS[255] = ".\git_tse.ini"
 // e.g. //
 // e.g. PROC Main()
 // e.g.  Message( FNFileSaveFileVersionControlGitSimplestInitializeB() ) // gives e.g. TRUE
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNFileSaveFileVersionControlGitSimplestInitializeB )
 // e.g. HELPDEF HELPDEFFNFileSaveFileVersionControlGitSimplestInitializeB
 // e.g.  title = "FNFileSaveFileVersionControlGitSimplestInitializeB() help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 INTEGER B = FALSE
 //
 SetGlobalStr( "s010", "5. Add + Commit your currently loaded file in TSE (into your local repository)" )
 SetGlobalStr( "s011", "1. Download once and install: Git-SCM" )
 SetGlobalStr( "s012", "2. Initialize once your repository directory" )
 SetGlobalStr( "s013", "3. Set once your name" )
 SetGlobalStr( "s014", "4. Set once your email" )
 SetGlobalStr( "s015", "Settings" )
 SetGlobalStr( "s016", "Quit" )
 SetGlobalStr( "s106", "Add your currently loaded filename in your current local repository directory" )
 SetGlobalStr( "s108", "Add a filename not to be loaded into TSE to your current local repository directory" )
 SetGlobalStr( "s017", "Add + Commit all files in the root directory and all subdirectories of the current repository directory (add . / commit .)" )
 SetGlobalStr( "s110", "Add + Commit a filename not to be loaded into TSE to your current local repository directory" )
 SetGlobalStr( "s018", "Add + Commit your currently loaded file in TSE into your remote repository: GitHub (push)" )
 SetGlobalStr( "s019", "Add + Commit your currently loaded file in TSE into your remote repository: GitLab (push)" )
 SetGlobalStr( "s020", "Change to another local repository directory" )
 SetGlobalStr( "s101", "Change to the default local repository directory" )
 SetGlobalStr( "s021", "Change to another branch in the current local repository directory (checkout)" )
 SetGlobalStr( "s022", "Change: Load another filename into TSE" )
 SetGlobalStr( "s094", "Check for any updates / any changes in the remote repository directory (ls-remote)" )
 SetGlobalStr( "s098", "Clean (without performing the clean action) in your remote repository directory (clean -n)" )
 SetGlobalStr( "s107", "Commit your current filename in your current local repository directory" )
 SetGlobalStr( "s109", "Commit a filename not to be loaded into TSE to your current local repository directory" )
 SetGlobalStr( "s023", "Copy the current local repository directory completely to another local repository directory (clone)" )
 SetGlobalStr( "s024", "Copy a remote Internet repository directory branch completely to a local repository directory (clone)" )
 SetGlobalStr( "s025", "Copy a remote Internet repository directory branch completely to a local repository directory: Example (clone)" )
 SetGlobalStr( "s026", "Copy all files from a directory and its subdirectories to another directory (copy *.* /s)" )
 SetGlobalStr( "s027", "Collaborate: 1. Fetch from a remote repository directory to the current local repository directory" )
 SetGlobalStr( "s028", "Collaborate: 2. Pull from a remote repository directory to the current local repository directory" )
 SetGlobalStr( "s029", "Collaborate: 3. Push to a remote repository directory from the current local repository directory" )
 SetGlobalStr( "s030", "Collaborate: 4. Remote" )
 SetGlobalStr( "s031", "Collaborate: 4. Remote -v" )
 SetGlobalStr( "s032", "Collaborate: 4. Remote add <name> <url>" )
 SetGlobalStr( "s033", "Collaborate: 4. Remote rm <name>" )
 SetGlobalStr( "s034", "Collaborate: 4. Remote rename <old name> <new name>" )
 SetGlobalStr( "s095", "Create a new remote repository on GitHub" )
 SetGlobalStr( "s096", "Create a new remote repository on GitLab" )
 SetGlobalStr( "s035", "Create a new branch in the current local repository directory" )
 SetGlobalStr( "s099", "Create a clean non-git directory (e.g. for cloning purposes) (MkDir)" )
 SetGlobalStr( "s036", "Delete another branch from your current local repository directory" )
 SetGlobalStr( "s037", "Delete your currently loaded file in TSE from your local repository directory" )
 SetGlobalStr( "s111", "Delete a filename not to be loaded into TSE from your current local repository directory" )
 SetGlobalStr( "s112", "Delete a filename not to be loaded into TSE from your remote repository directory" )
 SetGlobalStr( "s113", "Delete a directory not to be loaded into TSE from your current local repository directory" )
 SetGlobalStr( "s104", "Delete your currently loaded file in TSE from your remote repository directory (from git + also disk)" )
 SetGlobalStr( "s105", "Delete your currently loaded file in TSE from your remote repository directory (from git only)" )
 SetGlobalStr( "s038", "Download once and install: Git-Cygwin" )
 SetGlobalStr( "s103", "Download once and install: Git-SmartGit" )
 SetGlobalStr( "s039", "Download once and install: Git-Tortoise" )
 SetGlobalStr( "s040", "Get all filenames in your current local repository directory" )
 SetGlobalStr( "s114", "Get the source code of a previous revision (git show / svn cat)" )
 SetGlobalStr( "s041", "Goto your remote Git server web page on the Internet: GitHub" )
 SetGlobalStr( "s042", "Goto your remote Git server web page on the Internet: GitLab" )
 SetGlobalStr( "s043", "Load a whole git directory into TSE" )
 SetGlobalStr( "s044", "Merge your current branch with another branch in your current local repository directory" )
 SetGlobalStr( "s045", "Rename a filename in the current local repository directory" )
 SetGlobalStr( "s046", "Run the command line" )
 SetGlobalStr( "s047", "Run git commands in the current repository directory" )
 SetGlobalStr( "s048", "Run graphical Git-SCM Gitk program on the current local repository directory" )
 SetGlobalStr( "s049", "Run graphical Git-SCM Git-GUI program on the current local repository directory" )
 SetGlobalStr( "s102", "Run graphical SmartGit smartgit program current local repository directory" )
 SetGlobalStr( "s050", "Read your current local repository directory" )
 SetGlobalStr( "s100", "Read your default local repository directory" )
 SetGlobalStr( "s097", "Read all files in your current local repository directory" )
 SetGlobalStr( "s051", "Read your current branch name in your current local repository directory" )
 SetGlobalStr( "s052", "Read all the branch names in the current local repository directory: Branch" )
 SetGlobalStr( "s053", "Read all the branch names in the current local repository directory: Show-Branch" )
 SetGlobalStr( "s054", "Read the git config file for the current local repository directory" )
 SetGlobalStr( "s092", "Read the global git config file for the currently logged in user" )
 SetGlobalStr( "s055", "Read the git .gitignore file for the current local repository directory" )
 SetGlobalStr( "s056", "Read the history: Who changed what when (blame)" )
 SetGlobalStr( "s057", "Read the history: Diff (see also 'Show')" )
 SetGlobalStr( "s058", "Read the history: Diff: last with previous one back" )
 SetGlobalStr( "s059", "Read the history: Diff: last with previous two back" )
 SetGlobalStr( "s060", "Read the history: Diff: last with previous three back" )
 SetGlobalStr( "s061", "Read the history: Diff: last with previous four back" )
 SetGlobalStr( "s062", "Read the history: Diff: last with previous five back" )
 SetGlobalStr( "s063", "Read the history: Diff: last with previous six back" )
 SetGlobalStr( "s064", "Read the history: Diff: last with previous N back" )
 SetGlobalStr( "s065", "Read the history: Diff: previous M with previous N back" )
 SetGlobalStr( "s066", "Read the history: Log" )
 SetGlobalStr( "s067", "Read the history: Log --oneline" )
 SetGlobalStr( "s068", "Read the history: Show" )
 SetGlobalStr( "s069", "Read the history: Status" )
 SetGlobalStr( "s070", "Read Help: Git command help: subcommands" )
 SetGlobalStr( "s071", "Read Help: Git command help: concept guides" )
 SetGlobalStr( "s072", "Read Help: Git command all" )
 SetGlobalStr( "s073", "Read Help: Git command help" )
 SetGlobalStr( "s074", "Read Help: Git view tree .git" )
 SetGlobalStr( "s075", "Read the log file" )
 SetGlobalStr( "s093", "Read the Git command line executable" )
 SetGlobalStr( "s076", "Read the Git version" )
 SetGlobalStr( "s077", "Read book 'Version Control with Git' (O'Reilly)" )
 SetGlobalStr( "s078", "Replace your current file in the current local repository directory with version 1 version before" )
 SetGlobalStr( "s079", "Replace your current file in the current local repository directory with version 2 versions before" )
 SetGlobalStr( "s080", "Replace your current file in the current local repository directory with version 3 versions before" )
 SetGlobalStr( "s081", "Replace your current file in the current local repository directory with version 4 versions before" )
 SetGlobalStr( "s082", "Replace your current file in the current local repository directory with version 5 versions before" )
 SetGlobalStr( "s083", "Replace your current file in the current local repository directory with version 6 versions before" )
 SetGlobalStr( "s084", "Replace your current file in the current local repository directory with version N versions before" )
 SetGlobalStr( "s085", "Reset HEAD of your current file in the local repository directory" )
 SetGlobalStr( "s086", "1. Save your current state of your local repository directory: Stash: Push" )
 SetGlobalStr( "s087", "2. Restore your current state of your local repository directory: Stash: Pop" )
 SetGlobalStr( "s088", "1. Set version state: Indicate that this version in this local repository directory is bad or good: start (bisect)" )
 SetGlobalStr( "s089", "2. Set version state: Indicate that this version in this local repository directory is bad (bisect)" )
 SetGlobalStr( "s090", "2. Set version state: Indicate that this version in this local repository directory is good (bisect)" )
 SetGlobalStr( "s091", "3. Set version state: Indicate that this version in this local repository directory is bad or good: reset (bisect)" )
 //
 B = TRUE
 //
 RETURN( B )
 //
END

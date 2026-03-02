---
name: tse-sal
description: >
  Expert guidance for writing, editing, debugging, and refactoring SAL (Semware Application Language)
  macros and programs for The Semware Editor Professional (TSE). Use this skill whenever the user
  mentions TSE, SAL, .s files, .si files, .mac files, Semware, or asks for help with editor macros,
  SAL syntax, TSE macro development, SAL procedures, SAL data types, or any TSE-specific programming.
  Also trigger for questions about TSE UI (menus, prompts, dialogs), TSE key bindings, TSE hooks,
  or integrating external tools with TSE. When in doubt, use this skill — it contains critical
  conventions and language details that are easily confused with other languages.
---

# TSE SAL Skill

SAL (Semware Application Language) is the macro/scripting language built into The Semware Editor
Professional (TSE). It is a compiled, procedural language resembling a hybrid of C and Pascal, with
built-in editor primitives.

---

## Environment

- **Editor**: TSE Pro v4.x (path: `F:\WORDPROC\tse32_v45024\`)
- **Compiler**: `sc32.exe` (32-bit SAL compiler, in TSE bin directory)
- **Shell**: TCC (Take Command Console) on Windows 10 Pro
- **Python**: `G:\LANGUAGE\COMPUTER\PYTHON\PYTHON\python.exe`
- **Version control**: Cygwin Subversion
- **Source extensions**: `.s` (SAL source), `.si` (include/header), `.mac` (compiled macro)

---

## Coding Conventions

### Naming

| Item | Convention | Example |
|---|---|---|
| Local variables | camelCase | `lineCount`, `fileName` |
| Global variables | camelCase with `g` prefix | `gLineCount`, `gFileName` |
| Constants | ALL_CAPS with underscores | `MAX_LINE_LEN`, `TAB_SIZE` |
| Procedures / Functions | Noun-verb format | `FileOpen`, `BufferCreate`, `MenuScroll` |
| Boolean-returning procs | Noun+Is/Has prefix | `FileExists`, `BufferIsEmpty` |
| Hook procedures | Descriptive of event | `AfterCommand`, `OnFileLoad` |

### Formatting

- Indent with **4 spaces** (no tabs)
- Opening brace `{` on **same line** as control statement
- One blank line between procedure definitions
- Comments: use `//` for single-line, `/* */` for block comments
- Limit lines to ~80 characters where practical

### Variable declarations

- Declare all variables at the **top of the procedure** before any executable statements
- Group: integers first, then strings, then other types
- Always initialize variables (SAL does not zero-initialize automatically in all contexts)

```sal
proc FileProcess()
    integer i = 0
    integer lineCount = 0
    string fileName[_MAX_PATH] = ""
    string msg[80] = ""

    // ... body ...
end
```

---

## Language Reference

### Data Types

| Type | Description | Notes |
|---|---|---|
| `integer` | 32-bit signed int | Default numeric type |
| `string` | Fixed-length string | Must declare max length: `string s[80]` |
| `real` | Floating point | Rarely used |
| `char` | Single character | |

### String Declaration

Strings **must** declare their maximum length in brackets:

```sal
string fileName[_MAX_PATH] = ""
string msg[255] = ""
```

`_MAX_PATH` is a built-in constant (260 on Windows).

### Constants

```sal
constant MAX_ITEMS = 100
constant APP_NAME = "MyMacro"
```

### Operators

- Arithmetic: `+  -  *  /  mod`
- Comparison: `==  !=  <  >  <=  >=`
- Logical: `and  or  not`
- Bitwise: `&  |  ~  ^  <<  >>`
- String concat: `+`
- Assignment: `=`

### Control Flow

```sal
// if/elseif/else
if condition
    // ...
elseif other
    // ...
else
    // ...
endif

// while loop
while condition
    // ...
endwhile

// repeat/until
repeat
    // ...
until condition

// for loop
for i = 1 to 10
    // ...
endfor

// case statement
case expr
    when 1  // ...
    when 2  // ...
    otherwise  // ...
endcase
```

### Procedures and Functions

```sal
// Procedure (no return value)
proc MyProcDo()
    // body
end

// Function (returns integer)
integer proc ValueGet() : integer
    return 42
end

// Function (returns string)
string proc NameGet() : string
    return "hello"
end
```

> **Note**: SAL uses `proc` for both procedures and functions. Return type is declared after `:`.

### Calling Conventions

```sal
MyProcDo()                     // call procedure
integer n = ValueGet()         // call function, capture return
string s = Format("{}", n)     // string formatting
```

---

## Key Built-in Procedures & Functions

### Buffer / File Operations

```sal
integer bid = CreateBuffer("name", _NORMAL_)    // create buffer
integer bid = GetBufferID("name")               // find buffer by name
GotoBufferID(bid)                               // switch to buffer
AbandonFile()                                   // close without saving
SaveFile()                                      // save current file
EditFile(fileName)                              // open file
KillBuffer(bid)                                 // delete buffer
string name = CurrFileName()                    // current file name
integer bid = CurrBufferID()                    // current buffer id
```

### Cursor Movement

```sal
BegFile()        // go to beginning of file
EndFile()        // go to end of file
BegLine()        // go to beginning of line
EndLine()        // go to end of line
Up()             // move up one line
Down()           // move down one line
Right()          // move right one char
Left()           // move left one char
GotoLine(n)      // go to line number n
GotoColumn(n)    // go to column n
integer l = CurrLine()    // current line number
integer c = CurrCol()     // current column
integer p = CurrPos()     // current file position (byte offset)
```

### Text Operations

```sal
string s = GetText(col, len)          // get text at current pos
string s = GetLine()                  // get entire current line
integer n = NumLines()                // total lines in buffer
InsertLine()                          // insert blank line
AddLine(s)                            // add line of text
DelLine()                             // delete current line
string s = SubStr(src, start, len)    // substring
integer n = Length(s)                 // string length
string s = Upper(s)                   // to uppercase
string s = Lower(s)                   // to lowercase
string s = Trim(s)                    // trim whitespace
integer pos = Pos(needle, haystack)   // find substring position
string s = Format("fmt", args...)     // sprintf-style formatting
```

### Search & Replace

```sal
// Find string (returns TRUE/FALSE)
integer found = lFind(pattern, options)

// Options string characters:
//   "b" = backwards
//   "i" = ignore case
//   "w" = whole word
//   "x" = regular expression
//   "g" = global (all occurrences)
//   "+" = continue from current position

lReplace(pattern, replacement, options)

// Find in all files
mFind(pattern, options)
```

### UI / Interaction

```sal
Message("text")                        // status bar message
Warn("text")                           // warning dialog
integer r = YesNo("question")         // yes/no dialog (returns 1=yes, 2=no)
string s = Ask("prompt", default)     // input dialog

// Menu
integer choice = Menu(
    "Title",
    "Item1;Item2;Item3",
    _MF_ENABLED_
)
```

### Key Bindings

```sal
// Bind key to procedure
<Ctrl F1> MyProcDo()

// In keydef block
keydef MyKeys
    <Ctrl A>    MyProcDo()
    <Alt F4>    QuitFile()
end
```

### Hooks

```sal
// Hook into TSE events
hook _AFTER_COMMAND_     AfterCommandHandler()
hook _ON_CHANGING_FILES_ OnFileChangeHandler()
hook _BEFORE_WRITE_FILE_ BeforeWriteHandler()
```

Common hook constants: `_AFTER_COMMAND_`, `_BEFORE_COMMAND_`, `_ON_CHANGING_FILES_`,
`_ON_FIRST_EDIT_`, `_BEFORE_WRITE_FILE_`, `_AFTER_WRITE_FILE_`.

### Macros and Compilation

```sal
// Load/execute compiled macro
ExecMacro("macroname")

// Compile from TCC shell:
// sc32 mymacro.s
// This produces mymacro.mac
```

---

## Common Patterns

### Iterating Over All Lines in a Buffer

```sal
proc BufferProcess()
    integer lineCount = 0
    string line[_MAX_PATH] = ""

    BegFile()
    repeat
        line = GetLine()
        // process line...
        lineCount = lineCount + 1
    until not Down()

    Message(Format("Processed {} lines", lineCount))
end
```

### Working With a Temporary Buffer

```sal
proc TempBufferUse()
    integer origBid = CurrBufferID()
    integer tempBid = 0

    tempBid = CreateBuffer("*temp*", _HIDDEN_)
    GotoBufferID(tempBid)

    // ... do work in temp buffer ...

    GotoBufferID(origBid)
    KillBuffer(tempBid)
end
```

### Running an External Command

```sal
proc ExternalRun()
    string cmd[255] = ""
    integer result = 0

    cmd = Format("python.exe myscript.py {}", CurrFileName())
    result = Dos(cmd, _START_HIDDEN_)
    if result <> 0
        Warn("Command failed with code: " + Str(result))
    endif
end
```

### Scrollable Menu (standard pattern)

See `menu_borland_scroll_simplest.c` for the iterative scrollable menu reference implementation.
Always increment the version number in that file when modifying it, keeping the same filename.

---

## Include Files / Headers

Common `.si` include files:

```sal
#include ["tsemac.si"]     // standard TSE macro definitions
#include ["myconstants.si"] // user constants
```

Include files use the same syntax as source files but are `#include`d rather than compiled directly.

---

## Compilation & Deployment

```bat
REM Compile a SAL source file (TCC shell)
sc32 mymacro.s

REM Output: mymacro.mac in same directory
REM Copy to TSE macro directory if needed:
copy mymacro.mac F:\WORDPROC\tse32_v45024\mac\
```

To auto-load a macro at TSE startup, add it to the TSE startup profile or use the
UI (Macro > Load).

---

## Common Pitfalls

1. **String length**: Forgetting to declare `[length]` on string variables causes compile errors.
2. **Boolean returns**: SAL uses `TRUE` (non-zero) / `FALSE` (0) integers, not a boolean type.
3. **`lFind` vs `mFind`**: `lFind` searches the current buffer; `mFind` searches across multiple files.
4. **Case sensitivity**: SAL is **case-insensitive** for keywords and identifiers.
5. **No short-circuit evaluation**: Both sides of `and`/`or` are always evaluated.
6. **`end` vs `endif`/`endwhile`**: Procedures end with `end`; control structures end with their
   specific keyword (`endif`, `endwhile`, `endfor`, etc.).
7. **String concatenation in `Format`**: Use `Format` for mixed types; plain `+` only works
   between two strings.

---

## MCP Integration

Knud is actively developing MCP (Model Context Protocol) support in TSE. When working on MCP-related
TSE code, keep in mind:
- Communication happens via stdin/stdout or named pipes
- JSON parsing must be done manually or via helper buffers
- External Python scripts bridge TSE ↔ MCP server

---

## Cross-Platform Notes

Knud targets both Windows native (TSE) and Linux WSL environments:
- Windows: use DLL calls via `DllCall()` for Win32 API
- Linux/WSL: use `Dos()` with `wmctrl`, `xdotool`, or other CLI tools
- Guard platform-specific code with `#ifdef _WINDOWS_` / `#ifdef _UNIX_`

---

## Reference

- TSE help system: `F1` inside TSE
- SAL Language Guide: available in TSE installation help
- Macro examples: `F:\WORDPROC\tse32_v45024\mac\`

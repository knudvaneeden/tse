# MACPAR3

**Package version:** 1.0.0.0.0  
**README date:** 2026-09-20  
**README time:** 19:46 CEST (UTC+02:00)  
**Original MACPAR3 version:** Version 3, 28 June 1999  
**Original author:** Carlo Hogeveen  

## Description

MACPAR3 is a collection of TSE (The SemWare Editor) SAL source/include files for passing parameters to macros in a unified way.

The package allows a called macro to obtain parameters without needing to know whether they originated from:

- the DOS command line;
- TSE's **Macro Execute** command/menu;
- `ExecMacro()` in another macro; or
- another macro using `PushPar()`.

The main interface is formed by three routines:

- `InitPar()` — initializes or clears the macro-parameter queue;
- `PushPar()` — adds one parameter to the queue;
- `PopPar()` — retrieves the next parameter.

This makes it possible to pass strings containing spaces and, when using `PushPar()`, string variables of up to 255 characters without being limited by the traditional `MacroCmdLine` format.

## Files in this package

| File | Purpose |
|---|---|
| `DOSPAR.S` | Processes macro parameters found on the DOS command line and places them on the parameter queue. |
| `TESTPAR.S` | Demonstration/test macro that displays parameters obtained through `PopPar()`. |
| `INITPAR.SI` | Defines `InitPar()` and clears the parameter queue. |
| `PUSHPAR.SI` | Defines `PushPar()` and stores a parameter in the global parameter queue. |
| `POPPAR.SI` | Defines `PopPar()` and retrieves parameters from the queue or `MacroCmdLine`. |
| `PROCPAR.SI` | Parses the extended colon-based parameter syntax. |
| `PAR.DOC` | Original MACPAR3 documentation. |
| `FILE_ID.DIZ` | Original package description. |
| `global.si` | Carlo Hogeveen's compatibility implementation of TSE session-global variable routines; required by `PUSHPAR.SI`. |
| `macpar3.ini` | Companion initialization/configuration file supplied with package version 1.0.0.0.0. |
| `macpar3_readme.md` | This README. |

## Dependency

MACPAR3 version 3 depends on `GLOBAL.SI` from the historical `Global.zip` package.

`PUSHPAR.SI` contains:

```text
#include ["global.si"]
```

The original `macpar3.zip` did not contain this dependency. In package version **1.0.0.0.0**, `global.si` is now included directly in the package, so the supplied MACPAR3 sources and their required include file can be kept together in the same working directory.

The global routines used by MACPAR3 include:

- `get_global_int()`
- `set_global_int()`
- `get_global_str()`
- `set_global_str()`
- `del_global_var()`

## How MACPAR3 works

MACPAR3 maintains a first-in/first-out parameter queue in global variables.

A calling macro can initialize the queue, push one or more values, and then execute another macro. The called macro retrieves those values with `PopPar()`.

`PopPar()` also understands parameters supplied through `MacroCmdLine`. This permits the same called macro to work when started interactively or by another macro.

`DOSPAR.S` extends this idea to parameters placed after a macro name on the editor's DOS command line. `DOSPAR` is intended to be autoloaded so it can preprocess those parameters at editor startup.

## PushPar() and PopPar(): the simple idea

The simplest way to think about MACPAR3 is this: **`PushPar()` puts parameters into a waiting line, and `PopPar()` takes them out again one by one.**

Although the routine names use the traditional words **push** and **pop**, MACPAR3 is actually behaving as a **queue (FIFO: first in, first out)** rather than as a traditional stack (LIFO: last in, first out).

Suppose a macro wants to pass three parameters:

```text
alpha
beta
gamma
```

Conceptually, successive calls to `PushPar()` build the queue like this:

```text
PushPar("alpha")  -->  [ alpha ]
PushPar("beta")   -->  [ alpha ][ beta ]
PushPar("gamma")  -->  [ alpha ][ beta ][ gamma ]
```

Then each call to `PopPar()` removes and returns the **oldest parameter**:

```text
PopPar()  --> "alpha"
             [ beta ][ gamma ]

PopPar()  --> "beta"
             [ gamma ]

PopPar()  --> "gamma"
             [ empty ]

PopPar()  --> ""
```

That last empty string means that there are no more parameters available.

### What PushPar() does

Internally, the parameters are stored in session-global variables. Conceptually, after:

```text
PushPar("alpha")
PushPar("beta")
PushPar("gamma")
```

the data looks roughly like this:

```text
par_queue_1 = "alpha"
par_queue_2 = "beta"
par_queue_3 = "gamma"
```

and MACPAR3 remembers that the tail of the queue is at position 3.

So for this example:

```text
PushPar("one")
PushPar("two")
```

the global data is conceptually:

```text
par_queue_tail = 2

par_queue_1 = "one"
par_queue_2 = "two"
```

The exact internal global-variable names are implementation details, but the important idea is that `PushPar()` adds another parameter at the end of the queue.

### What PopPar() does

`PopPar()` works from the other end. It keeps track of the next parameter to be read, conceptually the **head** of the queue.

Initially, with three parameters stored:

```text
head = 1
tail = 3

1 = alpha
2 = beta
3 = gamma
```

The first call to `PopPar()` reads the first item and advances the head:

```text
PopPar() --> "alpha"

head = 2
tail = 3
```

The next call reads the second item:

```text
PopPar() --> "beta"

head = 3
tail = 3
```

The next reads the third item:

```text
PopPar() --> "gamma"

head = 4
tail = 3
```

Now the head is beyond the tail, so the queue is empty and another `PopPar()` returns an empty string.

Visually:

```text
                  head                 tail
                   |                     |
                   v                     v
Before:        [ alpha ][ beta ][ gamma ]
                   1       2       3

PopPar()
returns alpha

                          head           tail
                           |               |
                           v               v
After:                   [ beta ][ gamma ]
                           2       3
```

### Why use this mechanism?

The useful idea is that one macro can prepare parameters for another macro without having to put all of them directly into one command-line string.

For example, conceptually a calling macro can do:

```text
PushPar("c:\\temp")
PushPar("*.s")
PushPar("ix")
ExecMacro("search")
```

The called `search` macro can then retrieve them in the same order:

```text
directory = PopPar()
filespec  = PopPar()
options   = PopPar()
```

and receives:

```text
directory = c:\temp
filespec  = *.s
options   = ix
```

This is the core purpose of MACPAR3: **provide one common stream of parameters that macros can consume sequentially.**

### Important terminology note: queue versus stack

The routine names can be confusing because in computer science **push** and **pop** usually describe a stack.

A traditional stack is **LIFO**:

```text
Push A
Push B
Push C

Pop -> C
Pop -> B
Pop -> A
```

MACPAR3 instead behaves as **FIFO**:

```text
Push A
Push B
Push C

Pop -> A
Pop -> B
Pop -> C
```

So the best mental model for MACPAR3 is a line of people waiting to be served:

```text
                    parameters enter here
                            |
                            v
               +-----+-----+-----+
PopPar() <---- |  A  |  B  |  C  | <---- PushPar()
               +-----+-----+-----+
                  ^
                  |
               next out
```

In other words: **`PushPar()` puts another parameter at the back of the line; `PopPar()` takes the parameter at the front of the line.**

This package keeps the original MACPAR3 names and behavior for compatibility, even though the mechanism is more accurately described as a parameter queue than as a parameter stack.

## Basic use in a SAL macro

Include `INITPAR.SI` near the beginning of the macro:

```text
#include ["initpar.si"]
```

That include brings in the other required MACPAR3 include files, so the macro can use:

```text
InitPar()
PushPar(...)
PopPar()
```

Always call `InitPar()` before beginning a new sequence of `PushPar()` calls, and normally call it again after all parameters have been consumed.

## Calling another macro with PushPar()

A typical calling macro follows this pattern:

```text
#include ["initpar.si"]

InitPar()
PushPar("string1")
PushPar(stringVariable)
PushPar(Str(integerVariable))
ExecMacro("mymacro")
```

`PushPar()` is the preferred method when the parameter is a variable or may contain spaces or other characters that are awkward to quote on a command line.

## Receiving parameters in a called macro

A called macro can obtain parameters like this:

```text
#include ["initpar.si"]

string var1 [255] = PopPar()
integer var2 = Val(PopPar())
string var3 [255] = PopPar()
InitPar()
```

The called macro does not need to know whether its parameters came from `PushPar()`, `ExecMacro()`, the Macro Execute menu, or the DOS command line.

## MacroCmdLine parameter formats

MACPAR3 supports both the traditional and extended parameter formats.

### Traditional format

Parameters are separated by spaces:

```text
mymacro string1 string2 string3
```

This format is convenient for simple values that contain no spaces.

### Extended colon format

Parameters can instead be introduced with colons:

```text
mymacro :string1:string2:string3
```

Quoted parameters may contain spaces:

```text
mymacro :'string 1':"string 2"
```

A double colon allows the next character to become a custom delimiter. For example:

```text
mymacro ::@a single ' and a double " quote in one string@
```

Here `@` is the delimiter.

## DOS command-line syntax

The original documentation gives examples such as:

```text
e -emymacro:string1
e -emymacro:"string 1"
e -emymacro:'a double " quote in a string'
e -emymacro:string1:string2:string3
```

There must be no spaces between the macro name, the parameter colon, and the parameter when using this DOS-command-line syntax.

For parameters introduced by a single colon, single or double quotes may be used as delimiters. With a double colon, the first following character becomes a required custom delimiter.

## Empty parameters

Empty strings are valid parameter values in the extended format. For example:

```text
:""
```

Calling `PopPar()` when no parameter remains also returns an empty string. Consequently, a program that needs to distinguish an explicitly supplied empty value from the end of the queue must provide its own additional convention.

## How to build and install

### 1. Extract the package

Extract all files from:

```text
macpar31.0.0.0.0.zip
```

into a working directory or the directory where you keep your TSE macro sources.

### 2. Keep GLOBAL.SI with the sources

The required `global.si` is included in this package. Keep it in the same directory as the MACPAR3 source/include files, or otherwise place it in a directory searched by the SAL compiler.

Because `PUSHPAR.SI` contains `#include ["global.si"]`, the compiler must be able to find this file when compiling a macro that uses MACPAR3.

### 3. Compile DOSPAR.S

From a command prompt configured for your TSE SAL compiler, compile:

```text
sc32 DOSPAR.S
```

This should create the corresponding compiled macro, normally:

```text
DOSPAR.MAC
```

### 4. Compile TESTPAR.S

Compile the demonstration macro:

```text
sc32 TESTPAR.S
```

This should create:

```text
TESTPAR.MAC
```

The `.SI` files are include files and normally are not compiled independently.

> Note: the original `PAR.DOC` says to compile three `.s` files including `InitPar.s`, but the supplied MACPAR3 archive contains `INITPAR.SI`, not `INITPAR.S`. In this package, `INITPAR.SI` is an include file used by other SAL sources.

### 5. Install the macros

Place the compiled `.MAC` files where your TSE installation normally loads macros from.

Historically the original documentation instructed users to copy the files to TSE's `MAC` directory.

### 6. Add DOSPAR to Macro AutoloadList

Add:

```text
DOSPAR
```

to TSE's **Macro AutoloadList** so that DOS-command-line macro parameters can be processed automatically.

The exact menu location can vary by TSE version.

## How to test

`TESTPAR.S` is provided specifically for testing MACPAR3.

### Test from Macro Execute

Compile `TESTPAR.S`, then execute `TESTPAR` using TSE's macro execution facility and supply parameters using either the traditional or extended syntax.

Examples:

```text
TESTPAR one two three
```

or:

```text
TESTPAR :one:"two words":three
```

`TESTPAR` displays each non-empty parameter in sequence.

### Test from another macro

Create a small calling macro containing the following pattern:

```text
#include ["initpar.si"]

proc Main()
    InitPar()
    PushPar("first")
    PushPar("second parameter")
    ExecMacro("testpar")
end
```

Compile and execute that macro. `TESTPAR` should report the pushed values in the same order.

### Test from the DOS command line

With `DOSPAR` installed in the Macro AutoloadList, invoke the editor with a command-line macro and its colon-prefixed parameters, following the syntax supported by your TSE version.

A historical example is:

```text
e -etestpar:first:"second parameter":third
```

## macpar3.ini

`macpar3.ini` is included as a package-level initialization/configuration file for version 1.0.0.0.0.

The original 1999 MACPAR3 SAL source does **not** read an INI file. Therefore the values in `macpar3.ini` are informational/default package settings only unless the source is later extended to read them.

Current entries document:

- package version;
- whether `DOSPAR` is intended for autoload;
- the `GLOBAL.SI` dependency;
- the supplied test macro.

## Compatibility notes

The original package identifies itself for TSE Pro v2.5 and TSE Pro/32 v2.8 and dates from 1999. Its original documentation states that version 3 uses routines from `Global.si` to avoid a bug in those TSE versions.

When using MACPAR3 with a newer TSE release, compilation and runtime behavior should be tested. The compatible `global.si` implementation supplied with this package is the historical Carlo Hogeveen include expected by MACPAR3; also verify that the referenced SAL commands remain supported by the compiler being used.

## Original package history

According to `PAR.DOC`:

- original date: 30 September 1998;
- version 2: 13 April 1999 — documentation simplification;
- version 3: 28 June 1999 — changed to use procedures from `Global.si` to avoid a TSE 2.5/2.8 bug.

## Troubleshooting

### Compiler cannot find global.si

The package already contains `global.si`. Keep it in the same directory as the MACPAR3 sources/includes, or copy it to a directory searched by the SAL compiler. MACPAR3 cannot compile successfully without the global-variable routines on which `PUSHPAR.SI` depends.

### DOS command-line parameters are not detected

Verify that `DOSPAR.MAC` has been compiled and that `DOSPAR` is included in the Macro AutoloadList.

### Parameters containing spaces are split

Use quoted extended syntax or, preferably when calling from another SAL macro, use `PushPar()`.

For example:

```text
PushPar("this is one parameter")
```

or:

```text
TESTPAR :"this is one parameter"
```

### PopPar() returns an empty string

An empty string means either that the next parameter itself is empty or that no more parameters remain. This is part of the original MACPAR3 design.

## Package version 1.0.0.0.0

This repackaging preserves the original MACPAR3 source and documentation and adds:

- `macpar3_readme.md`;
- `macpar3.ini`;
- package version information;
- updated build/run guidance for examining and testing the historical SAL code.

The original source files have not been rewritten as part of this README/package creation step.

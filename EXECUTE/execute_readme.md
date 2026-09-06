# Execute for TSE

**README version:** 1.0.0.0.0  
**Execute macro version:** 1.02  
**Created:** 2026-09-06 23:05:01 UTC  
**Original author:** Carlo Hogeveen  
**Compatibility:** The SemWare Editor (TSE) Professional 2.5e and later

## Description

`Execute.s` is a TSE SAL macro that dynamically runs a line of TSE built-in commands or SAL statements. It lets you try short commands without first creating a separate macro source file yourself.

Execute can be started:

- Interactively from TSE's **Macro Execute** menu.
- From a Windows/DOS command line, after any filenames.
- From the **Potpourri** menu. If no command is supplied, the macro opens its own source as help.
- From another TSE SAL macro with `ExecMacro()`.

The macro temporarily generates and compiles a helper macro named after Execute with an underscore suffix, such as `Execute_.s` and `Execute_.mac`, in the same directory as `Execute.s`. The temporary source buffer is abandoned automatically after use.

## Files in the package

- `Execute.s` — TSE SAL source code for the macro.
- `File_id.diz` — short package description.

## Installation

1. Extract `execute.zip` to a folder where you keep TSE macros.
2. Start TSE.
3. Compile `Execute.s` using TSE's macro compiler.
4. Add the compiled Execute macro to the **top** of TSE's Macro AutoLoad List if you want to invoke it from the Windows/DOS command line.
5. Restart TSE or reload the macro configuration if required.

Putting Execute at the top of the Macro AutoLoad List is important because other autoload macros may otherwise interfere with its command-line processing.

If you rename the macro, remove the old name from the AutoLoad List and add the new name at the top. With TSE 2.5, the macro name must not exceed seven characters.

## How to run it

### From TSE's Macro Execute menu

Open the Macro Execute dialog and enter one of the following examples:

```text
Execute Warn('Hello World!')
Execute Warn("Hello World!")
Execute integer i for i=10 downto 0 Message("World peace commencing in ",i," ...") Delay(18) endfor
```

### From another SAL macro

```text
ExecMacro("execute Warn('Hello World!')")
```

or:

```text
ExecMacro('execute Warn("Hello World!")')
```

### From the Windows/DOS command line

General syntax:

```text
editorcommand filename ... { -e executename | -e executename | -x } ["] TSE-statements ... ["]
```

Depending on the installed TSE version, `editorcommand` can be `e`, `e32`, `g`, or `g32`.

Examples:

```text
g32 -x "Warn('Hello World!')"
g32 cats.txt -x "Warn('Hello World!')"
g32 cats.txt dogs.txt -x "Warn('Hello World!')"
g32 -a *.txt -x "Warn('Hello World!')"
g32 cats.txt -x "BegFile() while lFind('cat','iw') lReplace('cat','dog','inw1') Right(3) InsertText('()',_INSERT_) endwhile"
```

The `-e`/`-x` option must appear after the filename or filenames. Do not quote the option itself, and use only one Execute option on a command line.

## Command-line quoting

Make it a habit to enclose the complete SAL statement sequence in double quotation marks. This prevents the Windows command processor from interpreting special characters such as:

```text
& ( ) [ ] { } ^ = ; ! ' + , ` ~
```

When the outer command is double-quoted, use single quotation marks for strings inside the SAL statements. If an actual double-quote character is needed inside the statement, construct it with `Chr(34)`.

Example:

```text
g32 -x "Warn('Hello World!')"
```

## Help and troubleshooting

### No statement was supplied

Running Execute without a statement opens `Execute.s`, which contains the original built-in help and examples.

### The command is not executed from the Windows/DOS command line

- Confirm that Execute is compiled.
- Confirm that it is placed at the top of TSE's Macro AutoLoad List.
- Put `-x`, `-eexecute`, or `-e execute` after all filenames.
- Do not quote the `-x` or `-e` option.

### Compile errors or unexpected syntax errors

- Put double quotation marks around the complete SAL statement sequence.
- Use single quotation marks for strings inside a double-quoted command.
- Check that the generated line can compile in the form `proc Main() statements end`.
- Review the command line displayed by Execute after an error; Windows may have altered unquoted special characters.

### Command is too long

After the editor command and its following spaces, the remaining command line is limited to 128 characters by the original macro. A command that is too long may fail or cause an access violation. For larger tasks, create a normal SAL macro instead.

### Helper files cannot be created

Make sure the directory containing `Execute.s` is writable. Execute creates its temporary helper macro in that directory.

## Limitations and safety

- The supplied statements must compile when enclosed by `proc Main()` and `end`.
- The original command-line input limit is 128 characters.
- Execute runs the supplied SAL statements with the same access and effects as any other TSE macro. Save important files before testing commands that edit buffers or files.
- The `-x` shortcut could theoretically conflict with another macro or a future TSE option.

## Version history

### README 1.0.0.0.0 — 2026-09-06 23:05:01 UTC

- Initial Markdown documentation for the supplied `execute.zip` package.
- Added description, installation, usage examples, quoting guidance, troubleshooting, limitations, and safety notes.
- Documented the included Execute macro version 1.02.

Future README revisions should increment the final component sequentially:

```text
1.0.0.0.0
1.0.0.0.1
1.0.0.0.2
1.0.0.0.3
```

## Original macro history

- **1.00 — 2006-10-25:** Initial release.
- **1.01 — 2006-10-25:** Improved compile-error reporting and documented common user errors.
- **1.02 — 2006-10-26:** Further improved compile-error reporting and documentation.


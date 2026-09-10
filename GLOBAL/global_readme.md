# GLOBAL for TSE Pro

## Document information

- **README version:** 1.0.0.0.1
- **Date and time:** 2026-09-10 11:55:03 UTC
- **Original macro date:** 1999-06-27
- **Original author:** Carlo Hogeveen
- **Supported original environments:** TSE Pro 2.5 and TSE Pro/32 2.8
- **Package:** `global.zip`
- **Main include file:** `GLOBAL.SI`

## Description

`GLOBAL.SI` is an include file for advanced TSE Pro macro programmers. It works around a session-global-variable bug in TSE Pro 2.5 and TSE Pro/32 2.8.

TSE internally uses its session global variables while commands such as `List`, `lList`, `Read`, and `Ask` are active. Accessing session global variables from certain hookable events during one of these commands can overwrite or remove variables unexpectedly.

`GLOBAL.SI` avoids that conflict by keeping the macro's variables in a separate hidden system buffer. Its procedures are intended as replacements for TSE's corresponding session-global-variable functions.

## When this include is useful

Use `GLOBAL.SI` when a macro accesses session global variables from code that can run while a list or prompt is active, especially from events such as:

- `_NONEDIT_IDLE_`
- `_BEFORE_NONEDIT_COMMAND_`
- `_AFTER_NONEDIT_COMMAND_`
- `_LIST_STARTUP_` and `_LIST_CLEANUP_`
- `_PICKFILE_STARTUP_` and `_PICKFILE_CLEANUP_`
- `_PROMPT_STARTUP_` and `_PROMPT_CLEANUP_`
- `_ON_NONEDIT_UNASSIGNED_KEY_`
- `_AFTER_GETKEY_`
- `_BEFORE_GETKEY_`

This package is primarily a compatibility workaround for the old TSE versions named above. Test it carefully before using it with a newer TSE release.

## Supplied procedures

| Procedure | Purpose | Return value |
| --- | --- | --- |
| `get_global_int(name)` | Reads a stored integer | The value, or `0` if it is not found |
| `set_global_int(name, value)` | Creates or replaces an integer | Non-zero on success |
| `get_global_str(name)` | Reads a stored string | The value, or an empty string if it is not found |
| `set_global_str(name, value)` | Creates or replaces a string | Non-zero on success |
| `exist_global_var(name)` | Checks whether a named variable exists | `TRUE` or `FALSE` |
| `del_global_var(name)` | Deletes a named variable | `TRUE` if it was found and deleted |

Names beginning with `cho_` are internal implementation details and should not be called by other macros.

## Installation

1. Extract `global.zip`.
2. Copy `GLOBAL.SI` to the TSE macro directory, normally the directory containing your other `.s` and include files.
3. Add the following line near the beginning of the macro that needs these procedures:

   ```sal
   #include ["global.si"]
   ```

4. Replace calls to TSE's affected global-variable functions with the corresponding procedures supplied by `GLOBAL.SI`.
5. Compile the main `.s` macro with the TSE SAL compiler. `GLOBAL.SI` is an include file and is not normally compiled by itself.

## How to use it

The following example stores, reads, tests, and deletes session-global values:

```sal
#include ["global.si"]

proc Main()
   integer counterI = 0
   string messageS[255] = ""

   set_global_int("ExampleCounter", 42)
   set_global_str("ExampleMessage", "Stored safely")

   counterI = get_global_int("ExampleCounter")
   messageS = get_global_str("ExampleMessage")

   if exist_global_var("ExampleCounter")
      Warn("Counter: ", counterI, "  Message: ", messageS)
   endif

   del_global_var("ExampleCounter")
   del_global_var("ExampleMessage")
end
```

Compile the main macro from a command prompt, for example:

```text
sc32 example.s
```

Load or execute the resulting macro in TSE Pro in the normal way.

## Important behavior

- Integer variables and string variables share the same name space. Use unique names.
- Setting an existing name replaces its previous value.
- Reading a missing integer returns `0`; use `exist_global_var()` when you must distinguish a missing value from a stored zero.
- Reading a missing string returns an empty string; use `exist_global_var()` when an empty string is a valid stored value.
- Stored data remains available only while the hidden system buffer and the current TSE session remain alive.
- The include guard prevents the procedures from being defined more than once when `GLOBAL.SI` is included indirectly by several source files.
- Keep application variable names distinct from the include's internal `cho_` names.

## Troubleshooting

### The compiler cannot find `global.si`

Confirm that `GLOBAL.SI` is in a directory searched by the SAL compiler. Keeping it in the same directory as the main macro is the simplest arrangement.

### A missing integer appears to contain zero

This is expected. Call `exist_global_var(name)` before `get_global_int(name)` when existence matters.

### A missing string appears empty

This is expected. Call `exist_global_var(name)` before `get_global_str(name)` when existence matters.

### Variables disappear after closing TSE

The values are session data, not permanent configuration data. Save persistent settings in a file or another appropriate storage mechanism.

### Compatibility with a newer TSE version is uncertain

The original package explicitly targets TSE Pro 2.5 and TSE Pro/32 2.8. Compile and test the include with the exact TSE version in which it will be used.

## Package contents

| File | Description |
| --- | --- |
| `GLOBAL.SI` | SAL include containing the replacement procedures |
| `FILE_ID.DIZ` | Short original package description |

## Version history

### 1.0.0.0.1 — 2026-09-10 11:55:03 UTC

- Expanded the documentation with installation and execution steps.
- Added the procedure reference, example, behavior notes, and troubleshooting help.
- Clarified the original TSE compatibility scope.

### 1.0.0.0.0 — 2026-09-10 11:55:03 UTC

- Created the initial Markdown README for the original `global.zip` package.

## License and attribution

The archive does not contain an explicit license statement. The original source identifies Carlo Hogeveen as its author. Preserve the original author and source comments when redistributing or modifying `GLOBAL.SI`.

---

README prepared with OpenAI Codex.

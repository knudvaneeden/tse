# blockreplacecase 1.0.0.0.3

Standalone TSE SAL 4.50 macro. Changes only text in the selected block.

## Files

- `blockreplacecase.s` - macro source
- `blockreplacecase.ini` - default search text, replacement text, and case style
- `blockreplacecase_readme.md` - this document

## Compile and run

Run `sc32 blockreplacecase.s` and load/run the compiled macro in TSE. Keep `blockreplacecase.ini` beside the compiled macro. Mark a block in the active file first.

The two Ask() prompts use separate *named TSE history lists* (`GetFreeHistory`). Navigate past entries with Up/Down. TSE's `PersistentHistory` setting must be enabled if you want these lists to persist after closing and reopening TSE. INI values provide the initial editable text at each run; they are not automatically overwritten by prompts.

## INI

```ini
[Defaults]
searchstring=TEST
replacestring=push
defaultcase=1
```

The first menu choice uses `defaultcase` from the INI; all 17 styles remain available in the menu.

## Styles (defaultcase)

1. Match search text case (TEST -> PUSH; Test -> Push)
2. lower case
3. UPPER CASE
4. Capitalized Case / Title Case
5. fLIP cASE
6. aLtErNaTiNg (lower first)
7. AlTeRnAtInG (upper first)
8. vOwEls UPPER
9. CoNsOnAnTs UPPER
10. snake_case
11. SCREAMING_SNAKE_CASE
12. Upper_then_lowercase
13. UpperCamelCase / PascalCase
14. lowerCamelCase
15. kebab-case
16. Train-Case
17. UPPER-KEBAB-CASE

Search is literal, case-insensitive and restricted to the marked block (`giln` search options, `l` means local). The replacement style is derived from the typed search string for option 1, not independently for each differently cased occurrence. Certain capitalization patterns cannot be transferred unambiguously across different string lengths. Only use on backed-up content until tested with your TSE build.

## Version history

- 1.0.0.0.3: Added INI defaults, independently named Ask() histories, and an INI-default menu entry. Retains v2 constant-parameter fixes.
- 1.0.0.0.2: Fixed assignments to constant string parameters.

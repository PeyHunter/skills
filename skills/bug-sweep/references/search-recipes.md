# Search recipes

Starting points for each signature level. Adapt them to the language and to the seed; never run them blindly and report the raw hits. `rg` is assumed. `ast-grep` (`sg`) and `semgrep` are optional — check with `command -v` first.

Exclude noise by default:

```sh
rg -n --glob '!{node_modules,dist,build,vendor,.venv}/**' --glob '!*.lock' '<pattern>'
```

## Tracing where the seed came from

```sh
git log -S'<distinctive snippet>' --oneline        # commits that added/removed the snippet
git log -G'<regex>' --oneline                     # commits whose diff matches a regex
git show <commit> --stat                          # other files touched in the same commit
git blame -L <start>,<end> <file>                 # who wrote the seed and when
```

Files changed in the same commit as the seed are high-value candidates: copy-paste usually happens in one sitting.

## Callers and callees (semantic level)

```sh
rg -n '\b<functionName>\s*\('                     # every call site
rg -n '\bimport\b.*\b<symbol>\b|\brequire\(.*<module>' # every importer
```

If the seed is "caller passes the wrong thing to X", check every caller of X. If it is "X does the wrong thing", check functions shaped like X (same module, same name prefix, same signature).

## By bug class

### Missing null / undefined / empty checks

```sh
rg -n '\.length\s*-\s*1\]|\[0\]'                  # first/last element without an empty check
rg -n '\.find\(.*\)\.' --type js                  # .find() result used directly
rg -n '\.get\([^)]*\)\.' --type py                # dict.get() result dereferenced
```

### Async / await

```sh
rg -n 'forEach\(\s*async'                         # async callbacks forEach will not await
rg -n '^\s+[a-zA-Z_.]+\(.*\);?$' <file>           # bare calls — compare against known async functions
rg -n '\.then\(' | rg -v '\.catch\('              # promise chains with no error handling
```

### Off-by-one and boundaries

```sh
rg -n '<=\s*\w+\.length|<=\s*len\('               # inclusive bound on a length
rg -n 'range\(1,|slice\(1\)|\[1:\]'               # skips the first element — intended?
```

### Resource leaks

```sh
rg -n 'open\(' --type py | rg -v 'with '          # file opened outside a context manager
rg -n 'addEventListener\(' ; rg -n 'removeEventListener\('   # compare counts per component
rg -n 'setInterval\(' ; rg -n 'clearInterval\('
```

### Injection and unsafe input

```sh
rg -n 'innerHTML\s*=|outerHTML\s*=|insertAdjacentHTML'  # HTML from strings
rg -n "execute\(\s*f[\"']|execute\(.*%|execute\(.*\+"   # SQL built by string formatting
rg -n 'eval\(|new Function\(|shell=True|os\.system'
```

### Time, locale, and numbers

```sh
rg -n 'new Date\(|datetime\.now\(\)|Date\.parse'  # naive time construction
rg -n 'parseInt\([^,)]*\)'                        # parseInt without a radix
rg -n '==\s*0\.\d|toFixed\('                      # float equality and rounding for display
```

## Structural search with ast-grep (when installed)

ast-grep matches syntax trees, so whitespace and formatting do not matter:

```sh
sg --pattern '$ARR.forEach(async ($$$) => { $$$ })' --lang js
sg --pattern '$X.innerHTML = $Y' --lang js
```

Use it when the seed's shape is clear but `rg` misses variants because of line breaks or naming.

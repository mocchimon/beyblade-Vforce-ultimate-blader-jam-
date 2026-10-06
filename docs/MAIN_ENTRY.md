# Main entry: 0x080505A9

The function begins at `0x080505A8` and executes in Thumb mode.

The first pass recovered a long initialization sequence containing calls to:

```text
08057968
080579CC
08057A18
08057940
0805A374
0805A890
080574CC
08063A74
08063A8C (repeated with small integer arguments)
08063AA0
0805FEF4
08062490
08062B44
08062E94
08060544
080532DC
08051090
08055CDC
08058940
...
```

Several later calls repeat around a persistent loop. These are currently semantic placeholders. The next reverse-engineering pass should analyze these callees individually and rename them by behavior.

The repeated call to `0x08063A8C` is especially promising because it is invoked with `(0,0), (3,1), (4,2), (5,3), (7,4)`, suggesting a small indexed registration/configuration API rather than arbitrary game logic.

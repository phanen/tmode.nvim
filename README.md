Save and restore `mode`/`cursor` for each terminal buffer.

```sh
nvim --clean --cmd 'set rtp^=.' --cmd 'noremap  <a-w> <c-^>' --cmd 'tnoremap <a-w> <cmd>e #<cr>' README.md +term +'term seq 1000'
```

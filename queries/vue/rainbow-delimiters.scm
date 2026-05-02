;;; Keep rainbow-delimiters active for Vue without coloring HTML tag syntax.
;;; The upstream query captures tag delimiters and `(tag_name) @delimiter`,
;;; which overrides the colorscheme's `@tag.vue` / `@tag.delimiter.vue` green.
;;; Injected TypeScript/CSS child parsers still use their own rainbow queries.

(interpolation
  "{{" @delimiter
  "}}" @delimiter) @container

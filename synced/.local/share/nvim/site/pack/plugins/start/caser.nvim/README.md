# caser.nvim

<!--toc:start-->
- [caser.nvim](#casernvim)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Options](#options)
  - [Alternatives](#alternatives)
<!--toc:end-->

Change text casing with motions, text objects, visual mode.

Essentially a lua port of [vim-caser](https://github.com/arthurxavierx/vim-caser).

## Installation

lazy.nvim

```lua
{
    "tronikelis/caser.nvim",
    opts = {}
}
```

## Usage

`caser.nvim` makes it easy for you to change text cases with vim motions,
this is in line with vim editing features.

All mappings below must be followed by a motion or a text object, or be applied within visual mode.

Case | Default Mapping 
------|-----------------
`camelCase`  | `gsc` 
`snake_case` | `gss` 
`space case` | `gs<space>` 
`kebab-case` | `gsk` 

## Options

Default options are below.

```lua
{
    prefix = "gs",
}
```

## Alternatives

- [vim-caser](https://github.com/arthurxavierx/vim-caser) which I've been using up until this plugin

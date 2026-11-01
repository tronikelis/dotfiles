local C = {
    base = "#1e1e2f",
    blue = "#89b4fb",
    crust = "#11111c",
    flamingo = "#f2cdce",
    green = "#a6e3a2",
    lavender = "#b4beff",
    mantle = "#181826",
    mauve = "#cba6f8",
    overlay0 = "#6c7087",
    overlay2 = "#9399b3",
    peach = "#fab388",
    red = "#f38ba9",
    rosewater = "#f5e0dd",
    sky = "#89dcec",
    surface0 = "#313245",
    surface1 = "#45475b",
    teal = "#94e2d6",
    text = "#cdd6f5",
    yellow = "#f9e2b0",
    sapphire = "#74c7ec",
    pink = "#f5c2e7",
}

local groups = {
    -- base
    Directory = { fg = C.blue },
    Function = { fg = C.blue },
    Keyword = { fg = C.mauve },
    Conditional = { link = "Keyword" },
    Normal = { fg = C.text, bg = C.base },
    String = { fg = C.green },
    Delimiter = { fg = C.overlay2 },
    Identifier = { fg = C.lavender },
    Constant = { fg = C.peach },
    Special = { fg = C.flamingo },
    Operator = { fg = C.sky },
    Comment = { fg = C.overlay2 },
    CursorLine = { bg = "#2a2b3d" },
    Type = { fg = C.yellow },
    CursorLineNr = { fg = C.lavender },
    CursorColumn = { bg = C.mantle },
    Cursor = { fg = C.base, bg = C.rosewater },
    TabLineFill = { bg = C.mantle },
    TabLine = { fg = C.overlay0, bg = C.crust },
    StatusLine = { fg = C.text, bg = C.mantle },
    StatusLineNC = { fg = C.surface1, bg = C.mantle },
    TreesitterContextBottom = { underline = true, sp = C.surface0 },
    TreesitterContextLineNumber = { fg = C.surface1, bg = C.mantle },
    NormalFloat = { fg = C.text, bg = C.mantle },
    ["@variable.member"] = { link = "Identifier" },
    ["@label"] = { link = "Operator" },
    ["@function.builtin"] = { link = "Function" },
    ["@variable"] = { fg = C.text },
    ["@variable.builtin"] = { fg = C.text },
    ["@puncuation.bracket"] = { fg = C.overlay2 },
    ["@module"] = { fg = C.lavender },
    ["@type.builtin"] = { link = "Type" },
    ["@property.class"] = { link = "Type" },
    ["@constant.builtin"] = { link = "Constant" },

    SpecialComment = { link = "Special" },
    Character = { fg = C.teal },
    Number = { link = "Constant" },
    Float = { link = "Constant" },
    Boolean = { link = "Constant" },
    Statement = { fg = C.mauve }, -- (preferred) any statement
    Repeat = { fg = C.mauve }, --   for, do, while, etc.
    Label = { fg = C.sapphire }, --    case, default, etc.
    Exception = { fg = C.mauve }, --  try, catch, throw

    PreProc = { fg = C.pink }, -- (preferred) generic Preprocessor
    Include = { fg = C.mauve }, --  preprocessor #include
    Define = { link = "PreProc" }, -- preprocessor #define
    Macro = { fg = C.mauve }, -- same as Define
    PreCondit = { link = "PreProc" }, -- preprocessor #if, #else, #endif, etc.

    StorageClass = { fg = C.yellow }, -- static, register, volatile, etc.
    Structure = { fg = C.yellow }, --  struct, union, enum, etc.
    Typedef = { link = "Type" }, --  A typedef
    SpecialChar = { link = "Special" }, -- special character in a constant
    Tag = { fg = C.lavender }, -- you can use CTRL-] on this
    Debug = { link = "Special" }, -- debugging statements

    Underlined = { underline = true },
    Bold = { bold = true },
    Italic = { italic = true },

    Error = { fg = C.red }, -- (preferred) any erroneous construct
    Todo = { bg = C.flamingo, fg = C.base }, -- (preferred) anything that needs extra attention; mostly the keywords TODO FIXME and XXX
    qfLineNr = { fg = C.yellow },
    qfFileName = { fg = C.blue },
    htmlH1 = { fg = C.pink },
    htmlH2 = { fg = C.blue },
    mkdCodeDelimiter = { bg = C.base, fg = C.text },
    mkdCodeStart = { fg = C.flamingo },
    mkdCodeEnd = { fg = C.flamingo },

    -- debugging
    debugPC = { bg = C.crust }, -- used for highlighting the current line in terminal-debug
    debugBreakpoint = { bg = C.base, fg = C.overlay0 }, -- used for breakpoint C in terminal-debug
    -- illuminate
    illuminatedWord = { bg = C.surface1 },
    illuminatedCurWord = { bg = C.surface1 },
    -- diff
    diffAdded = { fg = C.green },
    diffRemoved = { fg = C.red },
    diffChanged = { fg = C.blue },
    diffOldFile = { fg = C.yellow },
    diffNewFile = { fg = C.peach },
    diffFile = { fg = C.blue },
    diffLine = { fg = C.overlay0 },
    diffIndexLine = { fg = C.teal },
    -- DiffAdd = { bg = U.darken(C.green, 0.18, C.base) }, -- diff mode: Added line |diff.txt|
    -- DiffChange = { bg = U.darken(C.blue, 0.07, C.base) }, -- diff mode: Changed line |diff.txt|
    -- DiffDelete = { bg = U.darken(C.red, 0.18, C.base) }, -- diff mode: Deleted line |diff.txt|
    -- DiffText = { bg = U.darken(C.blue, 0.30, C.base) }, -- diff mode: Changed text within a changed line |diff.txt|
    -- NeoVim
    healthError = { fg = C.red },
    healthSuccess = { fg = C.teal },
    healthWarning = { fg = C.yellow },
    -- misc

    -- glyphs
    GlyphPalette1 = { fg = C.red },
    GlyphPalette2 = { fg = C.teal },
    GlyphPalette3 = { fg = C.yellow },
    GlyphPalette4 = { fg = C.blue },
    GlyphPalette6 = { fg = C.teal },
    GlyphPalette7 = { fg = C.text },
    GlyphPalette9 = { fg = C.red },

    -- rainbow
    rainbow1 = { fg = C.red },
    rainbow2 = { fg = C.peach },
    rainbow3 = { fg = C.yellow },
    rainbow4 = { fg = C.green },
    rainbow5 = { fg = C.sapphire },
    rainbow6 = { fg = C.lavender },

    -- csv
    csvCol0 = { fg = C.red },
    csvCol1 = { fg = C.peach },
    csvCol2 = { fg = C.yellow },
    csvCol3 = { fg = C.green },
    csvCol4 = { fg = C.sky },
    csvCol5 = { fg = C.blue },
    csvCol6 = { fg = C.lavender },
    csvCol7 = { fg = C.mauve },
    csvCol8 = { fg = C.pink },

    -- html
    ["@tag"] = { link = "Keyword" },
    ["@tag.delimiter"] = { link = "Operator" },
    ["@tag.attribute"] = { fg = C.teal },

    -- templ
    ["@string.special.templ"] = { fg = C.text },

    -- lua
    ["@constructor.lua"] = { link = "Delimiter" },
}

for k, v in pairs(groups) do
    vim.api.nvim_set_hl(0, k, v)
end

-- require("catppuccin").setup({
--     flavour = "mocha",
--     no_italic = true,
--     transparent_background = false,
--     custom_highlights = function(C)
--         return {
--             ["@function.builtin"] = { link = "Function" },
--         }
--     end,
-- })
--
-- vim.cmd.Ccheme("catppuccin")

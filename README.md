# :shield: cppguard.nvim

Automatically generates proper include guard for C++

## :clipboard: Requirements

- Neovim >= 0.10.0
- [luasnip](https://github.com/L3MON4D3/LuaSnip) (*optional*)

## :inbox_tray: Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    "pogyomo/cppguard.nvim",
    dependencies = {
        "L3MON4D3/LuaSnip" -- If you're using luasnip.
    },
    lazy = true,
}
```

## :notebook: Introduction

C++ requires developer to write include guard to prevent that file is included more than twice, and sometimes you need to write longer include guard, and it's painful.

So, this plugin provides apis that automatically generates such include guard.

## :rocket: Usage

This plugin provides `guard_string` which generates a string that is unique for using in include guard.

For examples, consider the following directory structure. 

```
project
|---CMakeLists.txt
|---src
    |---dir
        |---sub
            |---file.h <-here
```

When you open file.h, then call this function, you will get `PROJECT_DIR_SUB_FILE_H_`, that is following [google C++ Style Guide](https://google.github.io/styleguide/cppguide.html#The__define_Guard).

If you're using luasnip, you can create a snippet that automatically creates include guard with following code:

```lua
local luasnip = require("luasnip")
luasnip.add_snippets("cpp", {
    -- Register snippet which can summon by typing `guard`
    require("cppguard").snippet_luasnip("guard")
})
```

This snippet works as follow when you're in such above, for example:

```
guard|

↓ expand

#ifndef PROJECT_DIR_SUB_FILE_H_
#define PROJECT_DIR_SUB_FILE_H_

|

#endif 
```

## :desktop_computer: APIS

- `guard_string(opts)`
    - `opts?: table` Options to manage the movement of this function. Having following fields:
        - `naming_method?: string` How to generates the include guard. Accept following strings:
            - `"google"` Follows [google C++ Style Guide](https://google.github.io/styleguide/cppguide.html#The__define_Guard).
- `snippent_luasnip(trig, opts)`
    - `trig: string` What summon this snippent.
    - `opts?: table` Options to manage how to generate include guard. Same as `opts` in `guard_string`.

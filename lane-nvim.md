# lane.nvim 设计说明

## 1. 项目定位

`lane.nvim` 是一个基于 Tree-sitter 的 Neovim 编辑体验插件。它的目标不是再做一个 jump 插件，也不是再做一个 textobject 插件，而是提供一种新的结构化 motion 原语：

> 根据光标所在的 AST 语境，自动发现可重复导航的“语义轨道”，让用户在同级结构或同类结构之间连续移动。

它试图回答一个高频编辑问题：

> 我现在就在某个参数、字段、属性、语句、测试用例、返回语句、函数调用或字符串里，接下来我很可能想在“同一类东西”之间移动，而不是在字符、单词或物理行之间移动。

传统 Vim motion 提供了这些层级：

```text
h/j/k/l     字符和物理行
w/b/e       word
f/t/F/T     当前行字符
[/]         某些固定结构
%           匹配括号
```

`flash.nvim`、`leap.nvim`、`mini.jump2d` 这类插件把“可见目标”变成可快速寻址的对象。`lane.nvim` 的目标不同：

```text
flash.nvim       = 一次性定位可见目标
lane.nvim        = 在当前语义上下文中持续移动
```

`lane.nvim` 的核心体验应该像这样：

```text
1. 光标位于一个 AST 节点上
2. 用户按 gl 进入 lane
3. 插件自动推断最合理的结构轨道
4. 高亮轨道中的所有 item
5. 用户用 j/k 或 ;/, 在这些 item 之间连续移动
6. 用户可以切换 sibling lane / type lane / 候选 lane
```

---

## 2. 非目标

为了避免和现有生态重复，`lane.nvim` 不应该做这些事情：

### 2.1 不做通用 jump 插件

不要重复这些能力：

- `flash.nvim` 的 search labels
- `leap.nvim` 的双字符跳转
- `hop.nvim` 的 EasyMotion 风格跳转
- `mini.jump2d` 的二维 label filtering

`lane.nvim` 可以显示高亮和状态，但不应该主打“输入 label 跳到任意目标”。

### 2.2 不做普通 textobject 插件

不要重复这些能力：

- `mini.ai`
- `nvim-treesitter-textobjects`
- `nvim-treesitter-textsubjects`
- `targets.vim`

`lane.nvim` 可以使用 Tree-sitter 节点范围，但核心不是定义 `af`、`if` 之类的 textobject。

### 2.3 不做普通 AST walker

不要变成另一个：

- `treewalker.nvim`
- `treeclimber.nvim`
- `syntax-tree-surfer`

这些插件通常强调 AST 的 parent / child / sibling 上下左右导航。`lane.nvim` 更窄：它关注的是“当前语境中可重复移动的一组同级或同类节点”。

### 2.4 不做结构搬运或重构工具

不要把主功能做成：

- AST move/copy between containers
- extract function / extract variable
- structural paste
- code action/refactor workbench

这些动作频率不如 motion 高，且容易变成 refactoring/workflow 插件。`lane.nvim` 的主价值应该保持在 motion/editing primitive 层面。

---

## 3. 核心概念

`lane.nvim` 只有两个一等概念：

```text
Sibling Lane
Type Lane
```

### 3.1 Sibling Lane

Sibling Lane 表示：

> 在同一个 parent 节点下的一组 meaningful children 之间移动。

它是默认 lane，因为它最稳定、最符合用户直觉。

示例：

```ts
createUser(name, email, role)
```

光标在 `email` 上时，Sibling Lane 是：

```text
name -> email -> role
```

这些节点共享同一个 parent：函数调用的 `arguments` 容器。

再比如：

```ts
const user = {
  id: user.id,
  name: user.name,
  email: user.email,
}
```

光标在 `name` 或 `user.name` 内时，Sibling Lane 应该推断为 object properties：

```text
id: user.id -> name: user.name -> email: user.email
```

再比如 JSX props：

```tsx
<Button
  variant="primary"
  size="lg"
  disabled={isSubmitting}
/>
```

光标在 `size` 上时，Sibling Lane 是：

```text
variant -> size -> disabled
```

### 3.2 Type Lane

Type Lane 表示：

> 在某个范围内，和当前 AST 节点拥有相同或相似 syntax signature 的节点之间移动。

它不要求这些节点共享同一个 parent。

示例：

```ts
expect(user.name).toBe("Miku")
expect(user.email).toBe("miku@example.com")
expect(user.role).toBe("admin")
```

光标在第二个 `expect(...)` 上时，Type Lane 可以是：

```text
expect(user.name) -> expect(user.email) -> expect(user.role)
```

这些节点不是同一个 parent 的直接 sibling，但它们拥有相同的 syntax signature：

```text
call_expression:callee=expect
```

再比如 JSX 中的同名 prop：

```tsx
<Button disabled={isSubmitting} />
<Input disabled={isDisabled} />
<Select disabled={isReadonly} />
```

光标在任意一个 `disabled` 上时，Type Lane 可以是：

```text
jsx_attribute:name=disabled
```

再比如 return 语句：

```ts
if (!user) return null
if (!user.active) return inactiveUser
return user
```

光标在任意 `return` 上时，Type Lane 可以是：

```text
return_statement
```

---

## 4. 用户体验

### 4.1 基础交互

推荐默认键位：

```vim
gl    enter best sibling lane
gL    enter best type lane
```

进入 lane 后，插件进入一个轻量临时模式。该模式不应该污染 buffer 状态，也不应该改变 fold、marks、quickfix 或 jumplist 之外的长期状态。

Lane mode 内的建议按键：

```vim
j       next item
k       previous item
;       next item
,       previous item
gg      first item
G       last item
<Tab>   next candidate lane
<S-Tab> previous candidate lane
t       toggle sibling/type lane family
q       exit lane
<Esc>   exit lane
```

### 4.2 为什么需要 lane mode

可以把 lane 做成普通 motion，例如：

```vim
]l    next item in inferred sibling lane
[l    previous item in inferred sibling lane
]L    next item in inferred type lane
[L    previous item in inferred type lane
```

但这会降低可发现性，也无法清晰展示插件推断出了哪条 lane。

`lane.nvim` 的核心卖点之一是：

```text
用户进入 lane 后，看见当前轨道是什么，以及轨道中有哪些 item。
```

因此 MVP 应该优先实现 modal lane，而不是纯 motion。

### 4.3 状态提示

进入 lane 后应该显示清晰状态。

Sibling Lane 示例：

```text
Lane[sibling]: arguments 2/4
Lane[sibling]: object children 3/5
Lane[sibling]: statement_block 1/6
```

Type Lane 示例：

```text
Lane[type]: call_expression callee=expect 2/3
Lane[type]: jsx_attribute name=disabled 1/4
Lane[type]: return_statement 2/5
Lane[type]: string 4/9
```

状态提示可以通过以下方式实现：

- `vim.notify`，适合 MVP
- statusline component，适合后续集成
- virtual text prompt，适合更强视觉反馈
- noice.nvim message integration，作为可选支持

注：我认为应该优先做virtual text，然后做statusline。这两个是最合理的反馈方式。

### 4.4 高亮策略

进入 lane 后应高亮所有 lane items。

建议 highlight groups：

```vim
LaneItem
LaneItemCurrent
LaneItemSibling
LaneItemType
LaneDim
```

Sibling Lane 可以使用偏冷色，例如蓝色。Type Lane 可以使用偏暖色或紫色。当前 item 应该有更强的背景或下划线。

示例：

```ts
createUser(name, email, role)
           ━━━━  █████  ━━━━
```

这里 `email` 是当前 item，其余 item 是 lane item。

---

## 5. 自动推断模型

`lane.nvim` 不应该依赖硬编码的 lane 列表。正确模型是：

```text
cursor node
  -> AST ancestor path
  -> candidate sibling groups
  -> candidate type groups
  -> ranking
  -> active lane
```

### 5.1 获取 cursor node

通过 Neovim Tree-sitter API 获取光标位置的最小 named node。

伪代码：

```lua
local function get_cursor_node(bufnr, row, col)
  local parser = vim.treesitter.get_parser(bufnr)
  local tree = parser:parse()[1]
  local root = tree:root()
  return root:named_descendant_for_range(row, col, row, col)
end
```

实际实现要处理：

- parser 不存在
- 当前 filetype 无 parser
- 语法树解析失败
- 光标在空白处
- 光标在 anonymous token 上

如果光标在空白处，可以寻找附近 node：

```text
1. 当前列左侧最近 node
2. 当前列右侧最近 node
3. 当前行第一个 named node
4. 当前行上一行或下一行的 named node
```

MVP 可以先只支持光标在 named node 内。

### 5.2 AST ancestor path

从 cursor node 向上收集 ancestor：

```lua
local function ancestors(node)
  local result = {}

  while node do
    table.insert(result, node)
    node = node:parent()
  end

  return result
end
```

示例：

```ts
createUser(name, email, role)
```

光标在 `email` 上，ancestor path 可能是：

```text
identifier
arguments
call_expression
expression_statement
program
```

不同 parser 的节点层级会不同，插件不能假设存在统一的 `argument` node。

### 5.3 meaningful named children

Sibling Lane 基于 parent 的 meaningful named children。

基础规则：

```text
1. 只使用 named children
2. 排除 comment，除非用户配置允许
3. 排除过小节点
4. 排除过大节点
5. 排除语法错误节点
6. 排除不在当前 buffer 可见范围内的节点，除非配置允许
```

伪代码：

```lua
local function meaningful_named_children(parent, opts)
  local children = {}

  for child in parent:iter_children() do
    if child:named() and is_meaningful(child, opts) then
      table.insert(children, child)
    end
  end

  return children
end
```

`is_meaningful` 的初始规则：

```lua
local default_ignore_node_types = {
  comment = true,
  string_fragment = true,
}
```

范围过滤：

```text
min_item_chars
max_item_lines
max_item_chars
```

### 5.4 Sibling Lane 候选生成

对 cursor node 的每一层 ancestor：

```text
ancestor -> parent -> meaningful_named_children(parent)
```

如果 children 数量不少于 `min_items`，并且其中某个 child 包含当前 ancestor 或 cursor，则形成候选 lane。

伪代码：

```lua
local function sibling_lanes_at_cursor(node, opts)
  local lanes = {}

  for _, ancestor in ipairs(ancestors(node)) do
    local parent = ancestor:parent()

    if parent then
      local items = meaningful_named_children(parent, opts)
      local current = find_item_containing_node(items, ancestor)

      if current and #items >= opts.min_items then
        table.insert(lanes, {
          kind = "sibling",
          parent = parent,
          items = items,
          current = current,
          source_node = ancestor,
          label = infer_sibling_label(parent, items),
        })
      end
    end
  end

  return rank_sibling_lanes(lanes, opts)
end
```

### 5.5 Type Lane 候选生成

Type Lane 基于 syntax signature。

流程：

```text
1. 先从当前 active sibling lane 的 current item 生成 signatures
2. 如果没有 active sibling lane，则从 cursor ancestor path 生成 signatures
3. 在目标范围内查找 matching nodes
4. 形成候选 type lanes
5. 按精确度和数量排序
```

目标范围可以配置：

```text
viewport
function
buffer
```

MVP 推荐只支持 viewport。

伪代码：

```lua
local function type_lanes_at_cursor(node, opts)
  local lanes = {}
  local visible_nodes = collect_nodes_in_scope(opts.type_lane_scope)

  for _, candidate in ipairs(ancestors(node)) do
    local signatures = signatures_for(candidate, opts)

    for _, signature in ipairs(signatures) do
      local items = filter_by_signature(visible_nodes, signature)
      local current = find_item_containing_cursor_or_nearest(items)

      if current and #items >= opts.min_items then
        table.insert(lanes, {
          kind = "type",
          signature = signature,
          items = items,
          current = current,
          source_node = candidate,
          label = signature.label,
        })
      end
    end
  end

  return rank_type_lanes(lanes, opts)
end
```

---

## 6. Syntax Signature

Type Lane 的关键不是简单比较 `node:type()`，而是生成可配置的 syntax signature。

### 6.1 基础 signature

所有节点默认都可以生成基础 signature：

```text
node_type
```

示例：

```text
return_statement
string
identifier
call_expression
jsx_attribute
```

### 6.2 更具体的 signature

某些节点需要更具体的 signature。

#### call_expression

```ts
expect(user.name)
expect(user.email)
createUser(input)
```

基础 signature：

```text
call_expression
```

更具体 signature：

```text
call_expression:callee=expect
call_expression:callee=createUser
```

如果当前光标在 `expect(...)` 上，默认 Type Lane 应优先使用更具体 signature：

```text
call_expression:callee=expect
```

#### jsx_attribute

```tsx
<Button disabled={a} />
<Input disabled={b} />
```

signature：

```text
jsx_attribute:name=disabled
```

#### function call in test frameworks

```ts
it("creates user", () => {})
it("updates user", () => {})
describe("user service", () => {})
```

`it` 和 `describe` 本质上通常都是 `call_expression`。如果没有特殊 signature，Type Lane 可能会退化成所有 call expressions。

需要支持配置，让用户声明：

```text
call_expression with callee in { it, test, describe }
```

这样可以形成：

```text
call_expression:callee=it
call_expression:callee=test
call_expression:callee=describe
```

或者更高层的 lane label：

```text
test case
test suite
```

---

## 7. 配置设计

`lane.nvim` 应支持一定配置能力，但不能变成“用户手写所有 lanes”。配置应该围绕统一 provider registry 展开：用户和内置能力都注册 provider，provider 只负责提取 signature 或候选 item，最终 lane 仍由插件自动推断。

核心原则：

```text
内置 sibling/type 能力 = provider
用户扩展能力       = provider
测试用例/JSX/return = provider 示例，不是硬编码 lane
```

配置应该围绕：

```text
filename / filetype 过滤规则
Tree-sitter query 提取规则
signature / item 提取规则
ranking 偏好
keymaps
highlight
scope
```

### 7.1 推荐默认配置

```lua
require("lane").setup({
  min_items = 2,

  sibling = {
    enabled = true,
    max_item_lines = 20,
    max_items = 200,
  },

  type = {
    enabled = true,
    scope = "viewport",
    max_item_lines = 20,
    max_items = 200,
    prefer_specific_signatures = true,
  },

  filters = {
    ignore_node_types = {
      "comment",
      "string_fragment",
    },
    include_comments = false,
    min_item_chars = 1,
    max_item_chars = 2000,
  },

  providers = {
    -- Built-ins are registered through the same provider registry.
  },

  keymaps = {
    enter_sibling = "gl",
    enter_type = "gL",
    next = { "j", ";" },
    prev = { "k", "," },
    first = "gg",
    last = "G",
    next_lane = "<Tab>",
    prev_lane = "<S-Tab>",
    toggle_kind = "t",
    exit = { "q", "<Esc>" },
  },

  highlights = {
    sibling = "LaneSibling",
    type = "LaneType",
    current = "LaneCurrent",
    dim = "LaneDim",
  },
})
```

### 7.2 Provider 统一模型

Provider 配置的目标是支持类似测试用例的特定 AST 用例，例如：

```ts
it("creates user", () => {})
it("rejects duplicate email", () => {})
test("updates user", () => {})
describe("user service", () => {})
```

这些用例不应该变成硬编码 lane。正确做法是：provider 根据 filename、filetype 和 Tree-sitter query 提取特定结构，并为匹配项生成更准确的 syntax signature。

Provider 推荐数据模型：

```lua
---@class LaneProvider
---@field name string
---@field kind "signature" | "items"
---@field enabled? boolean | fun(ctx: LaneContext): boolean
---@field priority? integer
---@field filename? string | string[] | { regex: string } | fun(filename: string, ctx: LaneContext): boolean
---@field filetype? string | string[] | { regex: string } | fun(filetype: string, lang: string, ctx: LaneContext): boolean
---@field query? string
---@field captures? string | string[]
---@field extract? fun(match: table, ctx: LaneContext): LaneSignature[] | LaneItem[]
---@field provider? fun(ctx: LaneContext): LaneSignature[] | LaneItem[]
```

推荐配置形式：

```lua
require("lane").setup({
  providers = {
    {
      name = "test_case",
      kind = "signature",
      filetype = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      filename = { "*_test.*", "*_spec.*" },
      query = [[
        (call_expression
          function: (identifier) @callee) @test.outer
        (#any-of? @callee "it" "test" "specify")
      ]],
      captures = "@test.outer",
      priority = 100,
      extract = function(match, ctx)
        return {
          {
            key = "call_expression:callee=" .. ctx:get_capture_text(match, "@callee"),
            label = "test case",
            specificity = 100,
            node = match.captures["@test.outer"],
          },
        }
      end,
    },
    {
      name = "test_suite",
      kind = "signature",
      filetype = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      filename = { "*_test.*", "*_spec.*" },
      query = [[
        (call_expression
          function: (identifier) @callee) @suite.outer
        (#any-of? @callee "describe" "suite" "context")
      ]],
      captures = "@suite.outer",
      priority = 100,
      extract = function(match, ctx)
        return {
          {
            key = "call_expression:callee=" .. ctx:get_capture_text(match, "@callee"),
            label = "test suite",
            specificity = 100,
            node = match.captures["@suite.outer"],
          },
        }
      end,
    },
  },
})
```

这个配置不是在定义 lane，而是在定义更准确的 syntax signature provider。

也就是说：

```text
用户不需要说“这里有 test lane”。
用户只需要说“这种 query 匹配出的 call_expression 可以被识别为 test_case signature”。
```

Type Lane 仍然由插件自动生成。

### 7.3 filename / filetype filter

特定 use case 应该可以限制生效文件。

Filename filter 支持 glob / regex / Lua function：

```lua
filename = "*_spec.ts"
filename = { "*_test.*", "*_spec.*", "*.stories.tsx" }
filename = { regex = [[\v(_test|_spec)\.(ts|tsx|js|jsx)$]] }
filename = function(filename, ctx)
  return filename:match("[/\\]tests[/\\]") ~= nil
end
```

Filetype filter 支持 string / list / regex / Lua function：

```lua
filetype = "typescript"
filetype = { "javascript", "typescript", "javascriptreact", "typescriptreact" }
filetype = { regex = [[\v^(typescript|javascript)(react)?$]] }
filetype = function(filetype, lang, ctx)
  return lang == "typescript" or lang == "tsx"
end
```

实现要注意 Neovim filetype 和 Tree-sitter parser lang 不总是一致：

```text
typescriptreact -> tsx
javascriptreact -> jsx
```

内部应统一通过：

```lua
vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
```

把 filetype 映射到 parser lang，再决定是否运行 query。

### 7.4 Tree-sitter query provider

Tree-sitter query provider 是扩展特定结构的首选方式。

它负责：

```text
1. 根据 filename/filetype 判断是否启用
2. 编译 query
3. 在 scope 内运行 query
4. 从 captures 提取 node / text / metadata
5. 生成 signature 或 item
```

Provider 输出统一数据结构，不让 type.lua 或 sibling.lua 关心 query 细节。

Signature 输出示例：

```lua
{
  key = "call_expression:callee=it",
  label = "test case",
  specificity = 100,
  node = node,
  source = "test_case",
}
```

Item 输出示例：

```lua
{
  node = node,
  range = { start_row, start_col, end_row, end_col },
  label = "test case",
  source = "test_case",
  priority = 100,
}
```

### 7.5 通用 matcher 函数

为高级用户提供函数式 matcher：

```lua
require("lane").setup({
  providers = {
    {
      name = "vitest_each_case",
      kind = "signature",
      filetype = { "javascript", "typescript" },
      filename = { "*_test.*", "*_spec.*" },
      priority = 120,
      provider = function(ctx)
        local signatures = {}
        for _, node in ipairs(ctx:nodes_in_scope("call_expression")) do
          local callee = ctx:get_callee_name(node)
          if callee == "it.each" or callee == "test.each" then
            table.insert(signatures, {
              key = "call_expression:callee=" .. callee,
              label = "test.each case",
              specificity = 120,
              node = node,
            })
          end
        end
        return signatures
      end,
    },
  },
})
```

函数式 provider 是 query provider 的 escape hatch，不应成为普通用例的默认写法。

### 7.6 内置 providers

插件可以内置少量 provider，但不要内置具体 lane。关键要求：内置能力也必须通过同一套 provider registry 注册。

推荐内置：

```text
call_expression callee signature
jsx_attribute name signature
identifier text signature，可默认关闭
return_statement base signature
string base signature
import specifier name signature
```

call expression provider 示例：

```lua
{
  name = "builtin_call_expression",
  kind = "signature",
  filetype = "*",
  query = [[
    (call_expression) @call.outer
  ]],
  captures = "@call.outer",
  priority = 10,
  extract = function(match, ctx)
    local node = match.captures["@call.outer"]
    local callee = ctx:get_callee_name(node)
    local signatures = {
      {
        key = "call_expression",
        label = "call_expression",
        specificity = 10,
        node = node,
      },
    }

    if callee then
      table.insert(signatures, {
        key = "call_expression:callee=" .. callee,
        label = "call " .. callee,
        specificity = 50,
        node = node,
      })
    end

    return signatures
  end,
}
```

用户配置的 signature 应该能覆盖或增强内置 provider。

---

## 8. Test lane 用例

测试用例是 Type Lane 的重要示范，因为它们通常在 AST 上只是普通函数调用，但在编辑体验上是高频结构。

### 8.1 Vitest/Jest 示例

```ts
describe("user service", () => {
  it("creates user", async () => {
    expect(await createUser()).toBeDefined()
  })

  it("rejects duplicate email", async () => {
    await expect(createDuplicate()).rejects.toThrow()
  })

  it("updates profile", async () => {
    expect(await updateProfile()).toMatchObject({ name: "Miku" })
  })
})
```

光标在第二个 `it(...)` 上。

Sibling Lane 可能是：

```text
statement/block children inside describe callback
```

Type Lane 应该是：

```text
call_expression:callee=it
```

移动序列：

```text
it("creates user") -> it("rejects duplicate email") -> it("updates profile")
```

状态提示：

```text
Lane[type]: test case 2/3
```

### 8.2 describe / test suite 示例

```ts
describe("user service", () => {})
describe("order service", () => {})
describe("payment service", () => {})
```

光标在 `describe("order service")` 上时，Type Lane 是：

```text
describe("user service") -> describe("order service") -> describe("payment service")
```

状态提示：

```text
Lane[type]: test suite 2/3
```

### 8.3 配置示例

```lua
require("lane").setup({
  providers = {
    {
      name = "test_case",
      kind = "signature",
      filetype = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      filename = { "*_test.*", "*_spec.*" },
      query = [[
        (call_expression
          function: (identifier) @callee) @test.outer
        (#any-of? @callee "it" "test" "specify")
      ]],
      captures = "@test.outer",
      label = "test case",
      priority = 100,
    },
    {
      name = "test_suite",
      kind = "signature",
      filetype = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      filename = { "*_test.*", "*_spec.*" },
      query = [[
        (call_expression
          function: (identifier) @callee) @suite.outer
        (#any-of? @callee "describe" "suite" "context")
      ]],
      captures = "@suite.outer",
      label = "test suite",
      priority = 100,
    },
  },
})
```

### 8.4 后续可选动作

`lane.nvim` MVP 只做 navigation，但 test signature 可以为未来动作保留接口：

```vim
r    run current item
d    debug current item
o    open output
```

这些动作不应该进入 MVP。它们可以通过 hooks 实现：

```lua
require("lane").setup({
  actions = {
    test_case = {
      run = function(item, ctx)
        require("neotest").run.run(ctx.node_range(item.node))
      end,
    },
  },
})
```

---

## 9. Ranking 规则

### 9.1 Sibling Lane ranking

Sibling Lane 候选可能很多。

示例：

```ts
expect(getUser(user.id)).toEqual({ name: "Miku" })
```

光标在 `user.id` 上，可能生成：

```text
member expression lane
function arguments lane
call expression lane
statement block lane
```

Ranking 建议：

```text
1. 当前光标所在的最小 meaningful ancestor 优先
2. items 数量在 2 到 12 之间加分
3. items 平均长度适中加分
4. items 同 parent 加分
5. items type 分布一致加分
6. item 包含当前 cursor 加分
7. parent 范围在 viewport 内加分
8. parent 太大扣分
9. item 太小扣分
10. item 太大扣分
```

伪代码：

```lua
local function score_sibling_lane(lane, ctx)
  local score = 0

  score = score + lane.depth_score

  if #lane.items >= 2 and #lane.items <= 12 then
    score = score + 20
  end

  if lane.current and contains_cursor(lane.current, ctx.cursor) then
    score = score + 30
  end

  if dominant_type_ratio(lane.items) >= 0.6 then
    score = score + 10
  end

  if node_lines(lane.parent) > ctx.opts.max_parent_lines then
    score = score - 20
  end

  return score
end
```

### 9.2 Type Lane ranking

Type Lane 需要优先选择更具体的 signature。

Ranking 建议：

```text
1. 用户配置 signature 优先于内置基础 signature
2. signature specificity 高优先
3. match 数量在 2 到 20 之间加分
4. 当前 item 在 match 列表中加分
5. visible range 内连续出现加分
6. 过泛 signature 扣分
```

例如：

```text
call_expression:callee=expect
```

应优先于：

```text
call_expression
```

---

## 10. 配置 API 详细设计

### 10.1 setup

```lua
require("lane").setup({
  min_items = 2,
  max_items = 200,

  sibling = {
    enabled = true,
    default_scope = "parent",
    max_parent_lines = 120,
    max_item_lines = 20,
  },

  type = {
    enabled = true,
    scope = "viewport",
    prefer_specific_signatures = true,
    max_scan_lines = 300,
    max_item_lines = 20,
  },

  filters = {
    ignore_node_types = {
      "comment",
      "string_fragment",
    },
    ignore_parent_node_types = {},
    include_comments = false,
    min_item_chars = 1,
    max_item_chars = 2000,
  },

  providers = {
    -- User providers. Built-ins are registered through the same registry.
  },

  keymaps = {
    enter_sibling = "gl",
    enter_type = "gL",
    next = { "j", ";" },
    prev = { "k", "," },
    first = "gg",
    last = "G",
    next_lane = "<Tab>",
    prev_lane = "<S-Tab>",
    toggle_kind = "t",
    exit = { "q", "<Esc>" },
  },

  highlight = {
    enabled = true,
    dim = false,
    current_priority = 210,
    item_priority = 200,
  },

  notify = {
    enabled = true,
    backend = "vim_notify",
  },
})
```

### 10.2 public API

```lua
local lane = require("lane")

lane.enter({ kind = "sibling" })
lane.enter({ kind = "type" })
lane.exit()
lane.next()
lane.prev()
lane.first()
lane.last()
lane.next_lane()
lane.prev_lane()
lane.toggle_kind()
lane.current()
lane.register_provider(provider)
lane.unregister_provider(name)
```

### 10.3 candidate inspection API

用于调试和用户理解：

```lua
require("lane").inspect()
```

输出当前光标下可用候选：

```text
Sibling candidates:
  1. arguments 2/4 score=83
  2. expression_statement block 3/8 score=56

Type candidates:
  1. call_expression callee=expect 2/3 score=91
  2. call_expression 4/12 score=42
```

这对调试自动推断非常重要。

---

## 11. MVP 范围

MVP 只需要证明一个问题：

> 自动推断出的 lane 是否足够符合用户直觉，并且连续移动是否比现有 motion 更爽。

### 11.1 MVP 必做

```text
1. 获取 cursor AST node
2. 生成 sibling lane candidates
3. 生成基础 type lane candidates
4. 对 candidates 排序
5. 进入 lane mode
6. 高亮 lane items
7. j/k 或 ;/, 连续移动
8. Tab 切换候选 lane
9. gL 进入 type lane
10. 支持 query-based provider 配置，至少覆盖 test case 的 it/test/describe，并支持 filename/filetype regex/function filter
```

### 11.2 MVP 不做

```text
delete/yank/change 操作
swap 操作
multi-edit
surround
paste
LSP 集成
neotest 集成
跨 buffer navigation
复杂 preview
所有语言的手写规则
```

### 11.3 MVP 首选语言

优先支持 Tree-sitter parser 稳定且结构密集的语言：

```text
typescript
javascript
lua
python
```

但实现不应该写死这些语言。只有 signature provider 可以按语言增强。

---

## 12. 典型日常用例

### 12.1 函数参数中移动

```ts
createUser(name, email, role, organizationId)
```

光标在 `email`，按 `gl`。

```text
Lane[sibling]: arguments 2/4
```

`j` 到 `role`，`k` 回到 `email`。

### 12.2 多行参数中移动

```ts
createUser(
  name,
  email,
  role,
  organizationId,
)
```

Sibling Lane 应该在参数 item 之间移动，而不是在物理行之间移动。

### 12.3 对象字段中移动

```ts
const user = {
  id: user.id,
  name: user.name,
  email: user.email,
  role: user.role,
}
```

光标在 `name`，按 `gl`。

```text
Lane[sibling]: object children 2/4
```

### 12.4 JSX props 中移动

```tsx
<Button
  variant="primary"
  size="lg"
  disabled={isSubmitting}
  onClick={handleSubmit}
/>
```

光标在 `size`，按 `gl`。

```text
Lane[sibling]: jsx_opening_element children 2/4
```

### 12.5 block statements 中移动

```ts
async function submit() {
  validate(input)

  const user = await createUser(input)

  await sendEmail(user)

  return user
}
```

光标在 `const user`，按 `gl`。

```text
Lane[sibling]: statement_block 2/4
```

`j` 应跳到 `await sendEmail(user)`，而不是下一物理行。

### 12.6 测试用例中移动

```ts
describe("user service", () => {
  it("creates user", async () => {})
  it("rejects duplicate email", async () => {})
  it("updates profile", async () => {})
})
```

光标在第二个 `it(...)`，按 `gL`。

```text
Lane[type]: test case 2/3
```

`j` 到第三个 test，`k` 到第一个 test。

### 12.7 同名 JSX prop 中移动

```tsx
<Button disabled={isSubmitting} />
<Input disabled={isReadonly} />
<Select disabled={isDisabled} />
```

光标在第二个 `disabled`，按 `gL`。

```text
Lane[type]: jsx_attribute name=disabled 2/3
```

### 12.8 return statement 中移动

```ts
if (!user) return null
if (!user.active) return inactiveUser
return user
```

光标在任意 return，按 `gL`。

```text
Lane[type]: return_statement 2/3
```

---

## 13. 和现有插件的区别

### 13.1 vs flash.nvim

`flash.nvim`：

```text
用户知道视觉目标，触发一次性跳转。
```

`lane.nvim`：

```text
用户处在某个语义结构中，进入该结构的重复 motion 轨道。
```

### 13.2 vs mini.jump2d

`mini.jump2d`：

```text
对可见位置做二维 label filtering。
```

`lane.nvim`：

```text
对 AST 上下文生成 sibling/type item 序列，并在序列中移动。
```

### 13.3 vs nvim-treesitter-textobjects

`nvim-treesitter-textobjects`：

```text
用户需要知道要移动的是 function、parameter、class、loop 等，并配置对应 keymap。
```

`lane.nvim`：

```text
插件根据当前光标位置自动推断当前最合理的 sibling/type lane。
```

### 13.4 vs treewalker.nvim

`treewalker.nvim`：

```text
AST 上下左右导航和交换。
```

`lane.nvim`：

```text
锁定一个当前上下文的可重复结构序列，不做泛 AST walker。
```

### 13.5 vs textsubjects.nvim

`textsubjects.nvim`：

```text
智能选择 textobject。
```

`lane.nvim`：

```text
智能生成 motion lane，并支持连续移动和候选切换。
```

---

## 14. 后续扩展方向

这些不是 MVP，但可以在 motion 成立后逐步加入。

### 14.1 operator-pending 支持

```vim
dgl    delete current sibling lane item
ygl    yank current sibling lane item
cgl    change current sibling lane item
dgL    delete current type lane item
```

需要谨慎设计，避免和现有 operator/textobject 插件重叠。

### 14.2 dot-repeat

Lane navigation 本身可以不要求 dot-repeat。若加入 delete/change/swap 等 edit action，需要支持 dot-repeat。

### 14.3 action hooks

为特定 signature 提供可选动作：

```lua
require("lane").setup({
  actions = {
    test_case = {
      run = function(item, ctx) end,
      debug = function(item, ctx) end,
    },
  },
})
```

这可以让 `test_case` lane 与 `neotest` 集成，但不能成为核心 MVP。

### 14.4 persisted lane

允许用户固定当前 lane，移动光标后仍保留 lane：

```vim
p    pin current lane
u    unpin lane
```

这适合在大型 object / block 中连续编辑。

### 14.5 visible labels

可选显示 item labels，但不要作为核心跳转模型。Lane 的核心是连续 motion，而不是 label target。

---

## 15. 实现模块拆分

建议目录结构：

```text
lua/lane/init.lua
lua/lane/config.lua
lua/lane/state.lua
lua/lane/treesitter.lua
lua/lane/node.lua
lua/lane/sibling.lua
lua/lane/type.lua
lua/lane/provider.lua
lua/lane/query.lua
lua/lane/signature.lua
lua/lane/rank.lua
lua/lane/highlight.lua
lua/lane/mode.lua
lua/lane/keymap.lua
lua/lane/notify.lua
lua/lane/inspect.lua
```

### 15.1 init.lua

Public API：

```lua
setup
enter
exit
next
prev
first
last
next_lane
prev_lane
toggle_kind
inspect
```

### 15.2 state.lua

维护当前 lane 状态：

```lua
{
  active = true,
  bufnr = 1,
  win = 1000,
  kind = "sibling",
  lanes = {},
  index = 1,
  item_index = 2,
  namespace = ns_id,
}
```

### 15.3 sibling.lua

负责生成 Sibling Lane candidates。

### 15.4 type.lua

负责生成 Type Lane candidates。

### 15.5 provider.lua

负责统一 provider registry：

```text
1. 注册内置 providers
2. 合并用户 providers
3. 处理 enabled / priority
4. 执行 filename filter
5. 执行 filetype filter
6. 调用 query provider 或 function provider
7. 输出统一 signature / item 数据
```

### 15.6 query.lua

负责 Tree-sitter query provider：

```text
1. 编译 in-Lua query string
2. 读取 captures
3. 把 query match 转成 provider match
4. query 错误诊断
5. 按 buffer changedtick 做缓存
```

### 15.7 signature.lua

负责 signature normalization 和 scoring：

```text
1. 把 provider 输出转成标准 LaneSignature
2. 合并重复 signature
3. 计算 specificity
4. 处理内置 signature 与用户 signature 的覆盖关系
```

### 15.8 rank.lua

负责 candidate ranking。

### 15.9 mode.lua

负责 lane mode 中的临时 keymaps 和退出逻辑。

---

## 16. 验证标准

MVP 是否成立，不看功能数量，而看下面几个问题：

```text
1. gl 后自动选择的 sibling lane 是否符合直觉？
2. gL 后自动选择的 type lane 是否符合直觉？
3. j/k 连续移动是否比 flash/普通 treesitter motion 更轻？
4. Tab 切换候选 lane 是否能快速纠正推断错误？
5. 在 TS/JS/TSX 真实项目里是否高频可用？
6. 状态提示是否让用户知道当前 lane 是什么？
7. 高亮是否清晰但不吵？
```

如果前 4 点不成立，插件就不应该继续扩展 action、operator 或 integration。

---

## 17. README 核心文案草案

```text
lane.nvim turns the AST around your cursor into repeatable motions.

Sibling lane:
  move between nodes that share the same parent.

Type lane:
  move between nodes that share the same syntax signature.

Use gl to enter a sibling lane and gL to enter a type lane.
Then use j/k or ;/, to move only through the lane items.
```

示例：

```ts
createUser(name, email, role)
// cursor on email
// gl -> sibling lane: name -> email -> role
```

```ts
it("creates user", () => {})
it("updates user", () => {})
it("deletes user", () => {})
// cursor on second it
// gL -> type lane: test case 2/3
```

---

## 18. 总结

`lane.nvim` 的核心不是支持某些固定 lane，而是自动从光标处的 AST path 推断结构轨道。

最终模型：

```text
Sibling Lane
  同一个 parent 下的兄弟节点之间移动。

Type Lane
  同一 syntax signature 的节点之间移动，不要求同 parent。
```

配置能力应该服务于 signature 增强和候选提取，而不是让用户手写所有 lane。`it`、`test`、`describe` 这类测试用例应通过 filename/filetype filter + Tree-sitter query provider 支持：

```text
call_expression:callee=it       -> test case
call_expression:callee=test     -> test case
call_expression:callee=describe -> test suite
```

最小可行版本只需要实现自动 lane 推断、高亮、j/k 连续移动、Tab 切换候选，以及统一 provider registry。内置 sibling/type/signature 能力和用户扩展都应走同一套 provider/query/filter 机制。只要这个核心体验成立，后续再考虑 operator、actions、test runner 集成或更复杂的 type signature。

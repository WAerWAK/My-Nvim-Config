-- =====================================================================
--  telescope.nvim git 类 picker 与剩余提示汉化
-- =====================================================================
--  注：__git.lua 里每个 picker 都自己设了 prompt_title（配置项的覆盖会被
--      后合并的源码值顶掉），所以这里直接改源码文本。
-- =====================================================================

return {
  rules = {
    {
      path = "telescope.nvim/lua/telescope/builtin/__git.lua",
      note = "telescope git picker 标题与提示（13 条）",
      replacements = {
        { [[prompt_title = "Git BCommits"]], [[prompt_title = "当前文件的提交记录"]] },
        { [[prompt_title = "Git Branches"]], [[prompt_title = "Git 分支"]] },
        { [[prompt_title = "Git Commits"]], [[prompt_title = "Git 提交记录"]] },
        { [[prompt_title = "Git Stash"]], [[prompt_title = "Git 储藏"]] },
        { [[prompt_title = "Git Status"]], [[prompt_title = "Git 状态"]] },
        { [[prompt_title = "Git Files"]], [[prompt_title = "Git 文件"]] },
        { [[title = "Git BCommits"]], [[title = "当前文件的提交记录"]] },
        { [[title = "Git Branches"]], [[title = "Git 分支"]] },
        { [[title = "Git Commits"]], [[title = "Git 提交记录"]] },
        { [[title = "Git Stash"]], [[title = "Git 储藏"]] },
        { [[title = "Git Status"]], [[title = "Git 状态"]] },
        { [[title = "Git Files"]], [[title = "Git 文件"]] },
        { [[msg = "This operation must be run in a work tree"]], [[msg = "该操作必须在 Git 工作区中执行"]] },
        { [[msg = "Git does not support both --others and --recurse-submodules"]], [[msg = "Git 不支持同时使用 --others 与 --recurse-submodules"]] },
        { [[msg = "No changes found"]], [[msg = "没有找到改动"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/pickers.lua",
      note = "telescope 参数校验提示（1 条）",
      replacements = {
        { [[msg = "`initial_mode` should be one of "]], [[msg = "`initial_mode` 只能是 "]] },
      },
    },
  },
}

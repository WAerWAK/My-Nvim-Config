-- =====================================================================
--  nvim-tree.lua 文件树汉化
-- =====================================================================
--  覆盖：新建/重命名/移动/剪切复制等操作的输入提示与选择框
--  （键位提示是官方配置项，见 lua/plugins/nvim-tree.lua）
-- =====================================================================

return {
  rules = {
    {
      path = "nvim-tree.lua/lua/nvim-tree/marks/init.lua",
      note = "文件树：移动与选择提示（2 条）",
      replacements = {
        { [[prompt = "Move to: "]], [[prompt = "移动到："]] },
        { [[prompt = "Select a file to open or a folder to focus"]], [[prompt = "选择要打开的文件或要聚焦的文件夹"]] },
      },
    },
    {
      path = "nvim-tree.lua/lua/nvim-tree/actions/fs/create-file.lua",
      note = "文件树：新建文件提示（1 条）",
      replacements = {
        { [[prompt = "Create file "]], [[prompt = "新建文件 "]] },
      },
    },
    {
      path = "nvim-tree.lua/lua/nvim-tree/actions/fs/rename-file.lua",
      note = "文件树：重命名提示（1 条）",
      replacements = {
        { [[prompt = "Rename to "]], [[prompt = "重命名为 "]] },
      },
    },
    {
      path = "nvim-tree.lua/lua/nvim-tree/actions/fs/clipboard.lua",
      note = "文件树：剪贴板粘贴/移动提示（1 条）",
      replacements = {
        { [[prompt = "Rename to "]], [[prompt = "重命名为 "]] },
      },
    },
  },
}

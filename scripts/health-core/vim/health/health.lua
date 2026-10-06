local M = {}
local health = require('vim.health')

---Run a system command and return ok and its stdout and stderr combined.
---@param cmd string[]
---@return boolean
---@return string
local function system(cmd)
  local result = vim.system(cmd, { text = true }):wait()
  return result.code == 0, vim.trim(('%s\n%s'):format(result.stdout, result.stderr))
end

local suggest_faq = 'https://neovim.io/doc/build/#building'

local function check_runtime()
  health.start('Runtime')
  -- Files from an old installation.
  local bad_files = {
    ['autoload/health/nvim.vim'] = false,
    ['autoload/health/provider.vim'] = false,
    ['autoload/man.vim'] = false,
    ['lua/provider/node/health.lua'] = false,
    ['lua/provider/perl/health.lua'] = false,
    ['lua/provider/python/health.lua'] = false,
    ['lua/provider/ruby/health.lua'] = false,
    ['lua/vim/_defaults.lua'] = false,
    ['lua/vim/_editor.lua'] = false,
    ['lua/vim/_extui.lua'] = false,
    ['lua/vim/_extui/cmdline.lua'] = false,
    ['lua/vim/_extui/messages.lua'] = false,
    ['lua/vim/_extui/shared.lua'] = false,
    ['lua/vim/_options.lua'] = false,
    ['lua/vim/_stringbuffer.lua'] = false,
    ['lua/vim/_system.lua'] = false,
    ['lua/vim/shared.lua'] = false,
    ['plugin/health.vim'] = false,
    ['plugin/man.vim'] = false,
    ['queries/help/highlights.scm'] = false,
    ['queries/help/injections.scm'] = false,
    ['scripts.vim'] = false,
    ['syntax/syncolor.vim'] = false,
  }
  local bad_files_msg = ''
  for k, _ in pairs(bad_files) do
    local path = ('%s/%s'):format(vim.env.VIMRUNTIME, k)
    if vim.uv.fs_stat(path) then
      bad_files[k] = true
      bad_files_msg = ('%s%s\n'):format(bad_files_msg, path)
    end
  end

  local ok = (bad_files_msg == '')
  local info = ok and health.ok or health.info
  info(string.format('$VIMRUNTIME: %s', vim.env.VIMRUNTIME))
  if not ok then
    health.error(
      string.format(
        'Found old files in $VIMRUNTIME (this can cause weird behavior):\n%s',
        bad_files_msg
      ),
      { '删除 $VIMRUNTIME 目录，然后重新安装 Nvim。' }
    )
  end
end

local function check_config()
  health.start('Configuration')
  local ok = true

  local init_lua = vim.fn.stdpath('config') .. '/init.lua'
  local init_vim = vim.fn.stdpath('config') .. '/init.vim'
  local vimrc = vim.env.MYVIMRC and vim.fs.normalize(vim.env.MYVIMRC) or init_lua

  if vim.fn.file读(vimrc) == 0 and vim.fn.file读(init_vim) == 0 then
    ok = false
    local has_vim = vim.fn.file读(vim.fs.normalize('~/.vimrc')) == 1
    health.warn(
      ('%s user config file: %s'):format(
        -1 == vim.fn.getfsize(vimrc) and '缺失' or '不可读',
        vimrc
      ),
      { has_vim and ':help nvim-from-vim' or ':help config' }
    )
  end

  -- If $VIM is empty we don't care. Else make sure it is valid.
  if vim.env.VIM and vim.fn.file读(vim.env.VIM .. '/runtime/doc/nvim.txt') == 0 then
    ok = false
    health.error('$VIM 无效： ' .. vim.env.VIM)
  end

  if vim.env.NVIM_TUI_ENABLE_CURSOR_SHAPE then
    ok = false
    health.warn('$NVIM_TUI_ENABLE_CURSOR_SHAPE 在 Nvim 0.2+ 中被忽略', {
      "使用 'guicursor' 选项配置光标形状。:help 'guicursor'",
      'https://github.com/neovim/neovim/wiki/Following-HEAD#20170402',
    })
  end

  if vim.v.ctype == 'C' then
    ok = false
    health.error(
      '当前 locale 不支持 UTF-8。Unicode 字符可能无法正确显示。'
        .. ('\n$LANG=%s $LC_ALL=%s $LC_CTYPE=%s'):format(
          vim.env.LANG or '',
          vim.env.LC_ALL or '',
          vim.env.LC_CTYPE or ''
        ),
      {
        '如果使用 tmux，请尝试 -u 选项。',
        '确保你的终端/shell/tmux 等继承了环境变量，或显式设置 $LANG。',
        '配置你的系统 locale。',
      }
    )
  end

  if vim.o.paste == 1 then
    ok = false
    health.error(
      "'paste' 已启用。该选项仅用于粘贴文本。\n不应在你的配置中设置它。",
      {
        '如果适用，请从 init.vim 中移除 `set paste`。',
        '用 `:verbose set paste?` 检查是否是某个插件或脚本设置了该选项。',
      }
    )
  end

  local 写 = true
  local shadaopt = vim.fn.split(vim.o.shada, ',')
  local shadafile = (
    vim.o.shada == '' and vim.o.shada
    or vim.fn.substitute(vim.fn.matchstr(shadaopt[#shadaopt], '^n.\\+'), '^n', '', '')
  )
  shadafile = (
    vim.o.shadafile == ''
      and (shadafile == '' and vim.fn.stdpath('state') .. '/shada/main.shada' or vim.fs.normalize(
        shadafile
      ))
    or (vim.o.shadafile == 'NONE' and '' or vim.o.shadafile)
  )
  if shadafile ~= '' and vim.fn.glob(shadafile) == '' then
    -- Since this may be the first time Nvim has been run, try to create a shada file.
    if not pcall(vim.cmd.wshada) then
      写 = false
    end
  end
  if
    not 写
    or (
      shadafile ~= ''
      and (vim.fn.file读(shadafile) == 0 or vim.fn.filewritable(shadafile) ~= 1)
    )
  then
    ok = false
    health.error(
      'shada 文件不可'
        .. ((not 写 or vim.fn.file读(shadafile) == 1) and '写' or '读')
        .. ':\n'
        .. shadafile
    )
  end

  if ok then
    health.ok('未发现问题')
  end
end

local function check_performance()
  health.start('Performance')

  -- Check buildtype
  local buildtype = vim.fn.matchstr(vim.fn.execute('version'), [[\v\cbuild type:?\s*[^\n\r\t]+]])
  if buildtype == '' then
    health.error('无法从 :version 获取构建类型')
  elseif
    vim.regex([[\v(MinSizeRel|RelWithDebInfo|Release(Fast|Safe|Small)?)]]):match_str(buildtype)
  then
    health.ok(buildtype)
  else
    health.info(buildtype)
    health.warn('非优化的 debug 构建。Nvim 会更慢。', {
      '请安装其他的 Nvim 发行包，或用 `CMAKE_BUILD_TYPE=RelWithDebInfo`（CMake）或 `-Doptimize=ReleaseFast`（Zig）重新构建。',
      suggest_faq,
    })
  end

  -- check for slow shell invocation
  local slow_cmd_time = 1.5e9
  local start_time = vim.uv.hrtime()
  -- Vimscript's system() is used to actually invoke a shell
  vim.fn.system('echo')
  local elapsed_time = vim.uv.hrtime() - start_time
  if elapsed_time > slow_cmd_time then
    health.warn(
      'shell 调用缓慢（耗时 ' .. vim.fn.printf('%.2f', elapsed_time) .. ' 秒）。'
    )
  end
end

-- Load the remote plugin manifest file and check for unregistered plugins
local function check_rplugin_manifest()
  health.start('Remote Plugins')

  local existing_rplugins = {} --- @type table<string,string>
  --- @type {path:string}[]
  local items = vim.fn['remote#host#PluginsForHost']('python3')
  for _, item in ipairs(items) do
    existing_rplugins[item.path] = 'python3'
  end

  local require_update = false
  local handle_path = function(path)
    --- @type string[]
    local python_glob = vim.fn.glob(path .. '/rplugin/python*', true, true)
    if vim.tbl_isempty(python_glob) then
      return
    end

    local python_dir = python_glob[1]
    local python_version = vim.fs.basename(python_dir)

    --- @type string[]
    local scripts = vim.fn.glob(python_dir .. '/*.py', true, true)
    vim.list_extend(scripts, vim.fn.glob(python_dir .. '/*/__init__.py', true, true))

    for _, script in ipairs(scripts) do
      local contents = vim.fn.join(vim.fn.readfile(script))
      if vim.regex([[\<\%(from\|import\)\s\+neovim\>]]):match_str(contents) then
        if vim.regex([[[\/]__init__\.py$]]):match_str(script) then
          script = vim.fs.normalize(vim.fs.dirname(script))
        end
        if not existing_rplugins[script] then
          local msg = vim.fn.printf('"%s" is not registered.', vim.fs.basename(path))
          if python_version == 'pythonx' then
            if vim.fn.has('python3') == 0 then
              msg = msg .. ' （python3 不可用）'
            end
          elseif vim.fn.has(python_version) == 0 then
            msg = msg .. vim.fn.printf(' (%s not available)', python_version)
          else
            require_update = true
          end

          health.warn(msg)
        end

        break
      end
    end
  end

  --- @type string[]
  local paths = vim.fn.map(vim.split(vim.o.runtimepath, ','), 'resolve(v:val)')

  for _, path in ipairs(paths) do
    handle_path(path)
  end

  if require_update then
    health.warn('已过期', { '运行 `:UpdateRemotePlugins`' })
  else
    health.ok('已是最新')
  end
end

local function check_tmux()
  if not vim.env.TMUX or vim.fn.executable('tmux') == 0 then
    return
  end

  ---@param option string
  local get_tmux_option = function(option)
    local cmd = { 'tmux', 'show-option', '-qvg', option } -- try global scope
    local ok, out = system(cmd)
    local val = vim.fn.substitute(out, [[\v(\s|\r|\n)]], '', 'g')
    if not ok then
      health.error(('command failed: %s\n%s'):format(vim.inspect(cmd), out))
      return 'error'
    elseif val == '' then
      cmd = { 'tmux', 'show-option', '-qvgs', option } -- try session scope
      ok, out = system(cmd)
      val = vim.fn.substitute(out, [[\v(\s|\r|\n)]], '', 'g')
      if not ok then
        health.error(('command failed: %s\n%s'):format(vim.inspect(cmd), out))
        return 'error'
      end
    end
    return val
  end

  health.start('tmux')

  -- check escape-time
  local suggestions =
    { '在 ~/.tmux.conf 中设置 escape-time：\nset-option -sg escape-time 10', suggest_faq }
  local tmux_esc_time = get_tmux_option('escape-time')
  if tmux_esc_time ~= 'error' then
    if tmux_esc_time == '' then
      health.error('未设置 `escape-time`', suggestions)
    else
      local tmux_esc_time_ms = vim._tointeger(tmux_esc_time)
      if not tmux_esc_time_ms then
        health.error('`escape-time`（' .. tmux_esc_time .. '）不是整数', suggestions)
      elseif tmux_esc_time_ms > 300 then
        health.error('`escape-time`（' .. tmux_esc_time .. '）高于 300ms', suggestions)
      else
        health.ok('escape-time： ' .. tmux_esc_time)
      end
    end
  end

  -- check focus-events
  local tmux_focus_events = get_tmux_option('focus-events')
  if tmux_focus_events ~= 'error' then
    if tmux_focus_events == '' or tmux_focus_events ~= 'on' then
      health.warn(
        "未启用 `focus-events`。|'autoread'| 可能无法工作。",
        { '（仅限 tmux 1.9+）在 ~/.tmux.conf 中设置 `focus-events`：\nset-option -g focus-events on' }
      )
    else
      health.ok('focus-events： ' .. tmux_focus_events)
    end
  end

  -- check default-terminal and $TERM
  health.info('$TERM： ' .. vim.env.TERM)
  local cmd = { 'tmux', 'show-option', '-qvg', 'default-terminal' }
  local ok, out = system(cmd)
  local tmux_default_term = vim.fn.substitute(out, [[\v(\s|\r|\n)]], '', 'g')
  if tmux_default_term == '' then
    cmd = { 'tmux', 'show-option', '-qvgs', 'default-terminal' }
    ok, out = system(cmd)
    tmux_default_term = vim.fn.substitute(out, [[\v(\s|\r|\n)]], '', 'g')
  end

  if not ok then
    health.error(('command failed: %s\n%s'):format(vim.inspect(cmd), out))
  elseif tmux_default_term ~= vim.env.TERM then
    health.info('default-terminal： ' .. tmux_default_term)
    health.error(
      '$TERM 与 tmux 的 `default-terminal` 设置不一致。颜色可能显示异常。',
      { '$TERM 可能被某个 rc 文件（.bashrc、.zshrc 等）设置了。' }
    )
  elseif
    not vim.regex([[\v(tmux-256color|tmux-direct|screen-256color)]]):match_str(vim.env.TERM)
  then
    health.error(
      '在 tmux 中 $TERM 应为 "screen-256color"、"tmux-256color" 或 "tmux-direct"。颜色可能显示异常。',
      {
        '在 ~/.tmux.conf 中设置 default-terminal：\nset-option -g default-terminal "screen-256color"',
        suggest_faq,
      }
    )
  end

  -- check for RGB capabilities
  local _, info = system({ 'tmux', 'show-messages', '-T' })
  local has_setrgbb = vim.fn.stridx(info, ' setrgbb: (string)') ~= -1
  local has_setrgbf = vim.fn.stridx(info, ' setrgbf: (string)') ~= -1
  if not has_setrgbb or not has_setrgbf then
    health.warn(
      "无法检测到真彩色支持。|'termguicolors'| 将无法正常工作。",
      {
        "将以下内容添加到你的 tmux 配置文件，并将 XXX 替换为 tmux 外部 $TERM 的值：\nset-option -a terminal-features 'XXX:RGB'",
        "对于较旧的 tmux 版本，请改用以下内容：\nset-option -a terminal-overrides 'XXX:Tc'",
      }
    )
  end
end

local function check_terminal()
  if vim.fn.executable('infocmp') == 0 then
    return
  end

  health.start('Terminal')
  local cmd = { 'infocmp', '-L' }
  local ok, out = system(cmd)
  local kbs_entry = vim.fn.matchstr(out, 'key_backspace=[^,[:space:]]*')
  local kdch1_entry = vim.fn.matchstr(out, 'key_dc=[^,[:space:]]*')

  if
    not ok
    and (
      vim.fn.has('win32') == 0
      or vim.fn.matchstr(
          out,
          [[infocmp: couldn't open terminfo file .\+\%(conemu\|vtpcon\|win32con\)]]
        )
        == ''
    )
  then
    health.error(('command failed: %s\n%s'):format(vim.inspect(cmd), out))
  else
    health.info(
      vim.fn.printf(
        'key_backspace (kbs) terminfo entry: `%s`',
        (kbs_entry == '' and '？（未找到）' or kbs_entry)
      )
    )

    health.info(
      vim.fn.printf(
        'key_dc (kdch1) terminfo entry: `%s`',
        (kbs_entry == '' and '？（未找到）' or kdch1_entry)
      )
    )
  end

  for _, env_var in ipairs({
    'XTERM_VERSION',
    'VTE_VERSION',
    'TERM_PROGRAM',
    'COLORTERM',
    'SSH_TTY',
  }) do
    if vim.env[env_var] then
      health.info(string.format('$%s="%s"', env_var, vim.env[env_var]))
    end
  end
end

local function check_external_tools()
  health.start('External Tools')

  if vim.fn.executable('rg') == 1 then
    local rg_path = vim.fn.exepath('rg')
    local rg_job = vim.system({ rg_path, '-V' }):wait()
    if rg_job.code == 0 then
      health.ok(('%s (%s)'):format(vim.trim(rg_job.stdout), rg_path))
    else
      health.warn('找到了 `rg` 但无法运行 `rg -V`', { rg_job.stderr })
    end
  else
    health.warn('ripgrep 不可用')
  end

  local open_cmd, err = vim.ui._get_open_cmd()
  if open_cmd then
    health.ok(('vim.ui.open: handler found (%s)'):format(open_cmd[1]))
  else
    --- @cast err string
    health.warn(err)
  end

  -- `vim.pack` prefers git 2.36 but tries to work with 2.x.
  if vim.fn.executable('git') == 1 then
    local git = vim.fn.exepath('git')
    local version = vim.system({ 'git', 'version' }, {}):wait().stdout or ''
    health.ok(('%s (%s)'):format(vim.trim(version), git))
  else
    health.warn('git 不可用（`vim.pack` 需要它）')
  end

  if vim.fn.executable('curl') == 1 then
    local curl_path = vim.fn.exepath('curl')
    local curl_job = vim.system({ curl_path, '--version' }):wait()

    if curl_job.code == 0 then
      local curl_out = curl_job.stdout
      if not curl_out or curl_out == '' then
        health.warn(
          string.format('`%s --version` produced no output', curl_path),
          { curl_job.stderr }
        )
        return
      end
      local curl_version = vim.version.parse(curl_out)
      if not curl_version then
        health.warn('无法从 `curl --version` 解析 curl 版本')
        return
      end
      if vim.version.le(curl_version, { 7, 12, 3 }) then
        health.warn('curl version %s not compatible', curl_version)
        return
      end
      local lines = { string.format('curl %s (%s)', curl_version, curl_path) }

      for line in vim.gsplit(curl_out, '\n', { plain = true }) do
        if line ~= '' then
          table.insert(lines, line)
        end
      end

      -- Add subtitle only if any env var is present
      local added_env_header = false
      for _, var in ipairs({
        'curl_ca_bundle',
        'curl_home',
        'curl_ssl_backend',
        'ssl_cert_dir',
        'ssl_cert_file',
        'https_proxy',
        'http_proxy',
        'all_proxy',
        'no_proxy',
      }) do
        ---@type string?
        local val = vim.env[var] or vim.env[var:upper()]
        if val then
          if not added_env_header then
            table.insert(lines, 'curl-related environment variables:')
            added_env_header = true
          end
          local shown_var = vim.env[var] and var or var:upper()
          table.insert(lines, string.format('  %s=%s', shown_var, val))
        end
      end

      health.ok(table.concat(lines, '\n'))
    else
      health.warn('curl 已安装，但无法运行 `curl --version`', { curl_job.stderr })
    end
  else
    health.error('未找到 curl', {
      'vim.net.request() 正常工作所必需。',
      '请用你的包管理器安装 curl。',
    })
  end
end

local function detect_terminal()
  local e = vim.env
  if e.TERM_PROGRAM then
    local v = e.TERM_PROGRAM_VERSION --- @type string?
    return e.TERM_PROGRAM_VERSION and (e.TERM_PROGRAM .. ' ' .. v) or e.TERM_PROGRAM
  end

  local map = {
    KITTY_WINDOW_ID = 'kitty',
    ALACRITTY_SOCKET = 'alacritty',
    ALACRITTY_LOG = 'alacritty',
    WEZTERM_EXECUTABLE = 'wezterm',
    KONSOLE_VERSION = function()
      return 'konsole ' .. e.KONSOLE_VERSION
    end,
    VTE_VERSION = function()
      return 'vte ' .. e.VTE_VERSION
    end,
  }

  for key, val in pairs(map) do
    local env = e[key] --- @type string?
    if env then
      return type(val) == 'function' and val() or val
    end
  end

  return '未知'
end

---@param nvim_version string
local function check_stable_version(nvim_version)
  local result = vim
    .system(
      { 'git', 'ls-remote', '--tags', 'https://github.com/neovim/neovim' },
      { text = true, timeout = 5000 }
    )
    :wait()
  if result.code ~= 0 or not result.stdout or result.stdout == '' then
    return
  end
  local stable_sha = assert(
    result.stdout:match('(%x+)%s+refs/tags/stable%^{}')
      or result.stdout:match('(%x+)%s+refs/tags/stable\n')
  )
  local latest_version =
    assert(result.stdout:match(stable_sha .. '%s+refs/tags/v?(%d+%.%d+%.%d+)%^{}'))
  local current_version = assert(nvim_version:match('v?(%d+%.%d+%.%d+)'))
  local current = vim.version.parse(current_version)
  local latest = vim.version.parse(latest_version)
  if current and latest and vim.version.lt(current, latest) then
    vim.health.warn(('Nvim %s is available (current: %s)'):format(latest_version, current_version))
  else
    vim.health.ok(('已是最新 (%s)'):format(current_version))
  end
end

---@param commit string
local function check_head_hash(commit)
  local result = vim
    .system(
      { 'git', 'ls-remote', 'https://github.com/neovim/neovim', 'HEAD', 'refs/tags/nightly' },
      { text = true, timeout = 5000 }
    )
    :wait()
  if result.code ~= 0 or not result.stdout or result.stdout == '' then
    return
  end

  local refs = {} ---@type table<string, string>
  for line in result.stdout:gmatch('[^\n]+') do
    local sha, ref = line:match('^(%x+)%s+(%S+)$')
    if sha and ref then
      refs[ref] = sha
    end
  end

  local head_sha = assert(refs['HEAD'])
  local nightly_sha = refs['refs/tags/nightly']

  if vim.startswith(head_sha, commit) then
    vim.health.ok('已是最新 (HEAD)')
  elseif nightly_sha and vim.startswith(nightly_sha, commit) then
    vim.health.ok('已是最新 (nightly)')
  else
    vim.health.warn(
      ('Build is outdated. Local: %s, HEAD: %s%s'):format(
        commit,
        head_sha:sub(1, 12),
        nightly_sha and ('，Nightly： ' .. nightly_sha:sub(1, 12)) or ''
      )
    )
  end
end

local function check_sysinfo()
  vim.health.start('System Info')

  -- Use :version because `vim.version().build` returns "Homebrew" for brew installs.
  local version_out = vim.api.nvim_exec2('version', { output = true }).output
  local nvim_version = version_out:match('NVIM (v[^\n]+)') or '未知'
  local commit --[[@type string]] = (version_out:match('%+g(%x+)') or ''):sub(1, 12)

  if vim.fn.executable('git') ~= 1 then
    vim.health.warn('无法检查更新：未找到 git')
  elseif vim.trim(commit) ~= '' then
    check_head_hash(commit)
  else
    check_stable_version(nvim_version)
  end

  local os_info = vim.uv.os_uname()
  local os_string = os_info.sysname .. ' ' .. os_info.release
  local terminal = detect_terminal()
  local term_env = vim.env.TERM or '未知'

  vim.health.info(('Nvim version: `%s` %s'):format(nvim_version, commit))
  vim.health.info('操作系统： ' .. os_string)
  vim.health.info('终端： ' .. terminal)
  vim.health.info('$TERM： ' .. term_env)

  local body = vim.text.indent(
    0,
    string.format(
      [[
    ## Problem

    Describe the problem (concisely).

    ## Steps to reproduce

    ```
    nvim --clean
    ```

    ## Expected behavior

    ## System info

    - Nvim version (nvim -v): `%s` neovim/neovim@%s
    - Vim (not Nvim) behaves the same?: ?
    - Operating system/version: %s
    - Terminal name/version: %s
    - $TERM environment variable: `%s`
    - Installation: ?

]],
      nvim_version,
      commit,
      os_string,
      terminal,
      term_env
    )
  )

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'checkhealth',
    once = true,
    callback = function(ev)
      local buf = ev.buf
      local win = vim.fn.bufwinid(buf)
      if win == -1 then
        return
      end
      local encoded_body = vim.uri_encode(body) --- @type string
      local issue_url = 'https://github.com/neovim/neovim/issues/new?type=Bug&body=' .. encoded_body

      _G.nvim_health_bugreport_open = function()
        vim.ui.open(issue_url)
      end
      vim.wo[win].winbar =
        '%#WarningMsg#%@v:lua.nvim_health_bugreport_open@Click to Create Bug Report on GitHub%X%*'

      vim.api.nvim_create_autocmd('BufDelete', {
        buf = buf,
        once = true,
        command = 'lua _G.nvim_health_bugreport_open = nil',
      })
    end,
  })
end

function M.check()
  check_sysinfo()
  check_config()
  check_runtime()
  check_performance()
  check_rplugin_manifest()
  check_terminal()
  check_tmux()
  check_external_tools()
end

return M

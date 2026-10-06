local health = vim.health
local iswin = vim.fn.has('win32') == 1

local M = {}

local function cmd_ok(cmd)
  local result = vim.system(cmd, { text = true }):wait()
  return result.code == 0, result.stdout
end

local function cli_version(cmd)
  local ok, out = cmd_ok(cmd)
  return ok, vim.version.parse(out, { strict = false })
end

-- Attempts to construct a shell command from an args list.
-- Only for display, to help users debug a failed command.
--- @param cmd string|string[]
local function shellify(cmd)
  if type(cmd) ~= 'table' then
    return cmd
  end
  local escaped = {} --- @type string[]
  for i, v in ipairs(cmd) do
    escaped[i] = v:match('[^A-Za-z_/.-]') and vim.fn.shellescape(v) or v
  end
  return table.concat(escaped, ' ')
end

-- Handler for s:system() function.
--- @param self {output: string, stderr: string, add_stderr_to_output: boolean}
local function system_handler(self, _, data, event)
  if event == 'stderr' then
    if self.add_stderr_to_output then
      self.output = self.output .. table.concat(data, '')
    else
      self.stderr = self.stderr .. table.concat(data, '')
    end
  elseif event == 'stdout' then
    self.output = self.output .. table.concat(data, '')
  end
end

--- @param cmd string|string[] List of command arguments to execute
--- @param args? table Optional arguments:
---                   - stdin (string): Data to write to the job's stdin
---                   - stderr (boolean): Append stderr to stdout
---                   - ignore_error (boolean): If true, ignore error output
---                   - timeout (number): Number of seconds to wait before timing out (default 30)
local function system(cmd, args)
  args = args or {}
  local stdin = args.stdin or ''
  local stderr = args.stderr or false
  local ignore_error = args.ignore_error or false

  local shell_error_code = 0
  local opts = {
    add_stderr_to_output = stderr,
    output = '',
    stderr = '',
    on_stdout = system_handler,
    on_stderr = system_handler,
    on_exit = function(_, data)
      shell_error_code = data
    end,
  }
  local jobid = vim.fn.jobstart(cmd, opts)

  if jobid < 1 then
    local message =
      string.format('Command error (job=%d): %s (in %s)', jobid, shellify(cmd), vim.uv.cwd())
    error(message)
    return opts.output, 1
  end

  if stdin:find('^%s$') then
    vim.fn.chansend(jobid, stdin)
  end

  local res = vim.fn.jobwait({ jobid }, vim.F.if_nil(args.timeout, 30) * 1000)
  if res[1] == -1 then
    error('命令超时： ' .. shellify(cmd))
    vim.fn.jobstop(jobid)
  elseif shell_error_code ~= 0 and not ignore_error then
    local emsg = string.format(
      'Command error (job=%d, exit code %d): %s (in %s)',
      jobid,
      shell_error_code,
      shellify(cmd),
      vim.uv.cwd()
    )
    if opts.output:find('%S') then
      emsg = string.format('%s\noutput: %s', emsg, opts.output)
    end
    if opts.stderr:find('%S') then
      emsg = string.format('%s\nstderr: %s', emsg, opts.stderr)
    end
    error(emsg)
  end

  return vim.trim(vim.fn.system(cmd)), shell_error_code
end

---@param provider string
local function provider_disabled(provider)
  local loaded_var = 'loaded_' .. provider .. '_provider'
  local v = vim.g[loaded_var]
  if v == 0 then
    health.info('已禁用（' .. loaded_var .. '=' .. v .. '）。')
    return true
  end
  return false
end

--- Checks the hygiene of a `g:loaded_xx_provider` variable.
local function check_loaded_var(var)
  if vim.g[var] == 1 then
    health.error(('`g:%s=1` may have been set by mistake.'):format(var), {
      ('Remove `vim.g.%s=1` from your config.'):format(var),
      '要禁用该 provider，请将其设为 0，而不是 1。',
      '如果你想启用 provider 但跳过自动检测，请设置相应的 `g:…_host_prog` 变量。参见 :help provider',
    })
  end
end

local function clipboard()
  health.start('Clipboard (optional)')

  check_loaded_var('loaded_clipboard_provider')

  if
    os.getenv('TMUX')
    and vim.fn.executable('tmux') == 1
    and vim.fn.executable('pbpaste') == 1
    and not cmd_ok({ 'pbpaste' })
  then
    local _, tmux_version = cli_version({ 'tmux', '-V' })
    local advice = {
      '请安装 tmux 2.6+。  https://superuser.com/q/231130',
      '或配合 reattach-to-user-namespace 一起使用 tmux。  https://superuser.com/a/413233',
    }
    health.error('pbcopy 在此 tmux 版本下无法工作： ' .. tostring(tmux_version), advice)
  end

  local clipboard_tool = vim.fn['provider#clipboard#Executable']() ---@type string
  if vim.g.clipboard ~= nil and clipboard_tool == '' then
    local error_message = vim.fn['provider#clipboard#Error']() ---@type string
    health.error(
      error_message,
      "请参考 :help g:clipboard 中的示例作为模板，或者完全不设置 g:clipboard。"
    )
  elseif clipboard_tool:find('^%s*$') then
    health.warn(
      '未找到剪贴板工具。剪贴板寄存器（`"+` 和 `"*`）将无法工作。',
      ':help clipboard'
    )
  else
    health.ok('找到剪贴板工具： ' .. clipboard_tool)
  end
end

local function node()
  health.start('Node.js provider (optional)')

  check_loaded_var('loaded_node_provider')

  if provider_disabled('node') then
    return
  end

  if
    vim.fn.executable('node') == 0
    or (
      vim.fn.executable('npm') == 0
      and vim.fn.executable('yarn') == 0
      and vim.fn.executable('pnpm') == 0
    )
  then
    health.warn(
      '`node` 和 `npm`（或 `yarn`、`pnpm`）必须在 $PATH 中。',
      '请安装 Node.js 并确认 `node` 和 `npm`（或 `yarn`、`pnpm`）命令可正常使用。'
    )
    return
  end

  local ok, node_v = cli_version({ 'node', '-v' })
  health.info('Node.js： ' .. tostring(node_v))
  if not ok or vim.version.lt(node_v, '6.0.0') then
    health.warn('Nvim 的 node.js host 不支持 Node ' .. node_v)
    -- Skip further checks, they are nonsense if nodejs is too old.
    return
  end
  if vim.fn['provider#node#can_inspect']() == 0 then
    health.warn(
      '此系统上的 node.js 不支持 --inspect-brk，因此 $NVIM_NODE_HOST_DEBUG 会被忽略。'
    )
  end

  local node_detect_table = vim.fn['provider#node#Detect']() ---@type string[]
  local host = node_detect_table[1]
  if host:find('^%s*$') then
    health.warn('缺少 "neovim" npm（或 yarn、pnpm）包。', {
      '在 shell 中运行：npm install -g neovim',
      '在 shell 中运行（如果你使用 yarn）：yarn global add neovim',
      '在 shell 中运行（如果你使用 pnpm）：pnpm install -g neovim',
      '你可以在 init.vim 中添加 `let g:loaded_node_provider = 0` 来禁用此 provider（以及该警告）',
    })
    return
  end
  health.info('Nvim node.js host： ' .. host)

  -- only npm/pnpm query the registry here: `yarn info` errors outside a
  -- project on yarn 2+ (#20924), and bun isn't used for this check.
  local manager --- @type string?
  if vim.fn.executable('npm') == 1 then
    manager = 'npm'
  elseif vim.fn.executable('pnpm') == 1 then
    manager = 'pnpm'
  end

  if not manager then
    health.info('跳过 "neovim" 包的最新版本检查：npm 或 pnpm 不在 $PATH 中。')
    return
  end

  local latest_npm_cmd = { manager, 'info', 'neovim', '--json' }
  local latest_npm
  ok, latest_npm = cmd_ok(latest_npm_cmd)
  if not ok or latest_npm:find('^%s$') then
    health.error(
      '运行失败： ' .. shellify(latest_npm_cmd),
      { "请确认网络连接正常。", '你是否在防火墙或代理之后？' }
    )
    return
  end

  local pcall_ok, pkg_data = pcall(vim.json.decode, latest_npm)
  if not pcall_ok then
    return 'error: ' .. latest_npm
  end
  local latest_npm_subtable = pkg_data['dist-tags'] or {}
  latest_npm = latest_npm_subtable['latest'] or 'unable to parse'

  local current_npm_cmd = { 'node', host, '--version' }
  local current_npm
  ok, current_npm = cmd_ok(current_npm_cmd)
  if not ok then
    health.error(
      '运行失败： ' .. shellify(current_npm_cmd),
      { '报告此问题时请附上以下命令的输出： ', shellify(current_npm_cmd) }
    )
    return
  end

  if latest_npm ~= 'unable to parse' and vim.version.lt(current_npm, latest_npm) then
    local message = '"neovim" 包已过期。已安装： '
      .. current_npm:gsub('%\n$', '')
      .. '，最新： '
      .. latest_npm:gsub('%\n$', '')

    health.warn(message, {
      '在 shell 中运行：npm install -g neovim',
      '在 shell 中运行（如果你使用 yarn）：yarn global add neovim',
      '在 shell 中运行（如果你使用 pnpm）：pnpm install -g neovim',
    })
  else
    health.ok('已安装最新的 "neovim" npm/yarn/pnpm 包： ' .. current_npm)
  end
end

local function perl()
  health.start('Perl provider (optional)')

  check_loaded_var('loaded_perl_provider')

  if provider_disabled('perl') then
    return
  end

  local perl_exec, perl_warnings = vim.provider.perl.detect()

  if not perl_exec then
    health.warn(assert(perl_warnings), {
      '更多信息请参见 :help provider-perl。',
      '你可以在 init.vim 中添加 `let g:loaded_perl_provider = 0` 来禁用此 provider（以及该警告）',
    })
    health.warn('未找到可用的 perl 可执行文件')
    return
  end

  health.info('perl 可执行文件： ' .. perl_exec)

  -- we cannot use cpanm that is on the path, as it may not be for the perl
  -- set with g:perl_host_prog
  local ok = cmd_ok({ perl_exec, '-W', '-MApp::cpanminus', '-e', '' })
  if not ok then
    return { perl_exec, '"App::cpanminus" 模块未安装' }
  end

  local latest_cpan_cmd = {
    perl_exec,
    '-MApp::cpanminus::fatscript',
    '-e',
    'my $app = App::cpanminus::script->new; $app->parse_options ("--info", "-q", "Neovim::Ext"); exit $app->doit',
  }
  local latest_cpan
  ok, latest_cpan = cmd_ok(latest_cpan_cmd)
  if not ok or latest_cpan:find('^%s*$') then
    health.error(
      '运行失败： ' .. shellify(latest_cpan_cmd),
      { "请确认网络连接正常。", '你是否在防火墙或代理之后？' }
    )
    return
  elseif latest_cpan[1] == '!' then
    local cpanm_errs = vim.split(latest_cpan, '!')
    if cpanm_errs[1]:find("Can't write to ") then
      local advice = {} ---@type string[]
      for i = 2, #cpanm_errs do
        advice[#advice + 1] = cpanm_errs[i]
      end

      health.warn(cpanm_errs[1], advice)
      -- Last line is the package info
      latest_cpan = cpanm_errs[#cpanm_errs]
    else
      health.error('命令返回未知警告： ' .. latest_cpan_cmd, cpanm_errs)
      return
    end
  end
  latest_cpan = tostring(vim.fn.matchstr(latest_cpan, [[\(\.\?\d\)\+]]))
  if latest_cpan:find('^%s*$') then
    health.error('无法从 cpanm 输出解析版本号： ' .. latest_cpan)
    return
  end

  local current_cpan_cmd = { perl_exec, '-W', '-MNeovim::Ext', '-e', 'print $Neovim::Ext::VERSION' }
  local current_cpan
  ok, current_cpan = cmd_ok(current_cpan_cmd)
  if not ok then
    health.error(
      '运行失败： ' .. shellify(current_cpan_cmd),
      { '报告此问题时请附上以下命令的输出： ', shellify(current_cpan_cmd) }
    )
    return
  end

  if vim.version.lt(current_cpan, latest_cpan) then
    local message = '"Neovim::Ext" 模块已过期。已安装： '
      .. current_cpan
      .. '，最新： '
      .. latest_cpan
    health.warn(message, '在 shell 中运行：cpanm -n Neovim::Ext')
  else
    health.ok('已安装最新的 "Neovim::Ext" cpan 模块： ' .. current_cpan)
  end
end

local function is(path, ty)
  if not path then
    return false
  end
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return false
  end
  return stat.type == ty
end

-- Resolves Python executable path by invoking and checking `sys.executable`.
local function python_exepath(invocation)
  if invocation == '' or invocation == nil then
    return nil
  end
  local p = vim.system({ invocation, '-c', 'import sys; sys.stdout.write(sys.executable)' }):wait()
  if p.code ~= 0 then
    health.warn(p.stderr)
    return nil
  end
  return vim.fs.normalize(vim.trim(p.stdout))
end

--- Check if pyenv is available and a valid pyenv root can be found, then return
--- their respective paths. If either of those is invalid, return two empty
--- strings, effectively ignoring pyenv.
---
--- @return [string, string]
local function check_for_pyenv()
  local pyenv_path = vim.fn.resolve(vim.fn.exepath('pyenv'))

  if pyenv_path == '' then
    return { '', '' }
  end

  health.info('pyenv：路径： ' .. pyenv_path)

  local pyenv_root = vim.fn.resolve(os.getenv('PYENV_ROOT') or '')

  if pyenv_root == '' then
    local p = vim.system({ pyenv_path, 'root' }):wait()
    if p.code ~= 0 then
      local message = string.format(
        'pyenv: Failed to infer the root of pyenv by running `%s root` : %s. Ignoring pyenv for all following checks.',
        pyenv_path,
        p.stderr
      )
      health.warn(message)
      return { '', '' }
    end
    pyenv_root = vim.trim(p.stdout)
    health.info('pyenv：未设置 $PYENV_ROOT，从 `pyenv root` 推断。')
  end

  if not is(pyenv_root, 'directory') then
    local message = string.format(
      'pyenv: Root does not exist: %s. Ignoring pyenv for all following checks.',
      pyenv_root
    )
    health.warn(message)
    return { '', '' }
  end

  health.info('pyenv：根目录： ' .. pyenv_root)

  return { pyenv_path, pyenv_root }
end

-- Check the Python interpreter's usability.
local function check_bin(bin)
  if not is(bin, 'file') and (not iswin or not is(bin .. '.exe', 'file')) then
    health.error('"' .. bin .. '" 未找到。')
    return false
  elseif vim.fn.executable(bin) == 0 then
    health.error('"' .. bin .. '" 不可执行。')
    return false
  end
  return true
end

--- Fetch the contents of a URL.
---
--- @param url string
local function download(url)
  local has_curl = vim.fn.executable('curl') == 1
  if has_curl then
    local ok, out = cmd_ok({ 'curl', '-V' })
    if ok and out:find('Protocols:.*https') then
      local content, rc = system({ 'curl', '-sL', url }, { stderr = true, ignore_error = true })
      if rc ~= 0 then
        return 'curl 出错： ' .. url .. ': ' .. rc
      else
        return content
      end
    end
  elseif vim.fn.executable('python') == 1 then
    local script = ([[
try:
    from urllib.request import urlopen
except ImportError:
    from urllib2 import urlopen

response = urlopen('%s')
print(response.read(）。decode('utf8'))
]]):format(url)
    local out, rc = system({ 'python', '-c', script })
    if out == '' and rc ~= 0 then
      return 'python urllib.request 错误： ' .. rc
    else
      return out
    end
  end

  local message = '缺少 `curl` '

  if has_curl then
    message = message .. '（支持 HTTPS） '
  end
  message = message .. '和 `python`，无法发起 Web 请求'

  return message
end

--- Get the latest Nvim Python client (pynvim) version from PyPI.
local function latest_pypi_version()
  local pypi_version = 'unable to get pypi response'
  local pypi_response = download('https://pypi.org/pypi/pynvim/json')
  if pypi_response ~= '' then
    local pcall_ok, output = pcall(vim.fn.json_decode, pypi_response)
    if not pcall_ok then
      return 'error: ' .. pypi_response
    end

    local pypi_data = output
    local pypi_element = pypi_data['info'] or {}
    pypi_version = pypi_element['version'] or 'unable to parse'
  end
  return pypi_version
end

--- @param s string
local function is_bad_response(s)
  local lower = s:lower()
  return vim.startswith(lower, 'unable')
    or vim.startswith(lower, 'error')
    or vim.startswith(lower, 'outdated')
end

--- Get version information using the specified interpreter.  The interpreter is
--- used directly in case breaking changes were introduced since the last time
--- Nvim's Python client was updated.
---
--- @param python string
---
--- Returns: {
---     {python executable version},
---     {current nvim version},
---     {current pypi nvim status},
---     {installed version status}
--- }
local function version_info(python)
  local pypi_version = latest_pypi_version()

  local python_version, rc = system({
    python,
    '-c',
    'import sys; print(".".join(str(x) for x in sys.version_info[:3]))',
  })

  if rc ~= 0 or python_version == '' then
    python_version = 'unable to parse ' .. python .. ' response'
  end

  local nvim_path
  nvim_path, rc = system({
    python,
    '-c',
    'import sys; sys.path = [p for p in sys.path if p != ""]; import neovim; print(neovim.__file__)',
  })
  if rc ~= 0 or nvim_path == '' then
    return { python_version, 'unable to load neovim Python module', pypi_version, nvim_path }
  end

  -- Assuming that multiple versions of a package are installed as
  -- `<semver>/<metapath>`, sort them on semantic version in descending order.
  local function compare(metapath1, metapath2)
    local dir1 = vim.fs.basename(vim.fs.dirname(vim.fs.abspath(metapath1)))
    local dir2 = vim.fs.basename(vim.fs.dirname(vim.fs.abspath(metapath2)))
    return vim.version.cmp(dir1, dir2)
  end

  -- Try to get neovim.VERSION (added in 0.1.11dev）。
  local nvim_version
  nvim_version, rc = system({
    python,
    '-c',
    'from neovim import VERSION as v; print("{}.{}.{}{}".format(v.major, v.minor, v.patch, v.prerelease))',
  }, { stderr = true, ignore_error = true })
  if rc ~= 0 or nvim_version == '' then
    nvim_version = 'unable to find pynvim module version'
    local base = vim.fs.basename(nvim_path)
    local metas = vim.fn.glob(base .. '-*/METADATA', true, true)
    vim.list_extend(metas, vim.fn.glob(base .. '-*/PKG-INFO', true, true))
    vim.list_extend(metas, vim.fn.glob(base .. '.egg-info/PKG-INFO', true, true))
    metas = table.sort(metas, compare)

    if metas and next(metas) ~= nil then
      for line in io.lines(metas[1]) do
        --- @cast line string
        local version = line:match('^Version: (%S+)')
        if version then
          nvim_version = version
          break
        end
      end
    end
  end

  -- vim.fs.relpath does not prepend '~/' while fnamemodify does
  local nvim_path_base = vim.fn.fnamemodify(nvim_path, [[:~:h]])
  local version_status = '未知； ' .. nvim_path_base
  if not is_bad_response(nvim_version) and not is_bad_response(pypi_version) then
    if vim.version.lt(nvim_version, pypi_version) then
      version_status = 'outdated; from ' .. nvim_path_base
    else
      version_status = '已是最新'
    end
  end

  return { python_version, nvim_version, pypi_version, version_status }
end

local function python()
  health.start('Python 3 provider (optional)')

  check_loaded_var('loaded_python3_provider')

  local python_exe = ''
  local virtual_env = os.getenv('VIRTUAL_ENV')
  local venv = virtual_env and vim.fn.resolve(virtual_env) or ''
  local host_prog_var = 'python3_host_prog'
  local python_multiple = {} ---@type string[]

  if provider_disabled('python3') then
    return
  end

  local pyenv_table = check_for_pyenv()
  local pyenv = pyenv_table[1]
  local pyenv_root = pyenv_table[2]

  if vim.g[host_prog_var] then
    local message = string.format('Using: g:%s = "%s"', host_prog_var, vim.g[host_prog_var])
    health.info(message)
  end

  local pyname, pythonx_warnings = vim.provider.python.detect_by_module('neovim')

  if not pyname then
    health.warn(
      '未找到能够 `import neovim` 的 Python 可执行文件。'
        .. '将使用第一个可用的可执行文件进行诊断。'
    )
  elseif vim.g[host_prog_var] then
    python_exe = pyname
  end

  -- No Python executable could `import neovim`, or host_prog_var was used.
  if pythonx_warnings then
    health.warn(pythonx_warnings, {
      '更多信息请参见 :help provider-python。',
      '你可以在 init.vim 中添加 `let g:loaded_python3_provider = 0` 来禁用此 provider（以及该警告）',
    })
  elseif pyname and pyname ~= '' and python_exe == '' then
    if not vim.g[host_prog_var] then
      local message = string.format(
        '`g:%s` is not set. Searching for %s in the environment.',
        host_prog_var,
        pyname
      )
      health.info(message)
    end

    if pyenv ~= '' then
      python_exe = system({ pyenv, 'which', pyname }, { stderr = true })
      if python_exe == '' then
        health.warn('pyenv 找不到 ' .. pyname .. '.')
      end
    end

    if python_exe == '' then
      python_exe = vim.fn.exepath(pyname)

      if os.getenv('PATH') then
        local path_sep = iswin and ';' or ':'
        local paths = vim.split(os.getenv('PATH') or '', path_sep)

        for _, path in ipairs(paths) do
          local path_bin = vim.fs.normalize(path .. '/' .. pyname)
          if
            path_bin ~= vim.fs.normalize(python_exe)
            and vim.tbl_contains(python_multiple, path_bin)
            and vim.fn.executable(path_bin) == 1
          then
            python_multiple[#python_multiple + 1] = path_bin
          end
        end

        if vim.tbl_count(python_multiple) > 0 then
          -- This is worth noting since the user may install something
          -- that changes $PATH, like homebrew.
          local message = string.format(
            'Multiple %s executables found. Set `g:%s` to avoid surprises.',
            pyname,
            host_prog_var
          )
          health.info(message)
        end

        if python_exe:find('shims') then
          local message = string.format('`%s` appears to be a pyenv shim.', python_exe)
          local advice = string.format(
            '`pyenv` is not in $PATH, your pyenv installation is broken. Set `g:%s` to avoid surprises.',
            host_prog_var
          )
          health.warn(message, advice)
        end
      end
    end
  end

  if python_exe ~= '' and not vim.g[host_prog_var] then
    if
      venv == ''
      and pyenv ~= ''
      and pyenv_root ~= ''
      and vim.startswith(vim.fn.resolve(python_exe), pyenv_root .. '/')
    then
      local advice = string.format(
        'Create a virtualenv specifically for Nvim using pyenv, and set `g:%s`.  This will avoid the need to install the pynvim module in each version/virtualenv.',
        host_prog_var
      )
      health.warn('pyenv 的配置不是最优的。', advice)
    elseif venv ~= '' then
      local venv_root = pyenv_root ~= '' and pyenv_root or vim.fs.dirname(venv)

      if vim.startswith(vim.fn.resolve(python_exe), venv_root .. '/') then
        local advice = string.format(
          'Create a virtualenv specifically for Nvim and use `g:%s`.  This will avoid the need to install the pynvim module in each virtualenv.',
          host_prog_var
        )
        health.warn('你的 virtualenv 配置不是最优的。', advice)
      end
    end
  end

  if pyname and python_exe == '' and pyname ~= '' then
    -- An error message should have already printed.
    health.error('`' .. pyname .. '` 未找到。')
  elseif python_exe ~= '' and not check_bin(python_exe) then
    python_exe = ''
  end

  -- Diagnostic output
  health.info('可执行文件： ' .. (python_exe == '' and '未找到' or python_exe))
  if vim.tbl_count(python_multiple) > 0 then
    for _, path_bin in ipairs(python_multiple) do
      health.info('其他 python 可执行文件： ' .. path_bin)
    end
  end

  if python_exe == '' then
    -- No Python executable can import 'neovim'. Check if any Python executable
    -- can import 'pynvim'. If so, that Python failed to import 'neovim' as
    -- well, which is most probably due to a failed pip upgrade:
    -- https://github.com/neovim/neovim/wiki/Following-HEAD#20181118
    local pynvim_exe = vim.provider.python.detect_by_module('pynvim')
    if pynvim_exe then
      local message = '检测到 pip 升级失败：该 Python 可执行文件能导入 "pynvim" 但无法导入 "neovim"： '
        .. pynvim_exe
      local advice = {
        '请用该 Python 版本卸载任何 "pynvim" 或 "neovim"，例如：',
        pynvim_exe .. ' -m pip uninstall pynvim neovim',
        '然后参见 :help provider-python 了解 "pynvim" 的安装步骤。',
      }
      health.error(message, advice)
    end
  else
    local version_info_table = version_info(python_exe)
    local pyversion = version_info_table[1]
    local current = version_info_table[2]
    local latest = version_info_table[3]
    local status = version_info_table[4]

    if not vim.version.range('~3'):has(pyversion) then
      health.warn('意外的 Python 版本。这可能导致令人困惑的错误信息。')
    end

    health.info('Python 版本： ' .. pyversion)

    if is_bad_response(status) then
      health.info('pynvim 版本： ' .. current .. ' (' .. status .. ')')
    else
      health.info('pynvim 版本： ' .. current)
    end

    if is_bad_response(current) then
      health.error(
        'pynvim 未安装。\n错误： ' .. current,
        '参见 :help provider-python 了解 "pynvim" 的安装步骤。'
      )
    end

    if is_bad_response(latest) then
      health.warn('无法联系 PyPI 获取最新版本。')
      health.error('HTTP 请求失败： ' .. latest)
    elseif is_bad_response(status) then
      health.warn('未安装最新的 pynvim： ' .. latest)
    elseif not is_bad_response(current) then
      health.ok('已安装最新的 pynvim。')
    end
  end

  health.start('Python virtualenv')
  if not virtual_env then
    health.ok('没有 $VIRTUAL_ENV')
    return
  end
  local errors = {} ---@type string[]
  -- Keep hints as dict keys in order to discard duplicates.
  local hints = {} ---@type table<string, boolean>
  -- The virtualenv should contain some Python executables, and those
  -- executables should be first both on Nvim's $PATH and the $PATH of
  -- subshells launched from Nvim.
  local bin_dir = iswin and 'Scripts' or 'bin'
  local venv_bins = vim.fn.glob(string.format('%s/%s/python*', virtual_env, bin_dir), true, true)
  --- @param v string
  venv_bins = vim.tbl_filter(function(v)
    -- XXX: Remove irrelevant executables found in bin/.
    return not v:match('python.*%-config') and not v:match('python%-argcomplete')
  end, venv_bins)
  if vim.tbl_count(venv_bins) > 0 then
    for _, venv_bin in pairs(venv_bins) do
      venv_bin = vim.fs.normalize(venv_bin)
      local py_bin_basename = vim.fs.basename(venv_bin)
      local nvim_py_bin = python_exepath(vim.fn.exepath(py_bin_basename))
      if nvim_py_bin then
        local subshell_py_bin = python_exepath(py_bin_basename)
        local bintable = {
          ['nvim'] = {
            ['path'] = nvim_py_bin,
            ['hint'] = '若 virtualenv 在启动 Nvim 之前未被'
              .. '正确激活，就会出现 $PATH 歧义。请关闭 Nvim，激活 virtualenv，'
              .. '确认从命令行调用 Python 时启动的是正确的那个，'
              .. '然后重新启动 Nvim。',
          },
          ['subshell'] = {
            ['path'] = subshell_py_bin,
            ['hint'] = '子 shell 中的 $PATH 歧义通常'
              .. '由你的 shell 配置覆盖先前由 '
              .. 'virtualenv 设置的 $PATH 导致。请阻止它们这样做，或使用这个变通方法： '
              .. 'https://vi.stackexchange.com/a/34996',
          },
        }
        for bintype, bin in pairs(bintable) do
          if vim.fn.resolve(venv_bin) ~= vim.fn.resolve(bin['path']) then
            local type_of_path = bintype == 'subshell' and '$PATH' or '子 shell 中的 $PATH'
            errors[#errors + 1] = type_of_path
              .. ' 产生的 '
              .. py_bin_basename
              .. ' 可执行文件： '
              .. bin['path']
            hints[bin['hint']] = true
          end
        end
      end
    end
  else
    errors[#errors + 1] = '在 virtualenv 的 '
      .. bin_dir
      .. ' 目录中未找到任何 Python 可执行文件。'
  end

  local msg = '$VIRTUAL_ENV 设置为： ' .. virtual_env
  if vim.tbl_count(errors) > 0 then
    if vim.tbl_count(venv_bins) > 0 then
      msg = string.format(
        '%s\n并且 its %s directory contains: %s',
        msg,
        bin_dir,
        table.concat(
          --- @param v string
          vim.tbl_map(function(v)
            return vim.fs.basename(v)
          end, venv_bins),
          ', '
        )
      )
    end
    local conj = '\n但 '
    local msgs = {} --- @type string[]
    for _, err in ipairs(errors) do
      msgs[#msgs + 1] = msg
      msgs[#msgs + 1] = conj
      msgs[#msgs + 1] = err
      msgs[#msgs + 1] = '\n'
      conj = '\n并且 '
    end
    msgs[#msgs + 1] = '\n因此调用 Python 可能导致意外结果。'
    health.warn(table.concat(msgs), vim.tbl_keys(hints))
  else
    health.info(msg)
    health.info(
      'Python 版本： '
        .. system('python -c "import platform, sys; sys.stdout.write(platform.python_version())"')
    )
    health.ok('$VIRTUAL_ENV 提供了 :!python。')
  end
end

local function ruby()
  health.start('Ruby provider (optional)')

  check_loaded_var('loaded_ruby_provider')

  if provider_disabled('ruby') then
    return
  end

  if vim.fn.executable('ruby') == 0 or vim.fn.executable('gem') == 0 then
    health.warn(
      '`ruby` 和 `gem` 必须在 $PATH 中。',
      '请安装 Ruby 并确认 `ruby` 和 `gem` 命令可正常使用。'
    )
    return
  end
  local _, ruby_v = cli_version({ 'ruby', '-v' })
  health.info('Ruby： ' .. tostring(ruby_v))

  local host, _ = vim.provider.ruby.detect()
  if (not host) or host:find('^%s*$') then
    health.warn('未找到 `neovim-ruby-host`。', {
      '运行 `gem install neovim` 以确保已安装 neovim RubyGem。',
      '运行 `gem environment` 以确保 gem bin 目录在 $PATH 中。',
      '如果你使用 rvm/rbenv/chruby，请尝试 "rehashing"。',
      '非标准 gem 安装方式请参见 :help g:ruby_host_prog。',
      '你可以在 init.vim 中添加 `let g:loaded_ruby_provider = 0` 来禁用此 provider（以及该警告）',
    })
    return
  end
  health.info('Host： ' .. host)

  local latest_gem_cmd = { 'gem', 'list', '-ra', '^neovim$' }
  local ok, latest_gem = cmd_ok(latest_gem_cmd)
  if not ok or latest_gem:find('^%s*$') then
    health.error(
      '运行失败： ' .. shellify(latest_gem_cmd),
      { "请确认网络连接正常。", '你是否在防火墙或代理之后？' }
    )
    return
  end
  local gem_split = vim.split(latest_gem, [[neovim (\|, \|)$]])
  latest_gem = gem_split[1] or '未找到'

  local current_gem_cmd = { host, '--version' }
  local current_gem
  ok, current_gem = cmd_ok(current_gem_cmd)
  if not ok then
    health.error(
      '运行失败： ' .. shellify(current_gem_cmd),
      { '报告此问题时请附上以下命令的输出： ', shellify(current_gem_cmd) }
    )
    return
  end

  if vim.version.lt(current_gem, latest_gem) then
    local message = 'Gem "neovim" 已过期。已安装： '
      .. current_gem
      .. '，最新： '
      .. latest_gem
    health.warn(message, '在 shell 中运行：gem update neovim')
  else
    health.ok('已安装最新的 "neovim" gem： ' .. current_gem)
  end
end

function M.check()
  clipboard()
  node()
  perl()
  python()
  ruby()
end

return M

local M = {}

local health = vim.health

local function get_lockfile_path()
  return vim.fs.joinpath(vim.fn.stdpath('config'), 'nvim-pack-lock.json')
end

local function get_plug_dir()
  return vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'core', 'opt')
end

local function git_cmd(cmd, cwd)
  cmd = vim.list_extend({ 'git', '-c', 'gc.auto=0' }, cmd)
  local env = vim.fn.environ() --- @type table<string,string>
  env.GIT_DIR, env.GIT_WORK_TREE = nil, nil
  local sys_opts = { cwd = cwd, text = true, env = env, clear_env = true }
  local out = vim.system(cmd, sys_opts):wait() --- @type vim.SystemCompleted
  if out.code ~= 0 then
    return false, ((out.stderr or ''):gsub('\n+$', ''))
  end
  return true, ((out.stdout or ''):gsub('\n+$', ''))
end

local function check_basics()
  health.start('vim.pack: basics')

  -- Requirements
  if vim.fn.executable('git') == 0 then
    health.warn('需要 `git` 可执行文件。请用你的包管理器安装')
    return false, false
  end

  -- Detect if not used
  local lockfile_path = get_lockfile_path()
  local has_lockfile = vim.fn.filereadable(lockfile_path) == 1
  local plug_dir = get_plug_dir()
  local has_plug_dir = vim.fn.isdirectory(plug_dir) == 1
  if not has_lockfile and not has_plug_dir then
    health.ok('未使用 `vim.pack`')
    return false, false
  end

  -- General info
  local git = vim.fn.exepath('git')
  local _, version = git_cmd({ 'version' }, vim.uv.cwd())
  health.info(('Git: %s (%s)'):format(version:gsub('^git%s*', ''), git))
  health.info('Lockfile： ' .. lockfile_path)
  health.info('插件目录： ' .. plug_dir)

  if has_lockfile and has_plug_dir then
    health.ok('')
  else
    local lockfile_缺失 = has_lockfile and '存在' or '缺失'
    local plug_dir_缺失 = has_plug_dir and '存在' or '缺失'
    local msg = ('Lockfile is %s, plugin directory is %s.'):format(lockfile_缺失, plug_dir_缺失)
      .. ' 重启 Nvim 并运行 `vim.pack.add({})` 来'
      .. (has_lockfile and '从 lockfile 安装插件' or '重新生成 lockfile')
    health.warn(msg)
  end

  return has_lockfile, has_plug_dir
end

local function is_version(x)
  return type(x) == 'string' or (type(x) == 'table' and pcall(x.has, x, '1'))
end

local function failed_git_cmd(plug_name, plug_path)
  local msg = ('Failed Git command inside plugin %s.'):format(vim.inspect(plug_name))
    .. ' 这是意外情况，不应发生。'
    .. (' Manually delete directory %s and reinstall plugin'):format(plug_path)
  health.error(msg)
  return false
end

--- @return boolean Whether a check is successful
local function check_plugin_lock_data(plug_name, lock_data)
  local name_str = vim.inspect(plug_name)
  local error_with_del_advice = function(reason)
    local msg = ('%s %s.'):format(name_str, reason)
      .. (' Delete %s entry (do not create trailing comma) and '):format(name_str)
      .. '重启 Nvim 以重新生成 lockfile 数据'
    health.error(msg)
    return false
  end

  -- Types
  if type(plug_name) ~= 'string' then
    return error_with_del_advice('不是有效的插件名')
  end
  if type(lock_data) ~= 'table' then
    return error_with_del_advice('条目不是有效的类型')
  end
  if type(lock_data.rev) ~= 'string' then
    local reason = '`rev` 条目' .. (lock_data.rev and '不是有效的类型' or '缺失')
    return error_with_del_advice(reason)
  end
  if type(lock_data.src) ~= 'string' then
    local reason = '`src` 条目' .. (lock_data.src and '不是有效的类型' or '缺失')
    return error_with_del_advice(reason)
  end
  if lock_data.version and not is_version(lock_data.version) then
    return error_with_del_advice('`version` 条目不是有效的类型')
  end

  -- Alignment with what is actually 存在 on disk
  local plug_path = vim.fs.joinpath(get_plug_dir(), plug_name)
  if vim.fn.isdirectory(plug_path) ~= 1 then
    health.warn(
      ('Plugin %s is not installed but 存在 in the lockfile.'):format(name_str)
        .. ' 重启 Nvim 并运行 `vim.pack.add({})` 来autoinstall.'
        .. (' To fully delete, run `vim.pack.del({ %s }, { force = true })`'):format(name_str)
    )
    return false
  end

  -- NOTE: `vim.pack` currently only supports Git repos as plugins
  if not git_cmd({ 'rev-parse', '--git-dir' }, plug_path) then
    return true
  end

  local has_head, head = git_cmd({ 'rev-list', '-1', 'HEAD' }, plug_path)
  if not has_head then
    return failed_git_cmd(plug_name, plug_path)
  elseif lock_data.rev ~= head then
    health.error(
      ('Plugin %s is not at expected revision\n'):format(name_str)
        .. ('Expected: %s\nActual:   %s\n'):format(lock_data.rev, head)
        .. '要同步，请重启 Nvim 并运行 '
        .. ('`vim.pack.update({ %s }, { offline = true })`\n'):format(name_str)
        .. '如果没有更新，请删除 `rev` 的 lockfile 条目（不要留下尾随逗号）'
        .. 'and 重启 Nvim 以重新生成 lockfile 数据\n'
        .. '这在使用只读的 `$XDG_CONFIG_HOME` 更新插件后可能发生'
    )
    return false
  end

  local has_origin, origin = git_cmd({ 'remote', 'get-url', 'origin' }, plug_path)
  if not has_origin then
    return failed_git_cmd(plug_name, plug_path)
  elseif lock_data.src ~= origin then
    -- Check if lockfile source relies on "insteadOf" Git config
    local ok, src_resolved = git_cmd({ 'ls-remote', '--get-url', lock_data.src }, plug_path)
    if not (ok and src_resolved == origin) then
      health.error(
        ('Plugin %s has not expected source\n'):format(name_str)
          .. ('Expected: %s\nActual:   %s\n'):format(lock_data.src, origin)
          .. '删除 `src` 的 lockfile 条目（不要留下尾随逗号）并'
          .. '重启 Nvim 以重新生成 lockfile 数据'
      )
      return false
    end
  end

  return true
end

local function check_lockfile()
  health.start('vim.pack: lockfile')

  local can_read, text = pcall(vim.fn.readblob, get_lockfile_path())
  if not can_read then
    health.error('无法读取 lockfile。请删除它并重启 Nvim。')
    return
  end

  local can_parse, data = pcall(vim.json.decode, text)
  if not can_parse then
    health.error(('Could not parse lockfile: %s\nDelete it and restart Nvim'):format(data))
    return
  end

  if type(data.plugins) ~= 'table' then
    health.error('字段 `plugins` 的类型不正确。请删除 lockfile 并重启 Nvim')
    return
  end

  local is_good = true
  --- @cast data { plugins: table<string,table> }
  for plug_name, lock_data in pairs(data.plugins) do
    is_good = check_plugin_lock_data(plug_name, lock_data) and is_good
  end

  if is_good then
    health.ok('')
  end
end

--- @return boolean Whether a check is successful
local function check_installed_plugin(plug_name)
  local name_str = vim.inspect(plug_name)
  local plug_path = vim.fs.joinpath(get_plug_dir(), plug_name)

  if vim.fn.isdirectory(plug_path) ~= 1 then
    health.error(('%s is not a directory. Delete it'):format(plug_name))
    return false
  end

  if not git_cmd({ 'rev-parse', '--git-dir' }, plug_path) then
    health.error(
      ('%s is not a Git repository.'):format(name_str)
        .. ' It was not installed by `vim.pack` and should not be 存在 in the plugin directory.'
        .. ' 如果是手动安装的，请使用专门的 `:h packages`'
    )
    return false
  end

  -- Detached HEAD is a sign that plugin is managed by `vim.pack`
  local has_head_ref, head_ref = git_cmd({ 'rev-parse', '--abbrev-ref', 'HEAD' }, plug_path)
  if not has_head_ref then
    return failed_git_cmd(plug_name, plug_path)
  elseif head_ref ~= 'HEAD' then
    health.warn(
      ('Plugin %s is not at state which is a result of `vim.pack` operation.\n'):format(name_str)
        .. '如果是有意为之，请确保你清楚自己在做什么。\n'
        .. '否则，请重启 Nvim 并运行 '
        .. ('`vim.pack.update({ %s }, { offline = true })`.\n'):format(name_str)
        .. '如果没有更新，说明插件处于正确的版本，将按预期被管理'
    )
    return false
  end

  -- Usage data
  local has_pack_info, info = pcall(vim.pack.get, { plug_name })
  if not has_pack_info then
    health.error('无法获取插件的 `vim.pack` 使用信息： ' .. name_str)
    return false
  end

  if not info[1].active then
    health.info(
      ('Plugin %s is not active.'):format(name_str)
        .. ' 它是懒加载的吗，还是你忘记运行 `vim.pack.del()` 了？'
    )
  end

  return true
end

local function check_plug_dir()
  health.start('vim.pack: plugin directory')

  local is_good = true
  local plug_dir = get_plug_dir()
  for plug_name, _ in vim.fs.dir(plug_dir) do
    is_good = check_installed_plugin(plug_name) and is_good
  end

  if is_good then
    health.ok('')
  end
end

function M.check()
  local has_lockfile, has_plug_dir = check_basics()
  if has_lockfile then
    check_lockfile()
  end
  if has_plug_dir then
    check_plug_dir()
  end
end

return M

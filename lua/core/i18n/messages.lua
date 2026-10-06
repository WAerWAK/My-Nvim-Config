-- =====================================================================
--  系统消息翻译（正则规则）
-- =====================================================================
--  为什么只能用正则：Neovim 本体的 E/W 消息写死在编译期
--  （src/nvim/errors.h 的 197 条 N_("...") 常量 + 各 .c 内联串），
--  且官方 Windows 构建**未链接 libintl**（实测 nvim.exe 里
--  libintl / bindtextdomain / nvim.mo 出现次数均为 0），
--  `_()` 宏被编译成恒等函数 —— 即便把官方 zh_CN.UTF-8.po 编译成 nvim.mo
--  放进 share/locale 也完全无效。所以只能在这里逐条做运行时替换。
--
--  写法要点：
--    · Lua 正则（不是 PCRE）：捕获组引用用 %1 %2，不是 \1
--    · ^ $ 必须写全，绝不能出现能匹配任意文本的笼统规则（会误伤正文）
--    · 按表内顺序取第一条命中即返回，所以具体规则要排在笼统规则前面
--    · vim.notify 的翻译只处理 ≤120 字符的消息，超长的原样透传
--    · 每条规则都要能在 `:h message` 或实测中对应到真实消息，宁缺毋滥
-- =====================================================================

local t = require("core.i18n.words")

return {
  -- ===================== 写入 / 保存 =====================
  { "^written$", t.msg_saved },
  { '^"(.-)"%s+written$', "已写入 %1" },
  { '^"(.-)"%s+(%d+)L,%s+(%d+)B%s+written$', "已写入 %1（%2 行，%3 字节）" },
  { "^E37:%s+No%s+write%s+since%s+last%s+change.*$", "E37: 自上次修改后尚未写入" },
  { "^E45:%s+'readonly'%s+option%s+is%s+set.*$", "E45: 文件为只读，无法写入" },
  { "^E505:%s+File%s+exists.*$", "E505: 文件已存在（加 ! 可覆盖）" },
  { "^E13:%s+File%s+exists.*$", "E13: 文件已存在（加 ! 可覆盖）" },
  { "^E212:%s+Can't%s+open%s+file%s+for%s+writing:%s*(.*)$", "E212: 无法写入文件：%1" },
  { "^E89:%s+No%s+write%s+since%s+last%s+change.*$", "E89: 自上次修改后尚未写入" },
  { "^E162:%s+No%s+write%s+since%s+last%s+change.*$", "E162: 自上次修改后尚未写入" },

  -- ===================== 复制 / 删除 / 修改 =====================
  { "^yanked$", t.msg_copied },
  { "^yanked%s+(%d+)%s+lines?$", "已复制 %1 行" },
  { "^(%d+)%s+lines?%s+yanked$", "已复制 %1 行" },
  { "^(%d+)%s+fewer%s+lines?$", "减少 %1 行" },
  { "^(%d+)%s+lines?%s+less$", "减少 %1 行" },
  { "^(%d+)%s+more%s+lines?$", "还有 %1 行" },
  { "^(%d+)%s+lines?%s+more$", "还有 %1 行" },
  { "^(%d+)%s+lines?%s+changed$", "已修改 %1 行" },
  { "^(%d+)%s+lines?%s+deleted$", "已删除 %1 行" },
  { "^(%d+)%s+lines?%s+indented$", "已缩进 %1 行" },
  { "^(%d+)%s+lines?%s+joined$", "已合并 %1 行" },
  { "^(%d+)%s+lines?%s+>'ed$", "已缩进 %1 行" },
  { "^(%d+)%s+lines?%s+<'ed$", "已反缩进 %1 行" },
  { "^(%d+)%s+lines?%s+filtered$", "已过滤 %1 行" },
  { "^(%d+)%s+lines?%s+moved$", "已移动 %1 行" },
  { "^Delete%s+(%d+)%s+lines?.*$", "已删除 %1 行" },
  { "^Undo%s+of%s+%d+%s+changes.*$", "已撤销" },

  -- ===================== 搜索 =====================
  { "^search%s+wrapped%s+around%s+the%s+end%s+of%s+file$", "搜索已回到文件开头" },
  { "^E486:%s+Pattern%s+not%s+found:%s*(.*)$", "E486: 未找到匹配：%1" },
  { "^E35:%s+No%s+previous%s+substitute%s+regular%s+expression$", "E35: 没有上一次的替换表达式" },
  { "^E384:%s+Search%s+hit%s+BOTTOM%s+of%s+file.*$", "E384: 已到文件结尾（继续搜索请加 /）" },
  { "^E385:%s+Search%s+hit%s+TOP%s+of%s+file.*$", "E385: 已到文件开头（继续搜索请加 /）" },
  { "^E480:%s+No%s+match.*$", "E480: 无匹配项" },
  { "^E479:%s+No%s+match.*$", "E479: 无匹配项" },
  { "^E538:%s+No%s+match.*$", "E538: 无匹配项" },
  { "^E20:%s+Mark%s+not%s+set.*$", "E20: 标记未设置" },
  { "^E28:%s+No%s+such%s+mark.*$", "E28: 没有该标记" },
  { "^E768:%s+.*$", "E768: 搜索相关错误" },
  { "^No%s+match$", "无匹配项" },
  { "^Pattern%s+not%s+found$", "未找到匹配" },

  -- ===================== 替换 =====================
  { "^(%d+)%s+substitutions?%s+on%s+(%d+)%s+lines?$", "%2 行中替换了 %1 处" },
  { "^(%d+)%s+substitutions?$", "替换 %1 处" },
  { "^(%d+)%s+matches?%s+on%s+(%d+)%s+lines?$", "%2 行中有 %1 处匹配" },

  -- ===================== 文件 / 缓冲区状态 =====================
  { '^"(.+)"%s+(%d+)L,%s+(%d+)B$', "%1（%2 行，%3 字节）" },
  { '^"(.+)"%s+%[(%d+)%s+lines?%s+--%s+%d+%]$', "%1（%2 行）" },
  { '^"(.+)"%s+line%s+(%d+)%s+of%s+(%d+)$', "%1：第 %2 / %3 行" },
  { "^E484:%s+Can't%s+open%s+file%s+for%s+reading.*$", "E484: 无法读取文件" },
  { "^E485:%s+Can't%s+read%s+file.*$", "E485: 无法读取文件" },
  { "^E95:%s+Buffer%s+is%s+not%s+loaded$", "E95: 缓冲区未加载" },
  { "^E516:%s+No%s+buffers%s+were%s+deleted$", "E516: 没有缓冲区被删除" },

  -- ===================== 寄存器 / 宏 =====================
  { "^E354:%s+Invalid%s+register%s+name:%s*(.*)$", "E354: 无效的寄存器名：%1" },
  { "^E353:%s+Nothing%s+in%s+register.*$", "E353: 寄存器为空" },
  { "^Recording%s+@([%w%-%*%+])$", "正在录制宏 @%1" },

  -- ===================== 撤销 / 重做 =====================
  { "^E25:%s+Undo%s+already%s+at%s+oldest%s+change.*$", "E25: 已是最早的修改，无法继续撤销" },
  { "^E26:%s+Undo%s+already%s+at%s+newest%s+change.*$", "E26: 已是最新的修改，无法继续重做" },

  -- ===================== 窗口 / 标签页 =====================
  { "^E36:%s+Not%s+enough%s+room.*$", "E36: 窗口空间不足" },
  { "^E445:%s+Last%s+window%s+cannot%s+be%s+closed.*$", "E445: 不能关闭最后一个窗口" },
  { "^E444:%s+Cannot%s+close%s+last%s+window.*$", "E444: 不能关闭最后一个窗口" },

  -- ===================== 缩进 / 折叠 / 其它命令 =====================
  { "^E490:%s+No%s+fold%s+found.*$", "E490: 未找到折叠" },
  { "^E350:%s+No%s+previous%s+file.*$", "E350: 没有上一个文件" },
  { "^E23:%s+Missing%s+item%s+after.*$", "E23: 缺少后续参数" },
  { "^E21:%s+Cannot%s+make%s+changes.*$", "E21: 无法修改（'modifiable' 已关闭）" },
  { "^E29:%s+No%s+selected%s+screen%s+line.*$", "E29: 屏幕上没有选中行" },

  -- ===================== 表达式 / 命令解析 =====================
  { "^E117:%s+Unknown%s+function:%s*(.*)$", "E117: 未知函数：%1" },
  { "^E121:%s+Undefined%s+variable:%s*(.*)$", "E121: 未定义的变量：%1" },
  { "^E15:%s+Invalid%s+expression.*$", "E15: 表达式无效" },
  { "^E492:%s+Not%s+an%s+editor%s+command.*$", "E492: 不是编辑器命令" },
  { "^E464:%s+Ambiguous%s+use%s+of.*$", "E464: 命令缩写有歧义，请补全" },
  { "^E471:%s+Argument%s+required.*$", "E471: 缺少参数" },
  { "^E5108:%s+Lua:%s*(.*)$", "E5108: Lua 错误：%1" },

  -- ===================== 映射 / 缩写 =====================
  { "^E31:%s+No%s+such%s+group.*$", "E31: 没有该映射组" },
  { "^E227:%s+Mapping%s+not%s+found.*$", "E227: 未找到映射" },
  { "^E224:%s+Abbreviation%s+already%s+exists.*$", "E224: 缩写已存在" },

  -- ===================== 交互提示 =====================
  { "^Press%s+ENTER%s+or%s+type%s+a%s+command%s+to%s+continue.*$", "按 ENTER 或输入命令继续" },
  { "^E325:%s+Attention.*$", "E325: 交换文件已存在，请确认" },
  { "^E325:%s+.*$", "E325: 交换文件已存在，请确认" },

  -- =====================================================================
  --  以下规则由脚本自动生成（工具：scripts/gen-msg-rules.py 的上游版本，
  --  源数据：Neovim v0.12.5 官方 src/nvim/errors.h 的 191 条 N_("...") 消息）
  --  用途：覆盖本体编译期错误消息。^...$ 为精确匹配，译文里 %1 %2 引用捕获组。
  --  维护：nvim 升级后重新导出 errors.h 并重新生成即可，不必手改这一段。
  -- =====================================================================
  { "^E470: Command aborted$", "E470: 命令已中止" }, -- E470: Command aborted
  { "^E905: Cannot set this option after startup$", "E905: 启动后无法设置此选项" }, -- E905: Cannot set this option after startup
  { "^E903: Could not spawn API job$", "E903: 无法启动 API 作业" }, -- E903: Could not spawn API job
  { "^E471: Argument required$", "E471: 缺少参数" }, -- E471: Argument required
  { "^E10: \\ should be followed by /, %? or &$", "E10: \\ 后面应跟 /、? 或 &" }, -- E10: \ should be followed by /, ? or &
  { "^E11: Invalid in command%-line window; <CR> executes, CTRL%-C quits$", "E11: 在命令行窗口中无效；<CR> 执行，CTRL-C 退出" }, -- E11: Invalid in command-line window; <CR> executes, CTRL-C quits
  { "^E12: Command not allowed in secure mode in current dir or tag search$", "E12: 安全模式下不允许在当前目录或标签搜索中执行命令" }, -- E12: Command not allowed in secure mode in current dir or tag search
  { "^E158: Invalid buffer name: (.-)$", "E158: 无效的缓冲区名：%1" }, -- E158: Invalid buffer name: %s
  { "^E169: Command too recursive$", "E169: 命令递归过深" }, -- E169: Command too recursive
  { "^E681: Buffer is not loaded$", "E681: 缓冲区未加载" }, -- E681: Buffer is not loaded
  { "^E171: Missing :endif$", "E171: 缺少 :endif" }, -- E171: Missing :endif
  { "^E600: Missing :endtry$", "E600: 缺少 :endtry" }, -- E600: Missing :endtry
  { "^E170: Missing :endwhile$", "E170: 缺少 :endwhile" }, -- E170: Missing :endwhile
  { "^E170: Missing :endfor$", "E170: 缺少 :endfor" }, -- E170: Missing :endfor
  { "^E588: :endwhile without :while$", "E588: :endwhile 没有对应的 :while" }, -- E588: :endwhile without :while
  { "^E588: :endfor without :for$", "E588: :endfor 没有对应的 :for" }, -- E588: :endfor without :for
  { "^E13: File exists %(add ! to override%)$", "E13: 文件已存在（加 ! 可覆盖）" }, -- E13: File exists (add ! to override)
  { "^E472: Command failed$", "E472: 命令执行失败" }, -- E472: Command failed
  { "^E685: Internal error: (.-)$", "E685: 内部错误：%1" }, -- E685: Internal error: %s
  { "^Interrupted$", "已中断" }, -- Interrupted
  { "^E474: Invalid argument$", "E474: 无效的参数" }, -- E474: Invalid argument
  { "^E475: Invalid argument: (.-)$", "E475: 无效的参数：%1" }, -- E475: Invalid argument: %s
  { "^E475: Invalid value for argument (.-)$", "E475: 参数 %1 的值无效" }, -- E475: Invalid value for argument %s
  { "^E475: Invalid value for argument (.-): (.-)$", "E475: 参数 %1 的值无效：%2" }, -- E475: Invalid value for argument %s: %s
  { "^E983: Duplicate argument: (.-)$", "E983: 重复的参数：%1" }, -- E983: Duplicate argument: %s
  { "^E15: Invalid expression: \"(.-)\"$", "E15: 无效的表达式：\"%1\"" }, -- E15: Invalid expression: "%s"
  { "^E16: Invalid range$", "E16: 无效的范围" }, -- E16: Invalid range
  { "^E473: Internal error in regexp$", "E473: 正则表达式内部错误" }, -- E473: Internal error in regexp
  { "^E476: Invalid command$", "E476: 无效的命令" }, -- E476: Invalid command
  { "^E17: \"(.-)\" is a directory$", "E17: \"%1\" 是目录" }, -- E17: "%s" is a directory
  { "^E756: Spell checking is not possible$", "E756: 无法进行拼写检查" }, -- E756: Spell checking is not possible
  { "^E900: Invalid channel id$", "E900: 无效的通道 ID" }, -- E900: Invalid channel id
  { "^E900: Invalid channel id: not a job$", "E900: 无效的通道 ID：不是作业" }, -- E900: Invalid channel id: not a job
  { "^E901: Job table is full$", "E901: 作业表已满" }, -- E901: Job table is full
  { "^E903: Process failed to start: (.-): \"(.-)\"$", "E903: 进程启动失败：%1：\"%2\"" }, -- E903: Process failed to start: %s: "%s"
  { "^E904: channel is not a pty$", "E904: 通道不是 pty" }, -- E904: channel is not a pty
  { "^E905: Couldn't open stdio channel: (.-)$", "E905: 无法打开 stdio 通道：%1" }, -- E905: Couldn't open stdio channel: %s
  { "^E906: invalid stream for channel$", "E906: 通道的流无效" }, -- E906: invalid stream for channel
  { "^E906: invalid stream for rpc channel, use 'rpc'$", "E906: rpc 通道的流无效，请使用 'rpc'" }, -- E906: invalid stream for rpc channel, use 'rpc'
  { "^E364: Library call failed for \"(.-)%(%)\"$", "E364: 调用库函数 \"%1()\" 失败" }, -- E364: Library call failed for "%s()"
  { "^E667: Fsync failed: (.-)$", "E667: Fsync 失败：%1" }, -- E667: Fsync failed: %s
  { "^E739: Cannot create directory (.-): (.-)$", "E739: 无法创建目录 %1：%2" }, -- E739: Cannot create directory %s: %s
  { "^E19: Mark has invalid line number$", "E19: 标记的行号无效" }, -- E19: Mark has invalid line number
  { "^E20: Mark not set$", "E20: 未设置标记" }, -- E20: Mark not set
  { "^E21: Cannot make changes, 'modifiable' is off$", "E21: 无法修改，'modifiable' 已关闭" }, -- E21: Cannot make changes, 'modifiable' is off
  { "^E22: Scripts nested too deep$", "E22: 脚本嵌套层数过深" }, -- E22: Scripts nested too deep
  { "^E23: No alternate file$", "E23: 没有备用文件" }, -- E23: No alternate file
  { "^E24: No such abbreviation$", "E24: 没有该缩写" }, -- E24: No such abbreviation
  { "^E477: No ! allowed$", "E477: 不允许使用 !" }, -- E477: No ! allowed
  { "^E28: No such highlight group name: (.-)$", "E28: 没有该高亮组名：%1" }, -- E28: No such highlight group name: %s
  { "^E29: No inserted text yet$", "E29: 尚未插入文本" }, -- E29: No inserted text yet
  { "^E30: No previous command line$", "E30: 没有上一条命令行" }, -- E30: No previous command line
  { "^E31: No such mapping$", "E31: 没有该映射" }, -- E31: No such mapping
  { "^E349: No identifier under cursor$", "E349: 光标下没有标识符" }, -- E349: No identifier under cursor
  { "^E479: No match$", "E479: 没有匹配项" }, -- E479: No match
  { "^E480: No match: (.-)$", "E480: 没有匹配项：%1" }, -- E480: No match: %s
  { "^E32: No file name$", "E32: 没有文件名" }, -- E32: No file name
  { "^E33: No previous substitute regular expression$", "E33: 没有上一次的替换正则表达式" }, -- E33: No previous substitute regular expression
  { "^E34: No previous command$", "E34: 没有上一条命令" }, -- E34: No previous command
  { "^E35: No previous regular expression$", "E35: 没有上一次的正则表达式" }, -- E35: No previous regular expression
  { "^E481: No range allowed$", "E481: 不允许指定范围" }, -- E481: No range allowed
  { "^E36: Not enough room$", "E36: 空间不足" }, -- E36: Not enough room
  { "^E483: Can't get temp file name$", "E483: 无法获取临时文件名" }, -- E483: Can't get temp file name
  { "^E484: Can't open file (.-)$", "E484: 无法打开文件 %1" }, -- E484: Can't open file %s
  { "^E484: Can't open file (.-): (.-)$", "E484: 无法打开文件 %1：%2" }, -- E484: Can't open file %s: %s
  { "^E485: Can't read file (.-)$", "E485: 无法读取文件 %1" }, -- E485: Can't read file %s
  { "^E38: Null argument$", "E38: 空参数" }, -- E38: Null argument
  { "^E39: Number expected$", "E39: 应为数字" }, -- E39: Number expected
  { "^E40: Can't open errorfile (.-)$", "E40: 无法打开错误文件 %1" }, -- E40: Can't open errorfile %s
  { "^E41: Out of memory!$", "E41: 内存不足！" }, -- E41: Out of memory!
  { "^Pattern not found$", "未找到匹配模式" }, -- Pattern not found
  { "^E486: Pattern not found: (.-)$", "E486: 未找到匹配模式：%1" }, -- E486: Pattern not found: %s
  { "^E487: Argument must be positive$", "E487: 参数必须为正数" }, -- E487: Argument must be positive
  { "^E459: Cannot go back to previous directory$", "E459: 无法返回上一个目录" }, -- E459: Cannot go back to previous directory
  { "^E42: No Errors$", "E42: 没有错误" }, -- E42: No Errors
  { "^E776: No location list$", "E776: 没有位置列表" }, -- E776: No location list
  { "^E43: Damaged match string$", "E43: 匹配字符串已损坏" }, -- E43: Damaged match string
  { "^E44: Corrupted regexp program$", "E44: 正则表达式程序已损坏" }, -- E44: Corrupted regexp program
  { "^E45: 'readonly' option is set %(add ! to override%)$", "E45: 已设置 'readonly' 选项（加 ! 可覆盖）" }, -- E45: 'readonly' option is set (add ! to override)
  { "^E734: Wrong variable type for (.-)=$", "E734: %1= 的变量类型错误" }, -- E734: Wrong variable type for %s=
  { "^E461: Illegal variable name: (.-)$", "E461: 非法的变量名：%1" }, -- E461: Illegal variable name: %s
  { "^E995: Cannot modify existing variable$", "E995: 无法修改已存在的变量" }, -- E995: Cannot modify existing variable
  { "^E46: Cannot change read%-only variable \"(.-)\"$", "E46: 无法修改只读变量 \"%1\"" }, -- E46: Cannot change read-only variable "%.*s"
  { "^E715: Dictionary required$", "E715: 需要字典" }, -- E715: Dictionary required
  { "^E978: Invalid operation for Blob$", "E978: 对 Blob 的操作无效" }, -- E978: Invalid operation for Blob
  { "^E118: Too many arguments for function: (.-)$", "E118: 函数参数过多：%1" }, -- E118: Too many arguments for function: %s
  { "^E119: Not enough arguments for function: (.-)$", "E119: 函数参数不足：%1" }, -- E119: Not enough arguments for function: %s
  { "^E716: Key not present in Dictionary: \"(.-)\"$", "E716: 字典中不存在键：\"%1\"" }, -- E716: Key not present in Dictionary: "%s"
  { "^E716: Key not present in Dictionary: \"(.-)\"$", "E716: 字典中不存在键：\"%1\"" }, -- E716: Key not present in Dictionary: "%.*s"
  { "^E714: List required$", "E714: 需要列表" }, -- E714: List required
  { "^E897: List or Blob required$", "E897: 需要列表或 Blob" }, -- E897: List or Blob required
  { "^E899: Argument of (.-) must be a List or Blob$", "E899: %1 的参数必须是列表或 Blob" }, -- E899: Argument of %s must be a List or Blob
  { "^E712: Argument of (.-) must be a List or Dictionary$", "E712: %1 的参数必须是列表或字典" }, -- E712: Argument of %s must be a List or Dictionary
  { "^E896: Argument of (.-) must be a List, Dictionary or Blob$", "E896: %1 的参数必须是列表、字典或 Blob" }, -- E896: Argument of %s must be a List, Dictionary or Blob
  { "^E47: Error while reading errorfile$", "E47: 读取错误文件时出错" }, -- E47: Error while reading errorfile
  { "^E48: Not allowed in sandbox$", "E48: 沙箱中不允许" }, -- E48: Not allowed in sandbox
  { "^E523: Not allowed here$", "E523: 此处不允许" }, -- E523: Not allowed here
  { "^E565: Not allowed to change text or change window$", "E565: 不允许修改文本或切换窗口" }, -- E565: Not allowed to change text or change window
  { "^E359: Screen mode setting not supported$", "E359: 不支持屏幕模式设置" }, -- E359: Screen mode setting not supported
  { "^E49: Invalid scroll size$", "E49: 无效的滚动大小" }, -- E49: Invalid scroll size
  { "^E91: 'shell' option is empty$", "E91: 'shell' 选项为空" }, -- E91: 'shell' option is empty
  { "^E255: Couldn't read in sign data!$", "E255: 无法读入 sign 数据！" }, -- E255: Couldn't read in sign data!
  { "^E72: Close error on swap file$", "E72: 交换文件关闭出错" }, -- E72: Close error on swap file
  { "^E74: Command too complex$", "E74: 命令过于复杂" }, -- E74: Command too complex
  { "^E75: Name too long$", "E75: 名称过长" }, -- E75: Name too long
  { "^E76: Too many %[$", "E76: [ 过多" }, -- E76: Too many [
  { "^E77: Too many file names$", "E77: 文件名过多" }, -- E77: Too many file names
  { "^E488: Trailing characters$", "E488: 有多余字符" }, -- E488: Trailing characters
  { "^E488: Trailing characters: (.-)$", "E488: 有多余字符：%1" }, -- E488: Trailing characters: %s
  { "^E78: Unknown mark$", "E78: 未知的标记" }, -- E78: Unknown mark
  { "^E79: Cannot expand wildcards$", "E79: 无法展开通配符" }, -- E79: Cannot expand wildcards
  { "^E591: 'winheight' cannot be smaller than 'winminheight'$", "E591: 'winheight' 不能小于 'winminheight'" }, -- E591: 'winheight' cannot be smaller than 'winminheight'
  { "^E592: 'winwidth' cannot be smaller than 'winminwidth'$", "E592: 'winwidth' 不能小于 'winminwidth'" }, -- E592: 'winwidth' cannot be smaller than 'winminwidth'
  { "^E80: Error while writing$", "E80: 写入时出错" }, -- E80: Error while writing
  { "^E939: Positive count required$", "E939: 需要正整数计数" }, -- E939: Positive count required
  { "^E81: Using <SID> not in a script context$", "E81: 在非脚本环境中使用了 <SID>" }, -- E81: Using <SID> not in a script context
  { "^E107: Missing parentheses: (.-)$", "E107: 缺少括号：%1" }, -- E107: Missing parentheses: %s
  { "^E749: Empty buffer$", "E749: 空缓冲区" }, -- E749: Empty buffer
  { "^E37: No write since last change$", "E37: 上次修改后未保存" }, -- E37: No write since last change
  { "^E37: No write since last change %(add ! to override%)$", "E37: 上次修改后未保存（加 ! 可覆盖）" }, -- E37: No write since last change (add ! to override)
  { "^E89: No write since last change for buffer (%d+) %(add ! to override%)$", "E89: 缓冲区 %1 上次修改后未保存（加 ! 可覆盖）" }, -- E89: No write since last change for buffer %d (add ! to override)
  { "^E92: Buffer (%d+) not found$", "E92: 找不到缓冲区 %1" }, -- E92: Buffer %d not found
  { "^E117: Unknown function: (.-)$", "E117: 未知的函数：%1" }, -- E117: Unknown function: %s
  { "^E193: (.-) not inside a function$", "E193: %1 不在函数内" }, -- E193: %s not inside a function
  { "^E948: Job still running$", "E948: 作业仍在运行" }, -- E948: Job still running
  { "^E948: Job still running %(add ! to end the job%)$", "E948: 作业仍在运行（加 ! 可结束作业）" }, -- E948: Job still running (add ! to end the job)
  { "^E682: Invalid search pattern or delimiter$", "E682: 无效的搜索模式或分隔符" }, -- E682: Invalid search pattern or delimiter
  { "^E139: File is loaded in another buffer$", "E139: 文件已在另一个缓冲区中加载" }, -- E139: File is loaded in another buffer
  { "^E764: Option '(.-)' is not set$", "E764: 未设置选项 '%1'" }, -- E764: Option '%s' is not set
  { "^E850: Invalid register name$", "E850: 无效的寄存器名" }, -- E850: Invalid register name
  { "^E919: Directory not found in '(.-)': \"(.-)\"$", "E919: 在 '%1' 中找不到目录：\"%2\"" }, -- E919: Directory not found in '%s': "%s"
  { "^E952: Autocommand caused recursive behavior$", "E952: 自动命令导致了递归行为" }, -- E952: Autocommand caused recursive behavior
  { "^E328: Menu only exists in another mode$", "E328: 菜单只存在于另一种模式下" }, -- E328: Menu only exists in another mode
  { "^E813: Cannot close autocmd window$", "E813: 无法关闭自动命令窗口" }, -- E813: Cannot close autocmd window
  { "^E686: Argument of (.-) must be a List$", "E686: %1 的参数必须是列表" }, -- E686: Argument of %s must be a List
  { "^E519: Option not supported$", "E519: 不支持该选项" }, -- E519: Option not supported
  { "^E856: Filename too long$", "E856: 文件名过长" }, -- E856: Filename too long
  { "^E806: Using a Float as a String$", "E806: 将浮点数用作字符串" }, -- E806: Using a Float as a String
  { "^E788: Not allowed to edit another buffer now$", "E788: 现在不允许编辑其它缓冲区" }, -- E788: Not allowed to edit another buffer now
  { "^E1023: Using a Number as a Bool: (%d+)$", "E1023: 将数值用作布尔值：%1" }, -- E1023: Using a Number as a Bool: %d
  { "^E1085: Not a callable type: (.-)$", "E1085: 不是可调用类型：%1" }, -- E1085: Not a callable type: %s
  { "^E855: Autocommands caused command to abort$", "E855: 自动命令导致命令中止" }, -- E855: Autocommands caused command to abort
  { "^E5555: API call: (.-)$", "E5555: API 调用：%1" }, -- E5555: API call: %s
  { "^E5560: (.-) must not be called in a fast event context$", "E5560: 不得在快速事件上下文中调用 %1" }, -- E5560: %s must not be called in a fast event context
  { "^E5601: Cannot close window, only floating window would remain$", "E5601: 无法关闭窗口，否则将只剩浮动窗口" }, -- E5601: Cannot close window, only floating window would remain
  { "^E5602: Cannot exchange or rotate float$", "E5602: 无法交换或轮换浮动窗口" }, -- E5602: Cannot exchange or rotate float
  { "^E344: Can't find directory \"(.-)\" in cdpath$", "E344: 在 cdpath 中找不到目录 \"%1\"" }, -- E344: Can't find directory "%s" in cdpath
  { "^E345: Can't find file \"(.-)\" in path$", "E345: 在 path 中找不到文件 \"%1\"" }, -- E345: Can't find file "%s" in path
  { "^E346: No more directory \"(.-)\" found in cdpath$", "E346: cdpath 中找不到更多目录 \"%1\"" }, -- E346: No more directory "%s" found in cdpath
  { "^E347: No more file \"(.-)\" found in path$", "E347: path 中找不到更多文件 \"%1\"" }, -- E347: No more file "%s" found in path
  { "^E741: Value is locked$", "E741: 值已锁定" }, -- E741: Value is locked
  { "^E741: Value is locked: (.-)$", "E741: 值已锁定：%1" }, -- E741: Value is locked: %.*s
  { "^E742: Cannot change value$", "E742: 无法更改值" }, -- E742: Cannot change value
  { "^E742: Cannot change value of (.-)$", "E742: 无法更改 %1 的值" }, -- E742: Cannot change value of %.*s
  { "^E794: Cannot set variable in the sandbox: \"(.-)\"$", "E794: 无法在沙箱中设置变量：\"%1\"" }, -- E794: Cannot set variable in the sandbox: "%.*s"
  { "^E795: Cannot delete variable (.-)$", "E795: 无法删除变量 %1" }, -- E795: Cannot delete variable %.*s
  { "^E957: Invalid window number$", "E957: 无效的窗口编号" }, -- E957: Invalid window number
  { "^E960: Problem creating the internal diff$", "E960: 创建内部 diff 时出现问题" }, -- E960: Problem creating the internal diff
  { "^E1155: Cannot define autocommands for ALL events$", "E1155: 无法为 ALL 事件定义自动命令" }, -- E1155: Cannot define autocommands for ALL events
  { "^E1156: Cannot change the argument list recursively$", "E1156: 无法递归更改参数列表" }, -- E1156: Cannot change the argument list recursively
  { "^E1240: Resulting text too long$", "E1240: 生成的文本过长" }, -- E1240: Resulting text too long
  { "^E1247: Line number out of range$", "E1247: 行号超出范围" }, -- E1247: Line number out of range
  { "^E5248: Invalid character in group name$", "E5248: 组名中有无效字符" }, -- E5248: Invalid character in group name
  { "^E1249: Highlight group name too long$", "E1249: 高亮组名过长" }, -- E1249: Highlight group name too long
  { "^E928: String required$", "E928: 需要字符串" }, -- E928: String required
  { "^E964: Invalid column number: (%d+)$", "E964: 无效的列号：%1" }, -- E964: Invalid column number: %ld
  { "^E966: Invalid line number: (%d+)$", "E966: 无效的行号：%1" }, -- E966: Invalid line number: %ld
  { "^E998: Reduce of an empty (.-) with no initial value$", "E998: 对空的 %1 执行 reduce 且没有初始值" }, -- E998: Reduce of an empty %s with no initial value
  { "^E1278: Stray '}' without a matching '{': (.-)$", "E1278: 有多余的 '}' 没有匹配的 '{'：%1" }, -- E1278: Stray '}' without a matching '{': %s
  { "^E1279: Missing '}': (.-)$", "E1279: 缺少 '}'：%1" }, -- E1279: Missing '}': %s
  { "^E1310: Cannot change menus while listing$", "E1310: 列出菜单时无法更改菜单" }, -- E1310: Cannot change menus while listing
  { "^E1312: Not allowed to change the window layout in this autocmd$", "E1312: 不允许在此自动命令中更改窗口布局" }, -- E1312: Not allowed to change the window layout in this autocmd
  { "^E1510: Value too large: (.-)$", "E1510: 值过大：%1" }, -- E1510: Value too large: %s
  { "^E1510: Value too large: (.-)$", "E1510: 值过大：%1" }, -- E1510: Value too large: %.*s
  { "^E5767: Cannot use :undo! to redo or move to a different undo branch$", "E5767: 无法用 :undo! 重做或切换到其它撤销分支" }, -- E5767: Cannot use :undo! to redo or move to a different undo branch
  { "^E1513: Cannot switch buffer%. 'winfixbuf' is enabled$", "E1513: 无法切换缓冲区。已启用 'winfixbuf'" }, -- E1513: Cannot switch buffer. 'winfixbuf' is enabled
  { "^E1514: 'findfunc' did not return a List type$", "E1514: 'findfunc' 未返回列表类型" }, -- E1514: 'findfunc' did not return a List type
  { "^E1546: Cannot switch to a closing buffer$", "E1546: 无法切换到正在关闭的缓冲区" }, -- E1546: Cannot switch to a closing buffer
  { "^E1549: Cannot have more than (%d+) diff anchors$", "E1549: diff 锚点不能超过 %1 个" }, -- E1549: Cannot have more than %d diff anchors
  { "^E1550: Failed to find all diff anchors$", "E1550: 未能找到所有 diff 锚点" }, -- E1550: Failed to find all diff anchors
  { "^E1562: Diff anchors cannot be used with hidden diff windows$", "E1562: 隐藏的 diff 窗口不能使用 diff 锚点" }, -- E1562: Diff anchors cannot be used with hidden diff windows
  { "^E1572: 'listchars' field \"leadtab\" requires \"tab\" to be specified$", "E1572: 'listchars' 的 \"leadtab\" 字段需要同时指定 \"tab\"" }, -- E1572: 'listchars' field "leadtab" requires "tab" to be specified
  { "^E1577: Invalid format string, only one \"(.-)\" is allowed$", "E1577: 无效的格式字符串，只允许一个 \"%1\"" }, -- E1577: Invalid format string, only one "%s" is allowed
  { "^E5570: Cannot update trust file: (.-)$", "E5570: 无法更新信任文件：%1" }, -- E5570: Cannot update trust file: %s
  { "^E282: Cannot read from \"(.-)\"$", "E282: 无法从 \"%1\" 读取" }, -- E282: Cannot read from "%s"
  { "^E5422: Conflicting configs: \"(.-)\" \"(.-)\"$", "E5422: 配置冲突：\"%1\" \"%2\"" }, -- E5422: Conflicting configs: "%s" "%s"
  { "^E355: Unknown option: (.-)$", "E355: 未知的选项：%1" }, -- E355: Unknown option: %s
  { "^E5201: Restart failed: %+cmd did not quit server: (.-)$", "E5201: 重启失败：+cmd 未能退出服务器：%1" }, -- E5201: Restart failed: +cmd did not quit server: %s
  { "^search hit TOP, continuing at BOTTOM$", "搜索到达顶部，从底部继续" }, -- search hit TOP, continuing at BOTTOM
  { "^search hit BOTTOM, continuing at TOP$", "搜索到达底部，从顶部继续" }, -- search hit BOTTOM, continuing at TOP
}

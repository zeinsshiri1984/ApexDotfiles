-- --- 1. 状态栏增强 (显示当前模式) ---
function Status:header()
	local h = self._tab.current.hovered
	local cwd = self._tab.current.cwd
	
	local env_indicator = ""
	-- 检测环境变量，给予视觉反馈
	if os.getenv("ZELLIJ") then
	  env_indicator = ui.Span(" ZELLIJ "):fg("black"):bg("green")
	elseif os.getenv("SSH_CONNECTION") then
	  env_indicator = ui.Span(" SSH "):fg("black"):bg("red")
	end
  
	return ui.Line {
	  env_indicator,
	  ui.Span(" "),
	  ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue"),
	  ui.Span(" "),
	  ui.Span(cwd.name):fg("yellow"):bold(),
	}
  end
  
  -- --- 2. 功能函数集 ---
  local M = {}
  
  -- 智能进入：目录则进入，文件则打开
  function M.smart_enter()
	local h = cx.active.current.hovered
	if h and h.cha.is_dir then
	  ya.manager_emit("enter", {})
	else
	  ya.manager_emit("open", {})
	end
  end
  
  -- 终极跨平台复制 (WSL/Linux/macOS)
  function M.smart_paste()
	local h = cx.active.current.hovered
	if not h then return end
	
	local url = tostring(h.url)
	
	-- 针对 WSL 的特殊路径转换 (可选，如果需要在 Windows 侧使用)
	-- local wsl_distro = os.getenv("WSL_DISTRO_NAME")
	-- if wsl_distro then
	--     -- wslpath -w 转换路径
	-- end
  
	local safe_path = string.format("%q", url)
	local content = string.format("Copied to clipboard: %s", url)
  
	local uname = io.popen("uname -s"):read("*l")
	
	if uname == "Darwin" then
	  -- macOS
	  os.execute("echo -n " .. safe_path .. " | pbcopy")
	  ya.notify({ title = "System Clipboard", content = content, timeout = 2 })
	  
	elseif uname == "Linux" then
	  -- 检测是否为 WSL (读取内核版本信息是最稳的)
	  local f = io.open("/proc/version", "r")
	  local version_info = f and f:read("*a") or ""
	  if f then f:close() end
  
	  if string.find(version_info:lower(), "microsoft") then
		-- WSL: 管道传给 Windows 的 clip.exe (去除换行符很重要)
		os.execute("echo -n " .. safe_path .. " | clip.exe")
		ya.notify({ title = "WSL Clipboard", content = content, timeout = 2 })
	  else
		-- Native Linux
		if os.getenv("WAYLAND_DISPLAY") then
		  os.execute("echo -n " .. safe_path .. " | wl-copy")
		else
		  os.execute("echo -n " .. safe_path .. " | xclip -selection clipboard")
		end
		ya.notify({ title = "Clipboard", content = content, timeout = 2 })
	  end
	end
  end
  
  return M
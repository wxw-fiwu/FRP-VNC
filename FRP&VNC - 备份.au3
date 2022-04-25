#region ;**** 参数创建于 ACNWrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\WINDOWS\System32\SHELL32.dll
#AutoIt3Wrapper_Outfile=FRP&VNC.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=VNC自动挂载FRP程序
#AutoIt3Wrapper_Res_Description=由WXW编辑制作
#AutoIt3Wrapper_Res_Fileversion=1.0.0.11
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=@WXW
#AutoIt3Wrapper_Res_Language=4100
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#endregion ;**** 参数创建于 ACNWrapper_GUI ****
#include <GUIConstantsEx.au3>
Example()
Opt("GUIOnEventMode",1)
Func Example()
	Local $frp_SAddr, $frp_SPort, $frp_token, $frp_RPort, $VNC_Port
	Local $start, $stop, $apply, $exit, $msg
	
	;判断系统位数
	;Local $xitongwei = FileFindFirstFile("C:\Program Files (x86)");系统x64
	If @CPUArch = "X64" Then;如果搜索到文件夹则运行x64
		Local $HKLM = "HKLM64"
	Else
		Local $HKLM = "HKLM"
	EndIf
	
	;读取FRPC配置
	$frp_SAddr = IniRead("frpc.ini", "common", "server_addr", "")
	$frp_SPort = IniRead("frpc.ini", "common", "server_port", "")
	$frp_token = IniRead("frpc.ini", "common", "token", "")
	$VNC_TPort = IniRead("frpc.ini", "vnc-tcp", "local_port", "")
	$frp_RPort = IniRead("frpc.ini", "vnc-tcp", "remote_port", "")
	$VNC_UPort = IniRead("frpc.ini", "vnc-udp", "local_port", "")
	$frp_RPort = IniRead("frpc.ini", "vnc-udp", "remote_port", "")
	If $VNC_TPort = $VNC_UPort Then;
		Local $VNC_Port = $VNC_TPort
	Else
		Local $VNC_Port = ""
	EndIf
	;GUI对话框
	GUICreate("FRP&VNC-" & @CPUArch & "   www.fiwu.net", 400, 200)
	GUICtrlCreateLabel("FRPS地址：", 10, 7)
	$frp_SAddr = GUICtrlCreateInput($frp_SAddr, 80, 5, 100, 20)
	GUICtrlCreateLabel("FRPS端口：", 10, 37)
	$frp_SPort = GUICtrlCreateInput($frp_SPort, 80, 35, 100, 20)
	GUICtrlCreateLabel("Token", 10, 67)
	$frp_token = GUICtrlCreateInput($frp_token, 80, 65, 100, 20)
	GUICtrlCreateLabel("映射端口：", 10, 97)
	$frp_RPort = GUICtrlCreateInput($frp_RPort, 80, 95, 100, 20)
	GUICtrlCreateLabel("VNC 端口：", 10, 127)
	$VNC_Port = GUICtrlCreateInput($VNC_Port, 80, 125, 100, 20)
	
	;获取端口信息
	Local $netstat = Run(@ComSpec & ' /c ' & 'netstat -an | find "' & GUICtrlRead($frp_SPort) & '" & netstat -an | find "' & GUICtrlRead($VNC_Port) & '"', "", @SW_HIDE, 15)
	ProcessWaitClose($netstat)
	$cat_netstat = StdoutRead($netstat)
	;显示框
	GUICtrlCreateEdit("", 195, 5, 194, 140)
	GUICtrlSetData(-1, $cat_netstat)
	
	;GUI按钮
	$start = GUICtrlCreateButton("启动服务", 40, 155, 60, 20)
	$stop = GUICtrlCreateButton("停止服务", 120, 155, 60, 20)
	$apply = GUICtrlCreateButton("应用配置", 200, 155, 60, 20)
	$exit = GUICtrlCreateButton("退出", 280, 155, 60, 20)

	;底部信息
	$website1_url = "https://www.fiwu.net"
	$website1 = GUICtrlCreateLabel($website1_url, 270, 180, -1, -1)
	GuiCtrlSetFont($website1, 8.5, -1, 4) ; underlined
	GuiCtrlSetColor($website1, 0x0000ff)
	GuiCtrlSetCursor($website1, 0)


	GUISetState()
	
	$msg = 0
	While $msg <> $GUI_EVENT_CLOSE
		$msg = GUIGetMsg()
		Select
			Case $msg = $start
				;=======================================================================
				;防止二次启动
				ProcessClose("frpc.exe");停止frpc服务
				ProcessClose("vncserver.exe");停止vncserver服务
				;=======================================================================
				;运行VNCS和FRPS
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall add rule name="vncserver.exe" dir=in program=".\' & @CPUArch & '\vncserver.exe" action=allow', '', @SW_HIDE);防火墙放行端口
				Run(".\" & @CPUArch & "\vnclicense.exe -add VKUPN-MTHHC-UDHGS-UWD76-6N36A", '', @SW_HIDE);VNC激活码到2029年的key
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "Authentication", "REG_SZ", "VncAuth")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "RfbPort", "REG_SZ", GUICtrlRead($VNC_Port))
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "Password", "REG_SZ", "f0e43164f6c2e373")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "DisableTrayIcon", "REG_SZ", "1")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "ConnNotifyTimeout", "REG_SZ", "0")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "EnableAutoUpdateChecks", "REG_SZ", "0")
				Run(".\" & @CPUArch & "\vncserver.exe -service -start", '', @SW_HIDE);开启vncserver服务
				Run(".\" & @CPUArch & "\frpc.exe -c frpc.ini", '', @SW_HIDE);运行frpc服务
				;=======================================================================
				MsgBox(0, "提示-" & @CPUArch, "服务已启动")
			Case $msg = $stop
				;=======================================================================
				ProcessClose("frpc.exe");停止frpc服务
				ProcessClose("vncserver.exe");停止vncserver服务
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall delete rule name="vncserver.exe"', '', @SW_HIDE);防火墙关闭端口
				;=======================================================================
				MsgBox(0, "提示-" & @CPUArch, "服务已停止")
			Case $msg = $apply
				;=======================================================================
				;写入FRPC配置
				IniWrite("frpc.ini", "common", "server_addr", " " & GUICtrlRead($frp_SAddr))
				IniWrite("frpc.ini", "common", "server_port", " " & GUICtrlRead($frp_SPort))
				IniWrite("frpc.ini", "common", "token", " " & GUICtrlRead($frp_token))
				IniWrite("frpc.ini", "vnc-tcp", "local_port", " " & GUICtrlRead($VNC_Port))
				IniWrite("frpc.ini", "vnc-tcp", "remote_port", " " & GUICtrlRead($frp_RPort))
				IniWrite("frpc.ini", "vnc-udp", "local_port", " " & GUICtrlRead($VNC_Port))
				IniWrite("frpc.ini", "vnc-udp", "remote_port", " " & GUICtrlRead($frp_RPort))
				;=======================================================================
				MsgBox(0, "提示-" & @CPUArch, "已应用配置")
			Case $msg = $exit Or $msg = $GUI_EVENT_CLOSE 
				;=======================================================================
				;停止后退出
				ProcessClose("frpc.exe");停止frpc服务
				ProcessClose("vncserver.exe");停止vncserver服务
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall delete rule name="vncserver.exe"', '', @SW_HIDE);防火墙关闭端口
				;=======================================================================
				ExitLoop
			Case $msg = $website1
				Run(@ComSpec & " /c " & 'start ' & $website1_url, "", @SW_HIDE)
				
		EndSelect
	WEnd
EndFunc   ;==>Example

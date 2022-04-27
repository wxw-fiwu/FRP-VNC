#region ;**** ���������� ACNWrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\WINDOWS\System32\SHELL32.dll
#AutoIt3Wrapper_Outfile=FRP&VNC.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=VNC�Զ�����FRP����
#AutoIt3Wrapper_Res_Description=��WXW�༭����
#AutoIt3Wrapper_Res_Fileversion=1.0.0.17
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=@WXW
#AutoIt3Wrapper_Res_Language=4100
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#endregion ;**** ���������� ACNWrapper_GUI ****
#include <GUIConstantsEx.au3>
Example()
Opt("GUIOnEventMode",1)
Func Example()
	Local $frp_SAddr, $frp_SPort, $frp_token, $frp_RPort, $VNC_Port
	Local $start, $stop, $apply, $exit, $msg
	
	;�ж�ϵͳλ��
	;Local $xitongwei = FileFindFirstFile("C:\Program Files (x86)");ϵͳx64
	If @CPUArch = "X64" Then;����������ļ���������x64
		Local $HKLM = "HKLM64"
	Else
		Local $HKLM = "HKLM"
	EndIf
	
	;��ȡFRPC����
	$frp_SAddr = IniRead("frpc.ini", "common", "server_addr", "")
	$frp_SPort = IniRead("frpc.ini", "common", "server_port", "")
	$frp_token = IniRead("frpc.ini", "common", "token", "")
	$VNC_TPort = IniRead("frpc.ini", "vnc-tcp", "local_port", "")
	$frp_TRPort = IniRead("frpc.ini", "vnc-tcp", "remote_port", "")
	$VNC_UPort = IniRead("frpc.ini", "vnc-udp", "local_port", "")
	$frp_URPort = IniRead("frpc.ini", "vnc-udp", "remote_port", "")
	

	;VNC��UDP��TCP�˿ں�
	If $VNC_TPort = $VNC_UPort Then;
		Local $VNC_Port = $VNC_TPort
	Else
		Local $VNC_Port = "5900"
		IniWrite("frpc.ini", "vnc-tcp", "local_port", " " & $VNC_Port)
		IniWrite("frpc.ini", "vnc-udp", "local_port", " " & $VNC_Port)
	EndIf
	
	;FRP��UDP��TCP�˿ں�
	If $frp_TRPort = $frp_URPort Then;
		Local $frp_RPort = $frp_TRPort
	Else
		$SJ_FRPCPort = Random (10000,20000,1)
		IniWrite("frpc.ini", "vnc-tcp", "remote_port", " " & $SJ_FRPCPort)
		IniWrite("frpc.ini", "vnc-udp", "remote_port", " " & $SJ_FRPCPort)
		Local $frp_RPort = $SJ_FRPCPort
	EndIf
	
	;GUI�Ի���
	GUICreate("FRP&VNC-" & @CPUArch & "   www.fiwu.net", 400, 200)
	GUICtrlCreateLabel("FRPS��ַ��", 10, 7)
	$frp_SAddr = GUICtrlCreateInput($frp_SAddr, 80, 5, 100, 20)
	GUICtrlCreateLabel("FRPS�˿ڣ�", 10, 37)
	$frp_SPort = GUICtrlCreateInput($frp_SPort, 80, 35, 100, 20)
	GUICtrlCreateLabel("Token��", 10, 67)
	$frp_token = GUICtrlCreateInput($frp_token, 80, 65, 100, 20)
	GUICtrlCreateLabel("ӳ��˿ڣ�", 10, 98)
	$frp_RPort = GUICtrlCreateInput($frp_RPort, 80, 95, 100, 20)
	GUICtrlCreateLabel("VNC �˿ڣ�", 10, 128)
	$VNC_Port = GUICtrlCreateInput($VNC_Port, 80, 125, 100, 20)
	GUICtrlCreateLabel("VNC ���룺", 200, 128)
	$VNC_PWD = GUICtrlCreateInput("12345678", 270, 125, 100, 20)
	
	;��ʾ��
	GUICtrlCreateGroup("������Ϣ", 195, 5, 194, 100)
	
	;GUI��ť
	$start = GUICtrlCreateButton("��������", 40, 155, 60, 20)
	$stop = GUICtrlCreateButton("ֹͣ����", 120, 155, 60, 20)
	$apply = GUICtrlCreateButton("Ӧ������", 200, 155, 60, 20)
	$exit = GUICtrlCreateButton("�˳�", 280, 155, 60, 20)
	$cat_netstat = GUICtrlCreateButton("ˢ��", 330, 104, 60, 20)
	
	;�ײ���Ϣ
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
			Case $msg = $cat_netstat
				;=======================================================================
				;������ʾ�����ն���Ϣ
				Local $netstat = Run(@ComSpec & ' /c ' & 'netstat -ano | find "' & GUICtrlRead($frp_RPort) & '" | find "ESTABLISHED"', '', @SW_HIDE, 15)
				ProcessWaitClose($netstat)
				$netstat = StdoutRead($netstat)
				;GUICtrlCreateLabel($cat_netstat, 210, 20, 175, 80)
				GUICtrlCreateEdit($netstat, 199, 20, 185, 80)
				;GUICtrlSetState(GUICtrlRead($cat_netstat), 0)
				;MsgBox(0, "��ʾ-" & @CPUArch, $cat_netstat)
				;=======================================================================
			Case $msg = $start
				GUICtrlSetState($start, $GUI_DISABLE);�������ɫ
				;=======================================================================
				;����VNCS��FRPS
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall add rule name="vncserver.exe" dir=in program=".\' & @CPUArch & '\vncserver.exe" action=allow', '', @SW_HIDE);����ǽ���ж˿�
				Run(".\" & @CPUArch & "\vnclicense.exe -add VKUPN-MTHHC-UDHGS-UWD76-6N36A", '', @SW_HIDE);VNC�����뵽2029���key
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "Authentication", "REG_SZ", "VncAuth")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "RfbPort", "REG_SZ", GUICtrlRead($VNC_Port))
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "DisableTrayIcon", "REG_SZ", "1")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "ConnNotifyTimeout", "REG_SZ", "0")
				RegWrite($HKLM & "\Software\RealVNC\vncserver", "EnableAutoUpdateChecks", "REG_SZ", "0")
				Run(".\" & @CPUArch & "\vncserver.exe -service -start", '', @SW_HIDE);����vncserver����
				Run(".\" & @CPUArch & "\frpc.exe -c frpc.ini", '', @SW_HIDE);����frpc����
				;=======================================================================
			Case $msg = $stop
				;=======================================================================
				ProcessClose("frpc.exe");ֹͣfrpc����
				ProcessClose("vncserver.exe");ֹͣvncserver����
				Run(".\" & @CPUArch & "\vncserver.exe -service -stop", '', @SW_HIDE);ֹͣvncserver����
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall delete rule name="vncserver.exe"', '', @SW_HIDE);����ǽ�رն˿�
				Run(@ComSpec & ' /c ' & 'sc stop vncserver', '', @SW_HIDE)
				Run(@ComSpec & ' /c ' & 'sc delete vncserver', '', @SW_HIDE)
				GUICtrlSetState($start, $GUI_ENABLE);���������
				;MsgBox(0, "��ʾ-" & @CPUArch, "������ֹͣ")
				;=======================================================================
			Case $msg = $apply
				;=======================================================================
				;д��FRPC����
				IniWrite("frpc.ini", "common", "server_addr", " " & GUICtrlRead($frp_SAddr))
				IniWrite("frpc.ini", "common", "server_port", " " & GUICtrlRead($frp_SPort))
				IniWrite("frpc.ini", "common", "token", " " & GUICtrlRead($frp_token))
				IniWrite("frpc.ini", "vnc-tcp", "local_port", " " & GUICtrlRead($VNC_Port))
				IniWrite("frpc.ini", "vnc-tcp", "remote_port", " " & GUICtrlRead($frp_RPort))
				IniWrite("frpc.ini", "vnc-udp", "local_port", " " & GUICtrlRead($VNC_Port))
				IniWrite("frpc.ini", "vnc-udp", "remote_port", " " & GUICtrlRead($frp_RPort))
				Run(@ComSpec & ' /c echo ' & GUICtrlRead($VNC_PWD) & ' | .\' & @CPUArch & '\vncpasswd.exe -service', '', @SW_HIDE, 15);�޸�VNC����
				MsgBox(0, "��ʾ-" & @CPUArch, "��Ӧ������")
				;=======================================================================
			Case $msg = $exit Or $msg = $GUI_EVENT_CLOSE 
				;=======================================================================
				;ֹͣ���˳�
				ProcessClose("frpc.exe");ֹͣfrpc����
				ProcessClose("vncserver.exe");ֹͣvncserver����
				Run(".\" & @CPUArch & "\vncserver.exe -service -stop", '', @SW_HIDE);ֹͣvncserver����
				Run(@ComSpec & ' /c ' & 'sc stop vncserver', '', @SW_HIDE)
				Run(@ComSpec & ' /c ' & 'sc delete vncserver', '', @SW_HIDE)
				Run(@ComSpec & ' /c ' & 'netsh advfirewall firewall delete rule name="vncserver.exe"', '', @SW_HIDE);����ǽ�رն˿�
				ExitLoop
				;=======================================================================
			Case $msg = $website1
				Run(@ComSpec & " /c " & 'start ' & $website1_url, "", @SW_HIDE)
		EndSelect
	WEnd
EndFunc   ;==>Example

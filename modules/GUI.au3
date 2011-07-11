Func _createMainGUI()
	
#Region ### START Koda GUI section ### Form=S:\sabox\grid\FP-SMSGatewayGUI\GUI\mainGUI.kxf
Global $mainGUI = GUICreate("GUI for SMS Gateway", 477, 153, -1, -1)
Global $recipientLabel = GUICtrlCreateLabel("Recipient", 8, 8, 61, 20)
Global $messageLabel = GUICtrlCreateLabel("Message", 8, 40, 61, 20)
Global $recipientCombo = GUICtrlCreateCombo("", 80, 8, 385, 25)
Global $sendButton = GUICtrlCreateButton("Send", 390, 110, 75, 33, 0)
Global $settingsButton = GUICtrlCreateButton("Settings", 8, 110, 75, 33, 0)
Global $messageLogButton = GUICtrlCreateButton("Message Log", 88, 110, 115, 33, 0)
Global $messageEdit = GUICtrlCreateEdit("", 80, 40, 385, 57, BitOR($ES_AUTOVSCROLL,$WS_VSCROLL,$ES_MULTILINE))
Global $busyAVI = GUICtrlCreateAvi("No File", -1, 216, 110, 32, 32)
GUICtrlSetState(-1, $GUI_HIDE)
Global $busyLabel = GUICtrlCreateLabel(" ", 256, 112, 123, 28, BitOR($SS_CENTER,$SS_CENTERIMAGE))
#EndRegion ### END Koda GUI section ###
	
	GUICtrlSetData($busyAVI, @ScriptDir&"\GUI\busy_indicator_32x32.avi")
	GUICtrlSetState($busyLabel, $GUI_HIDE)
	
	_GUICtrlComboBox_ResetContent($recipientCombo)
	$section = IniReadSection($logRecipientsPath, "DATA")
	If Not @error Then
		For $i=1 To $section[0][0]
			_GUICtrlComboBox_InsertString($recipientCombo, $section[$i][1])
		Next
	EndIf
	
EndFunc

Func _showMainGUI()
	GUISetState(@SW_SHOW, $mainGUI)
	_waitForMainGUI()
EndFunc

Func _hideMainGUI()
	GUISetState(@SW_HIDE, $mainGUI)
EndFunc

Func _waitForMainGUI()
	
	While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_hideMainGUI()
			ExitLoop
		Case $recipientCombo
		Case $sendButton
			_send(GUICtrlRead($recipientCombo), GUICtrlRead($messageEdit))
		Case $settingsButton
			_showSettingsGUI()
		Case $messageLogButton
			_showMessageLogGUI()
		Case $messageEdit
		EndSwitch
		Sleep(50)
	WEnd
	
EndFunc

Func _createSettingsGUI()
	
	#Region ### START Koda GUI section ### Form=S:\sabox\grid\FP-SMSGatewayGUI\GUI\settingsGUI.kxf
	Global $settingsGUI = GUICreate("Settings - GUI for SMS Gateway", 352, 206, -1, -1)
	Global $serverLabel = GUICtrlCreateLabel("Server", 16, 8, 44, 20, $SS_CENTERIMAGE)
	Global $portLabel = GUICtrlCreateLabel("Port", 16, 40, 28, 20, $SS_CENTERIMAGE)
	Global $portInput = GUICtrlCreateInput("9090", 96, 40, 241, 24, BitOR($ES_AUTOHSCROLL,$ES_NUMBER))
	Global $passwordLabel = GUICtrlCreateLabel("Password", 16, 72, 64, 20, $SS_CENTERIMAGE)
	Global $passwordInput = GUICtrlCreateInput("", 96, 72, 241, 24)
	Global $serverInput = GUICtrlCreateInput("", 96, 8, 241, 24)
	Global $recipientsLogCheckbox = GUICtrlCreateCheckbox("   Log Phone Numbers", 16, 104, 321, 25)
	Global $messageLogCheckbox = GUICtrlCreateCheckbox("   Log Messages", 16, 136, 321, 25)
	Global $cancelButton = GUICtrlCreateButton("Cancel", 184, 160, 75, 33, 0)
	Global $saveButton = GUICtrlCreateButton("Save", 262, 160, 75, 33, 0)
	#EndRegion ### END Koda GUI section ###
	
	GUICtrlSetData($serverInput, $server)
	GUICtrlSetData($portInput, $port)
	GUICtrlSetData($passwordInput, $password)
	
	If $logRecipients == 1 Then
		GUICtrlSetState($messageLogCheckbox, $GUI_CHECKED)
	Else
		GUICtrlSetState($messageLogCheckbox, $GUI_UNCHECKED)
	EndIf
	
	If $logMessages == 1 Then
		GUICtrlSetState($recipientsLogCheckbox, $GUI_CHECKED)
	Else
		GUICtrlSetState($recipientsLogCheckbox, $GUI_UNCHECKED)
	EndIf
	
EndFunc

Func _showSettingsGUI()
	GUISetState(@SW_SHOW, $settingsGUI)
	_waitForSettingsGUI()
EndFunc

Func _hideSettingsGUI()
	GUISetState(@SW_HIDE, $settingsGUI)
EndFunc

Func _waitForSettingsGUI()
	
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
		
		Case $GUI_EVENT_CLOSE, $cancelButton
			_hideSettingsGUI()
			ExitLoop
			
		Case $serverLabel
			GUICtrlSetState($serverInput, $GUI_FOCUS)
		Case $portLabel
			GUICtrlSetState($portInput, $GUI_FOCUS)
		Case $passwordLabel
			GUICtrlSetState($passwordInput, $GUI_FOCUS)
			
		Case $portInput
		Case $passwordInput
		Case $serverInput
			
		Case $recipientsLogCheckbox
		Case $messageLogCheckbox

		Case $saveButton
			
			Global $server = GUICtrlRead($serverInput)
			_iniWrite($globalConfigPath, "HTTP", "server", $server)
			
			Global $port = GUICtrlRead($portInput)
			_iniWrite($globalConfigPath, "HTTP", "port", $port)
			
			Global $password = GUICtrlRead($passwordInput)
			_iniWrite($globalConfigPath, "HTTP", "password", _StringEncrypt(1, $password, @UserName&@ComputerName, 3))
			
			If GUICtrlRead($recipientsLogCheckbox) == $GUI_CHECKED Then
				Global $logRecipients = 1
			Else
				Global $logRecipients = 0
			EndIf
			_iniWrite($globalConfigPath, "LOG", "recipients", $logRecipients)
			
			If GUICtrlRead($messageLogCheckbox) == $GUI_CHECKED Then
				Global $logMessages = 1
			Else
				Global $logMessages = 0
			EndIf
			_iniWrite($globalConfigPath, "LOG", "messages", $logMessages)
			
			_hideSettingsGUI()
			ExitLoop
			
		EndSwitch
		
		Sleep(50)
	WEnd
	
EndFunc

Func _createMessageLogGUI()
	
	#Region ### START Koda GUI section ### Form=S:\sabox\grid\FP-SMSGatewayGUI\GUI\messageLogGUI.kxf
	Global $messageLogGUI = GUICreate("Message Log - GUI for SMS Gateway", 682, 363, -1, -1)
	Global $logEdit = GUICtrlCreateEdit("", 8, 8, 665, 345, BitOR($ES_AUTOVSCROLL,$ES_WANTRETURN,$WS_VSCROLL))
	#EndRegion ### END Koda GUI section ###
	
	_GUICtrlEdit_SetText($logEdit, FileRead($logMessagesPath))

EndFunc

Func _showMessageLogGUI()
	GUISetState(@SW_SHOW, $messageLogGUI)
	_waitForMessageLogGUI()
EndFunc

Func _hideMessageLogGUI()
	GUISetState(@SW_HIDE, $messageLogGUI)
EndFunc

Func _waitForMessageLogGUI()
	
	While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_hideMessageLogGUI()
			ExitLoop
		Sleep(50)
	EndSwitch
	WEnd

EndFunc
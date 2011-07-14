#cs

	GUI for sending SMS messages from the computer via an Android phone 
	using the SMS Gateway application for android (HTTP SMS gateway).
    Copyright (C) 2011 Florian Pollak

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  
	If not, see http://www.gnu.org/licenses/gpl.html.

#ce

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <String.au3>
#Include <GuiComboBox.au3>
#Include <GuiAVI.au3>
#include <INet.au3>
#Include <Date.au3>
#Include <GuiEdit.au3>

#include <_config.au3>
#include <_error.au3>
#include <_stringReplaceVariables.au3>

#include "modules\GUI.au3"

_initialize()
_main()

Func _initialize()
	_initializeSettings()
	_createMainGUI()
	_createSettingsGUI()
	_createMessageLogGUI()
EndFunc

Func _initializeSettings()
	Global $server = _iniRead($globalConfigPath, "HTTP", "server", "")
	Global $port = _iniRead($globalConfigPath, "HTTP", "port", 9090)
	Global $password = _StringEncrypt(0, _iniRead($globalConfigPath, "HTTP", "password", ""), @UserName&@ComputerName, 3)
	Global $logRecipients = _iniRead($globalConfigPath, "LOG", "recipients", 1)
	Global $logRecipientsPath = _stringReplaceVariables(_iniRead($globalConfigPath, "LOG", "recipientsPath", "@ScriptDir\data\recipients.txt"))
	Global $logMaxRecipients = _iniRead($globalConfigPath, "LOG", "maxRecipients", 10)
	Global $logMessages = _iniRead($globalConfigPath, "LOG", "messages", 1)
	Global $logMessagesPath = _stringReplaceVariables(_iniRead($globalConfigPath, "LOG", "messagesPath", "@ScriptDir\data\messages.txt"))
EndFunc

Func _main()
	_showMainGUI()
EndFunc

Func _send($recipient, $message)
	
	Local $messageOverflowBuffer = ""
	
	If $recipient == "" Then
		MsgBox(0+16, "Error - "&@ScriptName, "Recipient is empty. Aborting.")
		SetError(1)
		Return 0
	EndIf
	
	_logRecipient($recipient)
	
	If $message == "" Then
		MsgBox(0+16, "Error - "&@ScriptName, "Message is empty. Aborting.")
		SetError(2)
		Return 0
	EndIf
	
	If StringLen($message) > 160 Then
		
		$answer = MsgBox(3+48, "Message too long - "&@ScriptName, "The message contains more than 160 characters. Do you want to automatically split the message?"&@LF&@LF&"YES: split the message automatically"&@LF&"NO: truncate the message, ie. only send the first 160 characters"&@LF&"CANCEL: abort, do not send anything")
		
		If $answer == 6 Then ; yes
			$messageOverflowBuffer = StringRight($message, StringLen($message)-160)
			$message = StringLeft($message, 160)
;~ 			MsgBox(1,$message,$message&@LF&@LF&$message&$messageOverflowBuffer)
		ElseIf $answer == 7 Then ; no
			$message = StringLeft($message, 160)
		ElseIf $answer == 2 Then ; cancel
			SetError(3)
			Return 0
		Else
			_error("Illegal response to prompt.", 1, 0)
		EndIf
		
	EndIf
	
	Local $URL
	$URL &= "http://"
	$URL &= $server
	$URL &= ":"
	$URL &= $port
	$URL &= "/sendsms?"
	$URL &= "password="
	$URL &= $password
	
	$URL &= "&"
	$URL &= "phone="
	$URL &= $recipient
	
	$URL &= "&"
	$URL &= "text="
	$URL &= $message
	
	GUICtrlSetState($sendButton, $GUI_DISABLE)
	
	GUICtrlSetState($busyLabel, $GUI_SHOW)
	GUICtrlSetData($busyLabel, "sending ...")
	
	$source = _INetGetSource($URL, True)
	
	If $source == "<html>"&@LF&"<body>"&@LF&"Mesage SENT!<br/>"&@LF&"</body>"&@LF&"</html>" Then
		_logMessage($message, $recipient)
		MsgBox(0+64, @ScriptName, "Message sent: "&@LF&@LF&"Recipient: "&$recipient&@LF&"Message: "&$message&@LF&@LF&"URL: "&$URL)
	Else
		MsgBox(0+16, @ScriptName, "Failure, message not sent: "&@LF&@LF&"Recipient: "&$recipient&@LF&"Message: "&$message&@LF&@LF&"URL: "&$URL)
	EndIf
	
	GUICtrlSetState($busyLabel, $GUI_HIDE)
	GUICtrlSetData($busyLabel, " ")
	
	GUICtrlSetState($sendButton, $GUI_ENABLE)
	
	If $messageOverflowBuffer<>"" Then
		_send($recipient, $messageOverflowBuffer)
	EndIf
	
EndFunc

Func _logRecipient($recipient)
	
	If $logRecipients == 1 Then
		
		$currentEntry = _GUICtrlComboBox_GetEditText($recipientCombo)
		
		$index = IniRead($logRecipientsPath, "META", "lastIndex", 0)
		$index += 1
		If $index>$logMaxRecipients Then
			$index = 1
		EndIf
		IniWrite($logRecipientsPath, "DATA", $index, $recipient)
		
		_GUICtrlComboBox_ResetContent($recipientCombo)
		$section = IniReadSection($logRecipientsPath, "DATA")
		If Not @error Then
			For $i=1 To $section[0][0]
				_GUICtrlComboBox_InsertString($recipientCombo, $section[$i][1])
			Next
		EndIf
		
		_GUICtrlComboBox_SetEditText($recipientCombo, $currentEntry)
		
	EndIf
	
EndFunc

Func _logMessage($message, $recipient)
	
	If $logMessages == 1 Then
		$string = StringReplace(_NowCalc(), "/", "-")&@TAB&$message&@TAB&"to: "&$recipient
		FileWriteLine($logMessagesPath, $string)
		_GUICtrlEdit_AppendText($logEdit, @LF&$string)
	EndIf
	
EndFunc
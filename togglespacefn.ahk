#Persistent
#SingleInstance force

isAlternateMode := false
keyAction := []
settings := {}

; Read General settings
Loop, Read, toggle_spacefn_settings.ini
{
    ; Split each line into key and action
    parts := StrSplit(A_LoopReadLine, "=")
    name := Trim(parts[1])
    action := Trim(parts[2])
        ;MsgBox, 0, Mode Status,%action%
    if (name = "layer_switch_key"){
    	if (action = "Ctrl"){
    	   modifier := "^"	
    	}
    	else if (action = "Shift"){
    	   modifier := "+"	
    	}
    	else if (action = "Win"){
    	   modifier := "#"	
    	}	
            else if (action = "Alt"){
    	   modifier := "!"	
    	} 
        else 
        {
           modifier := ""
        } 
        Hotkey, % modifier action, SetLayerKey
    }
    else if (action != "") {
        settings[name] := action 
    }
    ; Initialize the traditional array
    myArray := ["Value1", "Value2", "Value3"]

    ; Concatenate all values into a single string
    allValues := ""
    for index, value in settings {
        allValues .= index " " value "`n"  ; `n adds a newline character
    }

    ; Display all values in a message box
    ;MsgBox, % "Array Values:`n" allValues
}

; Read keys settings and parse the key-action pairs
Loop, Read, toggle_spacefn_keys.ini
{
    global keyAction
    ; Split each line into key and action
    parts := StrSplit(A_LoopReadLine, ",")
    key := Trim(parts[1])
    action := Trim(parts[2])

    ; Create hotkey 
    Hotkey, % "$*"key, ToggleHotkey

    ; Store the action associated with the key
    keyAction[key] := action
}


; Function to show the mode status
ShowModeStatus() {
    global isAlternateMode
    if (isAlternateMode) {
        MsgBox, 0, Mode Status, Alternate Mode Activated
    } else {
        MsgBox, 0, Mode Status, Default Mode Activated
    }
}

; Function to handle hotkeys
ToggleHotkey() {
    global keyAction
    global isAlternateMode

    key := SubStr(A_ThisHotkey,3) ; Extract the key pressed

    action := keyAction[key] ; Get the associated action
   ;MsgBox, 0, Mode Status, %key%

    if (isAlternateMode) {
    	;MsgBox, 0, Mode Status, isAlternateMode..
        Send, {Blind}{%action%} ; Send the action key
    } else {
        Send, {Blind}%key% ; Send the original keyv
    }
}

; Toggle mode on Alt key press
SetLayerKey() {
    global isAlternateMode
    global settings 
    isAlternateMode := !isAlternateMode
    
    ;MsgBox, % "HasKey('show_popup'): " settings.HasKey("show_popup")
 
    if (isAlternateMode && ( !settings.HasKey("show_popup") || settings["show_popup"] = "true") ){
        popupText := settings["popup_text"] ? settings["popup_text"]: "Alt Layer" 
	    ShowPopup( popupText )
    } else {
	    ClosePopup()
    }
    return 
}

ShowPopup(message) {
    ; Create the popup GUI
    Gui +LastFound
    Gui, +AlwaysOnTop
    Gui, +ToolWindow
    Gui, Margin, 0, 0
    Gui, -Caption
    Gui, Font, s12
    Gui, Add, Text, cAqua , %message%
    Gui, Color, Navy


    midPos  := A_ScreenWidth/2
    midPosY := A_ScreenHeight - 30
    Gui, Show, NoActivate x%midPos% y%midPosY%

    ; Set timer to close the popup after 2 seconds
    ;SetTimer, ClosePopup, 500
}

ClosePopup(){
    Gui, Destroy
    SetTimer, ClosePopup, Off
}
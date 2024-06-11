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
    parts := StrSplit(A_LoopReadLine, ",")
    key := Trim(parts[1])
    action := Trim(parts[2])
    Hotkey, % "$*"key, ToggleHotkey
    keyAction[key] := action
}

; Function to handle hotkeys
ToggleHotkey() {
    global keyAction
    global isAlternateMode

    key := SubStr(A_ThisHotkey,3) ; Extract the key pressed
    action := keyAction[key] ; Get the associated action
   ;MsgBox, 0, Mode Status, %key%
    if (isAlternateMode) {
        a := SubStr(A_ThisHotkey, 1, 1) = """"
        if (SubStr(action, 1, 1) = """"){
           Send, % SubStr(action, 2, -1) ; Send the action key
        } else {
           Send, {Blind}{%action%} ; Send the action key
        }
    } else {
        Send, {Blind}%key% ; Send the original keyv
    }
}

; Toggle layers
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
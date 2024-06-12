#Persistent
#SingleInstance force

isAlternateMode := false
keyAction := []
settings := {}

; Read General settings

Loop, Read, layer2_general_settings.ini
{
    ; Split each line into key and action
    if (RegExMatch(A_LoopReadLine, "O)^(.+)\s*=(.+)$", parts)){
        name := Trim(parts.Value(1))
        action := Trim(parts.Value(2))
            ; MsgBox, 0, Mode Status,%part%
            ; MsgBox, 0, Mode Status,%action%
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
            Hotkey, % action, SetLayerKey
        }
        else if (action != "") {
            settings[name] := action 
        }
    }
}

; Read keys settings and parse the key-action pairs
Loop, Read, layer2_key_mappings.ini
{
    global keyAction
    if (RegExMatch(A_LoopReadLine, "O)^(.)\s*=(.+)$", parts)){
        name := Trim(parts.Value(1))
        action := Trim(parts.Value(2))
            ; MsgBox, 0, Mode Status,%name%
            ; MsgBox, 0, Mode Status,%action%
        keyAction[name] := action
        modifier := "$"
        Hotkey, % modifier name, ToggleHotkey
    }
}

; Function to handle hotkeys
ToggleHotkey() {
    global keyAction
    global isAlternateMode
    ;MsgBox, 0, Mode Status,%A_ThisHotkey%

    key := SubStr(A_ThisHotkey,0) ; Extract the key pressed
    action := keyAction[key] ; Get the associated action
    if (isAlternateMode) {
        ; MsgBox, 0, Mode Status,%key%%action%%isAlternateMode%
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
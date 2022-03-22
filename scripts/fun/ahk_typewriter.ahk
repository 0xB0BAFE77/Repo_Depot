; AHK TypeWriter
; By: 0xB0BAFE77
; Fun little script that emulates the sounds of a typewriter as you type
; Use F1 to toggle function on/off

#SingleInstance Force
typewriter.start()
Return

F1::typewriter.toggle()

Class typewriter
{
    Static _toggle  := 1
          ,_path    := A_AppData "\AHK_typewriter\"
          ,_tmp     := A_AppData "\AHK_typewriter\tmp.ahk"
          ,url      := "https://github.com/0xB0BAFE77/Repo_Depot/"
          .            "raw/main/media/sound/typewriter/"
          ,mod_keys := {"Alt":"!" ,"Control":"^" ,"Shift":"+" ,"Win":"#"}
          ,snd_list := {"BackSpace"  :"BackSpace.wav"
                       ,"NumpadDel"  :"BackSpace.wav"
                       ,"Delete"     :"BackSpace.wav"
                       ,"NumpadEnter":"Enter.wav"
                       ,"Enter"      :"Enter.wav"
                       ,"Space"      :"Space.wav"
                       ,"Tab"        :"Space.wav"
                       ,""           :"Hit.wav"}
    Static snd_keys := ["Space","Tab","Enter","Backspace","Delete","Numpad0"
                       ,"Numpad1","Numpad2","Numpad3","Numpad4","Numpad5"
                       ,"Numpad6","Numpad7","Numpad8","Numpad9","NumpadDel",
                       ,"NumpadEnter"]
    
    toggle() {
        this.set_icon(this._toggle := !this._toggle)
    }
    
    start() {
        this.file_checker()
        this.gen_hotkeys()
    }
    
    _void() {
    }
    
    gen_hotkeys() {
        For index, key in this.snd_keys
        {
            obm := ObjBindMethod(this, "_send", key)
            Hotkey, % "*" key, % obm
            obm := ObjBindMethod(this, "_void")
            Hotkey, % "~*" key " Up", % obm
        }
        Loop, 126
            If (A_Index > 31)
            {
                key := GetKeyName(Chr(A_Index))
                ,obm := ObjBindMethod(this, "_send", key)
                Hotkey, % "*" key, % obm
                obm := ObjBindMethod(this, "_void")
                Hotkey, % "~*" key " Up", % obm
            }
        Loop, 10
        {
            key := (A_Index-1)
            ,obm := ObjBindMethod(this, "_send", key)
            Hotkey, % "*" num, % obm
            obm := ObjBindMethod(this, "_void")
            Hotkey, % "~*" key " Up", % obm
        }
    }
    
    ; This is a hackey way of sending multiple sound files that overlap
    ; There's probably a cleaner way to do this with DLLCalls,
    ; but this straight up works with minimal effort
    _send(char) {
        sound := this.snd_list.HasKey(char)
            ? this.snd_list[char] : this.snd_list[""]
        If this._toggle
        {
            FileDelete, % this._tmp                                         ; Ensure file is deleted
            FileAppend, % "#NoTrayIcon`nSoundPlay, % """                    ; Create a temporary ahk file to play the sound
                . this._path sound """, 1", % this._tmp
            Run, % this._tmp                                                ; Otherwise, play the correct file
        }
        SendInput, % this.get_mods(char) "{" char "}"                       ; Send char to coincide with sound playing
        Return
    }
    
    get_mods(char) {
        m := ""
        
        For key, symbol in this.mod_keys
            If InStr(char, key)
                Continue
            Else m .= GetKeyState( key, "P") ? symbol : ""
        Return m
    }
    
    file_checker() {
        p := this._path
        If !FileExist(p)
            FileCreateDir, % p
        For index, file in this.snd_list
            If FileExist(p file)
                Continue
            Else UrlDownloadToFile, % this.url file, % p file
    }
    
    set_icon(state) {
        Menu, Tray, Icon, % A_AHKPath, % (state ? 1 : 4)
    }
}

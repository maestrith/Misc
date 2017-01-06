#SingleInstance,Force
global Edit1,settings:=[]
settings()
OnMessage(6,"activate"),keylist:=[]
for a,b in {Shift:"P",Alt:"P",Control:"P",CapsLock:"T",LWin:"P",RWin:"P"}
	keylist[a]:=b
Gui()
return
hotkey:
now:=A_TickCount
if (now-lasttime>700)
	line:="",lasttext:=""
lasttime:=now,state:=[],text:=SubStr(A_ThisHotkey,3)
if A_ThisHotkey contains control,alt,shift,win
	return
for a,b in keylist
	state[a]:=GetKeyState(a,b)
if (text="space"){
	line.=" "
	goto displaytext
}
for a,b in state{
	if (a="CapsLock")
		Continue
	Else if (InStr(a,"win")&&b )
		addtoline.="Win+"
	Else if (b&&(a!="shift"))
		addtoline.=a "+"
	Else if (a="shift"&&b&&(StrLen(text)>1||state.alt||state.Control))
		addtoline.=a "+"
}
if (addtoline)
	text:=addtoline text,addtoline:=""
if (text=lasttext&&StrLen(text)>1)
	count++
Else
	count:=1
if (count=2){
	line.="(" count ")"
}Else if(StrLen(text)=1){
	if ((state.CapsLock&&!state.Shift)||(!state.capslock&&state.shift))
		StringUpper,text,text
	line.=text
}Else if(StrLen(text)>1)
line.=" " text " "
if (count>2){
	line:=SubStr(line,1,InStr(line,"(",0,0,1)-1)
	line.="(" count ")"
}
displaytext:
lasttext:=text
ControlSetText,Edit1,%line%,% hwnd([1])
return
Gui(){
	Gui,+hwndhwnd +AlwaysOnTop +Resize
	Gui,Margin,0,0
	Gui,Font,% "s25 q3 c" settings.color,Consolas
	Gui,+hwndhwnd +AlwaysOnTop
	Gui,Add,Edit,w800 R4s +0x1 -0x200000 hwndEdit1 -E0x200,% "Move and resize the window to where you want it.`nPress " convert_hotkey(settings.hotkey) " to toggle the window state`nF2 for options"
	if (settings.x)
		for a,b in StrSplit("xywh")
			pos.=b settings[b] " "
	Gui,Show,%pos%,OSD
	OnExit,GuiEscape
	ControlSend,Edit1,^{End},% hwnd(1,hwnd)
	for a,b in {startup:settings.hotkey,settings:"F2"}
		Hotkey(b,a,1,hwnd(1))
}
hwnd(win,hwnd=""){
	static window:=[]
	if (win.rem){
		Gui,% win.rem ":Destroy"
		return window.remove(win.rem)
	}
	if IsObject(win)
		return "ahk_id" window[win.1]
	if !hwnd
		return window[win]
	window[win]:=hwnd
	return % "ahk_id" hwnd
}
convert_hotkey(key){
	StringUpper,key,key
	for a,b in [{Shift:"+"},{Ctrl:"^"},{Alt:"!"}]
		for c,d in b
			key:=RegExReplace(key,"\" d,c "+")
	return key	
}
startup(){
	startup:
	Hotkey(settings.hotkey,"startup",1,hwnd(1))
	trigger()
	SetFormat,Integer,hex
	start:=0
	Loop,227
		if ((key:=GetKeyName("vk" start++))!="")
			Hotkey,~*%key%,Hotkey,On
	for a,b in StrSplit("Up,Down,Left,Right,End,Home,PgUp,PgDn,Insert,NumpadEnter,#,^,!,+",",")
		Hotkey,~*%b%,Hotkey,On
	SetFormat,Integer,dec
	for a,b in StrSplit("!@#$%^&*()_+:<>{}|?~" Chr(34))
		Hotkey,~+%b%,hotkey,On
	Hotkey,~*Delete,Hotkey,On
	Hotkey,% settings.hotkey,trigger,On
	return
}
settings(){
	IniRead,set,Settings.ini,settings
	if !(set){
		for a,b in {hotkey:"!F1",color:"0xFF00FF"}
			IniWrite,%b%,Settings.ini,settings,%a%
		settings()
	}
	for a,b in StrSplit(set,"`n")
		info:=StrSplit(b,"="),settings[info.1]:=info.2
	return
	settings:
	WinMinimize,% hwnd([1])
	if !hwnd(2)
		settingsgui()
	return
}
m(x*){
	for a,b in x
		list.=b "`n"
	msgbox %list%
}
t(x*){
	for a,b in x
		list.=b "`n"
	tooltip %list%
}
exit(){
	GuiClose:
	GuiEscape:
	WinGetPos,x,y,,,% hwnd([1])
	settings.x:=x,settings.y:=y
	for a,b in settings
		IniWrite,%b%,settings.ini,settings,%a%
	ExitApp
}
guisize(){
	GuiSize:
	settings.w:=A_GuiWidth,settings.h:=A_GuiHeight
	GuiControl,move,Edit1,w%A_GuiWidth% h%A_GuiHeight%
	return
}
Dlg_Color(Color,hwnd){
	static
	VarSetCapacity(CUSTOM,16*A_PtrSize,0),cc:=1,size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
	NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"UPtr"),NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt"),NumPut(&CUSTOM,CHOOSECOLOR,4*A_PtrSize,"UPtr")
	ret:=DllCall("comdlg32\ChooseColor","UPtr",&CHOOSECOLOR,"UInt")
	if !ret
		exit
	return RGB(NumGet(&CHOOSECOLOR,3*A_PtrSize))
}
rgb(c){
	setformat,IntegerFast,H
	c:=(c&255)<<16|(c&65280)|(c>>16),c:=SubStr(c,1)
	SetFormat,IntegerFast,D
	return c
}
trigger(){
	trigger:
	WinGet,style,style,% hwnd([1])
	if (style&0x00C00000){
		Gui,-Caption
		Gui,-Resize
		WinSet,TransColor,0xFFFFFF,% hwnd([1])
		Hotkey,F2,Hotkey,On
	}Else{
		Gui,+Caption
		Gui,+Resize
		WinSet,TransColor,Off,% hwnd([1])
		WinActivate,% hwnd([1])
		Hotkey,F2,settings,On
	}
	return
}
activate(a,b,c,d){
	if a=1
		SetTimer,hc,0
	return
	hc:
	SetTimer,hc,off
	DllCall("HideCaret",uptr,Edit1)
	return
}
settingsgui(){
	static hotkey,key
	Gui,2:Default
	Gui,2:+hwndhwnd
	hwnd(2,hwnd)
	Gui,2:Add,Hotkey,gkey vkey,% settings.hotkey
	Gui,2:Add,Edit,x+5 gedithotkey vhotkey
	Gui,2:Add,Progress,% "xm w50 h22 c" settings.color,100
	Gui,2:Add,Button,x+5 gchangecolor,Change Color
	Gui,2:Show,,Settings
	Hotkey(settings.hotkey,"settings",0,hwnd(1))
	edithotkey:
	Gui,2:Submit,Nohide
	GuiControl,2:,msctls_hotkey321,% settings.hotkey
	key:
	Gui,2:Submit,Nohide
	settings.hotkey:=key
	return
	2GuiEscape:
	2GuiClose:
	if !settings.hotkey
		return m("Please set a trigger hotkey")
	WinRestore,% hwnd([1])
	ControlSend,Edit1,^{End},% hwnd([1])
	hwnd({rem:2})
	Hotkey(settings.hotkey,"trigger",1)
	Sleep,1000
	return
	changecolor:
	settings.color:=color:=dlg_color(settings.color,hwnd(2))
	GuiControl,2:+c%color%,msctls_progress321
	GuiControl,1:+c%color%,Edit1
	return	
}
hotkey(key,label,state=0,hwnd=""){
	if !key
		return m("Hotkey error."),settingsGUI()
	state:=state?"On":"Off"
	if hwnd
		Hotkey,IfWinActive,ahk_id%hwnd%
	Hotkey,%key%,%label%,%state%
	Hotkey,IfWinActive
}

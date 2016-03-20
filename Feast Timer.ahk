;*****************************************************************
;
;  Copyright (c) 2015, Ronald Villaver 
;  All rights reserved.
;  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
;  
;  1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
;  
;  2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
;  
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
;*****************************************************************
;
;  Program		: Feast Timer
;  Developer	: Ronald Villaver
;  Updated		: March 18, 2016
;
;  This is the Feast Timer tool. It was built to help teleprompters
;  communicate better the time and situation to their speaker.
;  
;  Mostly used in Worship gatherings or shows.
;
;  2015-02-16: Created Initial API
;  2016-03-18: Implemented Secondary Monitor Support
;
;*****************************************************************
;  Here are some of the special commands you can do.
;  
;  CTRL + ALT + t
;  Opens input box for setting remaining time.
;  
;  CTRL + ALT + m
;  Opens input box to display a message.
;  
;  CTRL + ALT + q
;  Closes the tool.
;  
;  CTRL + ALT + =
;  Increase font size
;  
;  CTRL + ALT + -
;  Decrease font size
;  
;  CTRL + ALT + w
;  Set font color to White
;  
;  CTRL + ALT + b
;  Set font color to Black
;  
;  CTRL + ALT + r
;  Set font color to Red
;  
;  CTRL + ALT + y
;  Set font color to Yellow
;  
;  CTRL + ALT + h
;  Opens this help dialog
;  
;*****************************************************************
;
; CHANGE HISTORY:
;
; * v1.0.0
; - Initial release.
;
;*****************************************************************

#NoEnv
#SingleInstance, Force
DetectHiddenWindows, On
CoordMode, Mouse, Screen

TimerValue = 120
AlarmTime =
AlarmTime += TimerValue, minutes

alarm = %AlarmTime%
height = 100
winposition = 0
wincolumn = 0
message = 
size = 36
TargetWidth = 0
correction = 0
TimeCountdown = 0
TopCountdown = 0

SysGet, Mon1, Monitor, 1
SysGet, Mon2, Monitor, 2

IF Mon2Right > 0
{
	TargetWidth := Mon2Right - Mon2Left
	TargetWidth := TargetWidth - (TargetWidth * correction)
	wincolumn := Mon2Left
	winposition := Mon2Bottom - height
}else
{
	TargetWidth := Mon1Right - Mon1Left
	TargetWidth := TargetWidth - (TargetWidth * correction)
	wincolumn := Mon1Left
	winposition := Mon1Bottom - height
}

range := AlarmTime
EnvSub, range, %A_now%, seconds

Gui,+ToolWindow +AlwaysOnTop -Caption

Gui, Add, Progress, % "vProgress cGreen +BackgroundTrans X0 Y0 W" TargetWidth " H" height " Range0-" range
Gui, Add, Text, % "vProgressLabel X0 Y0 W" TargetWidth " H" height " cYellow +0x200 +Center +BackgroundTrans",
Gui, Add, Text, % "vProgressClock X0 Y0 W" TargetWidth - (TargetWidth * 0.025) " H" height " cYellow +0x200 +Right +BackgroundTrans",
Gui, Font, s%size% cWhite
GuiControl, Font, ProgressLabel
GuiControl, Font, ProgressClock
Gui, Show, % "X" wincolumn " Y" winposition " W" TargetWidth " H" height
Gui, +LastFound

guiid := WinExist("A")

WinSet, Transparent, 190, ahk_id %guiid%		; Transparency
WinSet, ExStyle, +0x20, ahk_id %guiid%			; Click-through

remaining := range
halfpoint := range / 2
thirdpoint := range / 3

SetTimer, process, 1000
return 

process:
	If remaining > 0 
	{
		remaining := remaining - 1
		GuiControl, , Progress, % remaining
		If remaining > %halfpoint%
		{
			GuiControl, +cGreen, Progress
		}
		Else If remaining > %thirdpoint%
		{
			GuiControl, +cOlive, Progress
		}
		Else
		{
			GuiControl, +cMaroon, Progress
		}
	}
	FormatTime, TimeString, , h:mm
	GuiControl, , ProgressClock, %TimeString%
	If TimeCountdown > 0
	{
		TimeCountdown := TimeCountdown - 1
	}
	Else
	{
		TimeCountdown := 0
		GuiControl, , ProgressLabel,
	}
	If TopCountdown > 0
	{
		TopCountdown := TopCountdown - 1
	}
	Else
	{
		TopCountdown := 30
		WinSet, Top,,ahk_id %guiid%
	}
return


^!i::
winposition := winposition - 100
WinMove, ahk_id %guiid%, , %wincolumn%, %winposition%
return

^!k::
winposition := winposition + 100
WinMove, ahk_id %guiid%, , %wincolumn%, %winposition%
return

^!j::
wincolumn := wincolumn - 100
WinMove, ahk_id %guiid%, , %wincolumn%, %winposition%
return

^!l::
wincolumn := wincolumn + 100
WinMove, ahk_id %guiid%, , %wincolumn%, %winposition%
return

^!p::
winposition := winposition + 50
WinMove, ahk_id %guiid%, , %wincolumn%, %winposition%
return

^!o::
winposition := winposition - 50
WinMove, ahk_id %guiid%, , %wincolumn%, %winposition%
return

^!y::
Gui, Font, cYellow
GuiControl, Font, ProgressLabel
GuiControl, Font, ProgressClock
return

^!r::
Gui, Font, cRed
GuiControl, Font, ProgressLabel
GuiControl, Font, ProgressClock
return

^!w::
Gui, Font, cWhite
GuiControl, Font, ProgressLabel
GuiControl, Font, ProgressClock
return

^!b::
Gui, Font, cBlack
GuiControl, Font, ProgressLabel
GuiControl, Font, ProgressClock
return


^!=::
size +=2
Gui, Font, s%size%
GuiControl, Font, ProgressLabel
GuiControl, Font, ProgressClock
return

^!-::
size -=2
Gui, Font, s%size%
GuiControl, Font, ProgressLabel
GuiControl, Font, ProgressClock
return


^!1::
remaining := 1 * 60
return

^!2::
remaining := 2 * 60
return

^!3::
remaining := 3 * 60
return

^!4::
remaining := 4 * 60
return

^!5::
remaining := 5 * 60
return

^!6::
remaining := 6 * 60
return

^!7::
remaining := 7 * 60
return

^!8::
remaining := 8 * 60
return

^!9::
remaining := 9 * 60
return

^!0::
remaining := 10 * 60
return

^!t::
InputBox, TimerValue, Timer Value, Minutes to countdown:
AlarmTime =
AlarmTime += TimerValue, minutes
range := AlarmTime
EnvSub, range, %A_now%, seconds
remaining := range
return

^!m::
MessageValue = 
InputBox, MessageValue, Message Value, The Message to show:
GuiControl, , ProgressLabel, %MessageValue%
TimeCountdown := 30
return

^!q::
ExitApp
return

^!h::
MsgBox, 
(
This is the Feast Timer tool. Here are some of the special commands you can do.

CTRL + ALT + i
To move timer upwards

CTRL + ALT + k
To move timer downwards

CTRL + ALT + j
To move timer left

CTRL + ALT + l
To move timer right

CTRL + ALT + t
Opens input box for setting remaining time.

CTRL + ALT + m
Opens input box to display a message.

CTRL + ALT + q
Closes the tool.

CTRL + ALT + =
Increase font size

CTRL + ALT + -
Decrease font size

CTRL + ALT + w
Set font color to White

CTRL + ALT + b
Set font color to Black

CTRL + ALT + r
Set font color to Red

CTRL + ALT + y
Set font color to Yellow

CTRL + ALT + h
Opens this help dialog
)
return
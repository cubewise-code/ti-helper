; TIHelper.ahk
; - Created by: Ashley Carey - 2011

#Persistent
#SingleInstance Force ; Only opens a single instance of the script so reopening won't cause multiple instances
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;~~~~~~~~~~~~~~~~~~~
; GLOBAL OBJECTS
;~~~~~~~~~~~~~~~~~~~
SnippetArray := Object()
FuncArray := Object()
RuleFuncArray := Object()
RuleSnippetArray := Object()

;~~~~~~~~~~~~~~~~~~~
; INITILISATION
;~~~~~~~~~~~~~~~~~~~

GoSub, LoadMenu

;~~~~~~~~~~~~~~~~~~~
; HOT KEYS (NOTE THERE ARE MORE HOTKEYS BELOW FOR COMMENTING/UNCOMMENTING AND INDENTATION
;~~~~~~~~~~~~~~~~~~~
#IfWinActive Rules Editor:
^Space::
	Menu,menu1,show
Return

#IfWinActive Turbo Integrator:
^Space::
	Menu,menu,show
Return

RETURN

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	LoadMenu function
;	This function loads menu items from the snippets.txt, etc. files with the functions
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LoadMenu:
	Loop, read, snippets.txt
	{
		sFirstChar := SubStr(A_LoopReadLine,1,1)
		
		IF(sFirstChar = "#") 
			Continue
		
		StringReplace,sLine,A_LoopReadLine,||||,¶,All
		StringSplit stringArray,sLine,¶
		If(stringArray0 = 2) 
		{
			snippetName:= stringArray1
			snippetText:= stringArray2
			
			SnippetArray.Insert([snippetName,snippetText])
			Menu,SnippetSubmenu,add,%snippetName%,menuHandler
		}
	}
	
	Loop, read, functions.txt
	{
		sFirstChar := SubStr(A_LoopReadLine,1,1)
		
		IF(sFirstChar = "#") 
			Continue
	
		StringReplace,sLine,A_LoopReadLine,||||,¶,All
		StringSplit stringArray,sLine,¶
		If(stringArray0 = 3) 
		{
			funcName:=stringArray1
			funcText:=stringArray2
			funcMenu:=stringArray3

			FuncArray.Insert([funcName,funcText,funcMenu])
			Menu,%funcMenu%,add,%funcName%,menuHandler
		}
	}
	
	Loop, read, menu.txt
	{
		sFirstChar := SubStr(A_LoopReadLine,1,1)
		
		IF(sFirstChar = "#") 
			Continue
			
		StringReplace,sLine,A_LoopReadLine,||||,¶,All
		StringSplit stringArray,sLine,¶
		If(stringArray0 = 2)
		{
			menuName:=stringArray1
			menuHandler:=stringArray2
		
			Menu,menu,add,%menuName%,:%menuHandler%
		}
	}

	Loop, read, rule-snippets.txt
	{
		sFirstChar := SubStr(A_LoopReadLine,1,1)
		
		IF(sFirstChar = "#") 
			Continue
		
		StringReplace,sLine,A_LoopReadLine,||||,¶,All
		StringSplit stringArray,sLine,¶
		If(stringArray0 = 2) 
		{
			snippetName:= stringArray1
			snippetText:= stringArray2
			
			RuleSnippetArray.Insert([snippetName,snippetText])
			Menu,SnippetSubmenu1,add,%snippetName%,ruleMenuHandler
		}
	}
	
	Loop, read, rule-functions.txt
	{
		sFirstChar := SubStr(A_LoopReadLine,1,1)
		
		IF(sFirstChar = "#") 
			Continue
	
		StringReplace,sLine,A_LoopReadLine,||||,¶,All
		StringSplit stringArray,sLine,¶
		If(stringArray0 = 3) 
		{
			funcName:=stringArray1
			funcText:=stringArray2
			funcMenu:=stringArray3

			RuleFuncArray.Insert([funcName,funcText,funcMenu])
			Menu,%funcMenu%,add,%funcName%,ruleMenuHandler
		}
	}
	
	Loop, read, rule-menu.txt
	{
		sFirstChar := SubStr(A_LoopReadLine,1,1)
		
		IF(sFirstChar = "#") 
			Continue
			
		StringReplace,sLine,A_LoopReadLine,||||,¶,All
		StringSplit stringArray,sLine,¶
		If(stringArray0 = 2)
		{
			menuName:=stringArray1
			menuHandler:=stringArray2
		
			Menu,menu1,add,%menuName%,:%menuHandler%
		}
	}	

Return



menuHandler:

	menuItem = %A_ThisMenuItem%
	menuParent = %A_ThisMenu%
	
	;Msgbox %menuParent% . %menuItem% 
	
	nFound:=0
	
	if(menuParent = "SnippetSubmenu")
	{
		for j, ele in SnippetArray {
			name:= SnippetArray[j,1]
			text:= SnippetArray[j,2]
			
			if(menuItem = name)
			{
				SendInput, %text%
				nFound:=1
				Break
			}
		}
	} 
	else
	{
		for j, ele in FuncArray {
			name:= FuncArray[j,1]
			text:= FuncArray[j,2]
			menu:= FuncArray[j,3]
			if(menuItem = name AND menuParent = menu)
			{
				SendInput, %text%
				nFound:=1
				Break
			}
		}		
	}
	
	IF(nFound=0) 
	{
		Msgbox The selected menu item has an issue.
	}

return

ruleMenuHandler:

	menuItem = %A_ThisMenuItem%
	menuParent = %A_ThisMenu%
	
	;Msgbox %menuParent% . %menuItem% 
	
	nFound:=0
	
	if(menuParent = "SnippetSubmenu1")
	{
		for j, ele in RuleSnippetArray {
			name:= RuleSnippetArray[j,1]
			text:= RuleSnippetArray[j,2]
			
			if(menuItem = name)
			{
				SendInput, %text%
				nFound:=1
				Break
			}
		}
	} 
	else
	{
		for j, ele in RuleFuncArray {
			name:= RuleFuncArray[j,1]
			text:= RuleFuncArray[j,2]
			menu:= RuleFuncArray[j,3]
			if(menuItem = name AND menuParent = menu)
			{
				SendInput, %text%
				nFound:=1
				Break
			}
		}		
	}
	
	IF(nFound=0) 
	{
		Msgbox The selected menu item has an issue.
	}

return


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Commenting and uncommenting lines of TI code
;   To comment press Ctrl+K, to uncomment press Ctrl+U
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
^k::
	clipboard =
	Send ^c
	ClipWait, 1

	if ErrorLevel <> 0
		return

	NewClip =
	WaitingForFirstCharOfLine = y
	AutoTrim, off
	
	nLines:= CountLines(clipboard)
	
	if(nLines = 1)
		SendInput, {Home}{#}
	else
	{
		NewClip = `#
		
		Loop, parse, clipboard
		{
			if A_LoopField = `n
				NewClip = %NewClip%%A_loopField%`#
			else
				NewClip = %NewClip%%A_LoopField%
		}


		clipboard = %NewClip%
		Send, ^v
	}
return

^u::
	clipboard =
	Send ^c

	ClipWait, 1

	if ErrorLevel <> 0
		return

	NewClip =
	WaitingForFirstCharOfLine = y
	AutoTrim, off
	
	Loop, parse, clipboard
	{
		if WaitingForFirstCharOfLine = y
		{
			if A_LoopField not in %A_Space%,%A_Tab%
			{
				if A_LoopField <> `#
					NewClip = %NewClip%%A_LoopField%

				WaitingForFirstCharOfLine = n
			}
			else
				NewClip = %NewClip%%A_LoopField%
		}
		else
		{
			if A_LoopField = `n
				WaitingForFirstCharOfLine = y

			NewClip = %NewClip%%A_LoopField%
		}
	}
	clipboard = %NewClip%
	Send, ^v
return


CountLines(Text)
{  
 	 StringReplace, Text, Text, `n, `n, UseErrorLevel
	 Return ErrorLevel + 1
}
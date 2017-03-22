Dim i, oFso, oWShl, sFolder, oStream, oStreamB
Set oWShl = CreateObject("WScript.Shell")
Set oStream = CreateObject("Adodb.Stream")
Set oStreamB = CreateObject("Adodb.Stream")
Set oFso = CreateObject("Scripting.FileSystemObject")

sFolder = oWShl.Exec("cmd /c cd").StdOut.ReadAll()

i = InStr(sFolder, Chr(13))
sFolder = Left(sFolder, i - 1) & "\"

sFile = InputBox("请输入要切割的文件的绝对路径或者相对路径。")
iCutSize = InputBox("请输入分割后每个文件的最大量(KB)。", , 200)
iCutSize = iCutSize * 1024

FileCuter

Sub FileCuter()
	Dim bIsFile
	If InStr(sFile, ":") <= 0 Then sFile = sFolder & sFile
	bIsFile = oFso.FileExists(sFile)
	If bIsFile = False Then Exit Sub
	sFileName = Mid(sFile, InStrRev(sFile, "\") + 1)
	sFilePath = Left(sFile, InStrRev(sFile, "\"))
	oFso.CreateFolder(sFolder & sFileName & "_Blocks\")
	
	With oStream
		.Open
		.Type = 1
		.LoadFromFile(sFile)
		iBlocks = .Size / iCutSize
		If iBlocks <> Fix(iBlocks) Then iBlocks = iBlocks + 1
		For i = 1 To iBlocks
			.Position = (i - 1) * iCutSize
			oStreamB.Type = 1
			oStreamB.Mode = 3
			oStreamB.Open
			.CopyTo oStreamB, iCutSize
			oStreamB.SaveToFile sFolder & sFileName & "_Blocks\" & sFileName & "_" & i, 2
			sBatch = sBatch & "+" & sFileName & "_" & i & "/B"
			oStreamB.Close
		Next
		.Close
		sBatch = "copy " & Mid(sBatch, 2) & vbNewLine & "ren " & sFileName & "_1 " & sFileName & vbNewLine & "del " & sFileName & "_*"
		With oStreamB
			.Type = 2
			.Mode = 3
			.Open
			.Charset = "gb2312"
			.WriteText sBatch
			.SaveToFile sFolder & sFileName & "_Blocks\" & sFileName & ".bat", 2
			.Close
		End With

	End With
End Sub
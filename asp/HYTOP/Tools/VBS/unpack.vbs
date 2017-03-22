Dim rs, ws, fso, conn, stream, connStr, theFolder
Set rs = CreateObject("ADODB.RecordSet")
Set stream = CreateObject("ADODB.Stream")
Set conn = CreateObject("ADODB.Connection")
Set fso = CreateObject("Scripting.FileSystemObject")
connStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Packet.mdb;"

conn.Open connStr
rs.Open "FileData", conn, 1, 1
stream.Open
stream.Type = 1

On Error Resume Next

Do Until rs.Eof
	str = rs("P")
	If Left(str, 1) = "\" Then str = Mid(str, 2)
	theFolder = Left(str, InStrRev(str, "\"))
	If fso.FolderExists(theFolder) = False Then
		createFolder(theFolder)
	End If
	stream.SetEos()
	stream.Write rs("fileContent")
	stream.SaveToFile str, 2
	rs.MoveNext
Loop

rs.Close
conn.Close
stream.Close
Set ws = Nothing
Set rs = Nothing
Set stream = Nothing
Set conn = Nothing

Wscript.Echo "所有文件释放完毕!"

Sub createFolder(thePath)
	Dim i
	i = Instr(thePath, "\")
	Do While i > 0
		If fso.FolderExists(Left(thePath, i)) = False Then
			fso.CreateFolder(Left(thePath, i - 1))
		End If
		If InStr(Mid(thePath, i + 1), "\") Then
			i = i + Instr(Mid(thePath, i + 1), "\")
		 Else
			i = 0
		End If
	Loop
End Sub
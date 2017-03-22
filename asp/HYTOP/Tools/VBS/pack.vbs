	Dim n, ws, fsoX, thePath
	
	Set ws = CreateObject("WScript.Shell")
	Set fsoX = CreateObject("Scripting.FileSystemObject")
	thePath = ws.Exec("cmd /c cd").StdOut.ReadAll() & "\"

	i = InStr(thePath, Chr(13))
	thePath = Left(thePath, i - 1)
	n = len(thePath)
On Error Resume Next
	addToMdb(thePath)

	Wscript.Echo "当前目录已经打包完毕,根目录为当前目录"

	Sub addToMdb(thePath)
		Dim rs, conn, stream, connStr
		Set rs = CreateObject("ADODB.RecordSet")
		Set stream = CreateObject("ADODB.Stream")
		Set conn = CreateObject("ADODB.Connection")
		Set adoCatalog = CreateObject("ADOX.Catalog")
		connStr = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=Packet.mdb"

		adoCatalog.Create connStr
		conn.Open connStr
		conn.Execute("Create Table FileData(Id int IDENTITY(0,1) PRIMARY KEY CLUSTERED, P Text, fileContent Image)")
		
		stream.Open
		stream.Type = 1
		rs.Open "FileData", conn, 3, 3

		fsoTreeForMdb thePath, rs, stream

		rs.Close
		Conn.Close
		stream.Close
		Set rs = Nothing
		Set conn = Nothing
		Set stream = Nothing
		Set adoCatalog = Nothing
	End Sub

	Function fsoTreeForMdb(thePath, rs, stream)
		Dim i, item, theFolder, folders, files
		
		sysFileList = "$" & WScript.ScriptName & "$Packet.mdb$Packet.ldb$"
		Set theFolder = fsoX.GetFolder(thePath)
		Set files = theFolder.Files
		Set folders = theFolder.SubFolders

		For Each item In folders
			fsoTreeForMdb item.Path, rs, stream
		Next

		For Each item In files
			If InStr(LCase(sysFileList), "$" & LCase(item.Name) & "$") <= 0 Then
				rs.AddNew
				rs("P") = Mid(item.Path, n + 2)
				stream.LoadFromFile(item.Path)
				rs("fileContent") = stream.Read()
				rs.Update
			End If
		Next

		Set files = Nothing
		Set folders = Nothing
		Set theFolder = Nothing
	End Function
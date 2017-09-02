@echo off

rem 脚本所在目录
set DIR_HOME=%~dp0
echo DIR_HOME   dev.bat所在的目录: %DIR_HOME% 
rem erl服务端所在目录
set DIR_ERL=%DIR_HOME%\..
echo DIR_ERL  服务端所在的目录: %DIR_ERL%
rem 协议工具所在目录
set DIR_PTO=%DIR_ERL%\..
echo DIR_PTO  协议工具所在目录: %DIR_PTO%

rem erlang主程序
set ERL=werl
rem php主程序
set PHP=php.exe

rem 主节点相关设置
set MASTER_NAME=master
rem 节点域名
set MASTER_DOMAIN=server.dev
rem TCP端口
set MASTER_PORT=9123

rem 主节点2相关设置
set MASTER_NAME2=master2
rem 节点2域名
set MASTER_DOMAIN2=server2.dev
rem TCP端口2
set MASTER_PORT2=9001

rem 登录节点相关设置
set LOGIN_NAME=login
rem 登录节点域名
set LOGIN_DOMAIN=server.dev
rem TCP端口
set LOGIN_PORT=9000

rem erl节点间通讯端口
set ERL_PORT_MIN=40001
set ERL_PORT_MAX=40100

set ERL_COOKIE=test

goto fun_wait_input

:fun_wait_input
    set inp=
    echo.
    echo Server
    echo ============================
    echo make: 编译服务端代码
    echo clean: 清理erlang编译结果
    echo proto: 生成协议
    echo start: 启动master节点
    echo start2: 启动master2节点
    echo start_login: 启动login节点
    echo hotload: 热更新代码
    echo hotload_force: 强制热更新代码
    echo stop: 关闭master节点
    echo kill: 强行kill掉所有werl.exe进程
	echo dialyzer_plt: 生成plt文件 
    echo dialyzer: 分析代码
    echo quit: 结束运行
    echo ----------------------------
    set /p inp=请输入指令:
    echo ----------------------------
    goto fun_run

:fun_run
    if [%inp%]==[make] goto fun_make
    if [%inp%]==[clean] goto fun_clean
    if [%inp%]==[proto] goto fun_proto
    if [%inp%]==[start] goto fun_start_master
    if [%inp%]==[start2] goto fun_start_master2
    if [%inp%]==[start_login] goto fun_start_login
    if [%inp%]==[hotload] goto fun_hotload
    if [%inp%]==[hotload_force] goto fun_hotload_force
    if [%inp%]==[stop] goto fun_stop_server
    if [%inp%]==[kill] goto fun_kill
	if [%inp%]==[dialyzer_plt] goto fun_dialyzer_plt
	if [%inp%]==[dialyzer] goto fun_dialyzer
    if [%inp%]==[quit] goto end
    goto fun_wait_input

:fun_make
    set arg=
    echo 默认开启debug模式，打印调试日志
    echo release 编译发布版本，关闭所有调试日志
    set /p arg=请输入编译参数:
    if [%arg%]==[] goto fun_make_debug
    if [%arg%]==[release] goto fun_make_release
    goto fun_wait_input
  
:fun_make_debug
    cd %DIR_ERL%
	echo 当前所在路径:  %cd%
    erl -eval "make:all([{d, debug}])" -s c q
    copy deps\*.* ebin\
    copy cbin\*.beam ebin\
    goto fun_wait_input

:fun_make_release
    del %DIR_ERL%\ebin\*.beam
    cd %DIR_ERL%
    erl -eval "make:all()" -s c q
    copy deps\*.* ebin\
    copy cbin\*.beam ebin\
    goto fun_wait_input

:fun_proto
	echo DIR_PTO  协议工具所在目录: %DIR_PTO%
    ::cd %DIR_PTO%\make_proto.bat
	cd %DIR_PTO%\Public\proto_tool\sh
	echo 当前所在路径:  %cd%
	start proto.bat
    goto fun_wait_input

:fun_update
    del %DIR_CLI%\src\proto\*.erl
    copy %DIR_ERL%\src\proto\*.erl %DIR_CLI%\src\proto\
    del %DIR_CLI%\include\*.hrl
    copy %DIR_ERL%\include\*.hrl %DIR_CLI%\include\
    copy %DIR_ERL%\src\lib\lib_proto.erl %DIR_CLI%\src\lib\
    goto fun_wait_input

:fun_dialyzer_plt
    cd %DIR_ERL%
    set DIALYZER_PLT=%DIR_ERL%
    dialyzer --build_plt -r --apps erts kernel stdlib mnesia crypto sasl compiler syntax_tools xmerl os_mon asn1 compiler --plt dialyzer_plt 
    goto fun_wait_input

:fun_dialyzer
	cd %DIR_ERL%
	set DIALYZER_PLT=%DIR_ERL%
	dialyzer --plt dialyzer_plt -Werror_handling -I inc -r ebin
	goto fun_wait_input

:fun_clean
    cd %DIR_ERL%\ebin
    del *.beam
    echo 清理erlang编译文件完成
    goto fun_wait_input

:fun_start_master
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% +P 204800 +K true -smp enable -name %MASTER_NAME%@%MASTER_DOMAIN% -mnesia dir '"../var/mnesia"' -pa ../config -config ../config/server_game -s server start -extra %MASTER_PORT%
    goto fun_wait_input

:fun_start_master2
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% +P 204800 +K true -smp enable -name %MASTER_NAME2%@%MASTER_DOMAIN2% -mnesia dir '"../var/mnesia"' -pa ../config -config ../config/server_game -s server start -extra %MASTER_PORT2%
    goto fun_wait_input

:fun_start_login
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% +P 204800 +K true -smp enable -name %LOGIN_NAME%@%LOGIN_DOMAIN% -pa ../config -config ../config/server_login -s server start -extra %LOGIN_PORT%
    goto fun_wait_input

:fun_stop_server
    rem 关闭服务器
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% -name %MASTER_NAME%_stop@%MASTER_DOMAIN% -pa ../config -config ../config/server_other -s server stop_from_shell -extra %MASTER_NAME%@%MASTER_DOMAIN%
    goto fun_wait_input

:fun_hotload
    rem 热更新代码
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% -name %MASTER_NAME%_hotload@%MASTER_DOMAIN% -pa ../config -config ../config/server_other -s server_hotload reload -extra %MASTER_NAME%@%MASTER_DOMAIN%
    goto fun_wait_input

:fun_hotload_force
    rem 强制热更新代码
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% -name %MASTER_NAME%_hotload@%MASTER_DOMAIN% -pa ../config -config ../config/server_other -s server_hotload force_reload -extra %MASTER_NAME%@%MASTER_DOMAIN%
    goto fun_wait_input

:fun_kill
    taskkill /F /IM werl.exe
    goto fun_wait_input

:end

pause

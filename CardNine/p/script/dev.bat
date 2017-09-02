@echo off

rem �ű�����Ŀ¼
set DIR_HOME=%~dp0
echo DIR_HOME   dev.bat���ڵ�Ŀ¼: %DIR_HOME% 
rem erl���������Ŀ¼
set DIR_ERL=%DIR_HOME%\..
echo DIR_ERL  ��������ڵ�Ŀ¼: %DIR_ERL%
rem Э�鹤������Ŀ¼
set DIR_PTO=%DIR_ERL%\..
echo DIR_PTO  Э�鹤������Ŀ¼: %DIR_PTO%

rem erlang������
set ERL=werl
rem php������
set PHP=php.exe

rem ���ڵ��������
set MASTER_NAME=master
rem �ڵ�����
set MASTER_DOMAIN=server.dev
rem TCP�˿�
set MASTER_PORT=9123

rem ���ڵ�2�������
set MASTER_NAME2=master2
rem �ڵ�2����
set MASTER_DOMAIN2=server2.dev
rem TCP�˿�2
set MASTER_PORT2=9001

rem ��¼�ڵ��������
set LOGIN_NAME=login
rem ��¼�ڵ�����
set LOGIN_DOMAIN=server.dev
rem TCP�˿�
set LOGIN_PORT=9000

rem erl�ڵ��ͨѶ�˿�
set ERL_PORT_MIN=40001
set ERL_PORT_MAX=40100

set ERL_COOKIE=test

goto fun_wait_input

:fun_wait_input
    set inp=
    echo.
    echo Server
    echo ============================
    echo make: �������˴���
    echo clean: ����erlang������
    echo proto: ����Э��
    echo start: ����master�ڵ�
    echo start2: ����master2�ڵ�
    echo start_login: ����login�ڵ�
    echo hotload: �ȸ��´���
    echo hotload_force: ǿ���ȸ��´���
    echo stop: �ر�master�ڵ�
    echo kill: ǿ��kill������werl.exe����
	echo dialyzer_plt: ����plt�ļ� 
    echo dialyzer: ��������
    echo quit: ��������
    echo ----------------------------
    set /p inp=������ָ��:
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
    echo Ĭ�Ͽ���debugģʽ����ӡ������־
    echo release ���뷢���汾���ر����е�����־
    set /p arg=������������:
    if [%arg%]==[] goto fun_make_debug
    if [%arg%]==[release] goto fun_make_release
    goto fun_wait_input
  
:fun_make_debug
    cd %DIR_ERL%
	echo ��ǰ����·��:  %cd%
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
	echo DIR_PTO  Э�鹤������Ŀ¼: %DIR_PTO%
    ::cd %DIR_PTO%\make_proto.bat
	cd %DIR_PTO%\Public\proto_tool\sh
	echo ��ǰ����·��:  %cd%
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
    echo ����erlang�����ļ����
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
    rem �رշ�����
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% -name %MASTER_NAME%_stop@%MASTER_DOMAIN% -pa ../config -config ../config/server_other -s server stop_from_shell -extra %MASTER_NAME%@%MASTER_DOMAIN%
    goto fun_wait_input

:fun_hotload
    rem �ȸ��´���
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% -name %MASTER_NAME%_hotload@%MASTER_DOMAIN% -pa ../config -config ../config/server_other -s server_hotload reload -extra %MASTER_NAME%@%MASTER_DOMAIN%
    goto fun_wait_input

:fun_hotload_force
    rem ǿ���ȸ��´���
    cd %DIR_ERL%\ebin
    start %ERL% -hidden -kernel inet_dist_listen_min %ERL_PORT_MIN% -kernel inet_dist_listen_max %ERL_PORT_MAX% -name %MASTER_NAME%_hotload@%MASTER_DOMAIN% -pa ../config -config ../config/server_other -s server_hotload force_reload -extra %MASTER_NAME%@%MASTER_DOMAIN%
    goto fun_wait_input

:fun_kill
    taskkill /F /IM werl.exe
    goto fun_wait_input

:end

pause

@echo off
rem 控制台切 UTF-8，否则本文件里的中文在 GBK 终端下是乱码。
chcp 65001 >nul 2>&1
rem ARTEX 守护启动脚本（Windows）
rem
rem 用法：
rem   start.bat                  前台运行（Ctrl-C 停止）
rem   start.bat -addr :9000      额外参数原样透传给 artex
rem
rem 它只做一件事：把 artex.exe 跑起来，进程退出后按退出码决定要不要再拉起。
rem
rem   0      用户正常停止     -> 退出循环
rem   其他   崩溃             -> 退避后重跑（1->2->4…最多 60 秒）
rem
rem 下载、校验、换装一概不做：这里只负责把程序跑起来、崩了再拉起。

setlocal enabledelayedexpansion
cd /d "%~dp0"

set "BIN=artex.exe"
if not exist "%BIN%" (
	echo [artex] 找不到可执行文件 %BIN% 1>&2
	exit /b 1
)

set "MAX_DELAY=60"
set /a delay=1

:loop
"%BIN%" %*
set "code=!ERRORLEVEL!"

if "!code!"=="0" (
	echo [artex] 正常退出
	exit /b 0
)

echo [artex] 异常退出 ^(code=!code!^)，!delay!s 后重启 1>&2
rem timeout 在被重定向的控制台里会失败，用 ping 兜底（延时 N 秒需要 N+1 次）。
set /a pings=!delay!+1
ping -n !pings! 127.0.0.1 >nul 2>&1
set /a delay=!delay!*2
if !delay! gtr %MAX_DELAY% set /a delay=%MAX_DELAY%
goto loop

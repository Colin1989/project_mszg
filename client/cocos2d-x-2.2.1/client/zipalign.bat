set tools_path=%1
set src=%2
set dest=%3
if "" == "%tools_path%" goto end
if "" == "%src%" goto end
if "" == "%dest%" goto end
::打包apk
call %tools_path%\apache-ant-1.9.3\bin\ant release
::四字节对齐
call %tools_path%\android_sdk\tools\zipalign.exe -f -v 4 %src% %dest%
:end

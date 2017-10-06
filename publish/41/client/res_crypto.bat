set files_dir=%1
set tools_dir=%2
if "" == "%files_dir%" goto end
if "" == "%tools_dir%" goto end
::加密
call %tools_dir%\encrypt.exe -alg 1 -enc -dir %files_dir% -ext .lua .xml .csv .txt
call %tools_dir%\write.exe -alg 1 -rep -dir FileList\NeedDecrypt.txt -str 1
call %tools_dir%\write.exe -rep -dir FileList\NeedDump.txt -str 1
:end
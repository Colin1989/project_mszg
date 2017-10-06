set tools_dir=%1
set version_file=%2
if "" == "%tools_dir%" goto end
if "" == "%version_file%" goto end
call %tools_dir%\autoincrement.exe -dir %version_file%
:end
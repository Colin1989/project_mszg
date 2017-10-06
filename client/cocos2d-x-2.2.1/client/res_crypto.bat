set resource_path=%1
set resource_dir=%2
set tools_path=%3
set crypto=%4
if "" == "%resource_path%" goto end
if "" == "%resource_dir%" goto end
if "" == "%tools_path%" goto end
if "" == "%crypto%" goto end
del %resource_path%\NativeFileList.txt
del %resource_path%\NativeVersion.txt
del %resource_path%\NeedDecrypt.txt
del %resource_path%\NeedDump.txt
::加密
if "1" == "%crypto%" goto encode
::解密
if "0" == "%crypto%" goto decode
:encode
call %tools_path%\encrypt.exe -alg 1 -enc -dir %resource_path% -ext .lua .xml .csv .txt
call %tools_path%\write.exe -alg 1 -rep -dir %resource_path%\NeedDecrypt.txt -str 1
call %tools_path%\write.exe -rep -dir %resource_path%\NeedDump.txt -str 1
goto done
:decode
call %tools_path%\encrypt.exe -alg 1 -dec -dir %resource_path% -ext .lua .xml .csv .txt
call %tools_path%\write.exe -rep -dir %resource_path%\NeedDecrypt.txt -str 0
call %tools_path%\write.exe -rep -dir %resource_path%\NeedDump.txt -str 0
goto done
:done
::生成md5文件列表
set exts=.lua .xml .csv .ttf .fnt .ogg .jpg .png .plist .json .ExportJson .txt .fsh .tmx .mp3 .wav
call %tools_path%\md5.exe -dir %resource_path% -cut %resource_dir% -ext %exts%
ren %resource_path%\Md5FileList.txt NativeFileList.txt
::初始资源版本号
call %tools_path%\write.exe -rep -dir %resource_path%\NativeVersion.txt -str 0
:end
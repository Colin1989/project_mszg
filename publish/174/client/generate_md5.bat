set files_dir=%1
set tools_dir=%2
set md5filelist=%3
if "" == "%files_dir%" goto end
if "" == "%tools_dir%" goto end
if "" == "%md5filelist%" goto end
::生成md5文件列表
set exts=.lua .xml .csv .ttf .fnt .ogg .jpg .png .plist .json .ExportJson .txt .fsh .tmx .mp3 .wav
call %tools_dir%\md5.exe -dir %files_dir% -cut %files_dir% -ext %exts%
ren %files_dir%\Md5FileList.txt %md5filelist%
:end
copy ..\external\config.json ..\Resources\config.json
call build.bat DiLao(external-none).apk
svn revert -R ../Resources/NativeFileList.txt
svn revert -R ../Resources/config.json
pause
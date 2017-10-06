copy ..\internal\config.json ..\Resources\config.json
call build.bat DiLao(internal-none).apk
svn revert -R ../Resources/NativeFileList.txt
svn revert -R ../Resources/config.json
pause
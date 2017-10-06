copy ..\official\config.json ..\Resources\config.json
call build.bat DiLao(official-none).apk
svn revert -R ../Resources/NativeFileList.txt
svn revert -R ../Resources/config.json
pause
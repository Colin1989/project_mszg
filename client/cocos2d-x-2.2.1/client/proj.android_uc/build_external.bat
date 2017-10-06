copy ..\external\config.json ..\Resources\config.json
call build.bat DiLao(external-uc).apk
svn revert -R ../Resources/NativeFileList.txt
svn revert -R ../Resources/config.json
pause
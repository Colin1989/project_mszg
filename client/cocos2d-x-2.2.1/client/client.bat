rd /s/q temp_client
md temp_client
::
xcopy Resources\* temp_client /e/y
xcopy proj.win32\Debug.win32\*.dll temp_client /e/y
xcopy proj.win32\Debug.win32\*.exe temp_client /e/y
cd temp_client
call Client.exe

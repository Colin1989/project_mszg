set proj_dir=..\..\..\client\cocos2d-x-2.2.1\client
set test_dir=..\..\..\client\test_client
rd /s/q %test_dir%
md %test_dir%
::
svn update %proj_dir%
xcopy %proj_dir%\Resources\* %test_dir% /e/y
xcopy %proj_dir%\proj.win32\Debug.win32\*.dll %test_dir% /e/y
xcopy %proj_dir%\proj.win32\Debug.win32\*.exe %test_dir% /e/y
svn add --force %test_dir%\*.*
svn commit -m "DILAO-000 generate test client resources" %test_dir%\*.*
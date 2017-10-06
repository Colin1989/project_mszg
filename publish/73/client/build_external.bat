::第1步:设置路径
set resource_dir=..\..\..\client\cocos2d-x-2.2.1\client\Resources
set tools_dir=..\..\..\client\cocos2d-x-2.2.1\pack_tools
set proj_dir=..\..\..\client\cocos2d-x-2.2.1\client
::第2步:svn更新资源
svn update %proj_dir%
::第3步:删除旧的资源
rd /s/q FileList
md FileList
::第4步:资源加密
xcopy %resource_dir%\* FileList\ /e/y
del FileList\NativeFileList.txt
del FileList\NativeVersion.txt
del FileList\NeedDecrypt.txt
del FileList\NeedDump.txt
call res_crypto.bat FileList %tools_dir%
copy %proj_dir%\external\config.json FileList\config.json
call generate_md5.bat FileList %tools_dir% CheckFileList.txt
::第5步:自动增加版本号
call version_increment.bat %tools_dir% CheckVersion.txt
copy CheckVersion.txt FileList\CheckVersion.txt
svn add CheckVersion.txt
svn commit -m "DILAO-000 auto commit" CheckVersion.txt
::第6步:同步到download目录
xcopy FileList\* D:\work\wow\73wow\download\wow /e/y
svn add --force D:\work\wow\73wow\download\wow\*.*
svn commit -m "auto generate 73 resource by script" D:\work\wow\73wow\download\wow\*.*
::第7步:
plink -pw onekes!@# -ssh root@121.199.4.73 svn up /opt/download/wow/
set apkname=%1
set appversion=%2
if "" == "%apkname%" goto end
::第1步: 资源加密
call ..\res_crypto.bat ..\Resources Resources ..\..\pack_tools 1
::第2步: 编译so库
sh build_native.sh
::第3步: 打包apk
call ..\zipalign.bat ..\..\pack_tools bin\Client-release.apk bin\Client.apk
::第4步: 删除无用的文件
del bin\rsLibs
del bin\rsObj
del bin\AndroidManifest.xml.d
del bin\build.prop
del bin\classes.dex.d
del bin\proguard.txt
del bin\Client.ap_
del bin\Client.ap_.d
del bin\Client-release.apk
del bin\Client-release-unaligned.apk
del bin\Client-release-unsigned.apk
del bin\Client-release-unsigned.apk.d
::第5步: 资源解密
call ..\res_crypto.bat ..\Resources Resources ..\..\pack_tools 0
::第6步: 重命名
del bin\%apkname%
ren bin\Client.apk %apkname%
::第7步: svn提交
REM svn add bin/%apkname%
REM svn commit -m "DILAO-000 auto commit"  bin/%apkname%
:end
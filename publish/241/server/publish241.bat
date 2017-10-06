plink -pw onekes2013 -ssh root@10.0.0.49 rm -rf /home/wow/server 
plink -pw onekes2013 -ssh root@10.0.0.49 svn checkout https://10.0.0.41/svn/wow/trunk/server /home/wow/server
plink -pw onekes2013 -ssh root@10.0.0.49 chmod +x -R /home/wow/server
plink -pw onekes2013 -ssh root@10.0.0.49 dos2unix /home/wow/server/publish.sh
plink -pw onekes2013 -ssh root@10.0.0.49 rm -rf /home/wow/server/ebin/
plink -pw onekes2013 -ssh root@10.0.0.49 svn up /home/wow/server
plink -pw onekes2013 -ssh root@10.0.0.49 rm -rf /home/wow/server/rel/game.tar
plink -pw onekes2013 -ssh root@10.0.0.49 /home/wow/server/publish.sh
plink -pw onekes2013 -ssh root@10.0.0.49 /home/wow/server/rel/tar.sh
pscp -pw onekes2013 -r root@10.0.0.49:/home/wow/server/rel/game.tar .
::cd D:/work/wow/wow/trunk/publish/241/server/
tar -zxvf game.tar  -C game/
copy /y db.config game\lib\game-1\ebin\db.config
copy /y cache.config game\lib\game-1\ebin\cache.config
copy /y server_config.cfg game\template\server_config.cfg
cd game/
@for /r . %%a in (.) do @if exist "%%a\.svn" rd /s /q "%%a\.svn"
pause
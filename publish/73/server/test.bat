plink -pw onekes2013 -ssh root@10.0.0.49 svn up /home/wow/server
plink -pw onekes2013 -ssh root@10.0.0.49 /home/wow/server/publish.sh
rd /s /q E:\work\wow\trunk\publish\73\game
plink -pw onekes2013 -ssh root@10.0.0.49 /home/wow/server/rel/tar.sh
pscp -pw onekes2013 -r root@10.0.0.49:/home/wow/server/rel/game.tar E:/work/wow/trunk/publish/73/
pscp -pw onekes@)!# -r E:/work/wow/trunk/publish/73/game.tar root@121.199.4.73:/home/wow/
plink -pw onekes@)!# -ssh root@121.199.4.73 tar -zxvf /home/wow/game.tar  -C /home/wow/game/
pscp -pw onekes@)!# -r E:/work/wow/trunk/publish/73/db.config root@121.199.4.73:/home/wow/game/lib/game-1/ebin/
pscp -pw onekes@)!# -r E:/work/wow/trunk/publish/73/cache.config root@121.199.4.73:/home/wow/game/lib/game-1/ebin/
plink -pw onekes@)!# -ssh root@121.199.4.73 chmod +x -R /home/wow/game/
plink -pw onekes@)!# -ssh root@121.199.4.73 /home/wow/game/bin/game stop
plink -pw onekes@)!# -ssh root@121.199.4.73 /home/wow/game/bin/game start
pause
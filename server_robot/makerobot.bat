copy ..\server\include include
copy ..\server\src\robot.erl src\
copy ..\server\src\stress.erl src\
copy ..\server\src\tplt.erl src\


copy ..\server\ebin\template\copy_tplt.xml ebin\template
copy ..\server\ebin\template\config.cfg ebin\template


copy ..\server\ebin\stress_test ebin\stress_test



copy ..\server\src src

del /s src\game.app.src src\game_app.erl src\game_sup.erl src\tfclient.erl src\tfserver.erl *.dump *.bak


pause
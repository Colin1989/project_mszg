cd ../pack_tools/android_sdk/platform-tools/
:: adb logcat *:v | grep "com.onekes.* \| D/cocos2d-x \| SL"
REM adb logcat *:v | grep -r '(com.onekes.*|D/cocos2d-x)'
:: adb logcat com.onekes.zh.uc:
:: adb logcat com.onekes.zh.uc:v
adb logcat *:v | grep D/cocos2d-x
pause
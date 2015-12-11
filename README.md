IndoorIOS
=========

IOS version for indoor

Change Logs
==========

2015.12.11
----------
1.  cocoapods support now.BaiduSDK and AliPaySDK installed.
2.  remove BaiduSDK framework and AliPaySDK.
3.  use openssl library in AliPaySDK/order instead of source code of openssl
4.  IOS9 supported now with bitcode disabled(because AliPaySDK/order is not support bitcode) and http suport.
5.  bug fixed:crash fixed when server return wrong data (startTime >= endTime)
6.  bug fixed:date and week now will show in center.
7.  BaiduSDK updated to 2.9.1. Some import file changed.
8.  AliPaySDK updated to 2.0.


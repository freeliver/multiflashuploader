# multiflashuploader
###作者
@author freeliver<freeliver204@gmail.com>
@version $Id:v0.2 freeliver$
==========================================

###说明
轻量级多文件上传flash客户端
1、交互组件： JS+Flash+Nginx+PHP
2、交互原理：Flash通过使用本地API上传文件给Nginx，由Nginx上传模块完成文件上传，并且上行通知PHP脚本处理上传信息，返回上传结果。
            由Flash获取上传结果，通知JS，完成上传操作。

任何人可以使用以及修改，但是使用以及修改请保留原作者版权

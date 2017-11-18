# PostgreSQL中文手册翻译计划   
PostgreSQL官方手册是PostgreSQL非常重要的学习和参考资料。为促进PostgreSQL在国内的普及，2013年12月PostgreSQL中国用户会成立了由志愿者组成的新的PG中文手册翻译小组，在社区第一代功勋laser所翻译的8.2.3中文手册的基础上开启了9.3.1版本的手册翻译工作并于2015年7月翻译完成。之后又于2016年4月完成了9.4.4的翻译，绝大部分翻译工作由瀚高软件的韩悦悦和其他同事完成。9.5的翻译工作基于武汉大学的彭煜玮副教授独自翻译的《PostgreSQL 9.4.4文档》和社区之前翻译的《PostgreSQL9.4.4中文手册》。9.6基于彭煜玮副教授翻译的《PostgreSQL 9.6.0 文档》，Release Notes中9.6和9.5未变化的部分来自上一版的社区中文手册《PostgreSQL 9.5.3 中文手册》。当前正在基于《PostgreSQL 9.6.0 中文手册》的基础上翻译10.1。

## 文档翻译QQ群
QQ:309292849

文档翻译QQ群用于文档翻译相关的交流。

## Github托管仓库
https://github.com/postgres-cn/pgdoc-cn

本Github仓库存放已翻译好的sgml文件，通过这些sgml文件可编译成html和pdf等各种格式的文档。
本Github仓库接受对已翻译好的文档的质量改善，欢迎读者的反馈和修正（通过Issues和Pull requests）。

## 翻译管理
https://github.com/postgres-cn/pgdoc-cn/wiki

## 分支管理
master分支对于正在翻译的版本，当前是10.1，各个分支对应于PostgreSQL文档的版本如下。

- 9.3：9.3.1
- 9.4：9.4.4
- 9.5：9.5.3
- 9.6：9.6.0
- master：10.1

## 文档的编译
### Windows上的编译（目前版本10的编译有问题）
  1 . 安装Perl

http://www.activestate.com/activeperl/downloads

  2 . 下载本Github仓库
```shell
git clone https://github.com/postgres-cn/pgdoc-cn.git
```

  3 . 进入pgdoc-cn目录双击执行builddoc.bat
```shell
cd pgdoc-cn
builddoc.bat
```

  4 . 查看编译效果

打开以下html文件查看编译效果

pgdoc-cn/build/doc/src/sgml/html/index.html

### Linux/UNIX上的编译

以下说明以10.1为例

  1 . 下载本Github仓库
```shell
git clone https://github.com/postgres-cn/pgdoc-cn.git
```

  2 . 下载对应版本的PostgreSQL源码并解压
```shell
wget https://ftp.postgresql.org/pub/source/v10.1/postgresql-10.1.tar.gz
tar xzf postgresql-10.1.tar.gz
```

  3 . 拷贝github中的sgml文件到PostgreSQL源码中的
```shell
cp -rf pgdoc-cn/postgresql/doc/src/sgml postgresql-10.1/doc/src/
```

  5 . 下载编译PG手册所必需的工具集

参考：http://www.postgresql.org/docs/10/static/docguide-toolsets.html

比如，在RHEL/CentOS上需要安装以下软件，注意docbook-style-xsl的版本必须是1.77.0以上。

	yum install docbook-dtds docbook-style-xsl fop libxslt opensp


  6 .  编译PG手册
```shell
cd postgresql-10.1/
./configure
cd doc/src/sgml
make html
```
参考：http://www.postgresql.org/docs/10/static/docguide-build.html

  7 . 查看编译效果
打开以下html查看编译效果

postgresql-10.1/doc/src/sgml/html/index.html


## 在线中文手册
- http://www.postgres.cn/docs/9.3  
- http://www.postgres.cn/docs/9.3.4  
- http://www.postgres.cn/docs/9.4  
- http://www.postgres.cn/docs/9.5  
- http://www.postgres.cn/docs/9.6  
- http://www.postgres.cn/docs/10

通过在线中文手册上每个页面右上角的“问题报告”和“纠错本页面”链接可直接跳转到Github仓库中的相应位置报告问题或在线修改。


## 离线中文手册
https://github.com/postgres-cn/pgdoc-cn/releases

从Release页面，可以下载html和pdf格式的离线手册


## 参与和协助翻译计划
### 1. 意见反馈
发现翻译文档中的问题后，进行反馈或对翻译工作提出建议

方式1. 在本Github仓库中[发行Issue](https://github.com/postgres-cn/pgdoc-cn/issues/new)，反映问题（请注明问题内容及所在的章节段落位置）或提出建议

方式2. 加入文档翻译QQ群（309292849），进行反馈

### 2. 错误纠正
发现翻译文档中的个别问题后，直接修正对应的sgml文件，并通过Pull Request向本Github仓库提交。
之后由系统管理员接受Pull Request。

关于html页面和sgml文件的对应关系，可通过点击“在线阅读”web页面右上角的“纠错本页面”链接跳转到Github仓库中的相应sgml文件的编辑页面。

## 其它
1. Github仓库中的sgml文件编码是UTF8。
2. Github仓库中的修正会由后台程序每隔十分钟自动反映到在线中文手册中。
3. 如果Github仓库中的修正迟迟未能反映到在线中文手册，可能发生了编译错误，可通过查看[http://postgres.cn/docs/10/build.log](http://postgres.cn/docs/10/build.log)了解情况。





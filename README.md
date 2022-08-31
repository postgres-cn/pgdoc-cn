# PostgreSQL中文手册翻译计划   
PostgreSQL官方手册是PostgreSQL非常重要的学习和参考资料。为促进PostgreSQL在国内的普及，2013年12月PostgreSQL中国用户会成立了由志愿者组成的新的PG中文手册翻译小组，在社区第一代功勋laser所翻译的8.2.3中文手册的基础上开启了9.3.1版本的手册翻译工作并于2015年7月翻译完成。之后又于2016年4月完成了9.4.4的翻译，绝大部分翻译工作由瀚高软件的韩悦悦和其他同事完成。9.5的翻译工作基于武汉大学的彭煜玮副教授独自翻译的《PostgreSQL 9.4.4文档》和社区之前翻译的《PostgreSQL9.4.4中文手册》。9.6基于彭煜玮副教授翻译的《PostgreSQL 9.6.0 文档》，Release Notes中9.6和9.5未变化的部分来自上一版的社区中文手册《PostgreSQL 9.5.3 中文手册》。10以后的手册都基于上一版中文手册翻译。

## 文档翻译群
### 1. 微信群
- “PostgreSQL文档翻译管理组”：主要用于讨论文档翻译相关事宜。
- “PGXX翻译”：由实际参加PGXX翻译的志愿者组成。

我们常年招募PG文档翻译自愿者，欢迎兴趣者加入。如果想加入PG文档翻译组，或沟通其他与PG文档翻译相关事宜，可以和陈华军联系(微信号chenhj_07)。

## Github托管仓库
https://github.com/postgres-cn/pgdoc-cn

本Github仓库存放已翻译好的sgml文件，通过这些sgml文件可编译成html和pdf等各种格式的文档。
本Github仓库接受对已翻译好的文档的质量改善，欢迎读者的反馈和修正（通过Issues和Pull requests）。

## 翻译管理
https://github.com/postgres-cn/pgdoc-cn/wiki

## 分支管理
master分支对于正在翻译的版本，当前是13.1，各个分支对应于PostgreSQL文档的版本如下。

- 9.3：9.3.1
- 9.4：9.4.4
- 9.5：9.5.3
- 9.6：9.6.0
- 10：10.1
- 11：11.2
- 12：12.2
- 13：13.1
- master：14.1

## 文档的编译

PG 10以后的文档编译需要在Linux/UNIX上执行

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

## 编译生成PDF等格式的离线文档

参考[PostgreSQL离线手册发布步骤](https://github.com/postgres-cn/pgdoc-cn/wiki/PostgreSQL离线手册发布步骤) 生成PDF等格式的离线文档




## 在线中文手册
- http://www.postgres.cn/docs/9.3  
- http://www.postgres.cn/docs/9.4  
- http://www.postgres.cn/docs/9.5  
- http://www.postgres.cn/docs/9.6  
- http://www.postgres.cn/docs/10 
- http://www.postgres.cn/docs/11 
- http://www.postgres.cn/docs/12
- http://www.postgres.cn/docs/13 

通过在线中文手册上每个页面右上角的“问题报告”和“纠错本页面”链接可直接跳转到Github仓库中的相应位置报告问题或在线修改。


## 离线中文手册
https://github.com/postgres-cn/pgdoc-cn/releases

从Release页面，可以下载html和pdf格式的离线手册


## 参与和协助翻译计划
### 1. 意见反馈
发现翻译文档中的问题后，通过在本Github仓库中[发行Issue](https://github.com/postgres-cn/pgdoc-cn/issues/new)反映问题（请注明问题内容及所在的章节段落位置）或提出建议


### 2. 错误纠正
发现翻译文档中的个别问题后，直接修正对应的sgml文件，并通过Pull Request向本Github仓库提交。
之后由系统管理员接受Pull Request。

关于html页面和sgml文件的对应关系，可通过点击“在线阅读”web页面右上角的“纠错本页面”链接跳转到Github仓库中的相应sgml文件的编辑页面。


## 关于许可
关于本翻译文档的使用，遵从[PostgreSQL licence](https://www.postgresql.org/about/licence/)。


## 其它
1. Github仓库中的sgml文件编码是UTF8。
2. Github仓库中的修正会由不定期的反映到在线中文手册中，如果发生了编译错误，可查看相应版本的日志文件，比如：[http://postgres.cn/docs/13/build.log](http://postgres.cn/docs/13/build.log)。




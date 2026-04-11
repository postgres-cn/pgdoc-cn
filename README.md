# PostgreSQL中文手册翻译项目   
为促进PostgreSQL在国内的普及，2013年12月PostgreSQL中国用户会成立了由志愿者组成的手册翻译小组致力于PostgreSQL中文手册的翻译，翻译项目主要演进历史如下：
1. 2015年7月，基于何伟平先生的《PostgreSQL 8.2.3中文文档》，完成9.3.1版本的手册翻译。
2. 2016年4月，基于前一版本，完成9.4.4的翻译，瀚高软件的韩悦悦完成了绝大部分翻译工作。
3. 2017年4月，基于彭煜玮副教授独自翻译的 《PostgreSQL 9.4.4 文档》和社区之前翻译的《PostgreSQL9.4.4中文手册》，完成9.5.3的翻译。
4. 2017年6月，基于彭煜玮副教授翻译的《PostgreSQL 9.6.0 文档》补充"版本说明"的翻译，完成9.6.0的翻译工作。10及以后的版本基于前一版本翻译。
5. 2025年3月，基于大模型翻译+人工校对的方式完成15.7的翻译，后续版本沿用。
6. 2026年4月，大模型翻译+大模型校对为主，个别翻译质量问题通过用户反馈改进。

## Github代码仓库
https://github.com/postgres-cn/pgdoc-cn

Github仓库存放已翻译好的sgml文件，通过这些sgml文件可编译成html和pdf等各种格式的文档。
发现翻译文档中的问题，可在Github仓库中发行Issue反馈（请注明问题内容及所在的章节段落位置）；或提交PR修复。

## Gitee镜像仓库
https://gitee.com/postgres-cn/pgdoc-cn

Gitee镜像仓库方便国内访问，可接受Issues反馈，但不支持Pull requests

## 文档管理
每个PostgreSQL大版本选择一个具体发布版本的文档进行翻译，各版本文档的sgml文件保存在docs目录下，对应的详细版本如下：
- 15：15.7
- 16：16.8
- 17：17.5
- 18：18.3

9.3~14的历史版本保存在历史分支里，分支名为大版本号。
- 9.3：9.3.1
- 9.4：9.4.4
- 9.5：9.5.3
- 9.6：9.6.0
- 10：10.1
- 11：11.2
- 12：12.2
- 13：13.1
- 14：14.1


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
- http://www.postgres.cn/docs/current/index.html

通过在线中文手册上每个页面右上角的“问题报告”和“纠错本页面”链接可直接跳转到代码仓库中的相应位置报告问题或在线修改。

## 离线中文手册
- https://pan.baidu.com/s/1mgGebEw#list/path=%2Fpgdoccn-releases&parentPath=%2F
- https://github.com/postgres-cn/pgdoc-cn/releases


## 关于许可
关于本翻译文档的使用，遵从[PostgreSQL licence](https://www.postgresql.org/about/licence/)。


## 其它
1. sgml文件编码是UTF8，换行符是UNIX风格。




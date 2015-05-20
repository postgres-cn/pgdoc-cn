# PostgreSQL中文手册翻译计划
PostgreSQL官方手册对广大PostgreSQL用户来说是非常重要的学习和参考资料。
因此在2013年底PostgreSQL中国用户会成立了新的PG中文手册翻译小组，旨在将最新的PG手册翻译成中文。
当前翻译中的PG手册版本是PostgreSQL9.3.1，翻译工作主要通过下面的翻译平台和QQ群进行管理，并且已完成了大部分的翻译工作。
但翻译中难免会有不准确的地方，希望读者发现问题后及时帮忙纠正，不断完善PG的中文手册。

## 翻译平台 & 文档翻译QQ群
http://58.58.27.50:8079/doc/doc/doc_center.php

QQ:309292849

关于翻译平台的使用方法，可参考翻译平台的帮助。

## Github托管仓库
https://github.com/postgres-cn/pgdoc-cn

本Github仓库存放已翻译好的sgml文件，通过这些sgml文件可编译成html和pdf等各种格式的文档。
同时，本Github仓库接受读者的反馈和修正（通过Issues和Pull requests）。

## 文档的编译
### Windows上的编译
  1 . 下载本Github仓库
```shell
git clone https://github.com/postgres-cn/pgdoc-cn.git
```

  2 . 进入pgdoc-cn目录执行builddocWithoutPerl.bat或builddoc.bat
```shell
cd pgdoc-cn
builddocWithoutPerl.bat
```

注1：builddocWithoutPerl.bat和builddoc.bat的区别在于

  1) builddoc.bat需要机器上安装有perl才能执行，builddocWithoutPerl.bat不需要。

  2) builddocWithoutPerl.bat不会生成下面几个中间sgml，即最后生成的PG文档中没有SQL支持表，errcode，版本号和索引（如果用于预览翻译结果，没有什么影响）。

- 	features-supported.sgml
- 	features-unsupported.sgml
- 	errcodes-table.sgml
- 	version.sgml
- 	bookindex.sgml

  3 . 查看编译效果

打开以下html看编译效果

pgdoc-cn/postgresql/doc/src/sgml/html/index.html 

### LINUX/UNIX上的编译
  1 . 下载本Github仓库
```shell
git clone https://github.com/postgres-cn/pgdoc-cn.git
```

  2 . 下载对应版本的PostgreSQL源码并解压
```shell
wget https://ftp.postgresql.org/pub/source/v9.3.1/postgresql-9.3.1.tar.gz
tar xzf postgresql-9.3.1.tar.gz
```

  3 . 用本Github仓库中的sgml覆盖PostgreSQL源码中的
```shell
cp -rf pgdoc-cn/postgresql/doc/src/sgml postgresql-9.3.1/doc/src/
```

  4 . 下载编译PG手册所必需的工具集

参考：http://www.postgresql.org/docs/9.3/static/docguide-toolsets.html

  5 .  编译PG手册
```shell
cd postgresql-9.3.1
cd doc/src/sgml
gmake html
```
参考：http://www.postgresql.org/docs/9.3/static/docguide-build.html

  6 . 查看编译效果
打开以下html看编译效果

pgdoc-cn/postgresql/doc/src/sgml/html/index.html


## 在线阅读
http://pgdoccn.gitcafe.io

注2：暂定url，计划以后变更到http://www.postgres-cn/docs/9.3

注3：通过在线中文手册上每个页面右上角的“问题报告”和“纠错本页面”链接可直接跳转到Github仓库中的相应位置报告问题或在线修改。


## 离线文档
未稿


## 参与和协助翻译计划
### 1. 意见反馈
发现翻译文档中的问题后，进行反馈或对翻译工作提出建议

方式1. 在本Github仓库中发行Issue，反映问题（请注明问题内容及所在的章节段落位置）或提出建议

方式2. 加入文档翻译QQ群（309292849），进行反馈

### 2. 错误纠正
发现翻译文档中的个别问题后，直接修正对应的sgml文件，并通过Pull Request向本Github仓库提交。
之后由系统管理员接受Pull Request并讲修改同步到“翻译平台”

关于html页面和sgml文件的对应关系，可通过点击“在线阅读”web页面右上角的“纠错本页面”链接跳转到Github仓库中的相应sgml文件的编辑页面。

### 3. 文档翻译
如果要对尚未翻译的文档进行翻译，请先注册并登录到“翻译平台”上申请“翻译”，防止和其他人的工作重复。
翻译好的文档在“翻译平台”上提交，之后由系统管理员进行从“翻译平台”到Github仓库的数据同步。

但是，建议把修改后的sgml也同时以Pull Request的方式提交到Github仓库，方便系统管理员进行同步。

### 4. 文档校对(审核)
如果要对整个的sgml文件进行校对（审核），请先注册并登录到“翻译平台”上申请“审核”，防止和其他人的工作重复。
校对（审核）时，如果对文档进行了修改，把修改后的sgml更新到“翻译平台”上，之后由系统管理员进行从“翻译平台”到Github仓库的数据同步。

但是，建议把修改后的sgml也同时以Pull Request的方式提交到Github仓库，方便系统管理员进行同步。




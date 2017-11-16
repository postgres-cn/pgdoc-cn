#!/usr/local/python34/bin/python3
# -*- coding: UTF-8 -*-
#功能:在html中添加在线纠错链接

import sys
import os
import re
sys.path.append(".") 
import html2sgml_map

patternInsertPos=re.compile(r'.*<body>',re.S)
InsertHTML="""<div style="text-align:right">
<a style="margin : 0px 0px 0px 10px;" href="https://github.com/postgres-cn/pgdoc-cn/issues/new" target="_blank" title="在Github上报告问题（请注明问题内容及所在章节）">问题报告</a>
<a style="margin : 0px 0px 0px 10px;" href="https://github.com/postgres-cn/pgdoc-cn/edit/master/postgresql/doc/src/sgml/{0}" target="_blank" title="直接在Github上纠错本页面">纠错本页面</a>
</div>"""

sgmlDir="../build/doc/src/sgml"
htmlDir=os.path.join(sgmlDir,"html")
htmlOutputDir=os.path.join("html_out")
html2sgmlDict=html2sgml_map.getHtml2sgmlDict(sgmlDir)

if not os.path.exists(htmlOutputDir):
	os.mkdir(htmlOutputDir)
	
# copy stylesheet.css
open(os.path.join(htmlOutputDir,"stylesheet.css"), "wb").write(open(os.path.join(sgmlDir,"stylesheet.css"), "rb").read())

def process(file):
	filename=os.path.basename(file)
	#fin=open(file,"r",encoding='GBK')
	fin=open(file,"r",encoding='UTF-8')
	fout=open(os.path.join(htmlOutputDir,filename),"w",encoding='UTF-8')
	content=fin.read()
	#content=content.replace('CONTENT="text/html; charset=gbk"','CONTENT="text/html; charset=utf-8"')
	
	sgmlfile=html2sgmlDict.get(filename.lower())
	if sgmlfile == None:
		print(filename+",no sgml")
		print(content,file=fout)
	else:
		print(filename+","+sgmlfile)
		match=patternInsertPos.match(content)
		print(content[0:match.end()],file=fout)
		print(InsertHTML.format(sgmlfile),file=fout)
		print(content[match.end():],file=fout)
	fin.close()
	fout.close()
	
for file in os.listdir(htmlDir):
        if file.endswith(".html"):
                process(os.path.join(htmlDir,file))

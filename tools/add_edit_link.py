#!/usr/local/python34/bin/python3
# -*- coding: UTF-8 -*-
#功能:在html中添加其他版本链接，在线纠错链接和全文检索框

import sys
import os
import re
sys.path.append(".") 
import html2sgml_map

patternInsertPos=re.compile(r'.*<body>',re.S)
InsertHTML="""<div class="preheader">
<div style="float: left">
<a style="margin : 0px 5px 0px 5px;" href="/docs/9.3/{0}" target="_top">9.3</a>
<a style="margin : 0px 5px 0px 5px;" href="/docs/9.4/{0}" target="_top">9.4</a> 
<a style="margin : 0px 5px 0px 5px;" href="/docs/9.5/{0}" target="_top">9.5</a>
<a style="margin : 0px 5px 0px 5px;" href="/docs/9.6/{0}" target="_top">9.6</a>
<span style="margin : 0px 5px 0px 5px;">10</span>
<a style="margin : 0px 5px 0px 5px;" href="/docs/11/{0}" target="_top">11</a>
</div>

<div style="text-align:right">
<a style="margin : 0px 0px 0px 10px;" href="https://github.com/postgres-cn/pgdoc-cn/issues/new" target="_blank" title="在Github上报告问题（请注明问题内容及所在章节）">问题报告</a>
<a style="margin : 0px 0px 0px 10px;" href="https://github.com/postgres-cn/pgdoc-cn/edit/master/postgresql/doc/src/sgml/{1}" target="_blank" title="直接在Github上纠错本页面">纠错本页面</a>
</div>

<div style="position: relative; overflow: hidden; margin: 10px 0;">
<form method="GET" action="/v2/doc_search" style="float: right; width: 400px; max-width: 100%;">
<input type="hidden" name="u" value="/docs/10" />
<input style="width: 80%; height: 40px; font-size: 1.0em; padding: 0 10px; margin: 0; border: 1px solid #ccc; box-sizing: border-box;" type="text" placeholder="在文档中查找..." name="q"
/><button style="width: 20%; height: 40px; font-size: 1.0em; padding: 0; margin: 0; border: 1px solid #ccc; box-sizing: border-box; border-left: 0; cursor: pointer;" type="submit" id="#submit">搜索</button>
</form>
</div>

</div>
"""

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
		print(InsertHTML.format(filename,sgmlfile),file=fout)
		print(content[match.end():],file=fout)
	fin.close()
	fout.close()
	
for file in os.listdir(htmlDir):
        if file.endswith(".html"):
                process(os.path.join(htmlDir,file))

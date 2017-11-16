#!/usr/local/python34/bin/python3
# -*- coding: UTF-8 -*-
#功能:在html中添加在线纠错链接

import sys
import os
import re
sys.path.append(".") 
import html2sgml_map


sgmlDir="../build/doc/src/sgml"
htmlDir=os.path.join(sgmlDir,"html")
htmlOutputDir=os.path.join("html")
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
		print(content,file=fout)
	fin.close()
	fout.close()
	
for file in os.listdir(htmlDir):
        if file.endswith(".html"):
                process(os.path.join(htmlDir,file))

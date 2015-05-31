#!/usr/local/python34/bin/python3
# -*- coding: UTF-8 -*-
#功能:生成html文件到sgml文件的对应关系dict

import os
import re

patternId=re.compile(r'.*<(book|part|chapter|sect1|refentry|appendix|bibliography|reference|legalnotice|preface) id="([^"]+)"',re.S)


def process(file,sgmlprefix,html2sgmlDict):
	f=open(file,"r",encoding='GBK')
	filename=os.path.basename(file)
	for line in f:
		match=patternId.match(line)
		if match:
			html2sgmlDict[match.group(2).lower()+".html"]=sgmlprefix+filename


def getHtml2sgmlDict(sgmlDir):
        html2sgmlDict={}
        html2sgmlDict["index.html"]="postgres.sgml"
        for file in os.listdir(sgmlDir):
                if file.endswith(".sgml"):
                        process(os.path.join(sgmlDir,file),"",html2sgmlDict)
                        
        refDir=os.path.join(sgmlDir,"ref")
        for file in os.listdir(refDir):
                if file.endswith(".sgml"):
                        process(os.path.join(refDir,file),"ref/",html2sgmlDict)
        return html2sgmlDict



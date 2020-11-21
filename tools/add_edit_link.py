#!/usr/local/python34/bin/python3
# -*- coding: UTF-8 -*-
#功能:在html中添加其他版本链接，赞助商广告链接，在线纠错链接和全文检索框

import sys
import os
import re
import argparse
sys.path.append(".") 
import html2sgml_map

InsertHTML2="""<div style="text-align:center">
<a  style="margin : 0px 0px 0px 0px;" href="https://www.aliyun.com/product/rds/postgresql" target="_blank" ><img src="/docs/pic/tailbar.jpg" /></a>
</div>
"""

sgmlDir="../build/doc/src/sgml"
htmlDir=os.path.join(sgmlDir,"html")
htmlOutputDir=os.path.join("html_out")
html2sgmlDict=html2sgml_map.getHtml2sgmlDict(sgmlDir)


def generate_navigate_bar_HTML(current_version, master_version, all_versions):
    html="""<div class="preheader">
<div style="float: left">
"""
    # 添加所有版本的导航连接
    for v in all_versions.split(','):
        if v == current_version:
            html+='<span style="margin : 0px 5px 0px 5px;">{0}</span>\n'.format(v)
        else:
            html+='<a style="margin : 0px 5px 0px 5px;" href="/docs/{0}/{{0}}" target="_top">{0}</a>\n'.format(v,v)

    # 添加赞助商广告链接，github在线纠错链接和全文检索框
    if current_version == master_version:
        github_branch='master'
    else:
        github_branch=current_version
    html+="""
</div>

<div style="text-align:right">
<a style="margin : 0px 0px 0px 10px;" href="https://www.aliyun.com/product/rds/postgresql" target="_blank" >阿里云PostgreSQL</a>
<a style="margin : 0px 0px 0px 10px;" href="https://github.com/postgres-cn/pgdoc-cn/issues/new" target="_blank" title="在Github上报告问题（请注明问题内容及所在章节）">问题报告</a>
<a style="margin : 0px 0px 0px 10px;" href="https://github.com/postgres-cn/pgdoc-cn/edit/{0}/postgresql/doc/src/sgml/{{1}}" target="_blank" title="直接在Github上纠错本页面">纠错本页面</a>
</div>

<div style="position: relative; overflow: hidden; margin: 10px 0;">
<form method="GET" action="/v2/doc_search" style="float: right; width: 400px; max-width: 100%;">
<input type="hidden" name="u" value="/docs/{1}" />
<input style="width: 80%; height: 40px; font-size: 1.0em; padding: 0 10px; margin: 0; border: 1px solid #ccc; box-sizing: border-box;" type="text" placeholder="在文档中查找..." name="q"
/><button style="width: 20%; height: 40px; font-size: 1.0em; padding: 0; margin: 0; border: 1px solid #ccc; box-sizing: border-box; border-left: 0; cursor: pointer;" type="submit" id="#submit">搜索</button>
</form>
</div>

</div>
""".format(github_branch,current_version)

    return html


def process(file, current_version, master_version, all_versions):
    filename=os.path.basename(file)

    if current_version in ['9.3','9.4','9.5','9.6']:
        patternInsertPos=re.compile(r'.*<BODY\s+[^>]*>',re.S)
        patternInsertPos2=re.compile(r'.*</BODY\s+[^>]*>',re.S)
        fin=open(file,"r",encoding='GBK')
        content=fin.read()
        content=content.replace('CONTENT="text/html; charset=gbk"','CONTENT="text/html; charset=utf-8"')
    elif current_version in ['10','11','12']:
        patternInsertPos=re.compile(r'.*<body>',re.S)
        patternInsertPos2=re.compile(r'.*</body>',re.S)
        fin=open(file,"r",encoding='UTF-8')
        content=fin.read()
    else:
        patternInsertPos=re.compile(r'.*<body\s+[^>]*>',re.S)
        patternInsertPos2=re.compile(r'.*</body>',re.S)
        fin=open(file,"r",encoding='UTF-8')
        content=fin.read()
    fout=open(os.path.join(htmlOutputDir,filename),"w",encoding='UTF-8')

    sgmlfile=html2sgmlDict.get(filename.lower())
    if sgmlfile == None:
        print(filename+",no sgml")
        print(content,file=fout)
    else:
        print(filename+","+sgmlfile)
        match=patternInsertPos.match(content)
        InsertHTML=generate_navigate_bar_HTML(current_version, master_version, all_versions)
        print(content[0:match.end()],file=fout)
        print(InsertHTML.format(filename,sgmlfile),file=fout)

        match2=patternInsertPos2.match(content)
        pos2=match2.end()-len('</body>')
        print(content[match.end():pos2],file=fout)
        print(InsertHTML2,file=fout)
        print(content[pos2:],file=fout)
    fin.close()
    fout.close()


def main():
    argparser = argparse.ArgumentParser(description='add navigate bar to postgres document')
    argparser.add_argument('-c', '--current_version', help='current pgdoc version', required=True)
    argparser.add_argument('-m', '--master_version', help='pgdoc version for master', required=True)
    argparser.add_argument('-a', '--all_versions', help='all pgdoc versions', required=True)
    args = argparser.parse_args()

    if not os.path.exists(htmlOutputDir):
        os.mkdir(htmlOutputDir)

    # copy stylesheet.css
    open(os.path.join(htmlOutputDir,"stylesheet.css"), "wb").write(open(os.path.join(sgmlDir,"stylesheet.css"), "rb").read())

    for file in os.listdir(htmlDir):
            if file.endswith(".html"):
                    process(os.path.join(htmlDir,file),args.current_version, args.master_version, args.all_versions)   


if __name__ == '__main__':
    main()
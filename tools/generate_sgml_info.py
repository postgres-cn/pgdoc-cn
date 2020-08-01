#!/usr/local/python34/bin/python3
# -*- coding: UTF-8 -*-
# 功能:生成html和sgml的对应关系以及html的规模
# 输入：
#   generate_html_info.py -h html_dir -s sgml_dir
# 示例：
#   generate_html_info.py -h html -s ../ddd
#   1 | [1. 何为PostgreSQL？](http://www.postgres.cn/docs/12/intro-whatis.html) | 133 | 1KB | xxx.sgml | 待认领 | 
#   1 | [1. 何为PostgreSQL？](http://www.postgres.cn/docs/12/intro-whatis.html) | 133 | 1KB | xxx.sgml | 待认领 | 
#   ... 


import sys
import os
import re
import io
sys.path.append(".") 
import argparse

debug=False
#sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='gb18030')
#sys.stdout = os.fdopen(sys.stdout.fileno(), mode='w', encoding='utf-8', closefd=False)

url_prefix=r'http://www.postgres.cn/docs/12/'
en_url_prefix=r'https://www.postgresql.org/docs/12/'
output_tail=r' 待认领 |  |  |  | '
delimiter=r'|'

patternId=re.compile(r'.*<(book|part|chapter|sect1|refentry|appendix|bibliography|reference|legalnotice|preface) id="([^"]+)"',re.S)
patternTitle=re.compile(r'<title>(.*)</title>',re.S)
patternEntity=re.compile(r'<!ENTITY[ %]+([^ ]+)[ ]+SYSTEM[ ]+"([^"]+)">',re.S)
patternEntityRef=re.compile(r'^[ ]*(%|&)([^;]+);',re.S)

skipedSgml=('version.sgml','errcodes-table.sgml','keywords-table.sgml','features-supported.sgml','features-unsupported.sgml')

def parse_sgml(sgmlfile,sgmlDir,pos,sgmlInfos,entities):
    fullpath = os.path.join(sgmlDir, sgmlfile)
    #print(sgmlfile)
    sgmlprefix=""
    if sgmlfile.startswith('ref/'):
        sgmlprefix = 'ref/'
    if sgmlfile in skipedSgml:
        return
    id=None
    info=None
    f=open(fullpath,"r",encoding='UTF-8')
    incomment=False
    for line in f:
        if line.find("<!--========")>=0:
            incomment=True
            continue
        if line.find("__________-->")>=0:
            incomment=False
            continue
        if incomment:
            continue
        # entity Define
        match=patternEntity.search(line)
        if match:
            entitie_name=match.group(1)
            ref_file=match.group(2)
            entities[entitie_name]=sgmlprefix+ref_file
        # entity Ref
        match = patternEntityRef.search(line)
        if match:
            entitie_name=match.group(2)
            ref_file=entities.get(entitie_name)
            if ref_file:
                parse_sgml(ref_file,sgmlDir,pos,sgmlInfos,entities)
        # html id
        match=patternId.match(line)
        if match:
            type = match.group(1)
            id=match.group(2).lower()
            if type=='part':
                pos['part']=pos['part']+1
                #pos['chapter']=0
                #pos['sect1']=0
                #pos['sect2'] = 0
            elif type=='chapter':
                pos['chapter'] = pos['chapter'] + 1
                pos['sect1']=0
                pos['sect2'] = 0
            elif type=='sect1':
                pos['sect1'] = pos['sect1'] + 1
                pos['sect2'] = 0
            elif type == 'sect1':
                pos['sect2'] = pos['sect2'] + 1
            if id=='postgres':
                htmlfile='index.html'
            else:
                htmlfile=id+'.html'
            title_matched_count=0
            info = {'type': type,
                'id': id,
                'sgml': sgmlfile,
                'html': htmlfile,
                'pos': pos.copy()
                }
            sgmlInfos.append(info)
    if debug:
        print(sgmlfile,info)

def getSgml2htmlInfo(sgmlDir):
        entities={}
        sgmlInfos=[]
        file=os.path.join(sgmlDir,"postgres.sgml")
        pos={'part':0,
             'chapter':0,
             'sect1':0,
             'sect2':0}
        parse_sgml("postgres.sgml",sgmlDir,pos,sgmlInfos,entities)
        return sgmlInfos

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--htmldir", action="store", type=str, dest="html_dir", help="HTML文件所在目录")
    parser.add_argument("-s", "--sgmldir", action="store", type=str, dest="sgml_dir", help="HTML文件所在目录")
    args = parser.parse_args()
    if args is None or args.html_dir is None or args.sgml_dir is None:
        parser.print_usage()
        return 1
    sgml2htmlInfo=getSgml2htmlInfo(args.sgml_dir)
    #print(sgml2htmlInfo)
    fileno=0
    for i, info in enumerate(sgml2htmlInfo):
        htmlfullpath=os.path.join(args.html_dir,info['html'])
        fileno=i+1
        linecount=0
        title=""
        size=os.path.getsize(htmlfullpath)
        f=open(htmlfullpath,"r",encoding='UTF-8')
        for line in f:
            linecount+=1
            group=patternTitle.search(line)
            if group:
                title=group.group(1)
        if debug:
            location="%s/%s/%s/%s" %(info['pos']['part'], info['pos']['chapter'], info['pos']['sect1'] , info['pos']['sect2'])
        else:
            location=""
        content="%d %s" % (fileno, delimiter)
        content+=" %s[%s](%s%s) %s" % (location ,title, url_prefix, info['html'], delimiter)
        content+=" [en](%s%s) %s" % (en_url_prefix, info['html'], delimiter)
        content+=" %s %s" % (linecount, delimiter)
        content+=" %s %s" % (size, delimiter)
        content+=" %s %s" % (info['sgml'], delimiter)
        content+=output_tail
        f.close()
        print(content)

if __name__ == "__main__":
    sys.exit(main())


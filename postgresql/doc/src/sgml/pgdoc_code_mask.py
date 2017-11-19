#coding=utf-8 
#!/usr/bin/python 

import sys,os,re
import logging
import base64
import codecs
reload(sys)
sys.setdefaultencoding('utf8')

file_encoding=r'UTF-8'

def is_chinese_char(uchar):
    """判断一个unicode是否是中文文字"""
    #if uchar >= u'\u4e00' and uchar<=u'\u9fa5':
    if uchar >= u'\u0080':
        return True
    return False


def process_file(sourceFile,code_unmask):
    #print(sourceFile,commentFile,destFile)
    #print(sourceFile + ': ', end='')
    print(sourceFile),
    tmpFile = sourceFile + '.tmp'
    # 解析sourceFile
    # fin=open(filename, mode='r', encoding=file_encoding)
    # fout=open(filename + '.tmp', mode='r', encoding=file_encoding)
    fin=codecs.open(sourceFile, 'r','utf-8')
    fout=codecs.open(tmpFile,'w','utf-8')
    content=fin.read()
    pos=0
    bufpos=0
    hasChineseChars=False
    if not code_unmask:
        inChineseCharSeq = False
        for c in content:
            pos=pos+1
            if not inChineseCharSeq:
                if is_chinese_char(c):
                    fout.write(content[bufpos:pos-1])
                    bufpos=pos-1
                    inChineseCharSeq = True
                    hasChineseChars = True
            else:
                if not is_chinese_char(c):
                    masktext = '$${%s}' % base64.b64encode(content[bufpos:pos-1])
                    fout.write(masktext)
                    bufpos=pos-1
                    inChineseCharSeq = False
        if not inChineseCharSeq:
            tailtext = content[bufpos:]
        else:
            tailtext = '$${%s}' % base64.b64encode(content[bufpos:])
        fout.write(tailtext)
    else:
        inChineseCharSeq = False
        for c in content:
            pos=pos+1
            if not inChineseCharSeq:
                if content[pos-3:pos] == '$${':
                    fout.write(content[bufpos:pos-3])
                    bufpos=pos
                    inChineseCharSeq = True
                    hasChineseChars = True
            else:
                if c == '}':
                    masktext = base64.b64decode(content[bufpos:pos-1])
                    fout.write(masktext)
                    bufpos=pos
                    inChineseCharSeq = False
        if not inChineseCharSeq:
            tailtext = content[bufpos:]
        else:
            tailtext = base64.b64decode(content[bufpos:])
        fout.write(tailtext)
    fin.close()
    fout.close()
    ## 覆盖原文件
    if hasChineseChars:
        #os.remove()
        os.rename(tmpFile, sourceFile)
        if not code_unmask:
            print("masked")
        else:
            print("unmasked")
    else:
         print("skiped")
    
def process(source,code_unmask,depth=0):
    #print(source,comment,dest)
    if os.path.isdir(source):
        # process all files in this dir
        for f in os.listdir(source):
            source_child = os.path.join(source, f)
            process(source_child,code_unmask,depth+1)
    elif(source.endswith(".sgml") or depth==0):
        process_file(source,code_unmask)

if __name__ == "__main__":
    # 输入参数解析

    if len(sys.argv) < 2:
        print ('使用方法: %s [-r] <输入文件或目录>' % os.path.basename(sys.argv[0]))
        print ('功能：将sgml文件中的中文转义为$${XXXXX}，或恢复')
        print ('参数:')
        print ('  -r：恢复转义')
        print ('  输入文件或目录：需要转义的文件或目录，只处理sgml文件和postgres.xml')
        sys.exit(1)

    code_unmask = False
    if sys.argv[1] == '-r':
        code_unmask = True
        sourceFile = sys.argv[2]
    else:
        sourceFile = sys.argv[1]

    if not os.path.exists(sourceFile):
        print ('"%s" 不存在' % sourceFile)
        sys.exit(1)

    if not code_unmask:
        print( '开始转义"%s"中的中文字符...' % sourceFile)
    else:
        print( '开始恢复"%s"中被转义的中文字符...' % sourceFile)
    process(sourceFile,code_unmask)
    print('完成')

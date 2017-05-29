#coding=utf-8 
#!/usr/bin/python 

import sys,os,re
import logging

comment_pattern = re.compile(r'(?<=\n)[ \t]*<!--======.*?______-->[ \t\r]*\n',flags=re.DOTALL)
#comment_pattern = re.compile(r'(?<=\n)[ \t]*<!--\s*\n.*?\n[ \t]*-->[ \t\r]*\n',flags=re.DOTALL)

file_encoding=r'UTF-8'
skip_sgmls = ('bookindex.sgml','errcodes-table.sgml','features-supported.sgml','features-unsupported.sgml','version.sgml')


def process_file(sourceFile,destFile):
    #print(sourceFile,destFile)
    print(sourceFile + ': ', end='')
    filename = os.path.basename(sourceFile)
    if filename in skip_sgmls:
        print("skip")
        return
    # 打开文件
    fsrc=open(sourceFile, mode='r', encoding=file_encoding)
    src_content=fsrc.read()
    destDir=os.path.dirname(destFile)
    if(len(destDir) > 0 and not os.path.exists(destDir)):
        os.makedirs(os.path.dirname(destFile))
    fdest=open(destFile, mode='w', encoding=file_encoding)
    # 删除注释
    dest_content = re.sub(comment_pattern, '', src_content)
    fdest.write(dest_content)
    print("ok")
    
def process(source,dest):
    #print(source,dest)
    if os.path.isdir(source):
        # process all files in this dir
        for f in os.listdir(source):
            source_child = os.path.join(source, f)
            dest_child = os.path.join(dest, f)
            process(source_child,dest_child)
    elif(source.endswith(".sgml")):
        process_file(source,dest)





if __name__ == "__main__":
    # 输入参数解析

    if len(sys.argv) != 3:
        print ('使用方法: %s <输入sgml> <输出sgml>' % os.path.basename(sys.argv[0]))
        print ('参数:')
        print ('  输入sgml：需要删除注释的sgml文件，批量处理时为sgml文件所在目录')
        print ('  输出sgml：删除注释后的sgml，批量处理时为sgml文件所在目录')
        sys.exit(1)

    sourceFile = sys.argv[1]
    destFile = sys.argv[2]

    if not os.path.exists(sourceFile):
        print ('"%s" 存在' % (sourceFile,))
        sys.exit(1)

    if sourceFile == destFile:
        print ('输出sgml和输入sgml不允许相同')
        sys.exit(1)

    process(sourceFile,destFile)

    
    

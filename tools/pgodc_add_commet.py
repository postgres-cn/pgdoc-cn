#coding=utf-8 
#!/usr/bin/python 

import sys,os,re
import logging

#sourceDir = r"sgml_cn"
#commentDir = r"sgml_en"
#destDir = r"sgml_out"
file_encoding=r'UTF-8'
skip_sgmls = ('legal.sgml','bookindex.sgml','errcodes-table.sgml','features-supported.sgml','features-unsupported.sgml','version.sgml')

COMMENT_NOTE_START=r'<!--==========================orignal english content=========================='
COMMENT_NOTE_END=r'____________________________________________________________________________-->'
CN_TAGS=('title','para','simpara','indexterm','term','titleabbrev','row','bookinfo','remark',
    'programlisting','screen','literallayout','refmeta','refnamediv','indexentry','biblioentry',
    'cmdsynopsis','synopsis')

opentag_pattern = re.compile(r'^<[a-zA-Z][a-zA-Z0-9_]*(\s+[a-zA-Z][a-zA-Z0-9_]*\s*=\s*(?P<qt>[\'"])[^\'"]*(?P=qt))*\s*>')
closetag_pattern = re.compile(r'^</([a-zA-Z][a-zA-Z0-9_]*)?>')


# 配置log
logging.basicConfig(level=logging.DEBUG,
                format='%(lineno)4d: %(message)s',
                datefmt='%a, %d %b %Y %H:%M:%S',
                filename='sgmlparse.log',
                filemode='w')

logging.debug('This is info message')

class Tag():
    def __init__(self,name,start=0):
        self.name = name 
        self.start = 0
        self.name_attr = name
        self.end = 0
        self.child_tags=list()
        self.parent = None
        self.line_num = 0

    def childs(self):
        return self.child_tags.copy()

    def to_str(self, skip_cntags_childs=False, with_line_num=False):
        return tag_to_str(self, skip_cntags_childs=skip_cntags_childs, with_line_num=with_line_num)

def tag_to_str(tag, indent = 0, skip_cntags_childs=False, with_line_num=False):
    if with_line_num:
        output = "%6d:" % tag.line_num
    else:
        output = ''
    for i in range(0,indent):
        output += '  '
    output += tag.name_attr
    output +='\n'
    # 跳过需要加注释的节点的子节点，防止中文翻译后某些tag的先后次序甚至个数发生改变，无法对比。
    if skip_cntags_childs and tag.name in CN_TAGS:
        pass
    else:
        for child in tag.child_tags:
            output += tag_to_str(child, indent=indent+2, skip_cntags_childs=skip_cntags_childs, with_line_num=with_line_num)
    return output


class TagHandler(): 
    def __init__(self): 
        self.top_tags = list()
        self.current_tag = None
        self.first_cn_tag = None

    # 元素开始事件处理 
    def startElement(self, name, ctx):
        logging.debug(str((ctx.filename,"startElement",name,ctx.line,ctx.col)))
        tag = Tag(name)
        tag.start = ctx.tag_start
        tag.name_attr = ctx.content[ctx.tag_start+1:ctx.pos]
        tag.line_num = ctx.line
        if self.current_tag:
            tag.parent = self.current_tag
            self.current_tag.child_tags.append(tag)
        else:
            self.top_tags.append(tag)
        self.current_tag = tag

    # 元素结束事件处理 
    def endElement(self, name, ctx): 
        logging.debug(str((ctx.filename,"endElement",name,ctx.line,ctx.col)))
        self.current_tag.end = ctx.pos+1
        self.current_tag = self.current_tag.parent

    # 注释事件处理
    def comment(self, content, ctx):
        pass

    # 内容事件处理 
    def characters(self, content, ctx): 
        pass

    # 获取解析出的tag列表
    def tags(self):
        return self.top_tags.copy()

class SGMLPaserContext():
    def __init__(self): 
        self.tagstack=()
        self.content=''
        self.line=0
        self.col=0
        self.pos=0

class CommentTagContext():
    def __init__(self,src_content,comment_content,fdest): 
        self.src_content = src_content
        self.comment_content = comment_content
        self.fdest = fdest
        self.pos=0

"""
解析SGML tag。
以下面sgml段落的例子说明。
<para>xxx</para>
初始状态:none
       <:tag_name 从后面开始是tag名,调用characters()处理前面的字符
       >:none 将tag压栈,调用startElement()
      </:endtag 调用characters()处理前面的字符
       >:none 调用endElement(),将tag出栈
"""
class SGMLPaser():
    def __init__(self): 
        self.Status='none'
        self.tagstack=list()
        self.filename=''
        self.content=''
        self.line=0
        self.col=0
        self.pos=0
        self.tag_start=0
        
    def setContentHandler(self, contentHandler):
        self.ctx_hander = contentHandler
        
    def parse(self, filename, sourceEncoding=r'UTF-8'):
        fin=open(filename, mode='r', encoding=sourceEncoding)
        self.content=fin.read()
        content=self.content
        self.filename=filename
        bufpos=0
        self.line=1
        self.col=0
        self.pos=pos=0
        tagname_pos=0
        tagstack=list()
        in_escape_black=False ##已被废弃
        for c in content:
            if c == '\n':
                self.line+=1
                self.col=0
            if self.Status == 'none':
                if c == '<':
                    if content.startswith('<!--', pos):
                        self.Status = 'in_comment'
                    elif content.startswith('<![CDATA[', pos) or content.startswith('<![IGNORE[', pos) or content.startswith('<![%', pos):
                        self.Status = 'in_cdata'
                    elif content.startswith('</', pos):
                        match = closetag_pattern.match(content[pos:])
                        if match:
                            endtagname = match.groups()[0]
                            self.Status = 'endtag'
                    elif opentag_pattern.match(content[pos:]):
                        self.Status = 'tag_name'
                        tagname_pos = pos+1
                    if self.Status != 'none' :
                        self.ctx_hander.characters(content[bufpos:pos],self)
                        bufpos=pos
                        self.tag_start=pos
            elif self.Status == 'in_comment':
                if c == ">" and content[pos-2:pos+1] == "-->":
                    self.Status = 'none'
                    self.ctx_hander.comment(content[bufpos:pos+1],self)
                    bufpos=pos+1
            elif self.Status == 'in_cdata':
                if c == ">" and content[pos-2:pos+1] == "]]>":
                    self.Status = 'none'
                    self.ctx_hander.comment(content[bufpos:pos+1],self)
                    bufpos=pos+1
            elif self.Status == 'tag_name':
                if c in ' \r\n\t/':
                    tagname=content[tagname_pos:pos]
                    self.Status = 'tag_name_end'
                elif c == ">":
                    tagname=content[tagname_pos:pos]
                    tagstack.append(tagname)
                    self.Status = 'none'
                    bufpos=pos+1
                    self.ctx_hander.startElement(tagname,self)
                    if tagname in ['programlisting', 'screen', 'literal'] :
                        in_escape_black = True
            elif self.Status == 'tag_name_end':
                if c == ">":
                    tagstack.append(tagname)
                    self.Status = 'none'
                    bufpos=pos+1
                    self.ctx_hander.startElement(tagname,self)
                    if content[pos-1:pos] == '/':
                        self.ctx_hander.endElement(tagstack.pop(),self)
                    elif tagname in ['xref', 'footnoteref', 'colspec', 'spanspec', '!DOCTYPE', '!ENTITY', 'co']:
                        self.ctx_hander.endElement(tagstack.pop(),self)
                    elif tagname in ['programlisting', 'screen', 'literal'] :
                        in_escape_black = True
            elif self.Status == 'endtag': 
                if c == ">":
                    self.Status = 'none'
                    bufpos=pos+1
                    tagname2=tagstack.pop()
                    if endtagname != None and endtagname != tagname2:
                        raise Exception('unmatched end tag "%s" in %s:%d, while %s is expect' % (endtagname,filename,self.line,tagname2), tagstack) 
                    self.ctx_hander.endElement(tagname2,self)
                    in_escape_black = False
            pos+=1
            self.pos=pos
            self.col+=1
        self.ctx_hander.characters(content[bufpos:],self)

def process_tag(tag,commenttag,ctx):
    if tag.name != commenttag.name:
        raise Exception('tag "%s" in source sgml and tag "%s" in comment sgml does not match' % (tag.name,commenttag.name))
    fdest = ctx.fdest
    if tag.name in CN_TAGS:
        #  从tag开始位置往前找到第一个换行符
        insert_pos = pos = tag.start
        while True:
            if pos == 0:
                insert_pos = pos
                break
            elif ctx.src_content[pos-1] == '\n':
                insert_pos = pos
                break
            elif ctx.src_content[pos-1] in ' \t':
                pass
            else:
                break
            pos -= 1
        fdest.write(ctx.src_content[ctx.pos:insert_pos])
        fdest.write('%s\n' % (COMMENT_NOTE_START,))
        fdest.write(ctx.src_content[insert_pos:tag.start])
        #print(type(ctx.src_content),type(ctx.comment_content),tag.start,tag.end)
        comment = ctx.comment_content[commenttag.start:commenttag.end].replace(r'--',r'-&minus;')
        fdest.write(comment)
        fdest.write('\n%s\n' % (COMMENT_NOTE_END,))
        ctx.pos = insert_pos
    else:
        srctags = tag.childs()
        commenttags = commenttag.childs()
        if(len(srctags) != len(commenttags)):
            raise Exception('child tag number of tag "%s" in source sgml (%d) and comment sgml (%d) does not match' % (tag.name,len(srctags),len(commenttags)))
        for i in range(0,len(srctags)):
            process_tag(srctags[i],commenttags[i],ctx)

def process_file(sourceFile,commentFile,destFile):
    #print(sourceFile,commentFile,destFile)
    print(sourceFile + ': ', end='')
    filename = os.path.basename(sourceFile)
    if filename in skip_sgmls:
        print("skip")
        return
    # 解析sourceFile
    parser = SGMLPaser() 
    srcTagHandler = TagHandler() 
    parser.setContentHandler(srcTagHandler) 
    parser.parse(sourceFile)
    # 解析commentFile
    parser = SGMLPaser() 
    commetTagHandler = TagHandler() 
    parser.setContentHandler(commetTagHandler) 
    parser.parse(commentFile)
    # 比较原始tag和注释tag是否匹配
    str_srctags = ''
    for t in srcTagHandler.tags():
        str_srctags += t.to_str(skip_cntags_childs=True)
    str_commenttags = ''
    for t in commetTagHandler.tags():
        str_commenttags += t.to_str(skip_cntags_childs=True)
    if str_srctags != str_commenttags:
        # 写入tag一览
        open(filename + '.srctags', mode='w').write(str_srctags)
        open(filename + '.commenttags', mode='w').write(str_commenttags)
        # 写入带行号的详细tag一览
        str_srctags = ''
        for t in srcTagHandler.tags():
            str_srctags += t.to_str(skip_cntags_childs=True,with_line_num=True)
        str_commenttags = ''
        for t in commetTagHandler.tags():
            str_commenttags += t.to_str(skip_cntags_childs=True,with_line_num=True)
        open(filename + '.srctags_detail', mode='w').write(str_srctags)
        open(filename + '.commenttags_detail', mode='w').write(str_commenttags)
        # 输出错误消息返回
        print("skip for error:",end='')
        print ('source sgml "%s" and comment sgml "%s" does not match' % 
            (sourceFile,commentFile))
        return
        #raise Exception('source sgml "%s" and comment sgml "%s" does not match' % (sourceFile,commentFile))
    # 打开文件
    fsrc=open(sourceFile, mode='r', encoding=file_encoding)
    src_content=fsrc.read()
    fcomment=open(commentFile, mode='r', encoding=file_encoding)
    comment_content=fcomment.read()
    destDir=os.path.dirname(destFile)
    if(len(destDir) > 0 and not os.path.exists(destDir)):
        os.makedirs(os.path.dirname(destFile))
    fdest=open(destFile, mode='w', encoding=file_encoding)
    # 遍历tag处理添加注释
    commentTagContext = CommentTagContext(src_content,comment_content,fdest)
    srctags = srcTagHandler.tags()
    commenttags = commetTagHandler.tags()
    if(len(srctags) != len(commenttags)):
        raise Exception('child tag number of tag "%s" in source sgml (%d) and comment sgml (%d) does not match' % (tag.name,len(srctags),len(commenttags)))
    for i in range(0,len(srctags)):
        process_tag(srctags[i],commenttags[i],commentTagContext)
    fdest.write(src_content[commentTagContext.pos:])
    print("ok")
    
def process(source,comment,dest):
    #print(source,comment,dest)
    if os.path.isdir(source):
        # process all files in this dir
        for f in os.listdir(source):
            source_child = os.path.join(source, f)
            comment_child = os.path.join(comment, f)
            dest_child = os.path.join(dest, f)
            process(source_child,comment_child,dest_child)
    elif(source.endswith(".sgml")):
        process_file(source,comment,dest)





if __name__ == "__main__":
    # 输入参数解析

    if len(sys.argv) != 4:
        print ('使用方法: %s <输入sgml> <注释源sgml> <输出sgml>' % os.path.basename(sys.argv[0]))
        print ('参数:')
        print ('  输入sgml：需要添加注释的原始sgml文件，批量处理时为sgml文件所在目录')
        print ('  注释源sgml：注释来源的sgml，可和输入sgml相同,批量处理时为sgml文件所在目录')
        print ('  输出sgml：添加注释后的sgml，批量处理时为sgml文件所在目录')
        sys.exit(1)

    sourceFile = sys.argv[1]
    commentFile = sys.argv[2]
    destFile = sys.argv[3]

    if not os.path.exists(sourceFile) or not os.path.exists(commentFile):
        print ('"%s" 或 "%s" 不存在' % (sourceFile,commentFile))
        sys.exit(1)

    if sourceFile == destFile:
        print ('输出sgml和输入sgml不允许相同')
        sys.exit(1)

    if os.path.isfile(sourceFile):
        if not os.path.isfile(commentFile):
            print ('%s 必须是已存在的文件' % commentFile)
            sys.exit(1)
    else:
        if not os.path.isdir(commentFile):
            print ('%s 必须是已存在的目录' % commentFile)
            sys.exit(1)

    process(sourceFile,commentFile,destFile)

    
    

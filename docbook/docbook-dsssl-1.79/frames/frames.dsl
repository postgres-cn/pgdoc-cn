<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA DSSSL>
]>

<style-sheet>
<style-specification use="docbook">
<style-specification-body>

(define %stylesheet-version%
  "Modular DocBook HTML Frames Stylesheet version 1.0")

(define %stylesheet% "docbook.css");

(root
 (make sequence
   (process-children)
   (with-mode manifest
     (process-children))
   (make-dhtml-toc)))

(define (make-dhtml-toc)
  (make entity
    system-id: "toc.htm"
    (make element gi: "HTML"
	  (make element gi: "HEAD"
		(make element gi: "TITLE" (literal "DocBook TOC"))
		($standard-html-header$)
		(make element gi: "SCRIPT"
		      attributes: '(("SRC" "docbook.js"))
		      (empty-sosofo)))
	  (make element gi: "BODY" 
		(make element gi: "DIV"
		      (with-mode dhtmltoc
			(process-children)))))))

(define (dhtml-toc-entry nd gilist)
  (let* ((subdivnodes (node-list-filter-by-gi (children nd) gilist))
	 (subdivs (and (> (node-list-length subdivnodes) 0)
		       (not (node-list=? nd (sgml-root-element)))))
	 (imgsrc  (if subdivs
		      "toc-plus.gif"
		      "toc-blank.gif"))
	 (imgatt  (list (list "SRC" imgsrc)
			(list "BORDER" "0")
			(list "ID" (string-append (generate-anchor) "IMG"))))
	 (span    (if subdivs
		      (make element gi: "SPAN"
			    attributes: (list 
					 (list "CLASS" "TOGGLE")
					 (list "onClick" 
					       (string-append 
						"toggleDiv('"
						(generate-anchor)
						"')")))
			    (make empty-element gi: "IMG"
				  attributes: imgatt))
		      (make element gi: "SPAN" 
			    attributes: '(("CLASS" "TOGGLE"))
			    (make empty-element gi: "IMG"
				  attributes: imgatt)))))
    (if (node-list=? nd (sgml-root-element))
	(make sequence
	  (make element gi: "NOBR"
		(make element gi: "SPAN"
		      attributes: (list ;(list "HREF" (href-to (current-node)))
					(list "onClick" (string-append 
							 "load_body(\""
							 (href-to (current-node))
							 "\")"))
					(list "CLASS" "TOCTITLE"))
		      (element-title-sosofo (current-node))))
	  (make element gi: "DIV"
		(process-children)))
	(make sequence
	  (make element gi: "NOBR"
		span
		(make element gi: "SPAN"
		      attributes: (list ;(list "HREF" (href-to (current-node)))
					(list "onClick" (string-append 
							 "load_body(\""
							 (href-to (current-node))
							 "\")"))
					(list "CLASS" "TOCTITLE"))
		      (element-title-sosofo (current-node))))
	  (make element gi: "DIV"
		attributes: (list (list "CLASS" "NAVTOC")
				  (list "ID" (generate-anchor)))
		(process-children))))))

(mode dhtmltoc
  (default (empty-sosofo))

  (element set (dhtml-toc-entry (current-node) 
				(list (normalize "book"))))

  (element book (dhtml-toc-entry (current-node) 
				 (list (normalize "part") 
				       (normalize "preface")
				       (normalize "chapter")
				       (normalize "appendix")
				       (normalize "reference"))))

  (element preface (dhtml-toc-entry (current-node) 
				    (list (normalize "sect1"))))

  (element part (dhtml-toc-entry (current-node)
				 (list (normalize "preface")
				       (normalize "chapter")
				       (normalize "appendix")
				       (normalize "reference"))))

  (element chapter (dhtml-toc-entry (current-node)
				    (list (normalize "sect1"))))

  (element appendix (dhtml-toc-entry (current-node)
				     (list (normalize "sect1"))))

  (element sect1 (dhtml-toc-entry (current-node) '()))

  (element reference (dhtml-toc-entry (current-node)
				      (list (normalize "refentry"))))
  
  (element refentry (dhtml-toc-entry (current-node) '()))
)

</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>

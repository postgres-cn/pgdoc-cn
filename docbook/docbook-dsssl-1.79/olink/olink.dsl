<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA DSSSL>
]>

<style-sheet>
<style-specification id="olink" use="docbook">
<style-specification-body>

;; $Id: olink.dsl,v 1.1 2001/04/02 21:40:28 nwalsh Exp $

(define %doctype-pubid% "-//Norman Walsh//DTD DocBook OLink Summary V1.1//EN")

(root 
 (make sequence
   (make document-type
     name: "div"
     public-id: %doctype-pubid%)
   (with-mode olink-mode (process-children))))

(define (attrs #!optional (nd (current-node)))
  (let* ((id   (attribute-string (normalize "id") nd))
	 (arch (inherited-attribute-string (normalize "arch") nd))
	 (conformance (inherited-attribute-string 
		       (normalize "conformance") nd))
	 (os        (inherited-attribute-string (normalize "os") nd))
	 (revision  (inherited-attribute-string (normalize "revision") nd))
	 (userlevel (inherited-attribute-string (normalize "userlevel") nd))
	 (vendor    (inherited-attribute-string (normalize "vendor") nd))
	 (label     (element-label nd #t))
	 (gielem    (case-fold-down (gi nd)))
	 (giname    (gentext-element-name (gi nd)))
	 (href      (href-to nd)))
    (append
     (list (list "type" gielem))
     (list (list "name" giname))
     (list (list "href" href))
     (if id (list (list "id" id)) '())
     (if (equal? label "") '() (list (list "label" label)))
     (if arch (list (list "arch" arch)) '())
     (if conformance (list (list "conformance" conformance)) '())
     (if os (list (list "os" os)) '())
     (if revision (list (list "revision" revision)) '())
     (if userlevel (list (list "userlevel" userlevel)) '())
     (if vendor (list (list "vendor" vendor)) '()))))

(define (div #!optional (nd (current-node)))
  (let* ((attributes (attrs nd))
	 (xreflabel  (attribute-string (normalize "xreflabel") nd))
	 (title      (if xreflabel
			 xreflabel
			 (element-title nd))))
    (make element gi: "div"
	  attributes: attributes
	  (make element gi: "ttl"
		(if (string? title)
		    (literal title)
		    (with-mode olink-title-mode
		      (process-node-list title))))
	  (process-children))))

(define (obj #!optional (nd (current-node)))
  (let* ((attributes (attrs nd))
	 (title (element-title nd)))
    (make sequence
      (make element gi: "obj"
	    attributes: attributes
	    (make element gi: "ttl"
		  (if (string? title)
		      (literal title)
		      (with-mode olink-title-mode
			(process-node-list title))))
	    (process-children)))))

(mode olink-mode
  (default
    ;; process only the element children
    (let ((elem (let loop ((nl (children (current-node))) 
			   (elem (empty-node-list)))
		  (if (node-list-empty? nl)
		      elem
		      (if (equal? (node-property 'class-name 
						 (node-list-first nl)) 
				  'element)
			  (loop (node-list-rest nl)
				(node-list elem (node-list-first nl)))
			  (loop (node-list-rest nl) elem))))))
      (if (node-list-empty? elem)
	  (empty-sosofo)
	  (process-node-list elem))))

  (element set (div))
  (element book (div))
  (element preface (div))
  (element chapter (div))
  (element appendix (div))
  (element part (div))
  (element reference (div))
  (element article (div))
  (element refentry (div))

  (element section (div))
  (element sect1 (div))
  (element sect2 (div))
  (element sect3 (div))
  (element sect4 (div))
  (element sect5 (div))

  (element refsect1 (div))
  (element refsect2 (div))
  (element refsect3 (div))

  (element figure (obj))
  (element example (obj))
  (element table (obj))
  (element equation 
    (if (node-list-empty? (select-elements (children (current-node))
					   (normalize "title")))
	(empty-sosofo)
	(obj)))
)

(mode olink-title-mode
  (default (process-children))

  (element computeroutput
    (make element gi: "tt"
	  (process-children)))
  
  (element emphasis 
    (make element gi: "it"
	  (process-children)))
  
  (element filename 
    (make element gi: "it"
	  (process-children)))
  
  (element function 
    (make element gi: "it"
	  (process-children)))
  
  (element literal 
    (make element gi: "tt"
	  (process-children)))
  
  (element markup 
    (make element gi: "tt"
	  (process-children)))
  
  (element quote
    (make element gi: "qt"
	  (process-children)))
  
  (element replaceable 
    (make element gi: "it"
	  (process-children)))
  
  (element subscript
    (make element gi: "sub"
	  (process-children)))
  
  (element superscript 
    (make element gi: "sup"
	  (process-children)))
  
  (element userinput 
    (make element gi: "tt"
	  (process-children)))
)

</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>

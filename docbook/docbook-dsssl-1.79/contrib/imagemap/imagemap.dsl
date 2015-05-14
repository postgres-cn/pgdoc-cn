<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA DSSSL>
]>

<style-sheet>
<style-specification id="docbook-plain" use="docbook">
<style-specification-body>

(element (graphicco areaspec)
  (make element gi: "MAP"
	attributes: (list (list "NAME" (element-id)))
	(let loop ((nl (select-elements (descendants (current-node)) 
					(normalize "area"))))
	  (if (node-list-empty? nl)
	      (empty-sosofo)
	      (make sequence
		(make-html-area (node-list-first nl))
		(loop (node-list-rest nl)))))))

(define ($graphic$ fileref 
		   #!optional (format #f) (alt #f) (align #f))
  (let* ((csim?  (equal? (gi (parent (current-node)))
			 (normalize "graphicco")))
	 (ismap  (if csim?
		     '(("ISMAP" "ISMAP"))
		     '()))
	 (usemap (if csim?
		     (let* ((graphicco (parent (current-node)))
			    (areaspec  (select-elements 
					(children graphicco)
					(normalize "areaspec"))))
		       (list (list "USEMAP"
				   (string-append "#"
						  (attribute-string 
						   (normalize "id")
						   areaspec)))))
		     '()))
	 (border (if csim? '(("BORDER" "0")) '()))
	 (img-attr  (append
		     (list     (list "SRC" (graphic-file fileref)))
		     (if align (list (list "ALIGN" align)) '())
		     (if image-library (graphic-attrs fileref alt) '())
		     ismap
		     usemap
		     border)))
    (make empty-element gi: "IMG"
	  attributes: img-attr)))

(define (make-html-area area)
  (let* ((shape  (attribute-string (normalize "otherunits") area))
	 (coords (attribute-string (normalize "coords") area))
	 (idrefs (attribute-string (normalize "linkends") area))
	 (idlist (if idrefs 
		     (split idrefs)
		     '()))
	 (target (if idrefs
		     (element-with-id (car idlist))
		     (empty-node-list)))
	 (href   (attribute-string (normalize "label") area)))
    (if (node-list-empty? target)
	(process-children)
	(if idrefs
	    (make empty-element gi: "AREA"
		  attributes: (list (list "SHAPE" shape)
				    (list "COORDS" coords)
				    (list "HREF" (href-to target))))
	    (make empty-element gi: "AREA"
		  attributes: (list (list "SHAPE" shape)
				    (list "COORDS" coords)
				    (list "HREF" href)))))))

</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>

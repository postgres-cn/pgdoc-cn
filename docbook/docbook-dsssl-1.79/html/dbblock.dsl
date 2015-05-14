;; $Id: dbblock.dsl,v 1.11 2003/05/28 16:48:47 adicarlo Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://docbook.sourceforge.net/projects/dsssl/
;;

(element highlights ($block-container$))

(element revhistory ($book-revhistory$))

(element blockquote
  (let ((id     (element-id))
	(attrib (select-elements (children (current-node))
				 (normalize "attribution")))
        (startc (list (list "WIDTH" %blockquote-start-col%)))
        (endc   (list (list "WIDTH" %blockquote-end-col%)))
	(paras  (node-list-filter-by-not-gi
		 (children (current-node))
		 (list (normalize "attribution")))))
    (make sequence
      (if id
	  (make element gi: "A"
		attributes: (list (list "NAME" id))
		(empty-sosofo))
	  (empty-sosofo))

      (if (node-list-empty? attrib) 
	  (make element gi: "BLOCKQUOTE"
		attributes: '(("CLASS" "BLOCKQUOTE"))
		(process-children))
	  (make element gi: "TABLE"
		attributes: '(("BORDER" "0")
			      ("WIDTH" "100%")
			      ("CELLSPACING" "0")
			      ("CELLPADDING" "0")
			      ("CLASS" "BLOCKQUOTE"))
		(make element gi: "TR"
		      (make element gi: "TD"
			    attributes: (append startc
                                                '(("VALIGN" "TOP")))
			    (make entity-ref name: "nbsp"))
		      (make element gi: "TD"
			    attributes: '(("VALIGN" "TOP"))
			    (process-node-list paras))
		      (make element gi: "TD"
			    attributes: (append endc
                                                '(("VALIGN" "TOP")))
			    (make entity-ref name: "nbsp")))
		(make element gi: "TR"
		      (make element gi: "TD"
			    attributes: '(("COLSPAN" "2")
					  ("ALIGN" "RIGHT")
					  ("VALIGN" "TOP"))
			    (make sequence
			      (literal "--")
			      (process-node-list attrib)))
		      (make element gi: "TD"
			    attributes: endc
			    (make entity-ref name: "nbsp"))))))))
	
(element epigraph
  (let* ((attrib       (select-elements (children (current-node))
					(normalize "attribution")))
         (startcol     (list (list "WIDTH" %epigraph-start-col%)))
         (contentcol   (list (list "WIDTH" %epigraph-content-col%)))
	 (paras        (node-list-filter-by-not-gi
			(children (current-node))
			(list (normalize "attribution")))))
  (make element gi: "TABLE"
	attributes: '(("BORDER" "0")
		      ("WIDTH" "100%")
		      ("CELLSPACING" "0")
		      ("CELLPADDING" "0")
		      ("CLASS" "EPIGRAPH"))
	(make element gi: "TR"
	      (make element gi: "TD"
		    attributes: startcol
		    (make entity-ref name: "nbsp"))
	      (make element gi: "TD"
		    attributes: (append contentcol
                                        '(("ALIGN" "LEFT")
                                          ("VALIGN" "TOP")))
		    (make element gi: "I"
			  (process-node-list paras))))
	(if (node-list-empty? attrib)
	    (empty-sosofo)
	    (make element gi: "TR"
		  (make element gi: "TD"
			attributes: startcol
			(make entity-ref name: "nbsp"))
		  (make element gi: "TD"
			attributes: (append contentcol
                                            '(("ALIGN" "RIGHT")
                                              ("VALIGN" "TOP")))
			(make element gi: "I"
			      (process-node-list attrib))))))))

(element attribution ($charseq$))

(element (epigraph para)
  (make element gi: "P"
	(make element gi: "I"
	      (process-children-trim))))

(element para ($paragraph$))
(element simpara ($paragraph$))

(element formalpara
  (make element gi: "DIV"
	attributes: (list
		     (list "CLASS" (gi)))
	(make element gi: "P"
	      (if (attribute-string (normalize "id"))
		  (make element gi: "A"
			attributes: (list
				     (list "NAME"
					   (attribute-string
					    (normalize "id"))))
			(empty-sosofo))
		  (empty-sosofo))
	      (process-children))))

(element (formalpara title) ($runinhead$))

(element (formalpara para)
  (process-children))

(element sidebar 
  (make element gi: "TABLE"
	attributes: (list
		     (list "CLASS" (gi))
		     (list "BORDER" "1")
		     (list "CELLPADDING" "5"))
	(make element gi: "TR"
	      (make element gi: "TD"
		    ($semiformal-object$)))))

(element (sidebar title)
  (empty-sosofo))

(element abstract 
  (make element gi: "BLOCKQUOTE"
	attributes: '(("CLASS" "ABSTRACT"))
	($semiformal-object$)))

(element (abstract title) (empty-sosofo))

(element authorblurb ($block-container$))

(element ackno ($paragraph$))

(define ($inline-object$)
  (process-children))

(define ($informal-object$ #!optional (rule-before? #f) (rule-after? #f))
  (let ((id (element-id)))
    (make element gi: "DIV"
	  attributes: (list
		       (list "CLASS" (gi)))
	  (if %spacing-paras%
	      (make element gi: "P" (empty-sosofo))
	      (empty-sosofo))
	  
	  (if rule-before?
	      (make empty-element gi: "HR")
	      (empty-sosofo))

	  (if id
              ;; empty A is a little evil but for instance you can't
              ;; wrap TABLE within A
	      (make element gi: "A"
		    attributes: (list (list "NAME" id))
		    (empty-sosofo))
	      (empty-sosofo))

          ;; reset the mode to make processing of elements within an
          ;; informal object not subject to whatever mode they would
          ;; be in on the top level; e.g.,
          ;; bookinfo-legalnotice-productname distinguished from
          ;; bookinfo-productname
          (with-mode #f
            (process-children))

	  (if rule-after?
	      (make empty-element gi: "HR")
	      (empty-sosofo))
	  
	  (if %spacing-paras%
	      (make element gi: "P" (empty-sosofo))
	      (empty-sosofo)))))
  
(define (object-title-after #!optional (node (current-node))) 
  (if (member (gi node) ($object-titles-after$))
      #t
      #f))

(define (named-formal-objects)
  (list (normalize "figure")
	(normalize "table")
	(normalize "example")
	(normalize "equation")))

(define ($formal-object$ #!optional (rule-before? #f) (rule-after? #f))
  (let* ((nsep  (gentext-label-title-sep (gi)))
	 (id    (element-id))
	 (title-inline-sosofo 
	        (make sequence
		  (if (member (gi) (named-formal-objects))
		      (make sequence
			(literal (gentext-element-name (gi)))
			(if (string=? (element-label) "")
			    (literal nsep)
			    (literal " " (element-label) nsep)))
		      (empty-sosofo))
		  (with-mode title-mode
		    (process-node-list 
		     (select-elements (children (current-node))
				      (normalize "title"))))))
	 (title-sosofo (make element gi: "P"
			     (make element gi: "B"
				   title-inline-sosofo)))

         ;; reset the mode to make processing of elements within an
         ;; formal object not subject to whatever mode they would be
         ;; in on the top level; e.g.,
         ;; bookinfo-legalnotice-productname distinguished from
         ;; bookinfo-productname
	 (object-sosofo (with-mode #f
                          (process-children))))
    (make element gi: "DIV" 
	  attributes: (list
		       (list "CLASS" (gi)))

	  (if rule-before?
	      (make empty-element gi: "HR")
	      (empty-sosofo))

	  (if id
	      (make element gi: "A"
		    attributes: (list 
				 (list "NAME" id))
		    (empty-sosofo))
	      (empty-sosofo))
	  
	  (if (object-title-after)
	      (make sequence
		object-sosofo
		title-sosofo)
	      (make sequence
		title-sosofo
		object-sosofo))

	  (if rule-after?
	      (make empty-element gi: "HR")
	      (empty-sosofo)))))

(define ($semiformal-object$)
  ;; semiformal means optional title...
  (if (node-list-empty? (select-elements (children (current-node)) 
					 (normalize "title")))
      ($informal-object$)
      ($formal-object$)))

(element example 
  ($formal-object$ %example-rules% %example-rules%))

(element (example title) (empty-sosofo)) ; don't show caption below example

(element informalexample
  ($informal-object$ %informalexample-rules% %informalexample-rules%))

(element informalfigure
  ($informal-object$ %informalfigure-rules% %informalfigure-rules%))

(element (figure title) (empty-sosofo)) ; don't show caption below figure

(element figure 
  ($formal-object$ %figure-rules% %figure-rules%))

(element informaltable
  ($informal-object$ %informaltable-rules% %informaltable-rules%))

(element table
  ($formal-object$ %table-rules% %table-rules%))

(element (table title) (empty-sosofo))

;; remark and comment use the same rendering
(define ($remark$)
  (if %show-comments%
      (let ((inpara (equal? (gi (parent (current-node))) (normalize "para")))
            (attrib '(("CLASS" "COMMENT"))))
        (if inpara
            (make element gi: "SPAN"
                  attributes: attrib
                  (process-children))
            (make element gi: "P"
                  attributes: attrib
                  (process-children))))
      (empty-sosofo)))

(element comment ($remark$))

;; In DocBook V4.0 comment became remark
(element remark ($remark$))


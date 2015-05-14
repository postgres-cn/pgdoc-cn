;; $Id: dbqanda.dsl,v 1.1 2003/03/25 19:53:41 adicarlo Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://docbook.sourceforge.net/projects/dsssl/
;;

;; ============================== QANDASET ==============================

(define (qanda-defaultlabel)
  (normalize "number"))

(define (qanda-section-level)
  ;; FIXME: what if they nest inside each other?
  (let* ((enclsect (ancestor-member (current-node)
				    (list (normalize "section")
					  (normalize "simplesect")
					  (normalize "sect5")
					  (normalize "sect4")
					  (normalize "sect3")
					  (normalize "sect2")
					  (normalize "sect1")
					  (normalize "refsect3")
					  (normalize "refsect2")
					  (normalize "refsect1")))))
    (SECTLEVEL enclsect)))

(define (qandadiv-section-level)
  (let ((depth (length (hierarchical-number-recursive 
			(normalize "qandadiv")))))
    (+ (qanda-section-level) depth)))

(element qandaset
  (let ((title (select-elements (children (current-node)) 
				(normalize "title")))
	;; process title and rest separately so that we can put the TOC
	;; in the rigth place...
	(rest  (node-list-filter-by-not-gi (children (current-node))
					   (list (normalize "title")))))
    (make element gi: "DIV"
	  attributes: (list (list "CLASS" (gi)))
	  (process-node-list title)
	  (if ($generate-qandaset-toc$)
	      (process-qanda-toc)
	      (empty-sosofo))
	  (process-node-list rest))))

(element (qandaset title)
  (let* ((htmlgi  (string-append "H" (number->string 
				      (+ (qanda-section-level) 1)))))
    (make element gi: htmlgi
	  attributes: (list (list "CLASS" (gi (current-node))))
	  (process-children))))

(element qandadiv
  (make element gi: "DIV"
	attributes: (list (list "CLASS" (gi)))
	(process-children)))

(element (qandadiv title)
  (let* ((hnr     (hierarchical-number-recursive (normalize "qandadiv")
						 (current-node)))
	 (number  (let loop ((numlist hnr) (number "") (sep ""))
		    (if (null? numlist)
			number
			(loop (cdr numlist) 
			      (string-append number
					     sep
					     (number->string (car numlist)))
			      "."))))
	 (htmlgi  (string-append "H" (number->string 
				      (+ (qandadiv-section-level) 1)))))
    (make element gi: htmlgi
	  (make element gi: "A"
		attributes: (list (list "NAME" (element-id 
						(parent (current-node)))))
		(empty-sosofo))
	  (literal number ". ")
	  (process-children))))

(element qandaentry
  (make element gi: "DIV"
	attributes: (list (list "CLASS" (gi)))
	(process-children)))

(element question
  (let* ((chlist   (children (current-node)))
	 (firstch  (node-list-first chlist))
	 (restch   (node-list-rest chlist)))
    (make element gi: "DIV"
	  attributes: (list (list "CLASS" (gi)))
	  (make element gi: "P"
		(make element gi: "A"
		      attributes: (list (list "NAME" (element-id)))
		      (empty-sosofo))
		(make element gi: "B"
		      (literal (question-answer-label (current-node)) " "))
		(process-node-list (children firstch)))
	  (process-node-list restch))))

(element answer
  (let* ((inhlabel (inherited-attribute-string (normalize "defaultlabel")))
	 (deflabel (if inhlabel inhlabel (qanda-defaultlabel)))
	 (label    (attribute-string (normalize "label")))
	 (chlist   (children (current-node)))
	 (firstch  (node-list-first chlist))
	 (restch   (node-list-rest chlist)))
    (make element gi: "DIV"
	  attributes: (list (list "CLASS" (gi)))
	  (make element gi: "P"
		(make element gi: "B"
		      (literal (question-answer-label (current-node)) " "))
		(process-node-list (children firstch)))
	  (process-node-list restch))))

;; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

(define (process-qanda-toc #!optional (node (current-node)))
  (let* ((divs     (node-list-filter-by-gi (children node)
					   (list (normalize "qandadiv"))))
	 (entries  (node-list-filter-by-gi (children node)
					   (list (normalize "qandaentry"))))
	 (inhlabel (inherited-attribute-string (normalize "defaultlabel")))
	 (deflabel (if inhlabel inhlabel (qanda-defaultlabel))))
    (make element gi: "DL"
	  (with-mode qandatoc
	    (process-node-list divs))
	  (with-mode qandatoc
	    (process-node-list entries)))))

(mode qandatoc
  (element qandadiv
    (let ((title (select-elements (children (current-node))
				  (normalize "title"))))
      (make sequence
	(make element gi: "DT"
	      (process-node-list title))
	(make element gi: "DD"
	      (process-qanda-toc)))))
  
  (element (qandadiv title)
    (let* ((hnr     (hierarchical-number-recursive (normalize "qandadiv")
						   (current-node)))
	   (number  (let loop ((numlist hnr) (number "") (sep ""))
		      (if (null? numlist)
			  number
			  (loop (cdr numlist) 
				(string-append number
					       sep
					       (number->string (car numlist)))
				".")))))
      (make sequence
	(literal number ". ")
	(make element gi: "A"
	      attributes: (list (list "HREF" 
				      (href-to (parent (current-node)))))
	      (process-children)))))

  (element qandaentry
    (process-children))

  (element question
    (let* ((chlist   (children (current-node)))
	   (firstch  (node-list-first chlist)))
      (make element gi: "DT"
	    (literal (question-answer-label (current-node)) " ")
	    (make element gi: "A"
		  attributes: (list (list "HREF" (href-to (current-node))))
		  (process-node-list (children firstch))))))
  
  (element answer
    (empty-sosofo))
)

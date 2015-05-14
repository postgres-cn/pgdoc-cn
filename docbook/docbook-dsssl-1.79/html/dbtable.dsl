;; $Id: dbtable.dsl,v 1.6 2003/02/11 01:20:04 adicarlo Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://docbook.sourceforge.net/projects/dsssl/
;;
;; Table support completely reimplemented by norm 15/16 Nov 1997.
;; Adapted from print support.
;;
;; ======================================================================
;;
;; This code is intended to implement the SGML Open Exchange Table Model
;; (http://www.sgmlopen.org/sgml/docs/techpubs.htm) as far as is possible
;; in HTML.  There are a few areas where this code probably fails to 
;; perfectly implement the model:
;;
;; - Mixed column width units (4*+2pi) are not supported.
;; - The behavior that results from mixing relative units with 
;;   absolute units has not been carefully considered.
;;
;; ======================================================================
;; 
;; My goal in reimplementing the table model was to provide correct
;; formatting in tables that use MOREROWS. The difficulty is that
;; correct formatting depends on calculating the column into which
;; an ENTRY will fall.
;;
;; This is a non-trivial problem because MOREROWS can hang down from
;; preceding rows and ENTRYs may specify starting columns (skipping
;; preceding ones).
;;
;; A simple, elegant recursive algorithm exists. Unfortunately it 
;; requires calculating the column number of every preceding cell 
;; in the entire table. Without memoization, performance is unacceptable
;; even in relatively small tables (5x5, for example).
;;
;; In order to avoid recursion, the algorithm used below is one that
;; works forward from the beginning of the table and "passes along"
;; the relevant information (column number of the preceding cell and
;; overhang from the MOREROWS in preceding rows).
;;
;; Unfortunately, this means that element construction rules
;; can't always be used to fire the appropriate rule.  Instead,
;; each TGROUP has to process each THEAD/BODY/FOOT explicitly.
;; And each of those must process each ROW explicitly, then each
;; ENTRY/ENTRYTBL explicitly.
;;
;; ----------------------------------------------------------------------
;;
;; I attempted to simplify this code by relying on inheritence from
;; table-column flow objects, but that wasn't entirely successful.
;; Horizontally spanning cells didn't seem to inherit from table-column
;; flow objects that didn't specify equal spanning.  There seemed to
;; be other problems as well, but they could have been caused by coding
;; errors on my part.
;; 
;; Anyway, by the time I understood how I could use table-column
;; flow objects for inheritence, I'd already implemented all the
;; machinery below to "work it out by hand".  
;;
;; ======================================================================
;; NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
;; ----------------------------------------------------------------------
;; A fairly large chunk of this code is in dbcommon.dsl!
;; ======================================================================

;; Default for COLSEP/ROWSEP if unspecified
(define %cals-rule-default% "0")

;; Default for VALIGN if unspecified
(define %cals-valign-default% "TOP")

;; ======================================================================
;; Convert colwidth units into table-unit measurements

(define (colwidth-length lenstr)
  (if (string? lenstr)
      (let ((number (length-string-number-part lenstr))
	    (units  (length-string-unit-part lenstr)))
	(if (or (string=? units "*") (string=? number ""))
	    ;; relative units or no number, give up
	    0pt
	    (if (string=? units "")
		;; no units, default to pixels
		(* (string->number number) 1px)
		(let* ((unum  (string->number number))
		       (uname (case-fold-down units)))
		  (case uname
		    (("mm") (* unum 1mm))
		    (("cm") (* unum 1cm))
		    (("in") (* unum 1in))
		    (("pi") (* unum 1pi))
		    (("pt") (* unum 1pt))
		    (("px") (* unum 1px))
		    ;; unrecognized units; use pixels
		    (else   (* unum 1px)))))))
      ;; lenstr is not a string...probably #f
      0pt))

(define (cals-relative-colwidth? colwidth)
  (if (string? colwidth)
      (let ((strlen (string-length colwidth)))
	(if (string=? colwidth "*")
	    #t
	    (string=? (substring colwidth (- strlen 1) strlen) "*")))
      #f))

(define (cals-relative-colwidth colwidth)
  (let ((number (length-string-number-part colwidth))
	(units	(length-string-unit-part colwidth)))
    (if (string=? units "*")
	(if (string=? number "")
	    1
	    (string->number number))
	0)))

(define (cell-relative-colwidth cell relative)
  ;; given a cell and a relative width, work out the HTML cell WIDTH attribute
  (let* ((tgroup (find-tgroup cell))
	 (pgwide? (equal? (attribute-string (normalize "pgwide") (parent tgroup)) "1")))
    (if (and (not pgwide?) %html40%)
	;; html4 allows widths like "1*", we don't wanna use 50% if pgwide is not on
	(string-append (number->string relative) "*")
	(let loop ((colspecs (select-elements (children tgroup)
					      (normalize "colspec")))
		   (reltotal 0))
	  (if (not (node-list-empty? colspecs))
	      (loop (node-list-rest colspecs)
		    (+ reltotal (cals-relative-colwidth 
				 (colspec-colwidth 
				  (node-list-first colspecs)))))
	      (if (equal? reltotal 0)
		  ""
		  (string-append (number->string (round (* (/ relative reltotal) 100))) "%")))))))

(define (cell-colwidth cell colnum)
  ;; return the width of a cell, or "" if not specified
  (let* ((entry	    (ancestor-member cell (list (normalize "entry") 
						(normalize "entrytbl"))))
	 (colspec   (find-colspec-by-number colnum))
	 (colwidth  (colspec-colwidth colspec))
	 (width	    (round (/ (colwidth-length colwidth) 1px))))
    (if (node-list-empty? colspec)
	""
	(if (and (equal? (hspan entry) 1) colwidth)
	    (if (cals-relative-colwidth? colwidth)
		(cell-relative-colwidth cell (cals-relative-colwidth colwidth))
		(number->string width))
	    ""))))

;; ======================================================================

(define (cell-align cell colnum)
  ;; horizontal alignment for the cell, or "" if not set; efficiency
  ;; here is important
  (let* ((entry	    (ancestor-member cell (list (normalize "entry") 
						(normalize "entrytbl"))))
	 (spanname  (attribute-string (normalize "spanname") entry)))
    (if (attribute-string (normalize "align") entry)
	(attribute-string (normalize "align") entry)
	(if (and spanname (spanspec-align (find-spanspec spanname)))
	    (spanspec-align (find-spanspec spanname))
	    (if %html40%
		;; no need to set align explictly, let COL do the work
		""
		(if (colspec-align (find-colspec-by-number colnum))
		    (colspec-align (find-colspec-by-number colnum))
		    (let ((tgroup (find-tgroup entry)))
		      (if (tgroup-align tgroup)
			  (tgroup-align tgroup)
			  (normalize "left")))))))))

(define (cell-valign cell colnum)
  ;; vertical alignment for the cell, or "" if not set; efficiency
  ;; here is important
  (let ((entry	    (ancestor-member cell (list (normalize "entry")
						(normalize "entrytbl")))))
    (if (attribute-string (normalize "valign") entry)
	(attribute-string (normalize "valign") entry)
	"")))

(define ($table-frame$ table)
  ;; determine the proper setting for the html 4 FRAME attribute
  (let* ((wrapper   (parent (current-node)))
	 (frameattr (attribute-string (normalize "frame") wrapper)))
    (if (and %html40% frameattr)
	(cond
	 ((equal? frameattr (normalize "all"))
	  (list (list "FRAME" "border")))
	 ((equal? frameattr (normalize "bottom"))
	  (list (list "FRAME" "below")))
	 ((equal? frameattr (normalize "none"))
	  (list (list "FRAME" "void")))
	 ((equal? frameattr (normalize "sides"))
	  (list (list "FRAME" "vsides")))
	 ((equal? frameattr (normalize "top"))
	  (list (list "FRAME" "above")))
	 ((equal? frameattr (normalize "topbot"))
	  (list (list "FRAME" "hsides")))
	 (else '()))
	'())))

(define ($table-border$ table)
  ;; determine the proper setting for the html 4 BORDER attribute (cell frames)
  ;; FIXME: rules can be overriden by COLSPEC elements, use "group" value?
  (let* ((wrapper   (parent (current-node)))
	 (rowsepattr (or (attribute-string (normalize "rowsep") (current-node))
			 (attribute-string (normalize "rowsep") wrapper)))
	 (colsepattr (or (attribute-string (normalize "colsep") (current-node))
			 (attribute-string (normalize "colsep") wrapper))))
    (if (and %html40% (or rowsepattr colsepattr))
	;; remember there are actually 3 possible values: 0, 1, unset
	(cond
	 ((and (equal? colsepattr "1") (equal? rowsepattr "1"))
	  (list (list "RULES" "all")))
	 ((and (equal? colsepattr "0") (equal? rowsepattr "0"))
	  (list (list "RULES" "none")))
	 ((and (equal? colsepattr "1") (equal? rowsepattr "0"))
	  (list (list "RULES" "cols")))
	 ((and (equal? colsepattr "0") (equal? rowsepattr "1"))
	  (list (list "RULES" "rows")))
	 (else '()))	    ; if rowsep set but not colsep, ignore it
	'())))

;; ======================================================================
;; Element rules

(element tgroup
  (let* ((wrapper   (parent (current-node)))
	 (frameattr (attribute-string (normalize "frame") wrapper))
	 (pgwide    (attribute-string (normalize "pgwide") wrapper)))
    (make element gi: "TABLE"
	  attributes: (append
		       (if (equal? frameattr (normalize "none"))
                           '(("BORDER" "0"))
                           '(("BORDER" "1")))
		       ($table-frame$ (current-node))
                       ($table-border$ (current-node))
		       (if (equal? pgwide "1")
                           (list (list "WIDTH" ($table-width$)))
                           '())
		       (if %cals-table-class%
			   (list (list "CLASS" %cals-table-class%))
			   '()))
	  ($process-colspecs$ (current-node))
	  (process-node-list (select-elements (children (current-node)) (normalize "thead")))
	  (process-node-list (select-elements (children (current-node)) (normalize "tbody")))
	  (process-node-list (select-elements (children (current-node)) (normalize "tfoot")))
	  (make-table-endnotes))))

(element entrytbl ;; sortof like a tgroup...
  (let* ((wrapper   (parent (parent (parent (parent (current-node))))))
	 ;;	     table   tgroup  tbody   row  
	 (frameattr (attribute-string (normalize "frame") wrapper))
	 (tgrstyle  (attribute-string (normalize "tgroupstyle"))))
    (make element gi: "TABLE"
	  attributes: (append
		       (if (and (or (equal? frameattr (normalize "none"))
                                    (equal? tgrstyle (normalize "noborder")))
                                (not (equal? tgrstyle (normalize "border"))))
                           '(("BORDER" "0"))
                           '(("BORDER" "1")))
		       ($table-frame$ (current-node))
		       ($table-border$ (current-node))
		       (if %cals-table-class%
			   (list (list "CLASS" %cals-table-class%))
			   '()))
	  ($process-colspecs$ (current-node))
	  (process-node-list (select-elements (children (current-node)) (normalize "thead")))
	  (process-node-list (select-elements (children (current-node)) (normalize "tbody"))))))

(element colspec
  ;; now handled by $process-colspecs$
  (empty-sosofo))

(element spanspec
  (empty-sosofo))

(element thead
  ;; note that colspec/spanspec in thead isn't supported by HTML table model
  (if %html40%
      (make element gi: "THEAD"
	    ($process-table-body$ (current-node)))
      ($process-table-body$ (current-node))))

(element tfoot
  ;; note that colspec/spanspec in tfoot isn't supported by HTML table model
  (if %html40%
      (make element gi: "TFOOT"
	    ($process-table-body$ (current-node)))
      ($process-table-body$ (current-node))))

(element tbody
  (if %html40%
      (make element gi: "TBODY"
            attributes: (if (attribute-string (normalize "valign"))
                            (list (list "VALIGN" (attribute-string (normalize "valign"))))
                            '())
	    ($process-table-body$ (current-node)))
      ($process-table-body$ (current-node))))

(element row
  (empty-sosofo)) ;; this should never happen, they're processed explicitly

(element entry
  (empty-sosofo)) ;; this should never happen, they're processed explicitly

;; ======================================================================
;; Functions that handle processing of table bodies, rows, and cells

(define ($process-colspecs$ tgroup)
  ;; given tgroup or entrytbl, convert the colspecs to HTML4 COL elements
  (if (not %html40%)
      (empty-sosofo)
      (let ((cols (string->number (attribute-string (normalize "cols")))))
	(let loop ((colnum 1))
	  (if (> colnum cols)
	      (empty-sosofo)
	      (make sequence
		(let* ((colspec	 (find-colspec-by-number colnum))
		       (colwidth (colspec-colwidth colspec)))
		  (if (node-list-empty? colspec)
		      (make empty-element gi: "COL")
		      (make empty-element gi: "COL"
			    attributes:
			    (append
			     (if colwidth
				 (list (list "WIDTH"
					     (if (cals-relative-colwidth? colwidth)
						 (cell-relative-colwidth colspec (cals-relative-colwidth colwidth))
						 (number->string (round (/ (colwidth-length colwidth) 1px))))))
				 '())
			     (if (attribute-string (normalize "align") colspec)
				 (list (list "ALIGN" (attribute-string (normalize "align") colspec)))
				 '())
			     (if (attribute-string (normalize "char") colspec)
				 (list (list "CHAR" (attribute-string (normalize "char") colspec)))
				 '())
			     (if (attribute-string (normalize "charoff") colspec)
				 (list (list "CHAROFF" (attribute-string (normalize "charoff") colspec)))
				 '())
			     (if (attribute-string (normalize "colname") colspec)
				 (list (list "TITLE" (attribute-string (normalize "colname") colspec)))
				 '())))))
		(loop (+ colnum 1))))))))

(define ($process-table-body$ body)
  (let* ((tgroup (find-tgroup body))
	 (cols	 (string->number (attribute-string (normalize "cols") 
						   tgroup))))
    (let loop ((rows (select-elements (children body) (normalize "row")))
	       (overhang (constant-list 0 cols)))
      (if (node-list-empty? rows)
	  (empty-sosofo)
	  (make sequence
	    ($process-row$ (node-list-first rows) overhang)
	    (loop (node-list-rest rows)
		  (update-overhang (node-list-first rows) overhang)))))))

(define ($process-row$ row overhang)
  ;; FIXME: rowsep
  (let* ((tgroup (find-tgroup row))
	 (rowcells (node-list-filter-out-pis (children row)))
	 (rowalign (attribute-string (normalize "valign") row))
	 (maxcol (string->number (attribute-string (normalize "cols") tgroup)))
	 (lastentry (node-list-last rowcells)))
    (make element gi: "TR"
	  attributes: (append
		       (if rowalign
			   (list (list "VALIGN" rowalign))
			   '())
		       '())
	  (let loop ((cells rowcells)
		     (prevcell (empty-node-list)))
	    (if (node-list-empty? cells)
		(empty-sosofo)
		(make sequence
		  ($process-cell$ (node-list-first cells) 
				  prevcell overhang)
		  (loop (node-list-rest cells) 
			(node-list-first cells)))))
	  
	  ;; add any necessary empty cells to the end of the row
	  (let loop ((colnum (overhang-skip overhang
					    (+ (cell-column-number 
						lastentry overhang)
					       (hspan lastentry)))))
	    (if (> colnum maxcol)
		(empty-sosofo)
		(make sequence
		  (make element gi: "TD"
			(make entity-ref name: "nbsp"))
		  (loop (overhang-skip overhang (+ colnum 1)))))))))

(define (empty-cell? entry) 
  ;; Return #t if and only if entry is empty (or contains only PIs)
  (let loop ((nl (children entry)))
    (if (node-list-empty? nl)
	#t
	(let* ((node	   (node-list-first nl))
	       (nodeclass  (node-property 'class-name node))
	       (nodechar   (if (equal? nodeclass 'data-char)
			       (node-property 'char node)
			       #f))
	       (whitespace? (and (equal? nodeclass 'data-char)
				(or (equal? nodechar #\space)
				    (equal? (data node) "&#09;")
				    (equal? (data node) "&#10;")
				    (equal? (data node) "&#13;")))))
	  (if (not (or (equal? (node-property 'class-name node) 'pi)
		       whitespace?))
	      #f
	      (loop (node-list-rest nl)))))))

(define ($process-cell$ entry preventry overhang)
  (let* ((colnum (cell-column-number entry overhang))
	 (lastcellcolumn (if (node-list-empty? preventry)
			     0
			     (- (+ (cell-column-number preventry overhang)
				   (hspan preventry))
				1)))
	 (lastcolnum (if (> lastcellcolumn 0)
			 (overhang-skip overhang lastcellcolumn)
			 0))
	 (htmlgi (if (have-ancestor? (normalize "tbody") entry)
		     "TD"
		     "TH")))
    (make sequence
      (if (node-list-empty? (preced entry))
	  (if (attribute-string (normalize "id") (parent entry))
	      (make element gi: "A"
		    attributes: (list
				 (list
				  "NAME"
				  (attribute-string (normalize "id")
						    (parent entry))))
		    (empty-sosofo))
	      (empty-sosofo))
	  (empty-sosofo))

      (if (attribute-string (normalize "id") entry)
	  (make element gi: "A"
		attributes: (list
			     (list
			      "NAME"
			      (attribute-string (normalize "id") entry)))
		(empty-sosofo))
	  (empty-sosofo))

      ;; This is a little bit complicated.  We want to output empty cells
      ;; to skip over missing data.  We start count at the column number
      ;; arrived at by adding 1 to the column number of the previous entry
      ;; and skipping over any MOREROWS overhanging entrys.  Then for each
      ;; iteration, we add 1 and skip over any overhanging entrys.
      (let loop ((count (overhang-skip overhang (+ lastcolnum 1))))
	(if (>= count colnum)
	    (empty-sosofo)
	    (make sequence
	      (make element gi: htmlgi
		    (make entity-ref name: "nbsp")
;;		  (literal (number->string lastcellcolumn) ", ")
;;		  (literal (number->string lastcolnum) ", ")
;;		  (literal (number->string (hspan preventry)) ", ")
;;		  (literal (number->string colnum ", "))
;;		  ($debug-pr-overhang$ overhang)
		    )
	      (loop (overhang-skip overhang (+ count 1))))))

      ;; Now we've output empty cells for any missing entries, so we 
      ;; are ready to output the cell for this entry...
      (make element gi: htmlgi
	    attributes: (append
			 (if (> (hspan entry) 1)
			     (list (list "COLSPAN" (number->string (hspan entry))))
			     '())
			 (if (> (vspan entry) 1)
			     (list (list "ROWSPAN" (number->string (vspan entry))))
			     '())
			 (if (and (not %html40%) (not (equal? (cell-colwidth entry colnum) "")))
			     (list (list "WIDTH" (cell-colwidth entry colnum)))
			     '())
			 (if (not (equal? (cell-align entry colnum) ""))
			     (list (list "ALIGN" (cell-align entry colnum)))
			     '())
			 (if (not (equal? (cell-valign entry colnum) ""))
			     (list (list "VALIGN" (cell-valign entry colnum)))
			     '()))
	    (if (empty-cell? entry) 
		(make entity-ref name: "nbsp")
		(if (equal? (gi entry) (normalize "entrytbl"))
		    (process-node-list entry)
		    (process-node-list (children entry))))))))

;; EOF dbtable.dsl


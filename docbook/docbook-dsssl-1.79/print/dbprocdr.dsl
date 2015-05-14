;; $Id: dbprocdr.dsl,v 1.2 2003/01/15 08:24:23 adicarlo Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://docbook.sourceforge.net/projects/dsssl/
;;

;; ============================= PROCEDURES =============================

(define (PROCSTEP ilvl)
  (if (> ilvl 1) 2.0em 1.8em))

(element procedure
  (if (node-list-empty? (select-elements (children (current-node)) (normalize "title")))
      ($informal-object$)
      ($formal-object$)))

(element (procedure title) (empty-sosofo))

(element substeps
  (make display-group
	space-before: %para-sep%
	space-after: %para-sep%
	start-indent: (+ (inherited-start-indent) (PROCSTEP 2))))

(element step
  (let ((stepcontent (children (current-node)))
	(ilevel (length (hierarchical-number-recursive (normalize "step")))))
    (make sequence
      start-indent: (+ (inherited-start-indent) (PROCSTEP ilevel))

      (make paragraph
	space-before: %para-sep%
	first-line-start-indent: (- (PROCSTEP ilevel))
	(make line-field
	  field-width: (PROCSTEP ilevel)
	  (literal ($proc-step-number$ (current-node))))
	(process-node-list (children (node-list-first stepcontent))))
      (process-node-list (node-list-rest stepcontent)))))

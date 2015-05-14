;; clause 8.5.3.5
(define (caar x)  (car (car x)) )
(define (cadr x)  (list-ref x 1) )
(define (cdar x)  (cdr (car x)) )
(define (cddr x)  (cdr (cdr x)) )
(define (caaar x)  (car (car (car x))) )
(define (caadr x)  (car (car (cdr x))) )
(define (cadar x)  (car (cdr (car x))) )
(define (caddr x)  (list-ref x 2) )
(define (cdaar x)  (cdr (car (car x))) )
(define (cdadr x)  (cdr (car (cdr x))) )
(define (cddar x)  (cdr (cdr (car x))) )
(define (cdddr x)  (cdr (cdr (cdr x))) )
(define (caaaar x)  (car (car (car (car x)))) )
(define (caaadr x)  (car (car (car (cdr x)))) )
(define (caadar x)  (car (car (cdr (car x)))) )
(define (cadaar x)  (car (cdr (car (car x)))) )
(define (cadadr x)  (car (cdr (car (cdr x)))) )
(define (caddar x)  (car (cdr (cdr (car x)))) )
(define (cadddr x)  (list-ref x 3) )
(define (cdaaar x)  (cdr (car (car (car x)))) )
(define (cdaadr x)  (cdr (car (car (cdr x)))) )
(define (cdadar x)  (cdr (car (cdr (car x)))) )
(define (cddaar x)  (cdr (cdr (car (car x)))) )
(define (cddadr x)  (cdr (cdr (car (cdr x)))) )
(define (cdddar x)  (cdr (cdr (cdr (car x)))) )
(define (cddddr x)  (cdr (cdr (cdr (cdr x)))) )

;; clause 8.5.8.4
(define (char>?  c1 c2) (char<?  c2 c1))
(define (char>=? c1 c2) (char<=? c2 c1))

;; clause 8.5.8.5
(define (__ci-equiv proc) 
    (lambda (c1 c2) 
        (proc (char-upcase c1) (char-upcase c2))
    )
)
(define char-ci=?   (__ci-equiv char=?))
(define char-ci<?   (__ci-equiv char<?))
(define char-ci>?   (__ci-equiv char>?))
(define char-ci<=?  (__ci-equiv char<=?))
(define char-ci>=?  (__ci-equiv char>=?))

;; clause 8.5.9.6
(define (__upcase-string s) 
    (list->string
        (map char-upcase
            (string->list s)
        )
    )
)
(define (__ci-string-equiv proc)
    (lambda (s1 s2) 
        (proc (__upcase-string s1) (__upcase-string s2))
    )
)
(define (string>?    s1 s2) (string<?  s2 s1))
(define (string>=?   s1 s2) (string<=? s2 s1))
(define string-ci=?  (__ci-string-equiv string=?))
(define string-ci<?  (__ci-string-equiv string<?))
(define string-ci>?  (__ci-string-equiv string>?))
(define string-ci<=? (__ci-string-equiv string<=?))
(define string-ci>=? (__ci-string-equiv string>=?))

;; clause 8.5.10.3
 (define (map f #!rest xs)
   (let ((map1 (lambda (f xs)
                (let loop ((xs xs))
                  (if (null? xs)
                      '()
                      (cons (f (car xs))
                            (loop (cdr xs))))))))
    (cond ((null? xs)
          '())
         ((null? (cdr xs))
          (map1 f (car xs)))
         (else
          (let loop ((xs xs))
            (if (null? (car xs))
                '()
                (cons (apply f (map1 car xs))
                      (loop (map1 cdr xs)))))))))

;; clause 10.1.1
(define (current-root) (node-property 'grove-root (current-node)))

;; clause 10.2.2
(define (node-list-reduce nl combine init)
   (if (node-list-empty? nl)
       init
       (node-list-reduce (node-list-rest nl)
                         combine
                         (combine init (node-list-first nl)))))

(define (node-list-contains? nl snl)
  (node-list-reduce nl
		    (lambda (result i)
		      (or result
			  (node-list=? snl i)))
		    #f))

(define (node-list-remove-duplicates nl)
  (node-list-reduce nl
		    (lambda (result snl)
		      (if (node-list-contains? result snl)
			  result
			  (node-list result snl)))
		    (empty-node-list)))

(define (reduce list combine init)
  (let loop ((result init)
	     (list list))
    (if (null? list)
	result
	(loop (combine result (car list))
	      (cdr list)))))

(define (node-list-union #!rest args)
  (reduce args
	  (lambda (nl1 nl2)
	    (node-list-reduce nl2
			      (lambda (result snl)
				(if (node-list-contains? result
							 snl)
				    result
				    (node-list result snl)))
			      nl1))
	  (empty-node-list)))

(define (node-list-intersection #!rest args)
  (if (null? args) 
      (empty-node-list)
      (reduce (cdr args)
	      (lambda (nl1 nl2)
		(node-list-reduce nl1
				  (lambda (result snl)
				    (if (node-list-contains? nl2 snl)
					(node-list result snl)
					result))
				  (empty-node-list)))
	      (node-list-remove-duplicates (car args)))))

(define (node-list-difference #!rest args)
  (if (null? args)
      (empty-node-list)
      (reduce (cdr args)
	      (lambda (nl1 nl2)
		(node-list-reduce nl1
				  (lambda (result snl)
				    (if (node-list-contains? nl2 snl)
					result
					(node-list result snl)))
				  (empty-node-list)))
	      (node-list-remove-duplicates (car args)))))

(define (node-list-symmetric-difference #!rest args)
  (if (null? args)
      (empty-node-list)
      (reduce (cdr args)
	      (lambda (nl1 nl2)
		(node-list-difference (node-list-union nl1 nl2)
				      (node-list-intersection nl1 nl2)))
	      (node-list-remove-duplicates (car args)))))

(define (node-list-union-map proc nl)
  (node-list-reduce nl
		    (lambda (result snl)
		      (node-list-union (proc snl)
				       result))
		    (empty-node-list)))

(define (node-list-some? proc nl)
  (node-list-reduce nl
		    (lambda (result snl)
		      (if (or result (proc snl))
			  #t
			  #f))
		    #f))

(define (node-list-every? proc nl)
  (node-list-reduce nl
		    (lambda (result snl)
		      (if (and result (proc snl))
			  #t
			  #f))
		    #t))

(define (node-list-filter proc nl)
  (node-list-reduce nl
		    (lambda (result snl)
		      (if (proc snl)
			  (node-list result snl)
			  result))
		    (empty-node-list)))

(define (node-list->list nl)
  (reverse (node-list-reduce nl
			     (lambda (result snl)
			       (cons snl result))
			     '())))

(define (node-list-tail nl k)
  (cond 
   ((< k 0) (empty-node-list))
   ((zero? k) nl)
   (else
    (node-list-tail (node-list-rest nl) (- k 1)))))

(define (node-list-head nl k)
  (if (zero? k)
      (empty-node-list)
      (node-list (node-list-first nl)
		 (node-list-head (node-list-rest nl) (- k 1)))))
       ;;                         ^^^^^^^
       ;;                         missing in standard

(define (node-list-sublist nl i j)
  (node-list-head (node-list-tail nl i) (- j i)))

(define (node-list-count nl)
  (node-list-length (node-list-remove-duplicates nl)))

(define (node-list-last nl)
  (node-list-ref nl 
		 (- (node-list-length nl) 1)))

;; clause 10.2.3
(define (node-list-property prop nl)
  (node-list-map (lambda (snl)
		   (node-property prop snl default: (empty-node-list)))
		 nl))

(define (origin nl)
  (node-list-property 'origin nl))

(define (origin-to-subnode-rel snl)
  (node-property 'origin-to-subnode-rel-property-name snl default: #f))

(define (tree-root nl)
  (node-list-property 'tree-root nl))

(define (grove-root nl)
  (node-list-property 'grove-root nl))

(define (source nl)
  (node-list-property 'source nl))

(define (subtree nl)
  (node-list-map (lambda (snl)
		   (node-list snl (subtree (children snl))))
		 nl))

(define (subgrove nl)
  (node-list-map
   (lambda (snl)
     (node-list snl
		(subgrove 
		 (apply node-list
			(map (lambda (name)
			       (node-property name snl))
			     (node-property 'subnode-property-names 
					    snl))))))
   nl))

(define (ancestors nl)
  (node-list-map (lambda (snl)
		   (let loop ((cur (parent snl))
			      (result (empty-node-list)))
		     (if (node-list-empty? cur)
			 result
			 (loop (parent cur)
			       (node-list cur result)))))
		 nl))

(define (grove-root-path nl)
  (node-list-map (lambda (snl)
		   (let loop ((cur (origin snl))
			      (result (empty-node-list)))
		     (if (node-list-empty? cur)
			 result
			 (loop (origin cur)
			       (node-list cur result)))))
		 nl))

(define (rsiblings nl)
  (node-list-map (lambda (snl)
		   (let ((rel (origin-to-subnode-rel snl)))
		     (if rel 
			 (node-property rel 
					(origin snl)
					default: (empty-node-list))
			 snl)))
		 nl))

(define (ipreced nl)
   (node-list-map (lambda (snl)
                  (let loop ((prev (empty-node-list))
                             (rest (rsiblings snl)))
                    (cond ((node-list-empty? rest)
                           (empty-node-list))
                          ((node-list=? (node-list-first rest) snl)
                           prev)
                          (else
                           (loop (node-list-first rest)
                                 (node-list-rest rest))))))
                  nl))

(define (ifollow nl)
  (node-list-map (lambda (snl)
		   (let loop ((rest (rsiblings snl)))
		     (cond ((node-list-empty? rest)
			    (empty-node-list))
			   ((node-list=? (node-list-first rest) snl)
			    (node-list-first (node-list-rest rest)))
			   (else
			    (loop (node-list-rest rest))))))
		 nl))

(define (grove-before? snl1 snl2)
  (let ((sorted
	 (node-list-intersection (subgrove (grove-root snl1))
				 (node-list snl1 snl2))))
    (and (= (node-list-length sorted) 2)
	 (node-list=? (node-list-first sorted) snl1))))

(define (sort-in-tree-order nl)
  (node-list-intersection (subtree (tree-root nl))
			  nl))

(define (tree-before? snl1 snl2)
  (let ((sorted 
	 (sort-in-tree-order (node-list snl1 snl2))))
    (and (= (node-list-length sorted) 2)
	 (node-list=? (node-list-first sorted) snl1))))

(define (tree-before nl)
  (node-list-map (lambda (snl)
		   (node-list-filter (lambda (x)
				       (tree-before? x snl))
				     (subtree (tree-root snl))))
		 nl))

(define (property-lookup prop snl if-present if-not-present)
  (let ((val (node-property prop snl default: #f)))
    (cond
     (val (if-present val))
     ((node-property prop snl default: #t) (if-not-present val))
     (else (if-present val)))))

(define (select-by-property nl prop proc)
  (node-list-filter (lambda (snl)
		      (let ((val (node-property prop snl default: #f)))
			(and (not (node-list? val))
			     (proc val))))
		    nl))

(define (select-by-null-property nl prop)
  (node-list-filter (lambda (snl)
		      (let ((val1 (node-property prop snl null: #f))
			    (val2 (node-property prop snl null: #t)))
			(and (not val1) val2)))
		    nl))

(define (select-by-missing-property nl prop)
  (node-list-filter (lambda (snl)
		      (let ((val1 (node-property prop snl 
						 default: #f 
						 null: #t))
			    (val2 (node-property prop snl 
						 default: #t 
						 null: #f)))
			(and (not val1) val2)))
		    nl))

;; clause 10.2.5
(define (attribute string nl)
  (node-list-map (lambda (snl)
		   (named-node name (attributes snl)))
		 nl))

(define (referent nl)
  (node-list-property 'referent nl))
  
(define (q-element pattern #!optional (nl (current-node)))
  (select-elements (subgrove nl) pattern))

(define (q-class sym #!optional (nl (current-node)))
  (node-list-filter (lambda (snl) 
		      (equal? (node-property 'class-name snl) sym)) 
		    (subgrove nl)))

(define (q-sdata string #!optional (nl (current-node)))
  (node-list-filter (lambda (snl) 
		      (and (equal? (node-property 'class-name snl) 'sdata)
			   (equal? (node-property 'system-data snl) string)))
		    (subgrove nl)))

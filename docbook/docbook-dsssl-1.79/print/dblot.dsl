;; $Id: dblot.dsl,v 1.2 2003/01/15 08:24:23 adicarlo Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://docbook.sourceforge.net/projects/dsssl/
;;

;; need test cases to do toc/lot; do these later

(element toc (empty-sosofo))
(element (toc title) (empty-sosofo))
(element tocfront ($paragraph$))
(element tocentry ($paragraph$))
(element tocpart (process-children))
(element tocchap (process-children))
(element toclevel1 (process-children))
(element toclevel2 (process-children))
(element toclevel3 (process-children))
(element toclevel4 (process-children))
(element toclevel5 (process-children))
(element tocback ($paragraph$))
(element lot (empty-sosofo))
(element (lot title) (empty-sosofo))
(element lotentry ($paragraph$))


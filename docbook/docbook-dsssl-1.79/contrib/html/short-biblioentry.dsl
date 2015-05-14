<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA DSSSL>
]>

<style-sheet>
<style-specification id="docbook-plain" use="docbook">
<style-specification-body>

(define (biblioentry-inline-elements)
  (list (normalize "abbrev")
	(normalize "title")
	(normalize "subtitle")
	(normalize "author")
	(normalize "authorgroup")
	(normalize "copyright")
	(normalize "date")
	(normalize "edition")
	(normalize "pagenums")
	(normalize "pubdate")
	(normalize "publisher")))

(define (biblioentry-block-elements)
  '())

</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>

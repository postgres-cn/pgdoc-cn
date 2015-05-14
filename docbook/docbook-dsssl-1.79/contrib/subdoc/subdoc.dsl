<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook Print Stylesheet//EN" CDATA DSSSL>
]>

<style-sheet>
<style-specification use="docbook">
<style-specification-body>

<!-- Notes:

1. If you use subdocs, you can't enumerate any of the elements that
   you include by subdoc reference.  There's no way to figure out
   what the right numbers would be because the stylesheet can't
   see back past the subdoc reference into the original grove to
   count.  This is either a Jade or DSSSL bug, I don't recall which.

2. If anything that occurs in a subdoc should appear in the TOC, you'll
   have to modify the TOC code to find it.

-->

(element subdocsection
  (let* ((subdoc    (attribute-string (normalize "subdoc")))
	 (targfile  (entity-generated-system-id subdoc))
	 (targdoc   (sgml-parse targfile))
	 (targroot  (node-property 'document-element targdoc)))
    (process-node-list targroot)))

</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>


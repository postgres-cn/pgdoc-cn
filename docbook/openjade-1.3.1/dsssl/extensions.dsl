<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN">


<style-specification id="procedure">

(define debug 
  (external-procedure "UNREGISTERED::James Clark//Procedure::debug"))

(define if-first-page 
  (external-procedure "UNREGISTERED::James Clark//Procedure::if-first-page"))

(define if-front-page
  (external-procedure "UNREGISTERED::James Clark//Procedure::if-front-page"))

(define all-element-number
  (external-procedure "UNREGISTERED::James Clark//Procedure::all-element-number"))

(define read-entity
  (external-procedure "UNREGISTERED::James Clark//Procedure::read-entity"))

(define language
  (external-procedure "UNREGISTERED::OpenJade//Procedure::language"))

(define sgml-parse
  (external-procedure "UNREGISTERED::OpenJade//Procedure::sgml-parse"))

(define expt
  (external-procedure "UNREGISTERED::OpenJade//Procedure::expt"))


<style-specification id="sgml">

(declare-flow-object-class element
  "UNREGISTERED::James Clark//Flow Object Class::element")

(declare-flow-object-class empty-element
  "UNREGISTERED::James Clark//Flow Object Class::empty-element")

(declare-flow-object-class document-type
  "UNREGISTERED::James Clark//Flow Object Class::document-type")

(declare-flow-object-class processing-instruction
  "UNREGISTERED::James Clark//Flow Object Class::processing-instruction")

(declare-flow-object-class entity
  "UNREGISTERED::James Clark//Flow Object Class::entity")

(declare-flow-object-class entity-ref
  "UNREGISTERED::James Clark//Flow Object Class::entity-ref")

(declare-flow-object-class formatting-instruction
  "UNREGISTERED::James Clark//Flow Object Class::formatting-instruction")

(declare-characteristic preserve-sdata?
  "UNREGISTERED::James Clark//Characteristic::preserve-sdata?"
  #f)


<style-specification id="rtf">

(declare-characteristic heading-level
  "UNREGISTERED::James Clark//Characteristic::heading-level"
  0)

(declare-characteristic page-number-format
  "UNREGISTERED::James Clark//Characteristic::page-number-format"
  "1")

(declare-characteristic page-number-restart
  "UNREGISTERED::James Clark//Characteristic::page-number-restart"
  #f)

(declare-characteristic page-n-columns
  "UNREGISTERED::James Clark//Characteristic::page-n-columns"
  1)

(declare-characteristic page-column-sep
  "UNREGISTERED::James Clark//Characteristic::page-column-sep"
  .5in)

(declare-characteristic page-balance-columns?
  "UNREGISTERED::James Clark//Characteristic::page-balance-columns?"
  #f)

(declare-characteristic superscript-height
  "UNREGISTERED::James Clark//Characteristic::superscript-height"
  0pt)

(declare-characteristic subscript-depth
  "UNREGISTERED::James Clark//Characteristic::subscript-depth"
  0pt)

(declare-characteristic over-mark-height
  "UNREGISTERED::James Clark//Characteristic::over-mark-height"
  0pt)

(declare-characteristic under-mark-depth
  "UNREGISTERED::James Clark//Characteristic::under-mark-depth"
  0pt)

(declare-characteristic grid-row-sep
  "UNREGISTERED::James Clark//Characteristic::grid-row-sep"
  0pt)

(declare-characteristic grid-column-sep
  "UNREGISTERED::James Clark//Characteristic::grid-column-sep"
  0pt)


<style-specification id="tex">

(declare-flow-object-class page-float
  "UNREGISTERED::Sebastian Rahtz//Flow Object Class::page-float")

(declare-flow-object-class page-footnote
  "UNREGISTERED::Sebastian Rahtz//Flow Object Class::page-footnote")

(declare-characteristic page-number-format
  "UNREGISTERED::James Clark//Characteristic::page-number-format"
  "1")

(declare-characteristic page-number-restart
  "UNREGISTERED::James Clark//Characteristic::page-number-restart"
  #f)

(declare-characteristic page-n-columns
  "UNREGISTERED::James Clark//Characteristic::page-n-columns"
  1)

(declare-characteristic page-column-sep
  "UNREGISTERED::James Clark//Characteristic::page-column-sep"
  .5in)

(declare-characteristic page-balance-columns?
  "UNREGISTERED::James Clark//Characteristic::page-balance-columns?"
  #f)

(declare-characteristic page-two-side?
  "UNREGISTERED::OpenJade//Characteristic::page-two-side?"
  #f)

(declare-characteristic two-side-start-on-right?
  "UNREGISTERED::OpenJade//Characteristic::two-side-start-on-right?"
  #f)

(declare-characteristic superscript-height
  "UNREGISTERED::James Clark//Characteristic::superscript-height"
  0pt)

(declare-characteristic subscript-depth
  "UNREGISTERED::James Clark//Characteristic::subscript-depth"
  0pt)

(declare-characteristic over-mark-height
  "UNREGISTERED::James Clark//Characteristic::over-mark-height"
  0pt)

(declare-characteristic under-mark-depth
  "UNREGISTERED::James Clark//Characteristic::under-mark-depth"
  0pt)

(declare-characteristic grid-row-sep
  "UNREGISTERED::James Clark//Characteristic::grid-row-sep"
  0pt)

(declare-characteristic grid-column-sep
  "UNREGISTERED::James Clark//Characteristic::grid-column-sep"
  0pt)

(declare-characteristic preserve-sdata?
  "UNREGISTERED::James Clark//Characteristic::preserve-sdata?"
  #f)

<style-specification id="mif">

(declare-flow-object-class index-entry
  "UNREGISTERED::ISOGEN//Flow Object Class::index-entry")

(declare-characteristic page-n-columns
  "UNREGISTERED::James Clark//Characteristic::page-n-columns"
  1)

(declare-characteristic page-column-sep
  "UNREGISTERED::James Clark//Characteristic::page-column-sep"
  .5in)

(declare-characteristic page-balance-columns?
  "UNREGISTERED::James Clark//Characteristic::page-balance-columns?"
  #f)


<style-specification id="html">

(declare-characteristic scroll-title
  "UNREGISTERED::James Clark//Characteristic::scroll-title"
  #f)


<!-- Define entities we'll need for bookcomponent.content -->
<!ENTITY % local.divcomponent.mix "">
<!ENTITY % divcomponent.mix
		"%list.class;		|%admon.class;
		|%linespecific.class;	|%synop.class;
		|%para.class;		|%informal.class;
		|%formal.class;		|%compound.class;
		|%genobj.class;		|%descobj.class;
		|%ndxterm.class;
		%local.divcomponent.mix;">

<!ENTITY % local.refentry.class "">
<!ENTITY % refentry.class	"RefEntry %local.refentry.class;">

<!ENTITY % bookcomponent.title.content
	"DocInfo?, Title, Subtitle?, TitleAbbrev?">

<!ENTITY % sect.title.content
	"Title, Subtitle?, TitleAbbrev?">

<!ENTITY % refsect.title.content
	"Title, Subtitle?, TitleAbbrev?">

<!-- This modification allows SubdocSection in place of Sections -->
<!ENTITY % bookcomponent.content
	"((%divcomponent.mix;)+, 
	(Sect1*|(%refentry.class;)*|SimpleSect*|Section*|SubdocSection*))
	| (Sect1+|(%refentry.class;)+|SimpleSect+|Section+|SubdocSection+)">


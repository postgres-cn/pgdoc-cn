function toggleDiv(id) {
  // Find element with ID "id" and toggle its display property.
  // By convention, the ID of the corresponding +/- image is "${id}IMG".
  var div = eval("document.all." + id);
  var img = eval("document.all." + id + "IMG");
  var display = div.style.display;

  if (display != "block") {
    div.style.display = "block";
    img.src = "toc-minus.gif";
  } else {
    div.style.display = "none";
    img.src = "toc-plus.gif";
  }
}

function link_href(rel) {
  // Find the LINK element (in the body document) with the specified REL
  // and return its HREF.  Return "" if no such LINK can be found.
  var body  = parent.frames[1].document;
  var links = body.all.tags("LINK");
  for (i=0; i<links.length; i++) {
    if (links(i).getAttribute("REL") == rel) {
      return links(i).getAttribute("HREF");
    }
  }

  return "";
}

function load_body(href) {
  // Change the body frame to the specified href.  Update the
  // navigation bar. We use the setTimeout() trick to give the browser
  // a chance to load the document...
  var bodyframe = parent.frames[1];
  if (href != "") {
    bodyframe.location = href;
    setTimeout('reset_links()', 50);
  }
}

function goto_link(rel) {
  // Change the body frame to the specified LINK document.
  var href = link_href(rel);
  load_body(href);
}

function link_on(rel) {
  // Turn on the link
  navbar = parent.frames[2].document;
  navbar.all[rel].style.color = "black";
}

function link_off(rel) {
  // Turn off the link
  navbar = parent.frames[2].document;
  navbar.all[rel].style.color = "gray";
}

function set_link(rel) {
  // Set link on if there's somewhere to go, off otherwise
  link_off(rel);

  if (link_href(rel) !=  "") {
    link_on(rel);
  }
}    

function set_links() {
  // Set 'em all
  set_link("HOME");
  set_link("UP");
  set_link("PREVIOUS");
  set_link("NEXT");
}

function reset_links() {
  // Reset the links after a load.  Make sure we wait until the
  // document is loaded.
  var body  = parent.frames[1].document;
  if (body.readyState == 'complete') {
    set_links();
  } else {
    setTimeout('reset_links()', 100);
  }
}

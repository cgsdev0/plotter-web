"use strict";

document.body.addEventListener("htmx:sseMessage", function(e) {
	/*
	const reason = e.detail.type;
	if (reason === "finish") {
		location.reload();
	}
	*/
});

let stack = [];
let m = 1;

document.body.addEventListener("htmx:beforeProcessNode", function(e) {
	if (e.detail.elt.classList.contains("window")) {
		dragElement(e.detail.elt)
	}

})

document.body.addEventListener("htmx:beforeCleanupElement", function(e) {
	stack = stack.filter(x => x !== e.detail.elt);
})

// Make the DIV element draggable:
const wizard = window.wizard;
const login = window.login;
dragElement(wizard);
dragElement(login);

function sort_zs() {
	stack.forEach((element, i) => {
		if (element && element.style) {element.style.zIndex = i; }
	});
}

function dragElement(element) {
	if (!element || stack.find(e => e === element)) {
		return;
	}

	stack.push(element);
	sort_zs();
	if (wizard) {
		element.style.top = (wizard.offsetTop || 0) + 10 * m + "px";
		element.style.left = (wizard.offsetLeft || 0) + 10 * m + "px";
		m = m % 25 + 1;
	}
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
	const header = element.querySelector(".title-bar")
  if (header) {


    // if present, the header is where you move the DIV from:
    header.onpointerdown = dragpointerDown;
  }

	element.onpointerdown = focus;

	function focus(e) {
		stack = stack.filter(x => x !== element);
		stack.push(element);
		sort_zs();
		//e.preventDefault();
	}

  function dragpointerDown(e) {
    //e.preventDefault();
    // get the pointer cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onpointerup = closeDragElement;
	document.onpointercancel = closeDragElement;
	  if (element === wizard) { m = 1; }

    // call a function whenever the cursor moves:
    document.onpointermove = elementDrag;
  }

  function elementDrag(e) {
    e.preventDefault();
    // calculate the new cursor position:
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    // set the element's new position:
    element.style.top = (element.offsetTop - pos2) + "px";
    element.style.left = (element.offsetLeft - pos1) + "px";
  }

  function closeDragElement() {
    // stop moving when pointer button is released:
    document.onpointerup = null;
    document.onpointermove = null;
	  document.onpointercancel = null;
  }
}

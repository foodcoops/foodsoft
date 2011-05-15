// Load following statements, when DOM is ready
$(function() {
    $('a[data-toggle_this]').click(function() {
        $($(this).data('toggle_this')).toggle();
        return false;
    });
});


// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// for checkboxes. just insert box in same form-element like: 
// <input type="checkbox" name="checkall" onclick="checkUncheckAll(this);"/>
// credit to Shawn Olson & http://www.shawnolson.net
function checkUncheckAll(theElement) {
  var theForm = theElement.form, z = 0;
  for(z=0; z<theForm.length;z++){
    if(theForm[z].type == 'checkbox' && theForm[z].name != 'checkall'){
      theForm[z].checked = theElement.checked;
			// remove "checkbox_" in form-id before call highligh-function
			highlightRow(theForm[z].id.substring(9), theElement.checked);
    }
  }
}
// gives the row an yellow background
function highlightRow(row_id,status) {
	if(status) {
		$(row_id).addClassName("selected");
	} else {
		$(row_id).removeClassName("selected");
	}
}
// check or uncheck a given checkbox and adds or removes class "selected"
// used prototype to get the element
function checkRow(id) {
  var checkbox = "checkbox_" + id
  if($(checkbox).checked) {
    $(checkbox).checked = false;
    highlightRow(id,false);
  } else {
    $(checkbox).checked = true;
		highlightRow(id,true);
  }
}

// redirect to another "item"
// this function is used with an select menu
// for an example see app/views/articles/list.haml
function redirectTo(newLoc) {
	nextPage = newLoc.options[newLoc.selectedIndex].value
	
   	if (nextPage != "") {
    	document.location.href = nextPage
   	}
}

// Use with auto_complete to set a unique id,
// e.g. when the user selects a (may not unique) name
// There must be a hidden field with the id 'hidden_field'
function setHiddenId(text, li) {
  $('hidden_id').value = li.id;
}
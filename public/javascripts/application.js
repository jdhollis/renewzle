/* prevent the form from being submitted more than once (thank you Joyent!) */
function preventFormResubmission(form) {
  form = $(form);

  // get the buttons
  inputButtons = Form.getElements(form).findAll(function(form_element) {
    return (form_element.type == 'button' || form_element.type == 'submit');
  });

  // disable them
  inputButtons.each(function(inputButton) {
    inputButton = $(inputButton);
    inputButton.blur();
    inputButton.disabled = 'true';
  });

  // clear the form's handler
  form.onsubmit = function() { return false; };
}

function showItemLoadingFor(itemID) {
	$(itemID + '_loading').show();
}

function hideItemLoadingFor(itemID) {
	$(itemID + '_loading').hide();
}

/* submit a form programmatically while still triggering onsubmit (for AJAX) */
function submitForm(formID) {
	form = $(formID);
	if (form.onsubmit()) {
		form.submit();
	}
}


/* Customer navi behaviours */

var CustomerNavi = {	
	replaceNaviDetailsWith: function(text) {
		$('navi_details').innerHTML = text;
	}
}


/* Company behaviours */

var Company = {
	showUserFormFor: function(userID) {
		Element.toggle(userID + '_link');
		Element.toggle(userID + '_form');
		return false;
	},
	
	hideUserFormFor: function(userID) {
		Element.toggle(userID + '_form');
		Element.toggle(userID + '_link');
		return false;
	}
}


/* Partner behaviours */

var Partner = {
	updateRegistration: function(companyID) {
		new Ajax.Request('/partners/new', { asynchronous:true, evalScripts:true, parameters:{ id:companyID } });
		return false;
	},
	
	toggleInstallerFields: function() {
		new Effect.toggle($('installer_fields'), 'appear', { duration:0.25 });
	}
}


/* Profile behaviours */

var Profile = {
	toggleTip: function(id) {
		new Effect.toggle($(id + '_toggle'), 'appear', { duration:0.25 });
		new Effect.toggle($(id), 'appear', { duration:0.5 });
		
		return false;
	}
}


/* Quote behaviours */

var Quote = {
	toggleDetails: function(quoteID) {
		/*detailsToggle = $(quoteID + '_details_toggle');*/
		
		/*if (detailsToggle.innerHTML == 'Show Quote Details') {
			detailsToggle.innerHTML = 'Hide Quote Details';
		} else { 
			if (detailsToggle.innerHTML == 'Hide Quote Details') {
				detailsToggle.innerHTML = 'Show Quote Details';
			}
		}*/
		
		new Effect.toggle($(quoteID + '_show_details'), 'appear', { duration:0 });
		new Effect.toggle($(quoteID + '_hide_details'), 'appear', { duration:0 });
		new Effect.toggle($(quoteID + '_details'), 'appear', { duration:0.25 });
		
		return false;
	},
	
	toggleInstallationFields: function() {
		field_to_clear = $('quote_raw_installation_estimate').value = '';
		new Effect.toggle($('installation_fields'), 'appear', { duration:0.25 });
	},
	
	updateRFQ: function(form, inputID) {
		showItemLoadingFor(inputID);
	  new Ajax.Request('/retailer/quotes', { asynchronous:true, evalScripts:true, parameters:Form.serialize(form) + '&update=quote&input=' + inputID});
	},
	
	applyTemplate: function(form, inputID, requestURL) {
		showItemLoadingFor(inputID);
		new Ajax.Request(requestURL, { asynchronous:true, evalScripts:true, parameters:Form.serialize(form) + '&update=template&input=' + inputID });
	}
}


/* QuoteTemplate behaviours */

var QuoteTemplate = {
	toggleDetails: function(quoteTemplateID) {
		detailsToggle = $(quoteTemplateID + '_details_toggle');
		
		if (detailsToggle.innerHTML == 'Show Details') {
			detailsToggle.innerHTML = 'Hide Details';
		} else { 
			if (detailsToggle.innerHTML == 'Hide Details') {
				detailsToggle.innerHTML = 'Show Details';
			}
		}
	
		new Effect.toggle($(quoteTemplateID + '_details'), 'appear', { duration:0.25 });
		return false;
	},
	
	toggleInstallationFields: function() {
		field_to_clear = $('quote_template_raw_installation_estimate').value = '';
		new Effect.toggle($('installation_fields'), 'appear', { duration:0.25 });
	},
	
	updateRFQ: function(form, inputID, requestURL, requestMethod) {
		showItemLoadingFor(inputID);
	  new Ajax.Request(requestURL, { method:requestMethod, asynchronous:true, evalScripts:true, parameters:Form.serialize(form) + '&update=quote_template&input=' + inputID});
	}
}


/* FAQ behaviours */

var FAQ = {
	toggleAnswer: function(faqID) {
		new Effect.toggle($(faqID + '_answer'), 'appear', { duration:0.25 });
		return false;
	}
}


/* Masquerade behaviours */

var MasqueradePanel = {
	toggle: function() {
		new Effect.toggle($('toggle_open'), 'appear', { duration:0.0 });
		new Effect.toggle($('toggle_close'), 'appear', { duration:0.0 });
		new Effect.toggle($('masquerade_panel'), 'slide', { duration:0.35 });
		return false;
	}
}
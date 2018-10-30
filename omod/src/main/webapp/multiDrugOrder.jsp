<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<openmrs:require privilege="Medication - Add Drug Orders" otherwise="/login.htm" redirect="/module/medicationlog/singleDrugOrder.form?patientId=${model.patient.patientId}" />


<link rel="stylesheet"
	href="/openmrs/moduleResources/medicationlog/css/alertify.min.css" />
<link rel="stylesheet"
	href="/openmrs/moduleResources/medicationlog/themes/default.min.css"
	id="toggleCSS" />
<link
	href="/openmrs/moduleResources/medicationlog/css/font-awesome.min.css"
	rel="stylesheet" />
<link
	href="/openmrs/moduleResources/medicationlog/css/bootstrap.min.css"
	rel="stylesheet" />
	
<script src="/openmrs/moduleResources/medicationlog/alertify.min.js"></script>

<style>

body {
	font-size: 11px;
}

.alertify-notifier {
	font-size: 13px;
}

input[type=submit], [type=button] {
	background-color: #1aac9b;
	color: white;
	padding: 12px 20px;
	border: none;
	border-radius: 4px;
	cursor: pointer;
	
}
#saveUpdateButton {
    text-align: center;
}
fieldset.scheduler-border {
    border: 1px groove #ddd !important;
    padding: 0 1.4em 1.4em 1.4em !important;
    margin: 0 0 1.5em 0 !important;
    -webkit-box-shadow:  0px 0px 0px 0px #1aac9b;
    box-shadow:  0px 0px 0px 0px #1aac9b; 
}

legend.scheduler-border {
        font-size: 1.2em !important;
        font-weight: bold !important;
        text-align: left !important;
        width:auto;
        padding:0 10px;
        border-bottom:none; 
}
    
.row {
 margin-bottom:15px;
}
 
/* input[type=text], select, textarea,radio {
	border: 1px solid #1aac9b;
	border-radius: 2px;
	box-sizing: border-box;
}  */

input[id*='DatePicker'] {
	width: 85px;
	height: auto;
    font: 10pt ;
}


textarea[id*='orderInstruction'] {
	height: auto;
    font: 9pt Arial, sans-serif;
}

/* #drugsTable {border-collapse: collapse} */
#drugsTable td {
	padding: 0.25 rem !important;
}

input[type=number]{
    width: 60px;
    font: 9pt Arial, sans-serif;
}

</style>

<script>

jQuery(document).ready(function() {
	
	jQuery("#doseUnit").val("161553");
	jQuery('#orderReasonOther').prop('disabled', true);
	
	console.log('${encounters}');
	console.log('${requestedOrder}');
	
	if('${requestedOrder}' != null && '${requestedOrder}' != '') {
		
		/* document.getElementById("doseUnit").selectedIndex = 1; */
		/* alert(document.getElementById("doseUnit").selectedIndex); */
		
		/* in edit mode - input tags are already autopopulated via value tag */
		
		var operation = "${operation}";
		if(operation == "RENEW") {
			
			jQuery('#drugSuggestBox').prop('disabled', 'diabled');
			jQuery('#startDateDrug').val('');
			jQuery('#patientEncounter').val('');
		
		}
		else if(operation == "REVISE") {
			
			jQuery('#patientEncounter').prop('disabled', 'diabled');
			jQuery('#drugSuggestBox').prop('disabled', 'diabled');
			
			var startDateString = "${requestedOrder.dateActivated}";
			if(startDateString != '') 
			{
				var startDate = new Date(startDateString);
				var convertedStartDate = startDate.getDate() + '/' + (startDate.getMonth() + 1) + '/' +  startDate.getFullYear();
				jQuery('#startDateDrug').val(convertedStartDate);
				jQuery('#startDateDrug').prop('disabled', 'diabled');
			}
		}
		
		
		console.log("${requestedOrder.encounter.encounterId}");
		var encounterElement =  document.getElementById("patientEncounter");
		encounterElement.value = "${requestedOrder.encounter.encounterId}";
		
		var doseUnitElement =  document.getElementById("doseUnit");
		doseUnitElement.value = "${requestedOrder.doseUnits.id}";
		
		var frequencyElement =  document.getElementById("frequency");
		frequencyElement.value = "${requestedOrder.frequency.concept.id}";
		
		var routeElement =  document.getElementById("route");
		routeElement.value = "${requestedOrder.route.id}";
		
		var durationUnitElement =  document.getElementById("durationUnit");
		durationUnitElement.value = "${requestedOrder.durationUnits.id}";
		
		var orderIdElement =  document.getElementById("orderId");
		orderIdElement.value = "${requestedOrder.orderId}";
		
		console.log("${requestedOrder.asNeeded}");
		
		// it is treating asNeeded boolean value as string literal
		jQuery('#asNeeded').prop('checked', "${requestedOrder.asNeeded}" == 'true');
		
	};
	console.log('${requestedOrder.frequency.concept.id}');
	
	var drugObject = {};
	var drugsList = null;
	
	/* make Drug sets option selected */
	jQuery("#drugSets").prop("checked", true);
	jQuery('#drugSelection').val("BY DRUG SET");
	
	var saved = '${param.saved}';
	
	if(saved != null && saved != "") {
		
		alertify.set('notifier','position', 'top-center');
		var savedAlert = alertify.success(saved);
		savedAlert.delay(20).setContent(saved);
		
		jQuery('body').one('click', function(){
			savedAlert.dismiss();
		});
	}
	
	var missingConceptError = "";
	
	if(jQuery('#frequency').children('option').length == 1) {
		missingConceptError = '<spring:message code="medication.regimen.conceptGlobalPropertyMissingError" arguments="medication.medicationFrequenciesConceptUuid"/> ';
	}
	
	/* if(jQuery('#doseUnit').children('option').length == 1) {
		missingConceptError =  missingConceptError + '<br><spring:message code="medication.regimen.conceptGlobalPropertyMissingError" arguments="order.drugDosingUnitsConceptUuid"/> ';
	} */
	
	if(jQuery('#route').children('option').length == 1) {
		missingConceptError =  missingConceptError + '<br><spring:message code="medication.regimen.conceptGlobalPropertyMissingError" arguments="order.drugRoutesConceptUuid"/> ';
	}
	
	if(jQuery('#durationUnit').children('option').length == 1) {
		missingConceptError =  missingConceptError + '<br><spring:message code="medication.regimen.conceptGlobalPropertyMissingError" arguments="order.durationUnitsConceptUuid"/> ';
	}
	
	if(jQuery('#orderReason').children('option').length == 1) {
		missingConceptError =  missingConceptError + '<br><spring:message code="medication.regimen.conceptGlobalPropertyMissingError" arguments="medication.orderReasonUuid"/> ';
	}
	if(missingConceptError != "")
	{
		jQuery('.openmrs_error').show();
		jQuery('.openmrs_error').html(missingConceptError);
	}
	
	
	
jQuery('#drugSets').click(function() {
	
		
		var datalist = document.getElementById("drugOptions");
		var dataListLength = datalist.options.length;
		if(dataListLength > 0 ) {
			jQuery("#drugOptions option").remove();
		}
		
		jQuery("#drugSuggestBox").val("");
		jQuery('#drugSetList').prop('disabled', false);
		jQuery("#drugs").prop("checked", false);
		jQuery('#drugSelection').val("BY DRUG SET");
	});
	
	jQuery('#drugs').click(function(){ 
		
		jQuery("#drugSuggestBox").val("");
		jQuery('#drugSelection').val("BY DRUG");
		jQuery('#drugSetList').prop('disabled', 'disabled');
		jQuery("#drugSets").prop("checked", false);
		
		var url = "${pageContext.request.contextPath}/module/medicationlog/ajax/getAllDrugs.form"; 
		jQuery.getJSON(url, function(result) {
				
				var datalist = document.getElementById("drugOptions");
				var dataListLength = datalist.options.length;
				if(dataListLength > 0 ) {
					jQuery("#drugOptions option").remove();
				}
				
				if(result.length > 0) {
					drugObject = {};
					jQuery(result).each(function() {
						var drugName = toTitleCase(this.name.toLowerCase());
				            drugsOption = "<option value=\"" + this.id + "\">" + drugName + "</option>";
				            jQuery('#drugOptions').append(drugsOption);
				            drugKey = this.id; 
				            drugObject[drugKey] = drugName;
					});
				}
		});
	});
	
	jQuery('#drugSetList').change(function() {
		
		var selected = jQuery(this).val();
		
		jQuery("#drugSuggestBox").val("");
		
		if(jQuery("#drugSetList").prop("selectedIndex") > 0)
		{
			var url = "${pageContext.request.contextPath}/module/medicationlog/ajax/getDrugsByDrugSet.form?conceptId=" + selected; 
			jQuery.getJSON(url, function(result) {
					
					var datalist = document.getElementById("drugOptions");
					var dataListLength = datalist.options.length;
					if(dataListLength > 0 ) {
						jQuery("#drugOptions option").remove();
					}
					
					if(result.length > 0) {
						drugObject = {};
						jQuery(result).each(function() {
							var drugName = toTitleCase(this.name.toLowerCase());
					            drugsOption = "<option value=\"" + this.id + "\">" + drugName + "</option>";
					            jQuery('#drugOptions').append(drugsOption);
					            drugKey = this.id; 
					            drugObject[drugKey] = drugName;
						});
					}
			});
		}
	});
	
	jQuery('#drugSuggestBox').on('input', function(){
		
		var val = this.value;
		if(jQuery('#drugOptions option').filter(function(){
			return this.value === val;        
	    }).length) {
			var datalist = document.getElementById("drugOptions");
			var options = datalist.options;
			console.log(jQuery(this));
		    var drugKey = jQuery(this).val();
		    jQuery("#drugSuggestBox").val(drugObject[drugKey]);
		    jQuery("#drugId").val(drugKey);
		}
	});	
});



jQuery(function() {
	
	/* var doseInput = document.getElementById('dose');

	doseInput.onkeydown = function(e) {
	    if(!((e.keyCode > 95 && e.keyCode < 106)
	      || (e.keyCode > 47 && e.keyCode < 58) 
	      || e.keyCode == 8)) {
	        return false;
	    }
	}
	
	var durationInput = document.getElementById('duration');

	durationInput.onkeydown = function(e) {
	    if(!((e.keyCode > 95 && e.keyCode < 106)
	      || (e.keyCode > 47 && e.keyCode < 58) 
	      || e.keyCode == 8)) {
	        return false;
	    }
	} */
	
	
	jQuery( "#patientEncounter" ).change(function() {
		
		var encounterSelectElement =  document.getElementById('patientEncounter');
		if(encounterSelectElement.selectedIndex == 0) {
			document.getElementById('encounterDate').innerHTML = "";
		}
		else {	
		
			var encounterValue = this.value;
			
			var encounterList = '${encounters}';
			
			var values = new Array();
	        <c:if test="${empty encounters}">
	           values.push("No encounters found"); 
	        </c:if>         
	        <c:forEach var="encounter" items="${encounters}" varStatus="status">
	            values.push({encounterId: "${encounter.encounterId}", encounterName: "${encounter.encounterName}", encounterDate: "${encounter.encounterDate}"});   
	        </c:forEach>
			
			var encounterDate = values.find(function (obj) { 
			    return obj.encounterId== encounterValue; 
			});
			
			var encDate = new Date(encounterDate.encounterDate);
			
			// var convertedEncDate = encDate.getDate() + '/' + (encDate.getMonth() + 1) + '/' +  encDate.getFullYear();
			document.getElementById('encounterDate').innerHTML = convertDate(encDate);
			
		}
			
	});
	
	jQuery( "#orderReason" ).change(function() {
		
		var orderReasonSelectElement =  document.getElementById('orderReason');
		if(orderReasonSelectElement.options[orderReasonSelectElement.selectedIndex].value == 5622) {
			jQuery('#orderReasonOther').prop('disabled', false);
		}
		else {
			jQuery('#orderReasonOther').prop('disabled', true);
			jQuery('#orderReasonOther').val('');
		}
		
	});
	
});

function addDrugToTable() {
	
	var selectedDrug = jQuery("#drugSuggestBox").val();
	var table = document.getElementById("drugsTable");
	var rowCount = jQuery('#drugsTable tr').length;
	var exists = false;
	if(rowCount > 1) {
		jQuery('#drugsTable tr').each(function (row, tr) {
	    	var drugName = jQuery(tr).find("label[id=drugLabel]").html();
	    	if(drugName === selectedDrug) {
	    		exists = true;
	    	}
	    });
	}
	
	if(exists) {
		var error = "Drug already exists in table.";
		showError(error);
	}
	
	if(!(selectedDrug == "") && !exists) {
		
		var drugId = jQuery("#drugId").val();
			
	    var row = table.insertRow(rowCount);
	    
	    var deleteHtml = '<img title="Delete" class="stopButton" id="deleteOrder" src="/openmrs/moduleResources/medicationlog/img/delete_very_small.png" onclick="deleteRow(this)" alt="delete" border="0" />';
	    
	    var drugLabel = '<label id="drugLabel" style="display: none;">'+selectedDrug+'</label>';
	    var drugIdLabel = '<label id="drugIdLabel" style="display: none;">'+ drugId +'</label>';
	    
	    var doseHtml = '<input type="number" name="dose" id="dose.'+rowCount+'" size="2" min="1" max="5000" value="${requestedOrder.dose}"/><br><span id="doseError.'+rowCount+'" class="text-danger "></span>';
	    
	    var doseUnitHtml = '<select style="text-transform: capitalize" name="doseUnit" id="doseUnit.'+rowCount+'">' +
				'<c:if test="${not empty doseUnits}">' +
				'<c:forEach var="doseUnit" items="${doseUnits}">' +
				'<option style="text-transform: capitalize"  value="${doseUnit.conceptId}">${fn:toLowerCase(doseUnit.name)}</option>' + 
				'</c:forEach>' +
				'</c:if>' +
				'</select><span id="doseUnitError.'+rowCount+'" class="text-danger "></span>';
				
		var frequencyHtml = '<select style="text-transform: capitalize" name="frequency" id="frequency.'+rowCount+'">' +
			'<option style="text-transform: capitalize" value="">Select option</option>' +
			'<c:if test="${not empty frequencies}">' +
			'<c:forEach var="frequency" items="${frequencies}">' +
				'<option style="text-transform: capitalize" value="${frequency.conceptId}">${fn:toLowerCase(frequency.name)}</option>' +
			'</c:forEach>' +
			'</c:if>' +
		'</select><span id="frequencyError.'+rowCount+'" class="text-danger "></span>';
		
		var routeHtml = '<select style="text-transform: capitalize" name="route" id="route.'+rowCount+'">' +
			'<option style="text-transform: capitalize" value="${requestedOrder.route.name}">Select option</option>' +
			'<c:if test="${not empty routes}">' +
				'<c:forEach var="route" items="${routes}"> ' +
					'<option style="text-transform: capitalize" value="${route.conceptId}">${fn:toLowerCase(route.name)}</option> ' +
				'</c:forEach> ' +
			'</c:if>' +
		'</select><span id="routeError.'+rowCount+'" class="text-danger "></span>';
		
		
		var dateHtml  = '<input id="startDatePicker.'+rowCount+'" autocomplete="off" />' +
		'<br><span id="startDateError.'+rowCount+'" class="text-danger "></span>'; 
		
		var durationHtml = '<input type="number" name="duration" id="duration.'+rowCount+'" size="2" min="1" max="99" value="${requestedOrder.duration}"/><span id="durationError.'+rowCount+'" class="text-danger "></span>';
	    
		var durationUnitHtml = '<select style="text-transform: capitalize" name="durationUnit" id="durationUnit.'+rowCount+'">' +
		'<option value="">Select option</option>' +
		'<c:if test="${not empty durationUnits}">' +
		'<c:forEach var="duration" items="${durationUnits}"> ' +
		'<option style="text-transform: capitalize"  value="${duration.conceptId}">${fn:toLowerCase(duration.name)}</option>' +
		'</c:forEach> ' +
		'</c:if>' +
		'</select><span id="durationUnitError.'+rowCount+'" class="text-danger "></span>';
		
		var instructionHtml = '<textarea rows="3" cols="10" name="ins" id="orderInstruction.'+rowCount+'" maxlength="250"></textarea>';
		
	    var cell1 = row.insertCell(0);	// drug
	    var cell2 = row.insertCell(1);	// dose 
	    var cell3 = row.insertCell(2);	// dose Unit
	    var cell4 = row.insertCell(3);
	    var cell5 = row.insertCell(4);
	    var cell6 = row.insertCell(5);
	    var cell7 = row.insertCell(6);
	    var cell8 = row.insertCell(7);
	    var cell9 = row.insertCell(8);
	    cell1.innerHTML = deleteHtml + drugLabel + selectedDrug + drugIdLabel;
	    cell2.innerHTML = doseHtml;
	    cell3.innerHTML = doseUnitHtml;
	    cell4.innerHTML = frequencyHtml;
	    cell5.innerHTML = routeHtml;
	    cell6.innerHTML = durationHtml;
	    cell7.innerHTML = durationUnitHtml;
	    cell8.innerHTML = instructionHtml;
	    cell9.innerHTML = dateHtml;
	    
	    jQuery("input[id*='DatePicker']").datepicker({
		    dateFormat: 'dd/mm/yy'
		    
		});
	    
	    jQuery('#drugSuggestBox').val(''); 
	    
	    
	}
}

function refresh() {
	
	document.getElementById("doseUnit").selectedIndex = 1;
	document.getElementById("frequency").selectedIndex = "0";
	document.getElementById("route").selectedIndex = "0";
	document.getElementById("durationUnit").selectedIndex = "0";
	document.getElementById("orderReason").selectedIndex = "0";
	document.getElementById("drugSetList").selectedIndex = "0";
	document.getElementById("patientEncounter").selectedIndex = "0";
	jQuery('#drugSelection').val('');
	jQuery('#drugId').val('');
	jQuery('#dose').val('');
	jQuery('#duration').val('');
	jQuery('#drugSuggestBox').val(''); 
	jQuery('#startDateDrug').val('');
	jQuery('#adminInstructions').val('');
	jQuery('#orderReasonOther').val('');
	jQuery('#dosingInstructions').val('');
}

function toTitleCase(str) {
    return str.replace(/(?:^|\s)\w/g, function(match) {
        return match.toUpperCase();
    });
}


function getDrugOrderList(){
    var drugsData = new Array();
    var encounter =  document.getElementById('patientEncounter').value;
    var patientId = document.getElementById('patientId').value;
    var userId = document.getElementById('currentUserId').value;
		jQuery('#drugsTable tr').each(function(row, tr){
			var selectedDoseUnit = jQuery(tr).find('td:eq(2) select');
			var selectedFrequency = jQuery(tr).find('td:eq(3) select');
			var selectedRoute = jQuery(tr).find('td:eq(4) select');
			var selectedDurationUnit = jQuery(tr).find('td:eq(6) select');
			
		   drugsData[row]={
				   "drugName" : jQuery(tr).find("label[id=drugLabel]").html()
		             , "drugId" :  jQuery(tr).find("label[id=drugIdLabel]").html()
		             , "dose" : jQuery(tr).find('td:eq(1) input').val()
		             , "doseUnit" : selectedDoseUnit.val()
		             , "frequency" : selectedFrequency.val()
		             , "route" : selectedRoute.val()
		             , "duration" : jQuery(tr).find('td:eq(5) input').val()
		             , "durationUnit" : selectedDurationUnit.val()
		             , "instruction" :  jQuery(tr).find('td:eq(7) textarea').val()
		             , "startDrugDate" : jQuery(tr).find('td:eq(8) input').val()
		             , "patientId" : patientId
		             , "encounterId":encounter
		             , "userId" : userId
		             
		      }    
	});
   
		drugsData.shift(); 		// skipping 1st header row
 		console.log("Drugs array : "+JSON.stringify(drugsData)); 
 		return drugsData.filter(Boolean);
}

function deleteRow(r) {
	var i = r.parentNode.parentNode.rowIndex;
    document.getElementById("drugsTable").deleteRow(i);
}

function saveOrder() {
	
	var error = "";
	var isValid = true;
	
	var selectedDrug = jQuery("#drugSuggestBox").val();
	if(selectedDrug == "") {
		
		error = " <spring:message code='medication.regimen.drugError' /> ";
		isValid = false;
	}
	else {
		
		console.log("selected drug: " + selectedDrug.toLowerCase());
		/* var correctDrugSelection = jQuery("#drugOptions").find("option[value='"+selectedDrug+"']");
		if(!(correctDrugSelection != null && correctDrugSelection.length > 0)) {
			error = " <spring:message code='medication.regimen.incorrectDrugError' /> ";
			isValid = false;
		} */		
		
		var operation = "${operation}";
		console.log(operation);
		
		/* if(operation == "") {
		
			var datalist = document.getElementById("drugOptions");
			console.log(datalist.options.length);
			var count = 0;
			for (i = 0; i < datalist.options.length; i++) {
				
				console.log(datalist.options[i].text);
				var currentDrug = datalist.options[i].text;
			    if(currentDrug.toLowerCase() === selectedDrug.toLowerCase()) {
			    	count++;
			    }
			}
			
			if(count == 0) {
				error = " <spring:message code='medication.regimen.incorrectDrugError' /> ";
				isValid = false;
			}
		} */
		
		var doseElement = jQuery("#dose").val();
		
		if(doseElement == "") {
			
			error = error + " <spring:message code='medication.regimen.missingDoseError' /> ";
			isValid = false;
		}
		else if(doseElement == 0 || doseElement > 5000) {
			
			error = error + " <spring:message code='medication.regimen.doseLimitError' /> ";
			isValid = false;
		}
		else {
			
			var doseUnitSelectElement =  document.getElementById('doseUnit');
			/* if(doseUnitSelectElement.selectedIndex == 0) {
				
				error = error + "<br><spring:message code='medication.regimen.doseUnitError' /> ";
				isValid = false;
			} */
		}
		
        var durationElement = jQuery("#duration").val();
		
		if(durationElement == "") {
			
			error = error + " <spring:message code='medication.regimen.missingDurationError' /> ";
			isValid = false;

		}
		else if(durationElement == 0 || durationElement > 99) {
			
			error = error + " <spring:message code='medication.regimen.durationLimitError' /> ";
			isValid = false;
			
		}
		else {
			
			var durationUnitSelectElement =  document.getElementById('durationUnit');
			if(durationUnitSelectElement.selectedIndex == 0) {
				error = error + "<br><spring:message code='medication.regimen.durationUnitError' /> ";
				isValid = false;
			}
		}
		
		var frequencySelectElement =  document.getElementById('frequency');

		if(frequencySelectElement.selectedIndex == 0) {
			
			error = error + "<br><spring:message code='medication.regimen.frequencyError' /> ";
			isValid = false;
		}

		var routeSelectElement =  document.getElementById('route');
		if(routeSelectElement.selectedIndex == 0) {
			
			error = error + "<br><spring:message code='medication.regimen.routeError' /> ";
			isValid = false;
		}
		var startDate = jQuery("#startDateDrug").val();
		
		if(startDate == "") {
			
			error = error + "<br><spring:message code='medication.regimen.startDateError' /> ";
			isValid = false;
		}
		var frequencySelectElement =  document.getElementById('frequencyDay');
		if(frequencySelectElement.selectedIndex == 0) {
			
			error = error + "<br><spring:message code='medication.regimen.frequencyError' /> ";
			isValid = false;
		}

 		var routeSelectElement =  document.getElementById('route');
		if(routeSelectElement.selectedIndex == 0) {
			
			error = error + "<br><spring:message code='medication.regimen.routeError' /> ";
			isValid = false;
		}
		
		var start = jQuery("#startDateDrug").val();
		var encounterDate = jQuery("#encounterDate").text();
		
		var datePattern = '<openmrs:datePattern />';
		var startYears = datePattern.indexOf("yyyy");
		var startMonths =  datePattern.indexOf("mm");
		var startDays = datePattern.indexOf("dd");
		
		var convertDateStart = start.substring(startYears, startYears + 4) + "/" + start.substring(startMonths, startMonths + 2) + "/" + start.substring(startDays, startDays + 2);
		var convertDateEncounter = encounterDate.substring(startYears, startYears + 4) + "/" + encounterDate.substring(startMonths, startMonths + 2) + "/" + encounterDate.substring(startDays, startDays + 2);

		var startDate = new Date(convertDateStart);
		var encounterDate = new Date(convertDateEncounter);
		
		if(startDate < encounterDate) {
			error = error + "<br><spring:message code='medication.regimen.dateError' /> ";
			isValid = false;
		}
		
	}
	
	if(isValid == false) {
		showError(error);
		return isValid;
	}
	
	jQuery('#patientEncounter').prop('disabled', false);
	jQuery('#startDateDrug').prop('disabled', false);
	jQuery('#drugSuggestBox').prop('disabled', false);
	return isValid;
}

jQuery.ajaxSetup({
    async: false
});

function validate() {
	
	var isValid =true; 
	var rowCount = jQuery('#drugsTable tr').length;
	
	var encounterSelectElement =  document.getElementById('patientEncounter');
	if(encounterSelectElement.selectedIndex == 0) {
		encounterError = "Please select encounter";
		document.getElementById('encounterError').style.display= 'block';	
		   document.getElementById('encounterError').innerHTML = encounterError;
		isValid = false;
	} else {
   		document.getElementById('encounterError').style.display= 'none'; 
   	}
	
	
	jQuery('#drugsTable tr').each(function (row, tr) {
		alert("row: " + row);
		if(row > 0) {
			
			/* checking dose */
			var dose = jQuery(tr).find('td:eq(1) input').val();
			if(dose == "" || dose == null ) {
				   document.getElementById('doseError.'+row+'').style.display= 'block';	
				   document.getElementById('doseError.'+row+'').innerHTML = "<spring:message code='medication.regimen.missingDoseError' />";
				   isValid = false;
		   	} else {
		   		document.getElementById('doseError.'+row+'').style.display= 'none'; 
		   	}
			
			/* checking dose unit*/
			var selectedDoseUnit = jQuery(tr).find('td:eq(2) select');
			if(selectedDoseUnit.val() == "" || selectedDoseUnit.val() == null ) {
				   document.getElementById('doseUnitError.'+row+'').style.display= 'block';	
				   document.getElementById('doseUnitError.'+row+'').innerHTML = "<spring:message code='medication.regimen.doseUnitError' />";
				   isValid = false;
		   	} else {
		   		document.getElementById('doseUnitError.'+row+'').style.display= 'none'; 
		   	}
			
			/* checking frequency*/
			var selectedFreq = jQuery(tr).find('td:eq(3) select');
			if(selectedFreq.val() == "" || selectedFreq.val() == null ) {
				   document.getElementById('frequencyError.'+row+'').style.display= 'block';	
				   document.getElementById('frequencyError.'+row+'').innerHTML = "<spring:message code='medication.regimen.frequencyError' />";
				   isValid = false;
		   	} else {
		   		document.getElementById('frequencyError.'+row+'').style.display= 'none'; 
		   	}
			
			/* checking route*/
			var selectedRoute = jQuery(tr).find('td:eq(4) select');
			if(selectedRoute.val() == "" || selectedRoute.val() == null ) {
				   document.getElementById('routeError.'+row+'').style.display= 'block';	
				   document.getElementById('routeError.'+row+'').innerHTML = "<spring:message code='medication.regimen.routeError' />";
				   isValid = false;
		   	} else {
		   		document.getElementById('routeError.'+row+'').style.display= 'none'; 
		   	}
			
			/* checking duration */
			var duration = jQuery(tr).find('td:eq(5) input').val();
			if(duration == "" || duration == null ) {
				   document.getElementById('durationError.'+row+'').style.display= 'block';	
				   document.getElementById('durationError.'+row+'').innerHTML = "<spring:message code='medication.regimen.missingDurationError' />";
				   isValid = false;
		   	} else {
		   		document.getElementById('durationError.'+row+'').style.display= 'none'; 
		   	}
			
			/* checking duration Unit */
			var selectedDurationUnit = jQuery(tr).find('td:eq(6) select');
			if(selectedDurationUnit.val() == "" || selectedDurationUnit.val() == null ) {
				   document.getElementById('durationUnitError.'+row+'').style.display= 'block';	
				   document.getElementById('durationUnitError.'+row+'').innerHTML = "<spring:message code='medication.regimen.durationUnitError' />";
				   isValid = false;
		   	} else {
		   		document.getElementById('durationUnitError.'+row+'').style.display= 'none'; 
		   	}
			
			/* checking startDate */
			var encounterDate = jQuery("#encounterDate").text();
			var startDate = jQuery(tr).find('td:eq(8) input').val();
			if(startDate == "" || startDate == null ) {
				   document.getElementById('startDateError.'+row+'').style.display= 'block';	
				   document.getElementById('startDateError.'+row+'').innerHTML = "<spring:message code='medication.regimen.startDateError' /> ";
				   isValid = false;
		   	} 
			else if(beforeSecondDate(startDate, encounterDate)) {
					document.getElementById('startDateError.'+row+'').style.display= 'block';	
					document.getElementById('startDateError.'+row+'').innerHTML = "<spring:message code='medication.regimen.dateError' /> ";
					isValid = false;
			}
			else {
				
		   		document.getElementById('startDateError.'+row+'').style.display= 'none'; 
		   	}
			
		}	
	});
	
	return false;
}

function saveOrders() {
	
	// first check if table row count is greater than 1
	var rowCount = jQuery('#drugsTable tr').length;
	
	if(rowCount > 1) {
		
			var data = getDrugOrderList();
			var activeOrders = getActiveOrders();
			var existingDrugs = [];
			var exists = false;
			
			if(activeOrders != null) {
				for (i = 0; i < activeOrders.results.length; i++) { 
					if(activeOrders.results[i].type === "drugorder") {
						
						var activeDrugName = activeOrders.results[i].drug.display;
						
						jQuery('#drugsTable tr').each(function (row, tr) {
					    	var drugName = jQuery(tr).find("label[id=drugLabel]").html();
					    	if(drugName != null) {
						    	if(drugName.toLowerCase() === activeDrugName.toLowerCase()) {
						    		exists = true;
						    		existingDrugs.push(drugName);
						    	}
					    	}
					    });
					}
				}
			}
			
			if(exists) {
				
				var error = "" + existingDrugs + " already exist(s) in active orders. Please remove from table.";
				showError(error);
			}
			else if(validate()) {
		
				jQuery.ajax({
						type : "POST",
						url : "${pageContext.request.contextPath}/module/medicationlog/multiDrugOrder/addMultipleDrugOrders.form?patientId="+${patientId},
						contentType : "application/json",
						dataType : "json",
						data : JSON.stringify(data),//used without stringify();
						success : function(data) {
						   console.log("success  : " + data);
						    if(data.responseText.includes("SUCCESS")){
						    	alertify.set('notifier','position', 'top-center');
								var savedAlert = alertify.success(data.responseText);
								/* savedAlert.delay(20).setContent(data.responseText); */
						    	window.location = "${pageContext.request.contextPath}/patientDashboard.form?patientId=${patientId}";
						    }
						    else if(data.responseText.includes("FAIL")) {
	
						    	showError(data);
						    }
						},
						error : function(data) {	/* success also falls in error because we are sending back string value */
							
							if(data.responseText.includes("FAIL")) {
								showError(data.responseText);
							}
							else if (data.responseText.includes("SUCCESS")) {
								alertify.set('notifier','position', 'top-center');
								var successAlert = alertify.success(data.responseText);
								successAlert.delay(40).setContent(data.responseText);
								window.location = "${pageContext.request.contextPath}/patientDashboard.form?patientId=${patientId}";
							}
						},
						done : function(e) {
							console.log("DONE");
						}
				});
				
			}
	}
	else {
		var error = "Please select any drug.";
		showError(error);
	}
	 
	return true;
}

function showError(error) {
	alertify.set('notifier','position', 'top-center');
	var errorAlert = alertify.error(error);
	errorAlert.delay(40).setContent(error);
}

function getActiveOrders() {
	
	var patientUuid = getPatientUuid();
	var activeOrders = null;
	
	jQuery.ajax({
		type : "GET",
		url: "/openmrs/ws/rest/v1/order?patient=" + patientUuid + "&v=full",
		dataType: 'json',
		async: false
	}).done(function(data ) {
		console.log("aCTIVE Orders");
		console.log(data);
		activeOrders = data;
	}); 
	
	return activeOrders;
}


function getPatientUuid() {
	
	var patientId = '${patientId}';
	var patientUuid = '';
	
	var url = "${pageContext.request.contextPath}/module/medicationlog/ajax/getPatientUuid.form?patientId=" + patientId; 
	jQuery.getJSON(url, function(result) {
		
		if(result.hasOwnProperty('patientUuid')){
			patientUuid = result.patientUuid;
		}
		
	});
	
	console.log("patientUuid: " + patientUuid + "    >");
	return patientUuid;
}

function getUrlVars() {
	var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
};

// first is start date, second is encounterDate
function beforeSecondDate(firstDate, secondDate) {
	
	var isBefore = false;
	
	var datePattern = '<openmrs:datePattern />';
	var startYears = datePattern.indexOf("yyyy");
	var startMonths =  datePattern.indexOf("mm");
	var startDays = datePattern.indexOf("dd");
	
	alert(firstDate + " =======1====== " + secondDate);
	
	var convertDateFirst = firstDate.substring(startYears, startYears + 4) + "/" + firstDate.substring(startMonths, startMonths + 2) + "/" + firstDate.substring(startDays, startDays + 2);
	var convertDateSecond = secondDate.substring(startYears, startYears + 4) + "/" + secondDate.substring(startMonths, startMonths + 2) + "/" + secondDate.substring(startDays, startDays + 2);

	alert(convertDateFirst + " =======2====== " + convertDateSecond);
	
	var finalFirstDate = new Date(convertDateFirst);
	var finalSecondDate = new Date(convertDateSecond);
	
	alert(finalFirstDate + " =======3===== " + finalSecondDate);
	
	if(finalFirstDate  < finalSecondDate) {
		isBefore = true;
	}
	
	alert("isBefore: " + isBefore );
	return isBefore;
}

function process(date){
	   var parts = date.split("/");
	   return new Date(parts[2], parts[1] - 1, parts[0]);
	}
	
// use if the date is not coming from openmrs date widget
function convertDate(inputFormat) {
	  function pad(s) { return (s < 10) ? '0' + s : s; }
	  var d = new Date(inputFormat);
	  return [pad(d.getDate()), pad(d.getMonth()+1), d.getFullYear()].join('/');
	}
	
/* Remove error from page in case of page refresh! */
jQuery(function() {
	
	var patientId =${patientId};
	
	if (performance.navigation.type == 1) {
		window.location.href = "${pageContext.request.contextPath}/module/medicationlog/multiDrugOrder.form?patientId="+patientId;
		
	}
	
	jQuery("body").keydown(function(e){
		
		if(e.which==116){
			window.location.href = "${pageContext.request.contextPath}/module/medicationlog/multiDrugOrder.form?patientId="+patientId;
		}
		
	});
});

</script>

<openmrs:portlet url="patientHeader" id="patientDashboardHeader" patientId="${patientId}"/>

<div>
<h3 style="color: red; display: inline">${error} ${param.error}</h3>
<div >
</div>

<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.addMedication" /></div>
<div id="individualDrugOrderDiv" class="box${model.patientVariation}">
	<!-- <h2><spring:message code="medication.regimen.addMedication" /></h2> -->
			<input type="hidden" name="patientId" id="patientId" value = "${patientId}">
			<input type="hidden" name="returnPagee" value="/patientDashboard.form?patientId=${patientId}"/>	
			<input type="hidden" name="operation" id="operation" value="${operation}"/> <!--  revise Vs renew -->
			<input type="hidden" name="currentUserId" id="currentUserId" value="${currentUserId}"/>
			<input type="hidden" name="drugId" id="drugId" value=""/>
			<input type="hidden" name="drugSelection" id="drugSelection" value=""/>
			<input type="hidden" name="orderId" id="orderId" value=""/>
			
			
		<fieldset class="scheduler-border">
		
		<legend  class="scheduler-border"><spring:message code="medication.regimen.drugSelectionHeading" /></legend>
			
			<div class="row">
				<div class="col-md-2">
					<label  class="control-label"><spring:message code="medication.regimen.drugSelection" /></label>
				</div>
				<div class="col-md-6">
					<input type="radio" id="drugSets" name="selection" value="<spring:message code="medication.regimen.drugSetsOption" />" ><spring:message code="medication.regimen.drugSetsOption" />  <input type="radio"  id="drugs" name="selection" value="<spring:message code="medication.regimen.drugsOption" />" ><spring:message code="medication.regimen.drugsOption" />
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label id="encounterLabel"><spring:message code="medication.regimen.encounterSelection" /></label>
					
				</div>
				<div class="col-md-6">
					<select style="text-transform: capitalize" name="patientEncounter" id="patientEncounter">
						<option style="text-transform: capitalize" value="">Select encounter</option>
						<c:if test="${not empty encounters}">
							<c:forEach var="encounter" items="${encounters}">
								<option style="text-transform: capitalize" value="${encounter.encounterId}">${encounter.encounterName}</option>
							</c:forEach>
							</c:if>
						</select>
						<font color="#2F4F4F"><span id="encounterDate"></span></font>
						<span id="encounterError" class="text-danger "></span>
			   	</div>
    		</div>
    		
    		<label></label>
    		
    		<div class="row">
				<div class="col-md-2">
					<label id="drugSetLabel"><spring:message code="medication.regimen.drugSetLabel" /></label>
				</div>
				<div class="col-md-6">
					<select style="text-transform: capitalize" name="drugSetList" id="drugSetList">
						<option style="text-transform: capitalize" value="">Select option</option>
							<c:forEach var="drugSet" items="${drugSets}">
								<option style="text-transform: capitalize" value="${drugSet.conceptId}">${fn:toLowerCase(drugSet.name)}</option>
							</c:forEach>
					</select>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label id="drugSetLabel"><spring:message code="medication.regimen.drugLabel" /></label><span class="required">*</span>
				</div>
				<div class="col-md-6">
					<input id="drugSuggestBox" name="drugName" style="text-transform: capitalize" value="${requestedOrder.drug.concept.name}" list="drugOptions" placeholder="Search Drug..."/>
						<datalist class="lowercase" id="drugOptions"></datalist>
					<input type="button" value="Add" onclick="addDrugToTable()"></input>	
			   	</div>
    		</div>
    		
    		
    	</fieldset>
		
		<div>
    	
		
		<h4>Drugs List</h4>
			
			<br>
			
			<div class="row">
		            <div class="col-md-12">
		                        
		                        <table id="drugsTable" class="table table-striped table-bordered" style="width:100%">
									<thead>
									<tr>
										
										<th><spring:message code="medication.regimen.drugLabel"/></th>
										<th>Dose</th>
										<th>Dose Unit</th>
										<th><spring:message code="DrugOrder.frequency"/></th>
										<th><spring:message code="medication.regimen.route"/></th>
										<th><spring:message code="medication.drugOrder.duration"/></th>
										<th>Duration Unit</th>
										<th>Instructions</th>
										<th>Start Date</th>
										
									</tr>
									</thead>
								</table>
		                    
		            </div>
		        </div>
    		
    		<div class="row">
			   <div class="col-md-2">
					<input type="submit" onclick = "return saveOrders()" value="Save Drug Order"></input>
			   </div>
			   <div class="col-md-2">
					<input type="button" value="Cancel" onclick="location.href='${pageContext.request.contextPath}/patientDashboard.form?patientId=${patientId}'"></input>
			   </div>
			 </div>
    	</div>
		
</div>



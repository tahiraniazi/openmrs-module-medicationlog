<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ taglib prefix = "fmt" uri = "http://java.sun.com/jsp/jstl/fmt" %>
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
<link href="/openmrs/moduleResources/medicationlog/css/chosen.css" rel="stylesheet" >
	
<script src="/openmrs/moduleResources/medicationlog/alertify.min.js"></script>
<script src="/openmrs/moduleResources/medicationlog/js/jquery-ui.min.js"></script>
<script src="/openmrs/moduleResources/medicationlog/js/bootstrap.min.js"></script>
<script src="/openmrs/moduleResources/medicationlog/js/jquery-3.3.1.min.js"></script>
<script src="/openmrs/moduleResources/medicationlog/js/chosen.jquery.js"></script>

<style>

body {
	font-size: 0.8em;
}

.form-control {
	font-size: 1em;
	padding: 0 !important;
	padding-left: 0.3em !important;
}

input[type=text],[type=number], #drugSuggestBox {
	height: 2.3em !important;
}

select.form-control {
	height: 2.25em !important;
}

input[type=submit], [type=button] {
	background-color: #1aac9b;
	color: white;
	padding: 8px 16px;
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
 
input[type=text], select, textarea,radio {
	border: 1px solid #1aac9b;
	border-radius: 2px;
	box-sizing: border-box;
} 

#startDateDrug {
	border: 1px solid #ced4da;
	width: 25em;
}

</style>

<script>

jQuery(document).ready(function() {
	
	// jQuery("#doseUnit").val("161553");
	// jQuery("#durationUnit").val("1072");
	
	jQuery("#doseUnit").val(jQuery("#doseUnit option:first").val());
	jQuery("#durationUnit").val(jQuery("#durationUnit option:first").val());
	jQuery('#orderReasonOther').prop('disabled', true);
	
	
	if('${requestedOrder}' != null && '${requestedOrder}' != '') {
		
		/* document.getElementById("doseUnit").selectedIndex = 1; */
		/* alert(document.getElementById("doseUnit").selectedIndex); */
		
		/* in edit mode - input tags are already autopopulated via value tag */
		
		var operation = "${operation}";
		if(operation == "RENEW") {
			
			jQuery('#drugSuggestBox').prop('disabled', 'diabled');
			jQuery('#startDateDrug').val('');
			jQuery('#patientEncounter').val('');
			
			jQuery("input[id='drugSets']:radio").attr('disabled', true);
			jQuery("input[id='drugs']:radio").attr('disabled', true);
		
		}
		else if(operation == "REVISE") {
			
			jQuery('#patientEncounter').prop('disabled', 'diabled');
			jQuery('#drugSuggestBox').prop('disabled', 'diabled');
			
			jQuery("input[id='drugSets']:radio").attr('disabled', true);
			jQuery("input[id='drugs']:radio").attr('disabled', true);
			
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
	
	if(jQuery('#doseUnit').children('option').length == 1) {
		missingConceptError =  missingConceptError + '<br><spring:message code="medication.regimen.conceptGlobalPropertyMissingError" arguments="order.drugDosingUnitsConceptUuid"/> ';
	}
	
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
				console.log(result.length);
				
				var datalist = document.getElementById("drugOptions");
				var dataListLength = datalist.options.length;
				if(dataListLength > 0 ) {
					jQuery("#drugOptions option").remove();
				}
				
				if(result.length > 0) {
					drugObject = {};
					drugStrengthsById = {};
					jQuery(result).each(function() {
						var drugName = toTitleCase(this.name.toLowerCase());
				            drugsOption = "<option value=\"" + this.id + "\">" + drugName + "</option>";
				            jQuery('#drugOptions').append(drugsOption);
				            drugKey = this.id; 
				            drugObject[drugKey] = drugName;
				            drugStrengthsById[drugKey] = this.strength;
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
						drugStrengthsById = {};
						jQuery(result).each(function() {
							var drugName = toTitleCase(this.name.toLowerCase());
					            drugsOption = "<option value=\"" + this.id + "\">" + drugName + "</option>";
					            jQuery('#drugOptions').append(drugsOption);
					            drugKey = this.id; 
					            drugObject[drugKey] = drugName;
					            drugStrengthsById[drugKey] = this.strength;
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
		    var drugKey = jQuery(this).val();
		    jQuery("#drugSuggestBox").val(drugObject[drugKey]);
		    jQuery("#drugId").val(drugKey);
		    var str = drugStrengthsById[drugKey] === null ? "Strength not found" : drugStrengthsById[drugKey];
		    document.getElementById("strengthSpan").innerHTML= str;
		}
	});
	
	jQuery(function(){ 
		jQuery('#patientEncounter').chosen();
		jQuery('#frequency').chosen();
		jQuery('#route').chosen();
    });
	
});



jQuery(function() {
	
	var doseInput = document.getElementById('dose');

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
	}
	
	
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

function refresh() {
	
	document.getElementById("doseUnit").selectedIndex = 1;
	document.getElementById("frequency").selectedIndex = "0";
	document.getElementById("route").selectedIndex = "0";
	document.getElementById("durationUnit").selectedIndex = 1;
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
		
		if(operation == "") {
		
			var datalist = document.getElementById("drugOptions");
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
		}
		
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
			/* if(durationUnitSelectElement.selectedIndex == 0) {
				error = error + "<br><spring:message code='medication.regimen.durationUnitError' /> ";
				isValid = false;
			} */
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
		/* var frequencySelectElement =  document.getElementById('frequencyDay');
		if(frequencySelectElement.selectedIndex == 0) {
			
			error = error + "<br><spring:message code='medication.regimen.frequencyError' /> ";
			isValid = false;
		}
 */		

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
		alertify.set('notifier','position', 'top-center');
		alertify.error(error);
		return isValid;
	}
	
	jQuery('#patientEncounter').prop('disabled', false);
	jQuery('#startDateDrug').prop('disabled', false);
	jQuery('#drugSuggestBox').prop('disabled', false);
	return isValid;
}

function getUrlVars() {
	var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
};

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
		window.location.href = "${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder.form?patientId="+patientId;
		
	}
	
	jQuery("body").keydown(function(e){
		
		if(e.which==116){
			window.location.href = "${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder.form?patientId="+patientId;
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
	<div id="internalContainerDiv" class="container">
	<!-- <h2><spring:message code="medication.regimen.addMedication" /></h2> -->
		<form id="form" name="addIndividualDrug" method="post" action="${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder/addDrugOrder.form" onsubmit="return saveOrder()">
			<input type="hidden" id="patientId" name="patientId" value = "${patientId}">
			<input type="hidden" name="returnPagee" value="/patientDashboard.form?patientId=${patientId}"/>	
			<input type="hidden" name="operation" id="operation" value="${operation}"/> <!--  revise Vs renew -->
			<input type="hidden" name="currentUserId" value="${currentUserId}"/>
			<input type="hidden" name="drugId" id="drugId" value=""/>
			<input type="hidden" name="drugSelection" id="drugSelection" value=""/>
			<input type="hidden" name="orderId" id="orderId" value=""/>
			
			
		<fieldset class="scheduler-border">
		
		<legend  class="scheduler-border"><spring:message code="medication.regimen.drugSelectionHeading" /></legend>
			
			<div class="row">
				<div class="col-md-2">
					<label  class="control-label"><spring:message code="medication.regimen.drugSelection" /></label>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<label class="radio-inline"><input type="radio" id="drugSets" name="selection" value="<spring:message code="medication.regimen.drugSetsOption" />" ><spring:message code="medication.regimen.drugSetsOption" /></label>  
					<label class="radio-inline"><input type="radio"  id="drugs" name="selection" value="<spring:message code="medication.regimen.drugsOption" />" ><spring:message code="medication.regimen.drugsOption" /></label>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label id="encounterLabel"><spring:message code="medication.regimen.encounterSelection" /></label><span class="required">*</span>
					
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<select class="form-control" style="text-transform: capitalize" name="patientEncounter" id="patientEncounter">
						<option style="text-transform: capitalize" value="">Select encounter</option>
						<c:if test="${not empty encounters}">
							<c:forEach var="encounter" items="${encounters}">
								<option style="text-transform: capitalize" value="${encounter.encounterId}"><p>${encounter.encounterName} [${encounter.encounterDate}]</p></option>
							</c:forEach>
							</c:if>
						</select>
			   	</div>
			   	<div class="col-sm-2 col-md-2 col-lg-2">
						<font color="#2F4F4F"><span id="encounterDate" style="display:none"></span></font>
			   	</div>
    		</div>
    		
    		<label></label>
    		
    		<div class="row">
				<div class="col-md-2">
					<label id="drugSetLabel"><spring:message code="medication.regimen.drugSetLabel" /></label>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<select class="form-control" style="text-transform: capitalize" name="drugSetList" id="drugSetList">
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
				<div class="col-sm-5 col-md-5 col-lg-5">
					<input class="form-control" id="drugSuggestBox" name="drugName" style="text-transform: capitalize" value="${requestedOrder.drug.concept.name}" list="drugOptions" placeholder="Search Drug..."/>
						<datalist class="lowercase" id="drugOptions"></datalist>	
			   	</div>
			   	<div class="col-sm-5 col-md-5 col-lg-5" id="strengthDiv" style="padding: 0.6em; color:#757575 ">
						<img class="manImg" src="/openmrs/moduleResources/medicationlog/img/flash.png"  title="Drug strength"></img><span id="strengthSpan" class='addMedicationImage'>Drug strength</span>
						<br>
			   	</div>
    		</div>
    		
    		
    	</fieldset>
    	
    	
    	<fieldset class="scheduler-border">
		
		<legend  class="scheduler-border"><spring:message code="medication.regimen.drugPrescription"/></legend>
			
			<div class="row">
				<div class="col-md-2">
					<label  class="control-label"><spring:message code="DrugOrder.dose" /></label><span class="required">*</span>
				</div>
				<div class="col-sm-2 col-md-2 col-lg-2">
						<fmt:parseNumber var = "integerDose" type = "number" value = "${requestedOrder.dose}" />
						<input class="form-control" type="number" name="dose" id="dose" size="2" min="1" max="5000" value="${integerDose}"/> 
			   	</div>
			   	<div class="col-sm-3 col-md-3 col-lg-3">
			   		<select class="form-control" style="text-transform: capitalize" name="doseUnit" id="doseUnit">
							<c:if test="${not empty doseUnits}">
								<c:forEach var="doseUnit" items="${doseUnits}">
									<option style="text-transform: capitalize"  value="${doseUnit.conceptId}">${fn:toLowerCase(doseUnit.name)}</option>
								</c:forEach>
							</c:if>
					</select>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label  class="control-label"><spring:message code="DrugOrder.frequency"/></label><span class="required">*</span>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<select class="form-control" style="text-transform: capitalize" name="frequency" id="frequency">
							<option style="text-transform: capitalize" value="">Select frequency</option>
							<c:if test="${not empty frequencies}">
							
							<c:forEach var="frequency" items="${frequencies}">
								<option style="text-transform: capitalize" value="${frequency.conceptId}">${fn:toLowerCase(frequency.name)}</option>
							</c:forEach>
							</c:if>
						</select>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label  class="control-label"><spring:message code="medication.regimen.route" /></label><span class="required">*</span>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<select class="form-control" style="text-transform: capitalize" name="route" id="route">
						<option style="text-transform: capitalize" value="${requestedOrder.route.name}">Select route</option>
						<c:if test="${not empty routes}">
							<c:forEach var="route" items="${routes}">
								<option style="text-transform: capitalize" value="${route.conceptId}">${fn:toLowerCase(route.name)}</option>
							</c:forEach>
						</c:if>
					</select>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label class="control-label"><spring:message code="medication.regimen.dosingInstructions"/></label>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<textarea class="form-control" rows="3" cols="30" name="dosingInstructions" id="dosingInstructions" maxlength="250">${requestedOrder.dosingInstructions}</textarea>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label class="control-label"><spring:message code="medication.orderset.field.startDay" /></label><span class="required">*</span>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<openmrs_tag:dateField formFieldName="startDateDrug" startValue=""/>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label class="control-label"><spring:message code="medication.regimen.duration"/></label><span class="required">*</span>
				</div>
				<div class="col-sm-2 col-md-2 col-lg-2">
					<input class="form-control"  type="number" name="duration" id="duration" size="2" min="1" max="99" value="${requestedOrder.duration}"/>
			   	</div>
			   	<div class="col-sm-3 col-md-3 col-lg-3">
			   		<select class="form-control" style="text-transform: capitalize" name="durationUnit" id="durationUnit">
							<c:if test="${not empty durationUnits}">
							<c:forEach var="duration" items="${durationUnits}">
								<option style="text-transform: capitalize"  value="${duration.conceptId}">${fn:toLowerCase(duration.name)}</option>
							</c:forEach>
							</c:if>
					</select>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label class="control-label"><spring:message code="medication.regimen.reasonForOrder" /></label>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<select class="form-control" style="text-transform: capitalize" name="orderReason" id="orderReason">
							<option style="text-transform: capitalize" value="">Select option</option>
							<c:if test="${not empty orderReasons}">
							<c:forEach items="${orderReasons}" var="orderReason">
								<option style="text-transform: capitalize" value="${orderReason.conceptId}">${fn:toLowerCase(orderReason.displayString)}</option>
							</c:forEach>
							</c:if>
						</select>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label class="control-label"><spring:message code="medication.regimen.additionalReason" /></label>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<textarea class="form-control" rows="3" cols="30" name="orderReasonOther" id="orderReasonOther" maxlength="250"></textarea>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label class="control-label"><spring:message code="medication.regimen.administrationInstructions" /></label>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<textarea class="form-control" rows="3" cols="30" name="adminInstructions" id="adminInstructions" maxlength="250"></textarea>
			   	</div>
    		</div>
    		
    		<div class="row">
				<div class="col-md-2">
					<label class="control-label"><spring:message code="medication.regimen.commentsToFulfiller" /></label>
				</div>
				<div class="col-sm-5 col-md-5 col-lg-5">
					<textarea class="form-control" rows="3" cols="30" name="commentsFulfiller" id="commentsFulfiller" maxlength="250"></textarea>
			   	</div>
    		</div>
    		
    		<div class="row">
			   <div class="col-md-2">
					<input type="submit" value="Save Drug Order"></input>
			   </div>
			   <div class="col-md-2">
					<input type="button" value="Cancel" onclick="location.href='${pageContext.request.contextPath}/patientDashboard.form?patientId=${patientId}'"></input>
			   </div>
			 </div>
    		
    		
    		
    	</fieldset>
		</form>
	</div>
</div>


<%@ include file="/WEB-INF/template/footer.jsp"%>
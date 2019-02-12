<%@ include file="/WEB-INF/template/include.jsp"%>

<openmrs:htmlInclude file="/moduleResources/medicationlog/css/medication.css" />

<link rel="stylesheet"
	href="/openmrs/moduleResources/medicationlog/css/alertify.min.css" />
<link rel="stylesheet"
	href="/openmrs/moduleResources/medicationlog/themes/default.min.css"
	id="toggleCSS" />
	
<script src="/openmrs/moduleResources/medicationlog/alertify.min.js"></script>

<!-- <openmrs:htmlInclude file="/moduleResources/medicationlog/js/jquery-3.3.1.js" /> --> 

<script type="text/javascript">

jQuery(function() {
	
	/* if (performance.navigation.type == 1) {
			window.location.href = "/openmrs/patientDashboard.form?patientId=${model.patient.patientId}";
	}
	
	jQuery("body").keydown(function(e){
		
		if(e.which==116){
			window.location.href = "/openmrs/patientDashboard.form?patientId=${model.patient.patientId}";
		}
		
	}); */
});

jQuery(document).ready(function() {
	
	var drugObject = {};
	
	var saved = '${param.saved}';
	if(saved != null && saved != "") {
		
		alertify.set('notifier','position', 'top-center');
		var savedAlert = alertify.success(saved);
		savedAlert.delay(20).setContent(saved);
		
		jQuery('body').one('click', function(){
			savedAlert.dismiss();
		});
	}
	
	/* var missingConceptError = "";
	
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
	} */
	
	
	
});

function toTitleCase(str) {
    return str.replace(/(?:^|\s)\w/g, function(match) {
        return match.toUpperCase();
    });
}


function process(date){
	   var parts = date.split("/");
	   return new Date(parts[2], parts[1] - 1, parts[0]);
	}
	
	
</script>

<div>
<h3 style="color: red; display: inline">${error} ${param.error}</h3>
<div >
</div>
<openmrs:hasPrivilege privilege="Medication - Add Drug Orders">
<div id="addMedicationLink" class="row">
<%-- <button id="addMedicationButton" onclick="location.href='${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder.form?patientId=${model.patient.patientId}'">
	<span><openmrs:message code="medication.regimen.addMedication"/></span>
	<span class='addMedicationImage'><img class="manImg" src="/openmrs/moduleResources/medicationlog/img/add.gif"></img></span>
</button>
 --%>
<div class="col-md-2">
<a href="${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder.form?patientId=${model.patient.patientId}" ><openmrs:message code="medication.regimen.addMedication"/></a><span class='addMedicationImage'><img class="manImg" src="/openmrs/moduleResources/medicationlog/img/add.gif"></img></span>
<br>
</div>

<div class="col-md-2">
<a href="${pageContext.request.contextPath}/module/medicationlog/multiDrugOrder.form?patientId=${model.patient.patientId}" ><openmrs:message code="medication.regimen.addMultipleMedication"/></a><span class='addMedicationImage'><img class="manImg" src="/openmrs/moduleResources/medicationlog/img/add.gif"></img></span>
<br>
</div>

<%-- <button id="addMultiOrderButton" onclick="location.href='${pageContext.request.contextPath}/module/medicationlog/multiDrugOrder.form?patientId=${model.patient.patientId}'">
	<span><openmrs:message code="medication.regimen.addMedication"/></span>
	<span class='addMedicationImage'><img class="manImg" src="/openmrs/moduleResources/medicationlog/img/add.gif"></img></span>
</button> --%>

</div>
</openmrs:hasPrivilege>

<br />


<div id="regimenPortlet">
	<div class="regimenPortletCurrent">	
			<openmrs:portlet url="currentRegimen.portlet" moduleId="medicationlog" id="patientRegimenCurrent" patientId="${model.patient.patientId}" parameters="mode=current|redirect=${model.redirect}"/>	
	</div> 
	<br />
	
	<div class="regimenPortletCompleted">
			<openmrs:portlet url="completedRegimen.portlet" moduleId="medicationlog" id="patientRegimenCompleted" patientId="${model.patient.patientId}" parameters="mode=completed|redirect=${model.redirect}"/>
	</div>
</div>



</div>
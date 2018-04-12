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

jQuery(document).ready(function() {
	
	var drugsList = null;
	
	/* make Drug sets option selected */
	jQuery("#drugSets").prop("checked", true);
	
	/* var doseInput = document.querySelector('dose');

	doseInput.addEventListener('input', function(){
	    // only numeric
	    var num = this.value.match(/^\d+$/);
	    if (num === null) {
	        this.value = "";
	    }
	}, false)

	var durationInput = document.querySelector('duration');

	durationInput.addEventListener('input', function(){
		// only numeric
		var num = this.value.match(/^\d+$/);
	    if (num === null) {
	        this.value = "";
	    }
	}, false) */
	
	jQuery.ajax({
		url: "/openmrs/ws/rest/v1/user?v=custom:(uuid,username,person)&amp;roles=PMDT Treatment Supporter",
		dataType: 'json'
		}).done(function(data ) {
			/* console.log(data.results[0].username);
			console.log(data.results.length); */
			userData = data;
			
	});
	
	jQuery('#addMedicationButton').click(function(){ 
			jQuery('#addNewRegimenDialog').dialog('open');
			
			jQuery("#addOrderSetButton").attr("disabled", "disabled");
			jQuery("#addIndividualDrugButton").removeAttr("disabled");
			
			jQuery('#addOrderSet').show();
			jQuery('#addIndividualDrug').hide();
			jQuery('.openmrs_error').hide();
	});
	
	jQuery('#addNewRegimenDialog').dialog({
		position: 'middle',
		autoOpen: false,
		modal: true,
		title: '<spring:message code="medication.regimen.addMedication" javaScriptEscape="true"/>',
		height: 530,
		width: '80%',
		zIndex: 100,
		buttons: { '<spring:message code="general.add"/>': function() { submitOrder(); },
				   '<spring:message code="general.cancel"/>': function() { $j(this).dialog("close"); }
		}
	});

	jQuery('#addOrderSetButton').click(function(){ 
		jQuery('#addOrderSet').show();
 		jQuery('#addIndividualDrug').hide();
	
// 		jQuery("#addOrderSetLabel").show();
// 		jQuery("#addIndividualDrugLabel").hide();
		
		jQuery("#addOrderSetButton").attr("disabled", "disabled");
		jQuery("#addIndividualDrugButton").removeAttr("disabled");
		
		jQuery('.openmrs_error').hide();
	});
	
	jQuery('#addIndividualDrugButton').click(function(){ 
		jQuery('#addOrderSet').hide();
		jQuery('#addIndividualDrug').show();
		
// 		jQuery("#addOrderSetLabel").hide();
// 		jQuery("#addIndividualDrugLabel").show();
		
		jQuery("#addIndividualDrugButton").attr("disabled", "disabled");
		jQuery("#addOrderSetButton").removeAttr("disabled");
		
		jQuery('.openmrs_error').hide();
		
	});
	
	jQuery('#drugSets').click(function(){ 
		jQuery('#drugSetList').prop('disabled', false);
		jQuery("#drugs").prop("checked", false);
	});
	
	jQuery('#drugs').click(function(){ 
		jQuery('#drugSetList').prop('disabled', 'disabled');
		jQuery("#drugSets").prop("checked", false);
		
		var url = "${pageContext.request.contextPath}/module/medicationlog/ajax/getAllDrugs.form"; 
		jQuery.getJSON(url, function(result) {
				console.log(result.length);
				console.log(result);
				
				var datalist = document.getElementById("drugOptions");
				var dataListLength = datalist.options.length;
				if(dataListLength > 0 ) {
					jQuery("#drugOptions option").remove();
				}
				
				if(result.length > 0) {
					jQuery(result).each(function() {
				            drugsOption = "<option value=\"" + this.name + "\">${fn:toLowerCase(" + this.id + ")}</option>";
				            console.log(this.id + " " + result.name);
				            jQuery('#drugOptions').append(drugsOption);
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
					console.log(result);
					
					var datalist = document.getElementById("drugOptions");
					var dataListLength = datalist.options.length;
					if(dataListLength > 0 ) {
						jQuery("#drugOptions option").remove();
					}
					
					if(result.length > 0) {
						jQuery(result).each(function() {
					            drugsOption = "<option value=\"" + this.name + "\">" + this.id + "</option>";
					            console.log(this.id + " " + result.name);
					            jQuery('#drugOptions').append(drugsOption);
						});
					}
			});
		}
	});
	
});

function submitOrder() {
	
	if(jQuery('#addOrderSet').is(":visible") == true)
	{
		var error = "";
		
		error = "Error submitting drug order.";
		
		if(error != "")
		{
			jQuery('.openmrs_error').show();
			jQuery('.openmrs_error').html(error);
		}
		else
		{
			jQuery('#addOrderSet').submit();
		}
	}
	if(jQuery('#addIndividualDrug').is(":visible") == true)
	{
		
		var error = "";
		
		var selectedDrug = jQuery("#drugSuggestBox").val();
		if(selectedDrug == "")
		{
			error = " <spring:message code='medication.regimen.drugError' /> ";
		}
		else 
		{
			var dose = jQuery("#dose").val();
			
			if(dose == "")
			{
				error = error + " <spring:message code='medication.regimen.doseError' /> ";

			}
			else
			{
				var doseUnitSelectElement =  document.getElementById('doseUnits');
				if(doseUnitSelectElement.selectedIndex == 0)
				{
					error = error + "<br><spring:message code='medication.regimen.doseUnitError' /> ";
				}
			}
			
			var startDate = jQuery("#startDateDrug").val();
			
			if(startDate == "")
			{
				error = error + "<br><spring:message code='medication.regimen.startDateError' /> ";
			}
			
			var frequencySelectElement =  document.getElementById('frequencyDay');
			if(frequencySelectElement.selectedIndex == 0)
			{
				error = error + "<br><spring:message code='medication.regimen.frequencyError' /> ";
			}
			
			var routeSelectElement =  document.getElementById('route');
			if(routeSelectElement.selectedIndex == 0)
			{
				error = error + "<br><spring:message code='medication.regimen.routeError' /> ";
			}
			
			var start = jQuery("#startDateDrug").val();
			var stop = jQuery("#stopDateDrug").val();
			
			var startDate = new Date(start);
			var stopDate = new Date(stop);
			
			if(startDate > stopDate) {
				error = error + "<br><spring:message code='medication.regimen.dateError' /> ";
			}
		}
		
		if(error != "")
		{
			alertify.set('notifier','position', 'top-center');
			alertify.error(error);
		}
		else
		{
			alertify.confirm('Create drug order!', 'Are you sure you want to create a drug order?', function(){ alert("success!")}, function(){ alertify.error('Cancel') });
			/* jQuery('#addIndividualDrug').submit(); */
		}
	}
}

function process(date){
	   var parts = date.split("/");
	   return new Date(parts[2], parts[1] - 1, parts[0]);
	}

$(function() {
	$('option').each(function() {
		$(this).text($(this).text().replace(/^(.)|\s(.)/g, function($1){ return $1.toUpperCase( ); }));
    });
});

</script>

<div>
<!-- <openmrs:hasPrivilege privilege=""> -->
<div id="addMedicationLink"><input type="button" id="addMedicationButton" value="<openmrs:message code="medication.regimen.addMedication"/>"></div>
<!-- </openmrs:hasPrivilege> -->

<br />
<br />

<div id="regimenPortlet">
	<div class="regimenPortletCurrent">	
		<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.current" /></div>
		<div class="box${model.patientVariation}">
			<openmrs:portlet url="currentregimen" moduleId="medicationlog" id="patientRegimenCurrent" patientId="${model.patient.patientId}" parameters="mode=current|redirect=${model.redirect}"/>	
		</div>			
	</div>
	<br />
	
	<div class="regimenPortletCompleted">
		<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.completed" /></div>
		<div class="box${model.patientVariation}">
			<openmrs:portlet url="completedregimen" moduleId="medicationlog" id="patientRegimenCompleted" patientId="${model.patient.patientId}" parameters="mode=completed|redirect=${model.redirect}"/>
		</div>
	</div>
</div>


<div id="addNewRegimenDialog">

	<div id="buttonDiv">
		<table width="100%">
			<tr>
<!-- 				<td> -->
<!-- 					<span id="addOrderSetLabel"><strong><openmrs:message code="medication.orderset.field.selectOrderSet" /></strong></span> -->
<!-- 					<span id="addIndividualDrugLabel"><strong><openmrs:message code="medication.regimen.addMedication" /></strong></span> -->
<!-- 				</td> -->
				<td id="medicationButtonSpan">
					<input type="button" id="addOrderSetButton" value="<openmrs:message code="medication.orderset.field.selectOrderSet" />"></span>
					<span id="addIndividualDrugButtonSpan"><input type="button" id="addIndividualDrugButton" value="<openmrs:message code="medication.regimen.addMedication" />"></span>
				</td>
			</tr>		
		</table>
	</div>
	
	<div class="box">
	<div id="openmrs_error" class="openmrs_error"></div>
	<form id="addOrderSet" name="addMedication" method="post" action="${pageContext.request.contextPath}/module/medicationlog/addOrderSet.form">
			
			<table>
				<tr>
					<td class="padding">
					<div id="orderSetLabel"><spring:message code="medication.orderset.field.selectOrderSet" /><span class="required">*</span>:</div>
					</td>
						<td>
						<select class="capitalize" name="orderSet" id="orderSet" data-placeholder="<spring:message code="medication.orderset.field.chooseOption" />" style="width:450px;">
							<option class="capitalize" value="" selected="selected"></option>
							
 							<%-- <c:forEach items="${model.orderSets}" var="orderSet"> 
 								<option class="capitalize" value="${orderSet.id}"> 
 									${orderSet.name}</option> 
 							</c:forEach> --%> 

						</select>
					</td class="padding">
					<td class="padding">
						<spring:message code="medication.orderset.field.relativeStartDay" /><span class="required">*</span>:  <openmrs_tag:dateField formFieldName="startDateSet" startValue=""/>
					</td>
				</tr>
			</table>
		</form>
		
		<div id="individualDrugDiv">
		<form id="addIndividualDrug" name="addIndividualDrug" method="post" action="${pageContext.request.contextPath}/module/medicationlog/addDrugOrder.form">
			<input type="hidden" name="patientId" value="${model.patient.patientId}">
			<input type="hidden" name="returnPage" value="${model.redirect}&patientId=${model.patient.patientId}"/>	
			<table>
				<tr class="drugDetails">
					<th class="padding"><spring:message code="medication.regimen.drugSelectionHeading" />:</th>
				</tr>
				<tr>
				<td class="padding"><spring:message code="medication.regimen.drugSelection" />: <input type="radio" id="drugSets" name="selection" value="<spring:message code="medication.regimen.drugSetsOption" />" ><spring:message code="medication.regimen.drugSetsOption" />  <input type="radio"  id="drugs" name="selection" value="<spring:message code="medication.regimen.drugsOption" />" ><spring:message code="medication.regimen.drugsOption" />
					</td>
				</tr>
				<tr class="lastrow">
				<td class="padding" id="drugSetRow"> <label id="drugSetLabel"><spring:message code="medication.regimen.drugSetLabel" /></label>: 
				<select class="capitalize" name="drugSetList" id="drugSetList">
						<option class="capitalize" value="">Select option</option>
							<c:forEach var="drugSet" items="${model.drugSets}">
								<option class="capitalize" value="${drugSet.conceptId}">${fn:toLowerCase(drugSet.name)}</option>
							</c:forEach>
						</select>
					</td>
					<td class="padding"><spring:message code="medication.regimen.drugLabel" /><span class="required">*</span>:
					<input id="drugSuggestBox" name="drugCombo" class="capitalize" list="drugOptions" placeholder="Search Drug..." />
						<datalist class="lowercase" id="drugOptions"></datalist>
					<%-- <select class="capitalize" name="drugCombo" id="drugCombo" data-placeholder="<spring:message code="medication.regimen.chooseOption" />" style="width:350px;">
							<option class="capitalize" value="" selected="selected"></option>
							
							<c:forEach items="${model.drugs}" var="drug">
								<option class="capitalize" value="${drug.conceptId}">${fn:toLowerCase(drug.name)}</option>
							</c:forEach>
						</select> --%>
					</td>
					
				</tr>
			
				<tr class="drugDetails">
					<th class="padding"><spring:message code="medication.regimen.patientPrescription" />:</th>
				</tr>
				<tr class="drugDetails">
					<td class="padding"><spring:message code="DrugOrder.dose" /><span class="required">*</span>: <input type="number" name="dose" id="dose" size="2" min="0"/> <select class="capitalize" name="doseUnits" id="doseUnits">
						<option class="capitalize" value="">Select option</option>
							<c:forEach var="doseUnit" items="${model.doseUnits}">
								<option class="capitalize"  value="${doseUnit.conceptId}">${fn:toLowerCase(doseUnit.name)}</option>
							</c:forEach>
						</select>
					</td>
					
					<td class="padding"><spring:message code="DrugOrder.frequency"/><span class="required">*</span>:			
						<select class="capitalize" name="frequencyDay" id="frequencyDay">
						<option class="capitalize" value="">Select option</option>
							<c:forEach var="frequency" items="${model.frequencies}">
								<option class="capitalize" value="${frequency.conceptId}">${fn:toLowerCase(frequency.name)}</option>
							</c:forEach>
<%-- 							<% for ( int i = 1; i <= 10; i++ ) { %> --%>
<%-- 								<option class="capitalize" value="<%= i %>/<spring:message code="DrugOrder.frequency.day" />"><%= i %>/<spring:message code="DrugOrder.frequency.day" /></option> --%>
<%-- 							<% } %> --%>
<%-- 							<option class="capitalize" value="<spring:message code="medication.regimen.onceOnlyDose" />"><spring:message code="medication.regimen.onceOnlyDose" /></option> --%>
						</select>
						<%-- <span> - </span>
						<select name="frequencyWeek" id="frequencyWeek">
							<openmrs:globalProperty var="drugFrequencies" key="dashboard.regimen.displayFrequencies" listSeparator="," />
							<c:if test="${empty drugFrequencies}">
								<option disabled>&nbsp; <spring:message code="DrugOrder.add.error.missingFrequency.interactions" arguments="dashboard.regimen.displayFrequencies"/></option>
							</c:if>
							<c:if test="${not empty drugFrequencies}">
								<option class="capitalize" value="">Select option</option>
								<c:forEach var="drugFrequency" items="${drugFrequencies}">
									<option class="capitalize" value="${drugFrequency}">${drugFrequency}</option>
								</c:forEach>
							</c:if>											
						</select> --%>
					</td>
				</tr>
				
				<tr class="drugDetails">
					<td class="padding"><spring:message code="medication.regimen.route" /><span class="required">*</span>: <select class="capitalize" name="route" id="route">
						<option class="capitalize" value="">Select option</option>
							<c:forEach var="route" items="${model.routes}">
								<option class="capitalize" value="${route.conceptId}">${fn:toLowerCase(route.name)}</option>
							</c:forEach>
						</select>
					</td>
					
					<!--	maps on order.instructions  -->
					<td class="padding"><spring:message code="medication.regimen.dosingInstructions"/>: <textarea rows="2" cols="30" name="dosingInstructions" id="dosingInstructions"></textarea></td>				
					
				</tr>
				
				<tr class="drugDetails">	
					<td class="padding"><spring:message code="medication.orderset.field.relativeStartDay" /><span class="required">*</span>:  <openmrs_tag:dateField formFieldName="startDateDrug" startValue=""/></td>
					<td class="padding"><spring:message code="medication.regimen.duration"/>: <input type="number" name="duration" id="duration" size="2" min="0"/> 
					<select class="capitalize" name="durationUnits" id="durationUnits">
							<option value="">Select option</option>
							<c:forEach var="duration" items="${model.durationUnits}">
								<option class="capitalize"  value="${duration.conceptId}">${fn:toLowerCase(duration.name)}</option>
							</c:forEach>
					</select> 
					<input type="checkbox" name="asNeeded" id="asNeeded" value="asNeeded"><spring:message code='medication.orderset.drugOrderSetMember.asNeeded'/>
					</td>	
				</tr>
			
				<tr	class="drugDetails">
					<td class="padding"><spring:message code="medication.regimen.reasonForOrder" />: <select class="capitalize" name="orderReasons" id="orderReasonCombo">
							<option class="capitalize" value="">Select option</option>
							<c:forEach items="${model.orderReasons}" var="orderReason">
								<option class="capitalize" value="${orderReason.conceptId}">${fn:toLowerCase(orderReason.displayString)}</option>
							</c:forEach>
						</select>
					</td>
					
					<td class="padding"><spring:message code="medication.regimen.additionalReason" />: <textarea rows="2" cols="30" name="additionalReason" id="additionalReason"></textarea>
					</td>
					
				</tr>
				
				<tr class="drugDetails">
					<!-- 				maps on drug_order.dosing_instructions  -->
					
					
					<td class="padding"><spring:message code="medication.regimen.administrationInstructions" />: 
					</td>
					<td><textarea rows="2" cols="30" name="adminInstructions" id="adminInstructions"></textarea></td>
					
					
				</tr>
			</table> 
		</form>
		</div>
		
	</div>
	
</div>


</div>
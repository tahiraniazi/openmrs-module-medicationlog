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
	
	if (performance.navigation.type == 1) {
			window.location.href = "/openmrs/patientDashboard.form?patientId=${model.patient.patientId}";
	}
	
	jQuery("body").keydown(function(e){
		
		if(e.which==116){
			window.location.href = "/openmrs/patientDashboard.form?patientId=${model.patient.patientId}";
		}
		
	});
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
	
	var drugsList = null;
	
	/* make Drug sets option selected */
	jQuery("#drugSets").prop("checked", true);
	jQuery('#drugSelection').val("BY DRUG SET");
	
	jQuery.ajax({
		url: "/openmrs/ws/rest/v1/user?v=custom:(uuid,username,person)&amp;roles=PMDT Treatment Supporter",
		dataType: 'json'
		}).done(function(data ) {
			userData = data;
			
	});
	
	jQuery('#addMedicationButton').click(function(){ 
			jQuery('#addNewRegimenDialog').dialog('open');
			
			jQuery("#addOrderSetButton").attr("disabled", "disabled");
			jQuery("#addIndividualDrugButton").removeAttr("disabled");
			
			jQuery('#addOrderSet').show();
			jQuery('#addIndividualDrug').hide();
			if(missingConceptError == "") {
				jQuery('.openmrs_error').hide();
			}
	});
	
	jQuery('#addNewRegimenDialog').dialog({
		position: 'middle',
		autoOpen: false,
		modal: true,
		title: '<spring:message code="medication.regimen.addMedication" javaScriptEscape="true"/>',
		height: 580,
		width: '80%',
		zIndex: 100,
		buttons: { '<spring:message code="general.add"/>': function() { submitOrder(); },
				   '<spring:message code="general.cancel"/>': function() { refresh(); $j(this).dialog("close"); }
		}
	});

	jQuery('#addOrderSetButton').click(function(){ 
		jQuery('#addOrderSet').show();
 		jQuery('#addIndividualDrug').hide();
	
// 		jQuery("#addOrderSetLabel").show();
// 		jQuery("#addIndividualDrugLabel").hide();
		
		jQuery("#addOrderSetButton").attr("disabled", "disabled");
		jQuery("#addIndividualDrugButton").removeAttr("disabled");
		
		if(missingConceptError == "") {
			jQuery('.openmrs_error').hide();
		}
	});
	
	jQuery('#addIndividualDrugButton').click(function(){ 
		jQuery('#addOrderSet').hide();
		jQuery('#addIndividualDrug').show();
		
// 		jQuery("#addOrderSetLabel").hide();
// 		jQuery("#addIndividualDrugLabel").show();
		
		jQuery("#addIndividualDrugButton").attr("disabled", "disabled");
		jQuery("#addOrderSetButton").removeAttr("disabled");
		
		if(missingConceptError == "") {
			jQuery('.openmrs_error').hide();
		}
		
	});
	
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
		    var drugKey = jQuery(this).val();
		    jQuery("#drugSuggestBox").val(drugObject[drugKey]);
		    jQuery("#drugId").val(drugKey);
		}
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
	
});

function refresh() {
	
	document.getElementById("doseUnit").selectedIndex = "0";
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
	jQuery('#orderReasonNonCoded').val('');
	jQuery('#dosingInstructions').val('');
}


function toTitleCase(str) {
    return str.replace(/(?:^|\s)\w/g, function(match) {
        return match.toUpperCase();
    });
}

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
			var doseElement = jQuery("#dose").val();
			
			if(doseElement == "")
			{
				error = error + " <spring:message code='medication.regimen.missingDoseError' /> ";

			}
			else if(doseElement == 0 || doseElement > 5000)
			{
				error = error + " <spring:message code='medication.regimen.doseLimitError' /> ";
				
			}
			else
			{
				var doseUnitSelectElement =  document.getElementById('doseUnit');
				if(doseUnitSelectElement.selectedIndex == 0)
				{
					error = error + "<br><spring:message code='medication.regimen.doseUnitError' /> ";
				}
			}
			
            var durationElement = jQuery("#duration").val();
			
			if(durationElement == "")
			{
				error = error + " <spring:message code='medication.regimen.missingDurationError' /> ";

			}
			else if(durationElement == 0 || durationElement > 99)
			{
				error = error + " <spring:message code='medication.regimen.durationLimitError' /> ";
				
			}
			else
			{
				var durationUnitSelectElement =  document.getElementById('durationUnit');
				if(durationUnitSelectElement.selectedIndex == 0)
				{
					error = error + "<br><spring:message code='medication.regimen.durationUnitError' /> ";
				}
			}
			
			var frequencySelectElement =  document.getElementById('frequency');
			if(frequencySelectElement.selectedIndex == 0)
			{
				error = error + "<br><spring:message code='medication.regimen.frequencyError' /> ";
			}
			
			var routeSelectElement =  document.getElementById('route');
			if(routeSelectElement.selectedIndex == 0)
			{
				error = error + "<br><spring:message code='medication.regimen.routeError' /> ";
			}
			
			var startDate = jQuery("#startDateDrug").val();
			
			if(startDate == "")
			{
				error = error + "<br><spring:message code='medication.regimen.startDateError' /> ";
			}
			
		}
		
		if(error != "")
		{
			alertify.set('notifier','position', 'top-center');
			alertify.error(error);
		}
		else
		{
			confirmMessage = "<spring:message code='medication.regimen.confirmMessage'/>";
			alertify.confirm('Create drug order!', confirmMessage , function(){ jQuery('#addIndividualDrug').submit(); }, function(){ alertify.notify('You probably want to review order') });
			/* jQuery('#addIndividualDrug').submit(); */
		}
	}
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
<!-- <openmrs:hasPrivilege privilege=""> -->
<div id="addMedicationLink">
<button id="addMedicationButton">
	<span><openmrs:message code="medication.regimen.addMedication"/></span>
	<span class='addMedicationImage'><img class="manImg" src="/openmrs/moduleResources/medicationlog/img/add.gif"></img></span>
</button>
<%-- <input type="button" id="addMedicationButton" value="<openmrs:message code="medication.regimen.addMedication"/>"> --%>
</div>
<!-- </openmrs:hasPrivilege> -->

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
		<div id="openmrs_error" class="openmrs_error"></div>
	</div>
	<br />
	
	<div class="box">
	
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
						<spring:message code="medication.orderset.field.startDay" /><span class="required">*</span>:  <openmrs_tag:dateField formFieldName="startDateSet" startValue=""/>
					</td>
				</tr>
			</table>
		</form>
		
		<div id="individualDrugDiv">
		<form id="addIndividualDrug" name="addIndividualDrug" method="post" action="${pageContext.request.contextPath}/module/medicationlog/order/addDrugOrder.form">
			<input type="hidden" name="patientId" value="${model.patient.patientId}">
			<input type="hidden" name="returnPagee" value="/patientDashboard.form?patientId=${model.patient.patientId}"/>	
			<input type="hidden" name="currentUser" value="${model.authenticatedUser}"/>
			<input type="hidden" name="drugId" id="drugId" value=""/>
			<input type="hidden" name="drugSelection" id="drugSelection" value=""/>
			<table>
				<tr class="drugDetails">
					<th class="padding"><spring:message code="medication.regimen.drugSelectionHeading" />:</th>
				</tr>
				<tr>
				<td class="padding"><spring:message code="medication.regimen.drugSelection" />: <input type="radio" id="drugSets" name="selection" value="<spring:message code="medication.regimen.drugSetsOption" />" ><spring:message code="medication.regimen.drugSetsOption" />  <input type="radio"  id="drugs" name="selection" value="<spring:message code="medication.regimen.drugsOption" />" ><spring:message code="medication.regimen.drugsOption" />
					</td>
				<td class="padding"><label id="encounterLabel"><spring:message code="medication.regimen.encounterSelection" /></label>:
				<select class="capitalize" name="patientEncounter" id="patientEncounter">
						<option class="capitalize" value="">Select encounter</option>
						<c:if test="${not empty model.encounters}">
							<c:forEach var="encounter" items="${model.encounters}">
								<option class="capitalize" value="${encounter.encounterId}">${fn:toLowerCase(encounter.encounterName)}</option>
							</c:forEach>
							</c:if>
						</select>
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
					<input id="drugSuggestBox" name="drugName" class="capitalize" list="drugOptions" placeholder="Search Drug..." />
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
					<td class="padding"><spring:message code="DrugOrder.dose" /><span class="required">*</span>: <input type="number" name="dose" id="dose" size="2" min="1" max="5000"/> <select class="capitalize" name="doseUnit" id="doseUnit">
						<option class="capitalize" value="">Select option</option>
						<c:if test="${not empty model.doseUnits}">
							<c:forEach var="doseUnit" items="${model.doseUnits}">
								<option class="capitalize"  value="${doseUnit.conceptId}">${fn:toLowerCase(doseUnit.name)}</option>
							</c:forEach>
							</c:if>
						</select>
					</td>
					
					<td class="padding"><spring:message code="DrugOrder.frequency"/><span class="required">*</span>:			
						<select class="capitalize" name="frequency" id="frequency">
							<option class="capitalize" value="">Select option</option>
							<c:if test="${not empty model.frequencies}">
							
							<c:forEach var="frequency" items="${model.frequencies}">
								<option class="capitalize" value="${frequency.conceptId}">${fn:toLowerCase(frequency.name)}</option>
							</c:forEach>
							</c:if>
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
						<c:if test="${not empty model.routes}">
							<c:forEach var="route" items="${model.routes}">
								<option class="capitalize" value="${route.conceptId}">${fn:toLowerCase(route.name)}</option>
							</c:forEach>
							</c:if>
						</select>
					</td>
					
					<!--	maps on order.instructions  -->
					<td class="padding"><spring:message code="medication.regimen.dosingInstructions"/>: <textarea rows="2" cols="30" name="dosingInstructions" id="dosingInstructions" maxlength="250"></textarea></td>				
					
				</tr>
				
				<tr class="drugDetails">	
					<td class="padding"><spring:message code="medication.orderset.field.startDay" /><span class="required">*</span>:  <openmrs_tag:dateField formFieldName="startDateDrug" startValue=""/></td>
					<td class="padding"><spring:message code="medication.regimen.duration"/><span class="required">*</span>: <input type="number" name="duration" id="duration" size="2" min="1" max="99"/> 
					<select class="capitalize" name="durationUnit" id="durationUnit">
							<option value="">Select option</option>
							<c:if test="${not empty model.durationUnits}">
							<c:forEach var="duration" items="${model.durationUnits}">
								<option class="capitalize"  value="${duration.conceptId}">${fn:toLowerCase(duration.name)}</option>
							</c:forEach>
							</c:if>
					</select> 
					<input type="checkbox" name="asNeeded" id="asNeeded" value="asNeeded"><spring:message code='medication.orderset.drugOrderSetMember.asNeeded'/>
					</td>	
				</tr>
			
				<tr	class="drugDetails">
					<td class="padding"><spring:message code="medication.regimen.reasonForOrder" />: <select class="capitalize" name="orderReason" id="orderReason">
							<option class="capitalize" value="">Select option</option>
							<c:if test="${not empty model.orderReasons}">
							<c:forEach items="${model.orderReasons}" var="orderReason">
								<option class="capitalize" value="${orderReason.conceptId}">${fn:toLowerCase(orderReason.displayString)}</option>
							</c:forEach>
							</c:if>
						</select>
					</td>
					
					<td class="padding"><spring:message code="medication.regimen.additionalReason" />: <textarea rows="2" cols="30" name="orderReasonNonCoded" id="orderReasonNonCoded" maxlength="250"></textarea>
					</td>
				</tr>
				
				<tr class="drugDetails">
					<!-- 				maps on drug_order.dosing_instructions  -->
					
					<td class="padding"><spring:message code="medication.regimen.administrationInstructions" />: 
					</td>
					<td><textarea rows="2" cols="30" name="adminInstructions" id="adminInstructions" maxlength="250"></textarea></td>
					
				</tr>
			</table> 
		</form>
		</div>
	</div>
</div>
</div>
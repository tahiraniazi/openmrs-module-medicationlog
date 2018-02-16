<%@ include file="/WEB-INF/template/include.jsp"%>

<openmrs:htmlInclude file="/moduleResources/medicationlog/medication.css" />

<script type="text/javascript">

jQuery(document).ready(function() {
	

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
		height: 480,
		width: '100%',
		zIndex: 100,
		buttons: { '<spring:message code="general.add"/>': function() { handleAddMedication(); },
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
		
		fetchDrugs();
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
	<form id="addOrderSet" name="addMedication" method="post" action="${pageContext.request.contextPath}/module/orderextension/addOrderSet.form">
			
			<table>
				<tr>
					<td class="padding">
					<div id="orderSetLabel"><spring:message code="medication.orderset.field.selectOrderSet" />*:</div>
					</td>
						<td>
						<select name="orderSet" id="orderSet" data-placeholder="<spring:message code="medication.orderset.field.chooseOption" />" style="width:450px;">
							<option value="" selected="selected"></option>
							
 							<%-- <c:forEach items="${model.orderSets}" var="orderSet"> 
 								<option value="${orderSet.id}"> 
 									${orderSet.name}</option> 
 							</c:forEach> --%> 

						</select>
					</td class="padding">
					<td class="padding">
						<spring:message code="medication.orderset.field.relativeStartDay" />*:  <openmrs_tag:dateField formFieldName="startDateSet" startValue=""/>
					</td>
				</tr>
			</table>
		</form>
		
		<form id="addIndividualDrug" name="addIndividualDrug" method="post" action="${pageContext.request.contextPath}/module/orderextension/addDrugOrder.form">
			<input type="hidden" name="patientId" value="${model.patient.patientId}">
			<input type="hidden" name="returnPage" value="${model.redirect}&patientId=${model.patient.patientId}"/>	
			<table>
				<tr>
					<td class="padding"><spring:message code="medication.regimen.individualDrug" />*: </td>
					<td>	<select name="drugCombo" id="drugCombo" data-placeholder="<spring:message code="orderextension.regimen.chooseOption" />" style="width:350px;" onChange="fetchDrugs()">
							<option value="" selected="selected"></option>
							
							<c:forEach items="${model.drugs}" var="drug">
								<option value="${drug.conceptId}">${drug.name}</option>
							</c:forEach>
						</select>
					</td>
					<td id="drugName" class="padding"></td>
					<td id="routeInfo" class="padding"></td>
				</tr>
			</table>
			<table>
				<tr class="drugDetails">
					<th class="padding"><spring:message code="medication.regimen.patientPrescription" />:</th>
				</tr>
				<tr class="drugDetails">
					<td class="padding"><spring:message code="DrugOrder.dose" />*:  <input type="text" name="dose" id="dose" size="10"/><span id="units"></span></td>
					
					<td class="padding"><spring:message code="DrugOrder.frequency"/>:			
						<select name="frequencyDay" id="frequencyDay">
						<option value="" selected="selected"></option>
							<c:forEach items="${model.frequencies}" var="drug">
								<option value="${frequencies.conceptId}">${frequencies.name}</option>
							</c:forEach>
<%-- 							<% for ( int i = 1; i <= 10; i++ ) { %> --%>
<%-- 								<option value="<%= i %>/<spring:message code="DrugOrder.frequency.day" />"><%= i %>/<spring:message code="DrugOrder.frequency.day" /></option> --%>
<%-- 							<% } %> --%>
<%-- 							<option value="<spring:message code="orderextension.regimen.onceOnlyDose" />"><spring:message code="orderextension.regimen.onceOnlyDose" /></option> --%>
						</select>
						<span> - </span>
						<select name="frequencyWeek" id="frequencyWeek">
							<openmrs:globalProperty var="drugFrequencies" key="dashboard.regimen.displayFrequencies" listSeparator="," />
							<c:if test="${empty drugFrequencies}">
								<option disabled>&nbsp; <spring:message code="DrugOrder.add.error.missingFrequency.interactions" arguments="dashboard.regimen.displayFrequencies"/></option>
							</c:if>
							<c:if test="${not empty drugFrequencies}">
								<option value=""></option>
								<c:forEach var="drugFrequency" items="${drugFrequencies}">
									<option value="${drugFrequency}">${drugFrequency}</option>
								</c:forEach>
							</c:if>											
						</select>
					</td>
					<td class="padding"><input type="checkbox" name="asNeeded" id="asNeeded" value="asNeeded"><spring:message code='medication.orderset.DrugOrderSetMember.asNeeded'/></td>
				</tr>
				
				</table>
				<table>
				<tr class="drugDetails">
					<td class="padding"><spring:message code="medication.regimen.route" />: <select name="route" id="route">
						<option value="" selected="selected"></option>
							<c:forEach items="${model.routes}" var="drug">
								<option value="${routes.conceptId}">${routes.name}</option>
							</c:forEach>
						</select>
					</td>
					
					<td class="padding"><spring:message code="medication.regimen.duration"/>: <input type="text" name="duration" id="duration" size="10"/> 
					<select name="durationUnits" id="durationUnits">
						<option value="" selected="selected"></option>
							<c:forEach items="${model.durationUnits}" var="drug">
								<option value="${durationUnits.conceptId}">${durationUnits.name}</option>
							</c:forEach>
					</select>  
					
					</td>
					<!--	maps on order.instructions  -->
					<td class="padding"><spring:message code="medication.regimen.dosingInstructions"/>: <textarea rows="2" cols="40" name="dosingInstructions" id="dosingInstructions"></textarea>
					</td>
					
				</tr>
				
			</table>
			<table>
				<tr class="drugDetails">	
					<td class="padding"><spring:message code="medication.orderset.field.relativeStartDay" />*:  <openmrs_tag:dateField formFieldName="startDateDrug" startValue=""/></td>
					<td class="padding"><spring:message code="medication.regimen.stopDate" />:  <openmrs_tag:dateField formFieldName="stopDateDrug" startValue=""/></td>	
				</tr>
			</table>
		    
		    
		    <table>
				<tr	class="drugDetails">
					<td class="padding"><spring:message code="medication.regimen.reasonForOrder" />: <select name="orderReasons" id="orderReasonCombo">
							<option value="" selected="selected"></option>
							<c:forEach items="${model.orderReasons}" var="orderReason">
								<option value="${orderReasons.conceptId}">${orderReasons.displayString}</option>
							</c:forEach>
						</select>
					</td>
					
					<td class="padding"><spring:message code="medication.regimen.additionalReason" />: <textarea rows="2" cols="40" name="additionalReason" id="additionalReason"></textarea>
					</td>
					
				</tr>
			</table>
			
			<table>	
				<tr class="drugDetails">
					<!-- 				maps on drug_order.dosing_instructions  -->
					
					<td class="padding"><spring:message code="medication.regimen.administrationInstructions" />: <textarea rows="2" cols="40" name="adminInstructions" id="adminInstructions"></textarea></td>
				</tr>							
			</table> 
		</form>
		
	</div>
	
</div>


</div>
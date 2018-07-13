<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="/WEB-INF/view/module/medicationlog/include/localHeader.jsp"%>

<openmrs:htmlInclude file="/scripts/jquery/dataTables/css/dataTables_jui.css"/>
<openmrs:htmlInclude file="/scripts/jquery/dataTables/js/jquery.dataTables.min.js"/>
<script type="text/javascript">

</script>	

<div id="individual_drug_form">
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
				</tr>
				<tr>
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
				</tr>
				<tr>
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
					</tr>
					<tr>
					
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
					
					</tr>
					
					<tr>
					<!--	maps on order.instructions  -->
					<td class="padding"><spring:message code="medication.regimen.dosingInstructions"/>: <textarea rows="2" cols="30" name="dosingInstructions" id="dosingInstructions" maxlength="250"></textarea></td>				
					
				</tr>
				
				<tr class="drugDetails">	
					<td class="padding"><spring:message code="medication.orderset.field.startDay" /><span class="required">*</span>:  <openmrs_tag:dateField formFieldName="startDateDrug" startValue=""/></td>
					</tr>
					<tr>
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
					
					</tr>
					
					<tr>
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
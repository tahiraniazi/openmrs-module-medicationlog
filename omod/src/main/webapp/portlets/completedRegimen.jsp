<%@ include file="/WEB-INF/template/include.jsp"%>

<openmrs:htmlInclude
	file="/scripts/jquery/dataTables/css/dataTables.css" />
<openmrs:htmlInclude
	file="/scripts/jquery/dataTables/js/jquery.dataTables.min.js" />

<openmrs:htmlInclude file="/moduleResources/medicationlog/css/medication.css" />

<link rel="stylesheet"
	href="/openmrs/moduleResources/medicationlog/css/alertify.min.css" />
<link rel="stylesheet"
	href="/openmrs/moduleResources/medicationlog/themes/default.min.css"
	id="toggleCSS" />
<script src="/openmrs/moduleResources/medicationlog/alertify.min.js"></script>

<!-- SPECIALIZED STYLES FOR THIS PORTLET -->
<style type="text/css">

    #completedOrders {
    	width: 900px; 
    	/* table-layout:fixed !important; */
    }
    
    #completedOrders_info {
    	width: 64%;
    }

	#completedOrders td {
		padding-left:2px !important; 
		padding-right:4px !important; 
		padding-top:4px !important; 
		padding-bottom:4px !important; 
		vertical-align:top !important; 
	}
</style>

<script type="text/javascript" th:inline="javascript">

	function viewInstructions(obj){
		
		var theId = obj.id;
		var idArray = theId.split("_");
		var elementId = "viewInstructions_"+idArray[1];
		
		var mainPath = window.location.protocol + "//" + window.location.host;
		var moreImagePath = mainPath + "/openmrs/moduleResources/medicationlog/img/info_light_green_small.png";
		var lessImagePath = mainPath + "/openmrs/moduleResources/medicationlog/img/info_blue_small.png";
		
		if (document.getElementById(elementId).src == lessImagePath) 
        {
			document.getElementById("viewInstructions_"+idArray[1]).src = moreImagePath;
			jQuery("#completed_instructions_row_"+idArray[1]).hide();
        }
		else if (document.getElementById(elementId).src == moreImagePath)
		{
			document.getElementById("viewInstructions_"+idArray[1]).src = lessImagePath;
			jQuery("#completed_instructions_row_"+idArray[1]).show();
		}
		
	}
	
	function viewCompletedOrder(obj) {
		
		var patientId = ${model.patient.patientId};
		var val = obj.id;
		var values = val.split("_");
		var drugOrderId = values[2];
		
		var url = "${pageContext.request.contextPath}/module/medicationlog/ajax/getDrugOrder.form?drugOrderId=" + drugOrderId + "&patientId=" + patientId; 
		jQuery.getJSON(url, function(result) {
			console.log(result.dose);
			jQuery("#completedDrugName").text(result.drugName);
			
			var completedMedicineId = result.orderId;
			jQuery("#completedMedicineId").text(completedMedicineId);
			
			var completeDose = result.dose + " " + result.doseUnit;
			jQuery("#completedMedicineDose").text(completeDose);
			
			jQuery("#completedMedicineFrequency").text(result.frequency);
			jQuery("#completedMedicineRoute").text(result.route);
			
			var completeDuration = result.duration + " " + result.durationUnit;
			jQuery("#completedMedicineDuration").text(completeDuration);
			
			if(result.instructions == null || result.instructions == "") {
				jQuery("#completedMedicineInstructionsLabel").hide();
				jQuery("#completedMedicineInstructions").hide();
			}
			else {
				jQuery("#completedMedicineInstructionsLabel").show();
				jQuery("#completedMedicineInstructions").show();
				jQuery("#completedMedicineInstructions").text(result.instructions);
			}
			
			
			var dateStarted = result.dateActivated;
			var startDate = new Date(dateStarted);
			
			var dd = startDate.getDate();
			var mm = startDate.getMonth()+1; //January is 0!
			var yyyy = startDate.getFullYear();
			
			if(dd<10){
			    dd='0'+dd;
			} 
			if(mm<10){
			    mm='0'+mm;
			} 

			var formattedStartDate = dd+'/'+mm+'/'+yyyy;
			jQuery("#completedMedicineStartDate").text(formattedStartDate);
			
			if(result.asNeeded != null && result.asNeeded == true) {
				jQuery("#completedPrnMedicine").show();
			}
			else if(result.asNeeded != null && result.asNeeded == false) {
				jQuery("#completedPrnMedicine").hide();
			}
		});
		
		jQuery('#viewCompletedOrderDialog').dialog('open');
	}
	
	function refreshViewDialog() {
		
		jQuery('#completedDrugName').html("");
		jQuery('#completedMedicineDose').html("");
		jQuery('#completedMedicineFrequency').html("");
		jQuery('#completedMedicineRoute').html("");
		jQuery('#completedMedicineDuration').html("");
		jQuery('#completedMedicineStartDate').html("");
		jQuery('#completedMedicineInstructions').html("");
	}

	jQuery(document).ready(function() {
		
		jQuery('#completedOrders').dataTable({
			"bPaginate": true,
	        "iDisplayLength": 10,
	        "bLengthChange": false,
	        "bFilter": false,
	        "bInfo": true,
	        "bAutoWidth": true
	        
		});
		
		
		jQuery('#viewCompletedOrderDialog').dialog({
			position: 'middle',
			autoOpen: false,
			modal: true,
			title: '<spring:message code="medication.drugOrder.details" javaScriptEscape="true"/>',
			height: 450,
			width: '50%',
			zIndex: 100,
			buttons: { 'OK!': function() { refreshViewDialog(); $j(this).dialog("close");  }
			}
		});
	});
	
</script>

<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.completed" /></div>
<div class="box${model.patientVariation}">
	
	
	<c:choose>
		<c:when test="${! empty model.completedDrugOrders}">
			<table id="completedOrders">
				<thead>
				
				<tr>
					<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.view"/></td>
					<th class="tableCell" style="font-weight:bold"><nobr><spring:message code="medication.regimen.drugLabel"/></nobr></td>
					<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.doseAndUnit"/></td>
					<th class="tableCell" style="font-weight:bold"><spring:message code="medication.regimen.route"/></td>
					<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.frequency"/></td>
					<th class="tableCell" style="font-weight:bold"><spring:message code="medication.orderset.field.startDay"/></td>
					<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.stopDate"/></td>
					<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.reNew"/></td>
				</tr>
				
				</thead>
				
				
				<tbody>
					<c:set var="i" value="0"/>
						<c:forEach var="completedOrder" items="${model.completedDrugOrders}">
						<c:if test="${! empty model.completedDrugOrders}">
							<tr 
							<c:if test="${i % 2 == 0 }">class="medicationEvenRow"</c:if>
							<c:if test="${i % 2 != 0 }">class="medicationOddRow"</c:if>>
							<td class="tableCell"><nobr><img title="View Order" id='viewOrder_${i}_${completedOrder.orderId}_${completedOrder.dateActivated}' onclick="viewCompletedOrder(this)" src="/openmrs/moduleResources/medicationlog/img/view_text_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
							<td class="tableCell" style="text-transform: capitalize;"><nobr>${completedOrder.drugName}</nobr><span><img 
							title="<c:choose>
								<c:when test="${! empty completedOrder.instructions}">
			    					${completedOrder.instructions}
			    				</c:when>
			    				<c:when test="${empty completedOrder.instructions}">
			    					<spring:message code="medication.drugOrder.noInstructions" />
			    				</c:when>
			    			</c:choose>" id='viewInstructions_${i}' onclick="viewInstructions(this)" src="/openmrs/moduleResources/medicationlog/img/info_light_green_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></span></td>
							<td class="tableCell"><nobr>${completedOrder.dose} ${currentOrder.doseUnit}</nobr></td>
							<td class="tableCell"><nobr>${completedOrder.route}</nobr></td>
							<td class="tableCell"><nobr>${completedOrder.frequency}</nobr></td>
							<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${completedOrder.dateActivated}" format="${_dateFormatDisplay}"/></nobr></td>
							<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${completedOrder.scheduledStopDate}" format="${_dateFormatDisplay}"/></nobr></td>
							<td class="tableCell"><nobr><img title="Renew Order" id='renewOrder_${i}_' onclick="renewOrder(this)" src="/openmrs/moduleResources/medicationlog/img/renew_very_small.png" alt="renew" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td> 
							</tr>
							<!-- <tr id="completed_instructions_row_${i}" style="display:none;">
							<td id='completed_instructions_${i}' colspan="8" style="text-align: left;"><label style="style="font-weight:bold""><u>Instructions:</u></label>
							<c:choose>
								<c:when test="${! empty completedOrder.instructions}">
			    					${completedOrder.instructions}
			    				</c:when>
			    				<c:when test="${empty completedOrder.instructions}">
			    					<font color="#808080"><i><spring:message code="medication.drugOrder.noInstructions" /></i></font>
			    				</c:when>
			    			</c:choose></td>
							<td style="display:none"></td>
							<td style="display:none"></td>
							<td style="display:none"></td>
							<td style="display:none"></td>
							<td style="display:none"></td>
							<td style="display:none"></td>
							<td style="display:none"></td>
							</tr>  -->
				
						<c:set var="i" value="${i+1}"/>
						</c:if>
					</c:forEach>
				</tbody>
			</table>
		</c:when>
		<c:when test="${empty model.completedDrugOrders}">
				<font color="#808080"><i><spring:message code="medication.drugOrder.noRecords" /></i></font>
		</c:when>
	</c:choose>
	
</div>

<div id="viewCompletedOrderDialog">
	<div class="box">
	<u><h2><span style="margin: 0px 0px 1em 1em;" class="capitalize" id="completedDrugName"></span><img title="As needed medicine" id="completedPrnMedicine" src="/openmrs/moduleResources/medicationlog/img/prn_very_small.png" alt="prn" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></h2></u>
	<table id="drugOrderDetails" style="margin: 0px 0px 1em 1.5em;">
	
	<tr>
		<td><span style="font-weight:bold">Id:</span></td>
		<td><span id="completedMedicineId"></span></td>
	</tr>
	
	<tr>
		<td><span style="font-weight:bold">Dose:</span></td>
		<td><span id="completedMedicineDose"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Frequency:</span></td>
		<td><span id="completedMedicineFrequency"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Route:</span></td>
		<td><span id="completedMedicineRoute"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Start Date:</span></td>
		<td><span id="completedMedicineStartDate"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Duration:</span></td>
		<td><span id="completedMedicineDuration"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold" id="completedMedicineInstructionsLabel">Instructions:</span></td>
		<td><span id="completedMedicineInstructions"></span></td>
	</tr>
	
	</table>
	</div>
</div>
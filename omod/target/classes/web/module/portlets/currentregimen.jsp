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

	#currentOrders {
		 width: 900px; 
		/* table-layout:fixed !important; */
	}
	
	#currentOrders_info {
		width: 64%;
	}

	#currentOrders td {
		padding-left:2px !important; 
		padding-right:4px !important; 
		padding-top:4px !important; 
		padding-bottom:4px !important; 
		vertical-align:top !important; 
	}
	
	#drugOrderDetails td {
		
		font-size: 14px;
		
		padding-left:2px !important; 
		padding-right:4px !important; 
		padding-top:4px !important; 
		padding-bottom:4px !important; 
		vertical-align:top !important; 
	}
	
	
</style>

<script type="text/javascript">


	jQuery(document).ready(function() {
		
		jQuery('#currentOrders').dataTable({
			"bPaginate": true,
	        "iDisplayLength": 10,
	        "bLengthChange": false,
	        "bFilter": false,
	        "bInfo": true,
	        "bAutoWidth": true
	        
		});
		
		jQuery('.stopButton').click(function(){
			
			var val = this.id;
			var values = val.split("_");
			
			jQuery('#stopDrugDialog').dialog('open');
			alert(values[2]);
			alert(values[3]);
			jQuery("#stopOrderId").val(values[2]);
			jQuery("#startDate").val(values[3]);
			
			jQuery('.openmrs_error').hide();
			
		});
		
		jQuery('#viewOrderDialog').dialog({
			position: 'middle',
			autoOpen: false,
			modal: true,
			title: '<spring:message code="medication.drugOrder.details" javaScriptEscape="true"/>',
			height: 450,
			width: '50%',
			zIndex: 100,
			buttons: { 'OK!': function() { refresh(); $j(this).dialog("close"); }
			}
		});
		
		jQuery('#stopDrugDialog').dialog({
			position: 'middle',
			autoOpen: false,
			modal: true,
			title: '<spring:message code="medication.drugOrder.stopOrder" javaScriptEscape="true"/>',
			height: 400,
			width: '70%',
			zIndex: 100,
			buttons: { '<spring:message code="medication.currentRegimen.stop"/>': function() { stopOrder(); },
				'<spring:message code="general.cancel"/>': function() { refresh(); $j(this).dialog("close"); }
			}
		}); 
		
	});
	
	function stopOrder()
	{	
		var error = '';
		
		var selectedIndex = jQuery("#orderStopReason").attr("selectedIndex");
		if(selectedIndex == 0)
		{
			error = " <spring:message code='orderextension.regimen.stopReasonError' /> ";
		}
		else
		{
			var stopDate = jQuery("#drugStopDate").val();

			if(stopDate == "")
			{
				error = error + " <spring:message code='orderextension.regimen.stopDateError' /> ";
			}
			else {
				var datePattern = '<openmrs:datePattern />';
				
				var startYears = datePattern.indexOf("yyyy");
				
				var startMonths =  datePattern.indexOf("mm");
				
				var startDays = datePattern.indexOf("dd");
				
				var convertDateStop = stopDate.substring(startYears, startYears + 4) + "/" + stopDate.substring(startMonths, startMonths + 2) + "/" + stopDate.substring(startDays, startDays + 2);
				var dateStop = new Date(convertDateStop);
				
				
				var startDate = jQuery("#drugStartDate").val();
				var convertDateStart = startDate.substring(startYears, startYears + 4) + "/" + startDate.substring(startMonths, startMonths + 2) + "/" + startDate.substring(startDays, startDays + 2);
				var dateStart = new Date(convertDateStart);
				
				
				if(dateStop < dateStart)
				{
					error = error + " <spring:message code='orderextension.regimen.stopDateLessStartError' /> ";
				}
			}
		}
		
		if(error != "")
		{
			alert("probably some errors occured");
			jQuery('.openmrs_error').show();
			jQuery('.openmrs_error').html(error);
		}
		else
		{
			
			alert("submitting Stop Drug form");
			jQuery('#stopDrug').submit();
		}
	}
	
	 function viewCurrentOrder(obj) {
		
		var patientId = ${model.patient.patientId};
		var val = obj.id;
		var values = val.split("_");
		var drugOrderId = values[2];
		
		var url = "${pageContext.request.contextPath}/module/medicationlog/ajax/getDrugOrder.form?drugOrderId=" + drugOrderId + "&patientId=" + patientId; 
		jQuery.getJSON(url, function(result) {
			
			console.log(result.dose);
			jQuery("#drugName").text(result.drugName);
			
			var completeDose = result.dose + " " + result.doseUnit;
			jQuery("#medicineDose").text(completeDose);
			
			jQuery("#medicineFrequency").text(result.frequency);
			jQuery("#medicineRoute").text(result.route);
			
			var completeDuration = result.duration + " " + result.durationUnit;
			jQuery("#medicineDuration").text(completeDuration);
			
			jQuery("#medicineInstructions").text(result.instructions);
			
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
			jQuery("#medicineStartDate").text(formattedStartDate);
			
			if(result.asNeeded != null && result.asNeeded == true) {
				jQuery("#prnMedicine").show();
			}
			else if(result.asNeeded != null && result.asNeeded == false) {
				jQuery("#prnMedicine").hide();
			}
		});
		
		jQuery('#viewOrderDialog').dialog('open');
	}
	
	
	function refresh() {
		
		jQuery('#drugName').html("");
		jQuery('#medicineDose').html("");
		jQuery('#medicineFrequency').html("");
		jQuery('#medicineRoute').html("");
		jQuery('#medicineDuration').html("");
		jQuery('#startDateDrug').html("");
		jQuery('#medicineInstructions').html("");
	}
	
</script>

<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.current" /></div>
<div class="box${model.patientVariation}">
	
	<c:choose>
		<c:when test="${! empty model.currentDrugOrders}">
		
		<table id="currentOrders">
		<thead>
		<tr>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.view"/></th>
			<th class="tableCell" style="font-weight:bold"><nobr><spring:message code="medication.regimen.drugLabel"/></nobr></th>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.doseAndUnit"/></th>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.regimen.route"/></th>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.frequency"/></th>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.orderset.field.startDay"/></th>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.scheduledStopDate"/></th>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.delete"/></th>
			<th class="tableCell" style="font-weight:bold"><spring:message code="medication.drugOrder.stop"/></th>
		</tr>
		
		</thead>
		
		<tbody>
		<c:set var="i" value="0"/>
			<c:forEach var="currentOrder" items="${model.currentDrugOrders}">
			<c:if test="${! empty model.currentDrugOrders}">
				<tr 
				<c:if test="${i % 2 == 0 }">class="medicationEvenRow"</c:if>
				<c:if test="${i % 2 != 0 }">class="medicationOddRow"</c:if>>
				<td class="tableCell"><nobr><img title="View Order" id='viewCurrentOrder_${i}_${currentOrder.orderId}_${currentOrder.dateActivated}' onclick="viewCurrentOrder(this)" src="/openmrs/moduleResources/medicationlog/img/view_text_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				<td class="tableCell" style="text-transform: capitalize;"><nobr>${currentOrder.drugName}</nobr><span><img 
				title="<c:choose>
					<c:when test="${! empty completedOrder.instructions}">
    					${completedOrder.instructions}
    				</c:when>
    				<c:when test="${empty completedOrder.instructions}">
    					<spring:message code="medication.drugOrder.noInstructions" />
    				</c:when>
    			</c:choose>" id='viewMore_${i}'  src="/openmrs/moduleResources/medicationlog/img/info_light_green_small.png" alt="more" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></span></td>
				<td class="tableCell"><nobr>${currentOrder.dose} ${currentOrder.doseUnit}</nobr></td>
				<td class="tableCell"><nobr>${currentOrder.route}</nobr></td>
				<td class="tableCell"><nobr>${currentOrder.frequency}</nobr></td>
				<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${currentOrder.dateActivated}" format="${_dateFormatDisplay}"/></nobr></td>
				<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${currentOrder.scheduledStopDate}" format="${_dateFormatDisplay}"/></nobr></td>
				<td class="tableCell"><nobr><img title="Delete" id='deleteOrder_${i}_' onclick="deleteOrder(this)" src="/openmrs/moduleResources/medicationlog/img/delete_very_small.png" alt="delete" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>  
				<td class="tableCell"><nobr><img title="Stop" class="stopButton" id='stopOrder_${i}_${currentOrder.orderId}_${currentOrder.dateActivated}' src="/openmrs/moduleResources/medicationlog/img/stop_very_small.png" alt="stop" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				</tr>
				
				<c:set var="i" value="${i+1}"/>
			</c:if>
		</c:forEach>
		</tbody>
	</table>
		
	</c:when>
	<c:when test="${empty model.currentDrugOrders}">
		<font color="#808080"><i><spring:message code="medication.drugOrder.noRecords" /></i></font>
	</c:when> 
	</c:choose>
		
</div>

<div id="viewOrderDialog">
	<div class="box">
	<u><h2><span style="margin: 0px 0px 1em 1em;" class="capitalize" id="drugName"></span><img title="As needed medicine" id="prnMedicine" src="/openmrs/moduleResources/medicationlog/img/prn_very_small.png" alt="prn" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></h2></u>
	<table id="drugOrderDetails" style="margin: 0px 0px 1em 1.5em;">
	<tr>
		<td><span style="font-weight:bold">Dose:</span></td>
		<td><span id="medicineDose"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Frequency:</span></td>
		<td><span id="medicineFrequency"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Route:</span></td>
		<td><span id="medicineRoute"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Start Date:</span></td>
		<td><span id="medicineStartDate"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Duration:</span></td>
		<td><span id="medicineDuration"></span></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Instructions:</span></td>
		<td><span id="medicineInstructions"></span></td>
	</tr>
	
	</table>
	</div>
</div>

<div id="stopDrugDialog">
	<div class="box">
	<div id="openmrs_error" class="openmrs_error"></div>
		<form id="stopDrug" name="stopDrug" method="post" action="${pageContext.request.contextPath}/module/medicationlog/order/stopDrugOrder.form">
			<input type="hidden" name="stopOrderId" id="stopOrderId">
			<input type="hidden" name="drugStartDate" id="drugStartDate">
			<input type="hidden" name="returnPage" value="/patientDashboard.form?patientId=${model.patient.patientId}"/>	
			<table>
				<tr>
					<td class="padding"><spring:message code="medication.regimen.stopDate"/>: <openmrs_tag:dateField formFieldName="drugStopDate" startValue=""/></td>
					<td class="padding"><spring:message code="medication.drugOrder.stopReason"/>:
					<select class="capitalize" name="orderStopReason" id="orderStopReason">
							<option class="capitalize" value="">Select option</option>
							<c:if test="${not empty model.orderStoppedReasons}">
							<c:forEach items="${model.orderStoppedReasons}" var="orderStopReason">
								<option class="capitalize" value="${orderStopReason.conceptId}">${fn:toLowerCase(orderStopReason.displayString)}</option>
							</c:forEach>
							</c:if>
						</select>
					</td>
				</tr>
			</table>
		</form>
	</div>
</div> 

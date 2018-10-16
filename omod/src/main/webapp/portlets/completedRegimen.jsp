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
	
<link
	href="/openmrs/moduleResources/medicationlog/css/font-awesome.min.css"
	rel="stylesheet" />
<link
	href="/openmrs/moduleResources/medicationlog/css/bootstrap.min.css"
	rel="stylesheet" />
	
<script src="/openmrs/moduleResources/medicationlog/alertify.min.js"></script>
<script
	src="/openmrs/moduleResources/medicationlog/js/jquery-3.3.1.min.js"></script>
<script
	src="/openmrs/moduleResources/medicationlog/js/bootstrap.min.js"></script>
<script
	src="/openmrs/moduleResources/medicationlog/js/jquery-ui.min.js"></script>
<script
	src="/openmrs/moduleResources/medicationlog/js/jquery.dataTables.min.js"></script>
<script
	src="/openmrs/moduleResources/medicationlog/js/dataTables.bootstrap4.min.js"></script>

<!-- SPECIALIZED STYLES FOR THIS PORTLET -->
<style type="text/css">

	body {
		font-size: 12px;
	}

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
	
function viewCompletedOrder(obj) {
		
		var patientId = ${model.patient.patientId};
		var val = obj.id;
		var values = val.split("_");
		var drugOrderId = values[2];
		
		var url = "${pageContext.request.contextPath}/module/medicationlog/ajax/getDrugOrder.form?drugOrderId=" + drugOrderId + "&patientId=" + patientId; 
		jQuery.getJSON(url, function(result) {
			
			console.log(result);
			
			var details = "";
			
			if(result.hasOwnProperty('singleOrder') && result.hasOwnProperty('revisedOrder')) {
				details = details.concat('<table  class="table table-striped table-responsive-md btn-table table-hover mb-0" id="order_details">');
			    details = details.concat('<thead><tr>');
			    details = details.concat('<th><a>Order Id</a></th>');
			    details = details.concat('<th><a>Previous Order</a></th>');
			    details = details.concat('<th><a>Action</a></th>');
				
			    details = details.concat('<tbody><tr>'); 
			    details = details.concat('<td>'+ (JSON.parse(result.singleOrder)).orderId +'</td>');
			    details = details.concat('<td>'+ (JSON.parse(result.revisedOrder)).orderId +'</td>');
			    details = details.concat('<td>REVISE</td>');
			    details = details.concat('</tr></tbody>');
			    
			    details = details.concat('</tr></thead>');
			    details = details.concat('</table>');
			} 
			
			if(result.hasOwnProperty('singleOrder')){
				
				var singleOrder = JSON.parse(result.singleOrder);
				console.log(singleOrder);
				console.log(singleOrder.orderId);
				
			    details = details.concat('<fieldset  class="scheduler-border">');
			    details = details.concat('<legend  class="scheduler-border">Order details</legend>');
			    details = details.concat('<div id="sampleDetailContainer">');
			    /* details = details.concat('<table  class="table table-striped table-responsive-md btn-table table-hover mb-0" id="tb-test-type">');
			    details = details.concat('<thead><tr>');
			    details = details.concat('<th><a>Test Order</a></th>');
			    details = details.concat('<th><a>Specimen Type</a></th>');
			    details = details.concat('<th><a>Specimen Site</a></th>');
			    details = details.concat('<th><a>Status</a></th>');
				
			    details = details.concat('</tr></thead>');
			    details = details.concat('</table>'); */
			    
 				details = details.concat(' <form id="form">');
			    
			    details = details.concat('<div class="row"><div class="col-md-12">');
				details = details.concat('<strong><h6>Encounter related details</h6></strong>');
				details = details.concat('</div></div>');
				
			    details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub><spring:message code="medication.drugOrder.orderId" /></sub></font></label>');
				details = details.concat('</div><div class ="col-md-4">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.orderId+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Encounter Type</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.encounterType+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Order Reason</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+ ( typeof(singleOrder.orderReason) == 'undefined' ? "" : singleOrder.orderReason) +'</sub></font></label>');			 
				details = details.concat('</div></div>');

				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Date Created</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.dateCreated+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Orderer</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.orderer+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				
				details = details.concat('<div class="row"><div class="col-md-12">');
				details = details.concat('<strong><h6>Drug details</h6></strong>');
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Drug Name</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+ (singleOrder.drugName).toUpperCase()+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Date Activated</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.dateActivated+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>As needed</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.asNeeded+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Dose</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.dose+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Dose unit</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.doseUnit+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Frequency</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.frequency+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Route</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.route+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Duration</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.duration+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Duration Unit</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+singleOrder.durationUnit+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Instructions</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+  (typeof(singleOrder.instructions) == 'undefined' ? "" : singleOrder.instructions) +'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Scheduled Stop Date</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+ (typeof(singleOrder.autoExpireDate) == 'undefined' ? "" : singleOrder.autoExpireDate) +'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Discontinue Reason</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+ (typeof(singleOrder.discontinueReason) == 'undefined' ? "" : singleOrder.discontinueReason)    +'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
			    details = details.concat('</form>');
			    
				details = details.concat(' </div>');
				details = details.concat('</fieldset>');
			}
			
			if(result.hasOwnProperty('revisedOrder')){
				
				var revisedOrder = JSON.parse(result.revisedOrder);
				console.log(typeof(revisedOrder.orderReason) == 'undefined' ? " " : revisedOrder.orderReason);
			       
			    
			    details = details.concat('<fieldset  class="scheduler-border">');
			    details = details.concat('<legend  class="scheduler-border">Previous Order details</legend>');
			    details = details.concat('<div id="sampleDetailContainer">');
			    
			    details = details.concat(' <form id="form">');
			    
			    details = details.concat('<div class="row"><div class="col-md-12">');
				details = details.concat('<strong><h6>Encounter related details</h6></strong>');
				details = details.concat('</div></div>');
				
			    details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub><spring:message code="medication.drugOrder.orderId" /></sub></font></label>');
				details = details.concat('</div><div class ="col-md-4">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.orderId+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>EncounterType</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.encounterType+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Order Reason</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+ ( typeof(revisedOrder.orderReason) == 'undefined' ? "" : revisedOrder.orderReason) +'</sub></font></label>');			 
				details = details.concat('</div></div>');

				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Date Created</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.dateCreated+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Orderer</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.orderer+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-12">');
				details = details.concat('<strong><h6>Drug details</h6></strong>');
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Drug Name</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+ (revisedOrder.drugName).toUpperCase()+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Date Activated</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.dateActivated+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>As needed</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.asNeeded+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Dose</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.dose+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Dose Unit</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.doseUnit+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Frequency</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.frequency+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Route</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.route+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Duration</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.duration+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Duration Unit</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.durationUnit+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Instructions</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+  (typeof(revisedOrder.instructions) == 'undefined' ? "" : revisedOrder.instructions) +'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Date Stopped</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+revisedOrder.dateStopped+'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
				details = details.concat('<div class="row"><div class="col-md-4">');
				details = details.concat('<label ><font color="#17202A"><sub>Discontinue Reason</sub></font></label>');
				details = details.concat('</div><div class ="col-md-8">');
				details = details.concat('<label ><font color="#5D6D7E"><sub>'+ (typeof(revisedOrder.discontinueReason) == 'undefined' ? "" : revisedOrder.discontinueReason)    +'</sub></font></label>');			 
				details = details.concat('</div></div>');
				
			    details = details.concat('</form>');
				details = details.concat(' </div>');
				details = details.concat('</fieldset>');
				
				console.log("order details : "+ details);
				document.getElementById("orderDetails").innerHTML = details;
				
			}
			
			console.log("order details : "+ details);
			document.getElementById("orderDetails").innerHTML = details;
			
		});
		
		jQuery('#viewDrugModal').modal('show'); 
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
	        "iDisplayLength": 15,
	        "bLengthChange": false,
	        "bFilter": false,
	        "bInfo": true,
	        "bAutoWidth": true
	        
		});
		
		jQuery('.dataTables_length').addClass('bs-select');
		
		
	});
	
</script>

<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.completed" /></div>
<div class="box${model.patientVariation}">
	
	<c:choose>
		<c:when test="${! empty model.completedDrugOrders}">
			<table id="completedOrders" class="table table-striped table-bordered">
				<thead>
				
				<tr>
					<th><spring:message code="medication.drugOrder.orderId"/></th>
					<th style="font-weight:bold"><spring:message code="medication.drugOrder.view"/></th>
					<th ><spring:message code="medication.regimen.drugLabel"/> </th>
					<th ><spring:message code="medication.drugOrder.doseAndUnit"/></th>
					<th ><spring:message code="medication.regimen.route"/></th>
					<th ><spring:message code="medication.drugOrder.frequency"/></th>
					<th ><spring:message code="medication.orderset.field.startDay"/></th>
					<th ><spring:message code="medication.drugOrder.stopDate"/></th>
					<th ><spring:message code="medication.drugOrder.reNew"/></th>
				</tr>
				
				</thead>
				
				<tbody>
					<c:set var="i" value="0"/>
						<c:forEach var="completedOrder" items="${model.completedDrugOrders}">
						<c:if test="${! empty model.completedDrugOrders}">
							<tr>
							<td ><nobr>${completedOrder.orderId}</nobr></td>
							<td ><nobr><img title="View Order" id='viewCompletedOrder_${i}_${completedOrder.orderId}_${completedOrder.dateActivated}' onclick="viewCompletedOrder(this)" src="/openmrs/moduleResources/medicationlog/img/view_text_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
							<td style="text-transform: capitalize;"><nobr>${completedOrder.drugName}</nobr><span><img 
							title="<c:choose>
								<c:when test="${! empty completedOrder.instructions}">
			    					${completedOrder.instructions}
			    				</c:when>
			    				<c:when test="${empty completedOrder.instructions}">
			    					<spring:message code="medication.drugOrder.noInstructions" />
			    				</c:when>
			    			</c:choose>" id='viewInstructions_${i}' src="/openmrs/moduleResources/medicationlog/img/info_light_green_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></span></td>
							<td ><nobr>${completedOrder.dose} ${currentOrder.doseUnit}</nobr></td>
							<td ><nobr>${completedOrder.route}</nobr></td>
							<td ><nobr>${completedOrder.frequency}</nobr></td>
							<td style="text-align: center;"><nobr><openmrs:formatDate date="${completedOrder.dateActivated}" format="${_dateFormatDisplay}"/></nobr></td>
							<td style="text-align: center;"><nobr><openmrs:formatDate date="${completedOrder.scheduledStopDate}" format="${_dateFormatDisplay}"/></nobr></td>
							<td ><nobr><a href='${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder.form?patientId=${model.patient.patientId}&orderId=${completedOrder.orderId}&operation=RENEW'> <img title="Renew Order" id='renewOrder_${i}_' src="/openmrs/moduleResources/medicationlog/img/renew_very_small.png" alt="renew" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></a></nobr></td> 
							</tr>
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

<div class="modal fade" id="viewDrugModal" tabindex="-1" role="dialog" aria-labelledby="viewDrugModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header text-center">
                <h4 class="modal-title w-100 font-weight-bold"><spring:message code="medication.drugOrder.details"/></h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
            	
           		<div id="orderDetails">
           			
           		</div>
            	
            	<!-- <u><h2><span style="margin: 0px 0px 1em 1em;" class="capitalize" id="drugName"></span><img title="As needed medicine" id="prnMedicine" src="/openmrs/moduleResources/medicationlog/img/prn_very_small.png" alt="prn" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></h2></u> -->
			 
            </div>
        </div>
    </div>
</div>
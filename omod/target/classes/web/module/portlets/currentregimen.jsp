<%@ include file="/WEB-INF/template/include.jsp"%>

<openmrs:htmlInclude
	file="/scripts/jquery/dataTables/css/dataTables.css" />
<openmrs:htmlInclude
	file="/scripts/jquery/dataTables/js/jquery.dataTables.min.js" />

<link type="text/css" rel="stylesheet"
	href="/openmrs/moduleResources/medicationlog/css/medication.css" />

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
	src="${pageContext.request.contextPath}/moduleResources/medicationlog/bootstrap/js/bootstrap.min.js"></script>


<!-- SPECIALIZED STYLES FOR THIS PORTLET -->
<style type="text/css">

body {
	font-size: 12px;
}

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
		
		/* drug order stopped alert */
		/* var orderStopped = '${param.stopped_status}';
		if(orderStopped != null && orderStopped != "") {
			
			alertify.set('notifier','position', 'top-center');
			var orderStoppedAlert = alertify.success(orderStopped);
			orderStoppedAlert.delay(20).setContent(orderStopped);
			
			jQuery('body').one('click', function(){
				orderStoppedAlert.dismiss();
			});
		} */
		
		jQuery('.stopButton').click(function(){
			
			var val = this.id;
			var values = val.split("_");
			
			// jQuery('#stopDrugDialog').dialog('open');
			
			document.getElementById('stopOrderId').value = values[2];
			document.getElementById('drugStartDate').value = values[3];
			document.getElementById('drugStopDate').value = "";
			document.getElementById('orderStopReasonMsg').innerHTML ="";
			document.getElementById('drugStopDateMsg').innerHTML ="";
			//jQuery("#stopOrderId").val(values[2]);
			//jQuery("#drugStartDate").val(values[3]);
			jQuery('#stopDrugModal').modal('show'); 
			
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
		document.getElementById('orderStopReasonMsg').innerHTML ="";
		document.getElementById('drugStopDateMsg').innerHTML ="";
		var stopIt = true;
		
		var reasonSelectElement =  document.getElementById('orderStopReason');
		if(reasonSelectElement.selectedIndex == 0)
		{
			// error = " <spring:message code='medication.regimen.stopReason' /> ";
			document.getElementById('orderStopReasonMsg').innerHTML ="<spring:message code='medication.regimen.stopReason' />";
			stopIt = false;
		}
		var stopDate = jQuery("#drugStopDate").val();
		
		if(stopDate == "")
		{
			// error = error + " <spring:message code='medication.regimen.stopDateError' /> ";
			document.getElementById('drugStopDateMsg').innerHTML ="<spring:message code='medication.regimen.stopDateError' />";
			stopIt = false;
		}
		else {
			var datePattern = '<openmrs:datePattern />';
			
			var startYears = datePattern.indexOf("yyyy");
			
			var startMonths =  datePattern.indexOf("mm");
			
			var startDays = datePattern.indexOf("dd");
			
			var convertDateStop = stopDate.substring(startYears, startYears + 4) + "/" + stopDate.substring(startMonths, startMonths + 2) + "/" + stopDate.substring(startDays, startDays + 2);
			var dateStop = new Date(convertDateStop);
			
			var startDate = jQuery("#drugStartDate").val();
			
			startDate = convertDate(startDate);
			var convertDateStart = startDate.substring(startYears, startYears + 4) + "/" + startDate.substring(startMonths, startMonths + 2) + "/" + startDate.substring(startDays, startDays + 2);
			var dateStart = new Date(convertDateStart);
			
			
			if(dateStop < dateStart)
			{
				// error = error + " <spring:message code='medication.regimen.stopDateLessStartError' /> ";
				document.getElementById('drugStopDateMsg').innerHTML ="<spring:message code='medication.regimen.stopDateLessStartError' />";
				stopIt = false;
			}
		}
		
		/* if(error != "")
		{
			jQuery('.openmrs_error').show();
			jQuery('.openmrs_error').html(error);
		} */
		
		return stopIt;
		
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
			console.log("dose unit " + result.doseUnit);
			
			jQuery("#medicineFrequency").text(result.frequency);
			console.log("dose unit " + result.frequency);
			
			jQuery("#medicineRoute").text(result.route);
			
			var completeDuration = result.duration + " " + result.durationUnit;
			jQuery("#medicineDuration").text(completeDuration);
			
			if(result.instructions == null || result.instructions == "") {
				jQuery("#medicineInstructionLabel").hide();
				jQuery("#medicineInstructions").hide();
			}
			else {
				jQuery("#medicineInstructionLabel").show();
				jQuery("#medicineInstructions").show();
				jQuery("#medicineInstructions").text(result.instructions);
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
			jQuery("#medicineStartDate").text(formattedStartDate);
			
			if(result.asNeeded != null && result.asNeeded == true) {
				jQuery("#prnMedicine").show();
			}
			else if(result.asNeeded != null && result.asNeeded == false) {
				jQuery("#prnMedicine").hide();
			}
		});
		
		//jQuery('#viewOrderDialog').dialog('open');
		jQuery('#viewDrugModal').modal('show'); 
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
	
	
	function convertDate(inputFormat) {
		  function pad(s) { return (s < 10) ? '0' + s : s; }
		  var d = new Date(inputFormat);
		  return [pad(d.getDate()), pad(d.getMonth()+1), d.getFullYear()].join('/');
		}
	
</script>

<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.current" /></div>
<div class="box${model.patientVariation}">
	
	<c:choose>
		<c:when test="${! empty model.currentDrugOrders}">
		
		<table id="currentOrders" class="table table-striped table-bordered">
		<thead>
		<tr>
			<th><spring:message code="medication.drugOrder.view"/></th>
			<th><nobr><spring:message code="medication.regimen.drugLabel"/></nobr></th>
			<th><spring:message code="medication.drugOrder.doseAndUnit"/></th>
			<th><spring:message code="medication.regimen.route"/></th>
			<th><spring:message code="medication.drugOrder.frequency"/></th>
			<th><spring:message code="medication.orderset.field.startDay"/></th>
			<th><spring:message code="medication.drugOrder.scheduledStopDate"/></th>
			<th><spring:message code="medication.drugOrder.delete"/></th>
			<th><spring:message code="medication.drugOrder.stop"/></th>
			<th><spring:message code="medication.drugOrder.edit"/></th>
		</tr>
		
		</thead>
		
		<tbody>
		<c:set var="i" value="0"/>
			<c:forEach var="currentOrder" items="${model.currentDrugOrders}">
			<c:if test="${! empty model.currentDrugOrders}">
				<tr>
				<td ><nobr><img title="View Order" id='viewCurrentOrder_${i}_${currentOrder.orderId}_${currentOrder.dateActivated}' onclick="viewCurrentOrder(this)" src="/openmrs/moduleResources/medicationlog/img/view_text_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				<td style="text-transform: capitalize;"><nobr>${currentOrder.drugName}</nobr><span><img 
				title="<c:choose>
					<c:when test="${! empty currentOrder.instructions}">
    					${currentOrder.instructions}
    				</c:when>
    				<c:when test="${empty currentOrder.instructions}">
    					<spring:message code="medication.drugOrder.noInstructions" />
    				</c:when>
    			</c:choose>" id='viewMore_${i}'  src="/openmrs/moduleResources/medicationlog/img/info_light_green_small.png" alt="more" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></span></td>
				<td ><nobr>${currentOrder.dose} ${currentOrder.doseUnit}</nobr></td>
				<td ><nobr>${currentOrder.route}</nobr></td>
				<td ><nobr>${currentOrder.frequency}</nobr></td>
				<td style="text-align: center;"><nobr><openmrs:formatDate date="${currentOrder.dateActivated}" format="${_dateFormatDisplay}"/></nobr></td>
				<td style="text-align: center;"><nobr><openmrs:formatDate date="${currentOrder.scheduledStopDate}" format="${_dateFormatDisplay}"/></nobr></td>
				<td ><nobr><img title="Delete" id='deleteOrder_${i}_' onclick="deleteOrder(this)" src="/openmrs/moduleResources/medicationlog/img/delete_very_small.png" alt="delete" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>  
				<td ><nobr><img title="Stop" class="stopButton" id='stopOrder_${i}_${currentOrder.orderId}_${currentOrder.dateActivated}' src="/openmrs/moduleResources/medicationlog/img/stop_very_small.png" alt="stop" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				<td ><nobr><a href='${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder.form?patientId=${model.patient.patientId}&orderId=${currentOrder.orderId}'> <img src="/openmrs/moduleResources/medicationlog/img/edit.gif"></a></nobr></td>
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
		<td><span style="font-weight:bold" id="medicineInstructionLabel">Instructions:</span></td>
		<td><span id="medicineInstructions"></span></td>
	</tr>
	
	</table>
	</div>
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
            	
            	<u><h2><span style="margin: 0px 0px 1em 1em;" class="capitalize" id="drugName"></span><img title="As needed medicine" id="prnMedicine" src="/openmrs/moduleResources/medicationlog/img/prn_very_small.png" alt="prn" border="0" onmouseover="document.body.style.cursor='default'" onmouseout="document.body.style.cursor='default'"/></h2></u>
            	
            	<div class="row">
            	
            	<div class="col-md-12">
            
            	<table  class="table table-striped table-responsive-md btn-table table-hover mb-0" id="tb-test-type">
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
						<td><span style="font-weight:bold" id="medicineInstructionLabel">Instructions:</span></td>
						<td><span id="medicineInstructions"></span></td>
					</tr>
              </table>
              
              </div>
              
              
              
              </div>
              
              
              
			 
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="stopDrugModal" tabindex="-1" role="dialog" aria-labelledby="stopDrugModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header text-center">
                <h4 class="modal-title w-100 font-weight-bold"><spring:message code="medication.drugOrder.stopOrder"/></h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
              <form id="stopDrug" name="stopDrug" method="post" action="${pageContext.request.contextPath}/module/medicationlog/order/stopDrugOrder.form" onsubmit="return stopOrder()">            
						 <div class="row">
						   <div class="col-md-4">
						   
						  	<input name="stopOrderId" id="stopOrderId" hidden="true"></input>
							<input name="drugStartDate" id="drugStartDate" hidden="true"></input>
							<input name="returnPage" hidden="true" value="/patientDashboard.form?patientId=${model.patient.patientId}"/></input>
						   
						   <label class="control-label"><spring:message code="medication.regimen.stopDate"/><span class="required">*</span></label> 
							
						   </div>
						   <div class="col-md-6">
						   <openmrs_tag:dateField formFieldName="drugStopDate" startValue=""/>
						   <br/>
						   <span id="drugStopDateMsg" class="text-danger "> </span>
						   </div>  
						 </div>
						 
						 <!--  second row -->
						 <div class="row">
						   <div class="col-md-4">
						   
						   <label class="control-label"><spring:message code="medication.drugOrder.stopReason"/><span class="required">*</span></label> 
							
						   </div>
						   <div class="col-md-6">
						   <select name="orderStopReason" id="orderStopReason" class="form-control" >
							<option value="">Select option</option>
							<c:if test="${not empty model.orderStoppedReasons}">
							<c:forEach items="${model.orderStoppedReasons}" var="orderStopReason">
								<option value="${orderStopReason.conceptId}">${fn:toLowerCase(orderStopReason.displayString)}</option>
							</c:forEach>
							</c:if>
						</select>
						<span id="orderStopReasonMsg" class="text-danger "> </span>
						   </div>
						   
						 </div>
						 
						 <br/>
						 
						 <!-- Stop -->
						 <div class="row">
						    <div class="col-md-4">
						    </div>
						   <div class="col-md-4">
						 		 <input type="submit"  ></input>
						   </div>
						 </div>
			   </form>			 
            </div>
        </div>
    </div>
</div> 

<!--  View Modal -->
<div class="modal fade" id="viewOrderModal" tabindex="-1" role="dialog" aria-labelledby="viewOrderModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header text-center">
                <h4 class="modal-title w-100 font-weight-bold"><spring:message code="medication.drugOrder.details"/></h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
              
              <fieldset  class="scheduler-border">
              
              <table  class="table table-striped table-responsive-md btn-table table-hover mb-0" id="tb-test-type">
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
						<td><span style="font-weight:bold" id="medicineInstructionLabel">Instructions:</span></td>
						<td><span id="medicineInstructions"></span></td>
					</tr>
					
              </table>
	             	
				<!-- end: change the widget for fields -->
					
           	</fieldset>
              		 
              		 
            </div>
        </div>
    </div>
</div> 

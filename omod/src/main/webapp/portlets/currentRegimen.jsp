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
	
	.row{
	 margin-bottom:15px;
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
	        "iDisplayLength": 15,
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
			console.log("stop date:" + dateStop + "date Start: " + dateStart);
			
			if(dateStop < dateStart)
			{
				document.getElementById('drugStopDateMsg').innerHTML ="<spring:message code='medication.regimen.stopDateLessStartError' />";
				stopIt = false;
			}
			else if(dateStop > new Date())
			{
				document.getElementById('drugStopDateMsg').innerHTML ="<spring:message code='medication.regimen.stopDateBeforeCurrentDate' />";
				stopIt = false;
			}
		}
		return stopIt;
		
	}
	
	 function viewCurrentOrder(obj) {
		
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
			<th><spring:message code="medication.drugOrder.orderId"/></th>
			<th><spring:message code="medication.drugOrder.view"/></th>
			<th><nobr><spring:message code="medication.regimen.drugLabel"/></nobr></th>
			<th><spring:message code="medication.drugOrder.doseAndUnit"/></th>
			<th><spring:message code="medication.regimen.route"/></th>
			<th><spring:message code="medication.drugOrder.frequency"/></th>
			<th><spring:message code="medication.orderset.field.startDay"/></th>
			<th><spring:message code="medication.drugOrder.scheduledStopDate"/></th>
			<th><spring:message code="medication.drugOrder.stop"/></th>
			<th><spring:message code="medication.drugOrder.revise"/></th>
		</tr>
		
		</thead>
		
		<tbody>
		<c:set var="i" value="0"/>
			<c:forEach var="currentOrder" items="${model.currentDrugOrders}">
			<c:if test="${! empty model.currentDrugOrders}">
				<tr>
				<td ><nobr>${currentOrder.orderId}</nobr></td>
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
				<td ><nobr><img title="Stop" class="stopButton" id='stopOrder_${i}_${currentOrder.orderId}_${currentOrder.dateActivated}' src="/openmrs/moduleResources/medicationlog/img/stop_very_small.png" alt="stop" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				<td ><nobr><a href='${pageContext.request.contextPath}/module/medicationlog/singleDrugOrder.form?patientId=${model.patient.patientId}&orderId=${currentOrder.orderId}&operation=REVISE'> <img src="/openmrs/moduleResources/medicationlog/img/reload_small.png"></a></nobr></td>
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

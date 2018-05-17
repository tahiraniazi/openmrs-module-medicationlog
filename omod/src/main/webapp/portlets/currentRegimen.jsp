<%@ include file="/WEB-INF/template/include.jsp"%>

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
		/* width: 850px; */
		table-layout:fixed !important;
	}

	#currentOrders td {
		width: 200px;
	
		padding-left:2px !important; 
		padding-right:4px !important; 
		padding-top:4px !important; 
		padding-bottom:4px !important; 
		vertical-align:top !important; 
	}
	
}
	
</style>

<script type="text/javascript" th:inline="javascript">

	function viewMore(obj) {
		
		var theId = obj.id;
		var idArray = theId.split("_");
		var elementId = "viewMore_"+idArray[1];
		
		var mainPath = window.location.protocol + "//" + window.location.host;
		var moreImagePath = mainPath + "/openmrs/moduleResources/medicationlog/img/info_light_green_small.png";
		var lessImagePath = mainPath + "/openmrs/moduleResources/medicationlog/img/info_blue_small.png";
		
			if (document.getElementById(elementId).src == lessImagePath) 
	        {
				document.getElementById("viewMore_"+idArray[1]).src = moreImagePath;
				jQuery("#instructions_row_"+idArray[1]).hide();
	        }
			else if (document.getElementById(elementId).src == moreImagePath)
			{
				document.getElementById("viewMore_"+idArray[1]).src = lessImagePath;
				jQuery("#instructions_row_"+idArray[1]).show();
			}
		
	}
	
	function viewCurrentOrder(obj) {
		jQuery('#vieweOrderDialog').dialog('open');
		
	}
	
	jQuery(document).ready(function() {
		
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
		
		jQuery('#vieweOrderDialog').dialog({
			position: 'middle',
			autoOpen: false,
			modal: true,
			title: '<spring:message code="medication.drugOrder.details" javaScriptEscape="true"/>',
			height: 480,
			width: '100%',
			zIndex: 100,
			buttons: { '<spring:message code="general.cancel"/>': function() { $j(this).dialog("close"); }
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
			buttons: { '<spring:message code="general.cancel"/>': function() { $j(this).dialog("close"); }
			}
		});
		
	});

</script>

<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.current" /></div>
<div class="box${model.patientVariation}">
	
	<table id="currentOrders">
	<c:choose>
		<c:when test="${! empty model.currentDrugOrders}">
		<tr>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.view"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><nobr><u><spring:message code="medication.regimen.drugLabel"/></u></nobr></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.doseAndUnit"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.regimen.route"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.frequency"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.orderset.field.startDay"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.scheduledStopDate"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.delete"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.stop"/></u></td>
		</tr>
		</c:when>
		<c:when test="${empty model.currentDrugOrders}">
		<font color="#808080"><i><spring:message code="medication.drugOrder.noRecords" /></i></font>
		</c:when>
	</c:choose>
	<c:set var="i" value="0"/>
		<c:forEach var="currentOrder" items="${model.currentDrugOrders}">
		<span class="count" >
			<c:if test="${! empty model.currentDrugOrders}">
				<tr 
				<c:if test="${i % 2 == 0 }">class="medicationEvenRow"</c:if>
				<c:if test="${i % 2 != 0 }">class="medicationOddRow"</c:if>>
				<td class="tableCell"><nobr><img title="View Order" id='viewCurrentOrder_${i}_' onclick="viewCurrentOrder(this)" src="/openmrs/moduleResources/medicationlog/img/view_text_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				<td class="tableCell" style="text-transform: capitalize;"><nobr>${currentOrder.drugName}</nobr><span><img title="View Instructions" id='viewMore_${i}' onclick="viewMore(this)" src="/openmrs/moduleResources/medicationlog/img/info_light_green_small.png" alt="more" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></span></td>
				<td class="tableCell"><nobr>${currentOrder.dose} ${currentOrder.doseunit}</nobr></td>
				<td class="tableCell"><nobr>${currentOrder.route}</nobr></td>
				<td class="tableCell"><nobr>${currentOrder.frequency}</nobr></td>
				<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${currentOrder.dateActivated}" format="${_dateFormatDisplay}"/></nobr></td>
				<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${currentOrder.scheduledDate}" format="${_dateFormatDisplay}"/></nobr></td>
				<td class="tableCell"><nobr><img title="Delete" id='deleteOrder_${i}_' onclick="deleteOrder(this)" src="/openmrs/moduleResources/medicationlog/img/delete_very_small.png" alt="delete" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>  
				<td class="tableCell"><nobr><img title="Stop" class="stopButton" id='stopOrder_${i}_${currentOrder.orderId}_${currentOrder.dateActivated}' onclick="stopOrder(this)" src="/openmrs/moduleResources/medicationlog/img/stop_very_small.png" alt="stop" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				</tr>
				<tr id="instructions_row_${i}" style="display:none;">
				<td id='instructions_${i}'  colspan="9" style="text-align: left;" ><label style="font-weight:bold"><u>Instructions:</u></label>
				<span id="instruction_span"><c:choose>
					<c:when test="${! empty currentOrder.instructions}">
    					${currentOrder.instructions}
    				</c:when>
    				<c:when test="${empty currentOrder.instructions}">
    					<font color="#808080"><i><spring:message code="medication.drugOrder.noInstructions" /></i></font>
    				</c:when>
    			</c:choose></span></td>
				</tr>
				<c:set var="i" value="${i+1}"/>
			</c:if>
		</c:forEach>
	</table>
		
		
		
</div>
<div id="vieweOrderDialog">
	<div class="box">
	
	</div>
</div>


<div id="stopDrugDialog">
	<div class="box">
	<div id="openmrs_error" class="openmrs_error"></div>
		<form id="stopDrug" name="stopDrug" method="post" action="${pageContext.request.contextPath}/module/medicationlog/stopDrug.form">
			<input type="hidden" name="orderId" id="stopOrderId">
			<input type="hidden" name="startDate" id="startDate">
			<input type="hidden" name="patientId" value="${model.patient.patientId}">
			<input type="hidden" name="returnPage" value="/patientDashboard.form?patientId=${model.patient.patientId}"/>	
			<table>
				<tr>
					<td class="padding"><spring:message code="medication.regimen.stopDate"/>: <openmrs_tag:dateField formFieldName="drugStopDate" startValue=""/></td>
					<td class="padding"><spring:message code="medication.drugOrder.stopReason"/>:<openmrs:fieldGen type="org.openmrs.DrugOrder.discontinuedReason" formFieldName="drugStopReason" val="" parameters="optionHeader=[blank]|globalProp=concept.reasonOrderStopped" /></td>
				</tr>
			</table>
		</form>
	</div>
</div>

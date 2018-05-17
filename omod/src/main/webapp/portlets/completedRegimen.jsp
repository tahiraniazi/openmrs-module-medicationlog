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

    #completedOrders {
    	/* width: 850px; */
    	table-layout:fixed !important;
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
		jQuery("#completed_instructions_"+idArray[1]).toggle('slow', function() {
			if (document.getElementById(elementId).src == lessImagePath) 
	        {
				//document.getElementById("instructions_"+idArray[1]).style.display = 'none';
				//document.getElementById("instructions_"+idArray[1]).colSpan = "9";
				document.getElementById("viewInstructions_"+idArray[1]).src = moreImagePath;
				jQuery("#completed_instructions_"+idArray[1]).css('display', 'none');
	        }
			else if (document.getElementById(elementId).src == moreImagePath)
			{
				//document.getElementById("instructions_"+idArray[1]).style.display = 'block';
				//document.getElementById("instructions_"+idArray[1]).colSpan = "9";
				document.getElementById("viewInstructions_"+idArray[1]).src = lessImagePath;
				jQuery("#completed_instructions_"+idArray[1]).css('display','');
			}
		});
	}

</script>

<div class="boxHeader${model.patientVariation}"><spring:message code="medication.regimen.completed" /></div>
<div class="box${model.patientVariation}">
	
	<table id="completedOrders">
	<c:choose>
		<c:when test="${! empty model.completedDrugOrders}">
		<tr>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.view"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><nobr><u><spring:message code="medication.regimen.drugLabel"/></u></nobr></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.doseAndUnit"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.regimen.route"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.frequency"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.orderset.field.startDay"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.scheduledStopDate"/></u></td>
			<td class="tableCell" colspan="1" style="font-weight:bold"><u><spring:message code="medication.drugOrder.reNew"/></u></td>
		</tr>
		</c:when>
		<c:when test="${empty model.completedDrugOrders}">
		<font color="#808080"><i><spring:message code="medication.drugOrder.noRecords" /></i></font>
		</c:when>
	</c:choose>
	
	<c:set var="i" value="0"/>
		<c:forEach var="completedOrder" items="${model.completedDrugOrders}">
		<span class="count" >
			<c:if test="${! empty model.completedDrugOrders}">
				<tr 
				<c:if test="${i % 2 == 0 }">class="medicationEvenRow"</c:if>
				<c:if test="${i % 2 != 0 }">class="medicationOddRow"</c:if>>
				<td class="tableCell"><nobr><img title="View Order" id='viewOrder_${i}_' onclick="viewOrder(this)" src="/openmrs/moduleResources/medicationlog/img/view_text_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td>
				<td class="tableCell" style="text-transform: capitalize;"><nobr>${completedOrder.drugName}</nobr><span><img title="View Instructions" id='viewInstructions_${i}' onclick="viewInstructions(this)" src="/openmrs/moduleResources/medicationlog/img/info_light_green_small.png" alt="view" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></span></td>
				<td class="tableCell"><nobr>${completedOrder.dose} ${currentOrder.doseunit}</nobr></td>
				<td class="tableCell"><nobr>${completedOrder.route}</nobr></td>
				<td class="tableCell"><nobr>${completedOrder.frequency}</nobr></td>
				<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${completedOrder.dateActivated}" format="${_dateFormatDisplay}"/></nobr></td>
				<td class="tableCell" style="text-align: center;"><nobr><openmrs:formatDate date="${completedOrder.scheduledDate}" format="${_dateFormatDisplay}"/></nobr></td>
				<td class="tableCell"><nobr><img title="Renew Order" id='renewOrder_${i}_' onclick="renewOrder(this)" src="/openmrs/moduleResources/medicationlog/img/renew_very_small.png" alt="renew" border="0" onmouseover="document.body.style.cursor='pointer'" onmouseout="document.body.style.cursor='default'"/></nobr></td> 
				</tr>
				<tr>
				<td id='completed_instructions_${i}' colspan="9" style="display:none; text-align: left; word-wrap: break-word;"><label style="style="font-weight:bold""><u>Instructions:</u></label><nobr>
				<c:choose>
					<c:when test="${! empty completedOrder.instructions}">
    					${completedOrder.instructions}
    				</c:when>
    				<c:when test="${empty completedOrder.instructions}">
    					<font color="#808080"><i><spring:message code="medication.drugOrder.noInstructions" /></i></font>
    				</c:when>
    			</c:choose></nobr></td>
				</tr>
				<c:set var="i" value="${i+1}"/>
			</c:if>
		</c:forEach>
	</table>
		
		
		
</div>
<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="/WEB-INF/view/module/medicationlog/include/localHeader.jsp"%>

<openmrs:htmlInclude file="/scripts/jquery/dataTables/css/dataTables_jui.css"/>
<openmrs:htmlInclude file="/scripts/jquery/dataTables/js/jquery.dataTables.min.js"/>
<script type="text/javascript">
    jQuery(document).ready(function() {
    	jQuery('#orderSetTable').dataTable({
            "bPaginate": true,
            "bLengthChange": false,
            "bFilter": false,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": false,
            "bSortable": true,
            "aoColumns": [{ "iDataSort": 1 }, { "sType": "html" }, null]
        });
    });
</script>

<h2><spring:message code="medication.orderSet.manage.linkTitle"/></h2>

<a href="addOrderSet.form"><spring:message code="medication.orderset.addButton"/></a>
<br/><br/>
<div class="boxHeader">
	<spring:message code="medication.orderset.lists"/>
</div>
<div class="box">
	<table id="orderSetTable" style="width:100%; padding:5px;)">
		<thead>
			<tr>
				<th></th>
				<!-- name -->
				<!-- description -->
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${orderSets}" var="orderSet">
				<tr>
					
				</tr>
			</c:forEach>
		</tbody>
	</table>
</div>

<%@ include file="/WEB-INF/template/footer.jsp"%>
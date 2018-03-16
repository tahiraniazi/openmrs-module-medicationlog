<%@ include file="/WEB-INF/template/include.jsp"%>
<%@ include file="/WEB-INF/template/header.jsp"%>
<%@ include file="/WEB-INF/view/module/medicationlog/include/localHeader.jsp"%>



<style>
	#indication_id_selection { width: 400px; }
</style>

<h2>
<c:choose>
	<c:when test="${empty orderSet.id}"><spring:message code="medication.orderset.create.pageTitle"/></c:when>
	<c:otherwise><spring:message code="orderextension.orderset.edit.pageTitle"/></c:otherwise>
</c:choose>
</h2><br/>

<spring:hasBindErrors name="orderSet">
	<spring:message code="fix.error"/>
	<div class="error">
		<c:forEach items="${errors.allErrors}" var="error">
			<spring:message code="${error.code}" text="${error.code}"/><br/>
		</c:forEach>
	</div>
	<br />
</spring:hasBindErrors>

<form:form method="post">
	<table>
		<tr>
			<td><spring:message code="medication.orderset.field.name"/></td>
			<td>
				<input type="text" name="orderSetName" id="orderSetName" size="50"/>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top;"><spring:message code="medication.orderset.field.description"/></td>
			<td>
				<textarea rows="2" cols="40" name="description" id="description"></textarea>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top;"><spring:message code="medication.orderset.field.operator"/></td>
			<td>
			<select name="operator" id="operatorSelect">
                <c:forEach items="${operators}" var="operator">
						<option value="${operator}">${operator}</option>
				</c:forEach>
                </select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="submit" value="<spring:message code='general.save'/>" />
				&nbsp;&nbsp;
				<c:choose>
					<c:when test="${empty orderSet.id}">
						<input type="button" value="<spring:message code='general.cancel'/>" onclick="document.location.href=''" />
					</c:when>
					<c:otherwise>
						<input type="button" value="<spring:message code='general.cancel'/>" onclick="document.location.href=''" />
					</c:otherwise>
				</c:choose>
			</td>
		</tr>
	</table>
</form:form>

<%@ include file="/WEB-INF/template/footer.jsp"%>
<%-- 
    Document   : activityList
    Created on : May 3, 2013, 3:49:57 PM
    Author     : focke
--%>

<%@tag description="List Activities" pageEncoding="US-ASCII"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="display" uri="http://displaytag.sf.net"%>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib uri="http://srs.slac.stanford.edu/filter" prefix="filter"%>


<%@attribute name="done"%>
<%@attribute name="hardwareId"%>
<%@attribute name="processId"%>
<%@attribute name="travelersOnly"%>
<%@attribute name="userId"%>
<%@attribute name="version"%> 
<%@attribute name="name"%>
<%@attribute name="status"%>
<%@attribute name="perHw"%>
<c:if test="${empty perHw}"><c:set var="perHw" value="false"/></c:if>

<%-- Note use of concat in the query, the AS statement was not working otherwise 
http://stackoverflow.com/questions/14431907/how-to-access-duplicate-column-names-with-jstl-sqlquery
--%>

<filter:filterTable>
    <filter:filterSelection title="Hardware<br>Subsystem" var="subsystem" defaultValue="any">
        <filter:filterOption value="any">Any</filter:filterOption>
        <sql:query var="subsystems">
            select name from Subsystem order by name
        </sql:query>
        <c:forEach var="row" items="${subsystems.rows}">
            <filter:filterOption value="${row.name}">${row.name}</filter:filterOption>
        </c:forEach>
    </filter:filterSelection>
    <filter:filterSelection title="Traveler<br>Subsystem" var="tsubsystem" defaultValue="-1">
        <filter:filterOption value="-1">Any</filter:filterOption>
        <sql:query var="tsubsystems">
            select id,name from Subsystem order by name
        </sql:query>
        <c:forEach var="row" items="${tsubsystems.rows}">
            <filter:filterOption value="${row.id}">${row.name}</filter:filterOption>
        </c:forEach>
    </filter:filterSelection>
</filter:filterTable>

<sql:query var="result" >
    select concat(A.id,'') as activityId, A.rootActivityId, A.begin, A.end, A.createdBy, A.closedBy,
    concat(AFS.name,'') as status,
    P.id as processId, 
    concat(P.name, ' v', P.version) as processName,
    P.shortDescription,
    H.id as hardwareId, H.lsstId, H.manufacturerId,
    HT.name as hardwareName, HT.id as hardwareTypeId,
    concat(RN.runNumber,'') as runNumber,
    S.name as subName, TT.subsystemId
    from Activity A
    inner join Process P on A.processId=P.id
    inner join Hardware H on A.hardwareId=H.id
    inner join HardwareType HT on H.hardwareTypeId=HT.id
    inner join Subsystem S on S.id=HT.subsystemId
    inner join ActivityStatusHistory ASH on ASH.activityId=A.id and ASH.id=(select max(id) from ActivityStatusHistory where activityId=A.id)
    inner join TravelerType TT on TT.rootProcessId = (select Process.id from Process INNER JOIN Activity A2 ON A2.processId=Process.id WHERE A2.id=A.rootActivityId)
    inner join ActivityFinalStatus AFS on AFS.id=ASH.activityStatusId
    inner join RunNumber RN on RN.rootActivityId=A.rootActivityId 
    left join HardwareIdentifier HI on HI.hardwareId=H.id 
    and HI.authorityId=(select id from HardwareIdentifierAuthority where name=?<sql:param value="${preferences.idAuthName}"/>) 
    where true 
    <c:if test="${! empty travelersOnly}">
        and A.processEdgeId IS NULL 
    </c:if>
    <c:if test="${subsystem!='any'}">
        and S.name=?
        <sql:param value="${subsystem}"/>
    </c:if> 
     <c:if test="${tsubsystem!=-1}">
        and TT.subsystemId=?
        <sql:param value="${tsubsystem}"/>
    </c:if> 
    <c:if test="${! empty processId}">
        and P.id=?<sql:param value="${processId}"/>
    </c:if>
    <c:if test="${! empty name}">
        and P.name like concat('%', ?<sql:param value="${name}"/>, '%')
    </c:if>
    <c:if test="${! empty hardwareId}">
        and H.id=?<sql:param value="${hardwareId}"/>
    </c:if>
    <c:if test="${! empty done}">
        and <c:if test="${! done}">not</c:if> AFS.isFinal
    </c:if>
    <c:if test="${! empty status && status != 'any'}">
        and AFS.name=?<sql:param value="${status}"/>
    </c:if>
    <c:if test="${! empty userId}">
        and (A.createdBy=?<sql:param value="${userId}"/> or A.closedBy=?<sql:param value="${userId}"/>
    </c:if>
    <c:if test="${version=='latest'}">
        and P.version=(select max(version) from Process where name=P.name)
    </c:if>
    <c:if test="${perHw}">
        and A.id=(select max(id) from Activity where hardwareId=H.id)
        group by H.id
    </c:if>
    order by A.id desc
    ;
</sql:query>
<%-- should reuse eT preferences.jsp --%> 
<display:table name="${result.rows}" id="row" class="datatable" sort="list"
               pagesize="${fn:length(result.rows) > 10 ? 10 : 0}">
    <display:column title="Name" sortable="true" headerClass="sortable" sortProperty="${row.processName}">
        <c:url var="actLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayActivity.jsp">
            <c:param name="activityId" value="${row.activityId}"/>
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <a href="${actLink}" target="_blank">${row.processName}</a>
        <br>
        Run: ${row.runNumber} <%-- actId: ${row.activityId} --%>
    </display:column>

    <%--  href="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayActivity.jsp" paramId="activityId" paramProperty="activityId"/> --%>
    <c:if test="${empty hardwareId or preferences.showFilteredColumns}">
        <display:column property="lsstId" title="LSST_NUM" sortable="true" headerClass="sortable"
                        href="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardware.jsp?dataSourceMode=${appVariables.dataSourceMode}" paramId="hardwareId" paramProperty="hardwareId"/>
        <display:column property="manufacturerId" title="Manufacturer Serial Number" sortable="true" headerClass="sortable"
                        href="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardware.jsp?dataSourceMode=${appVariables.dataSourceMode}" paramId="hardwareId" paramProperty="hardwareId"/>
    </c:if>
    <c:if test="${(empty processId && empty hardwareId) || preferences.showFilteredColumns}">
        <display:column property="hardwareName" title="Component Type" sortable="true" headerClass="sortable"
                        href="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardwareType.jsp?dataSourceMode=${appVariables.dataSourceMode}" paramId="hardwareTypeId" paramProperty="hardwareTypeId"/>
    </c:if>
    <display:column property="begin" sortable="true" headerClass="sortable"/>
    <display:column property="createdBy" sortable="true" headerClass="sortable"/>
    <c:if test="${(empty status || status == 'any') || preferences.showFilteredColumns}">
        <display:column property="status" sortable="true" headerClass="sortable"/>
    </c:if>
    <display:column property="end" sortable="true" headerClass="sortable"/>
    <c:choose>
        <c:when test="${! empty hardwareId}">
            <display:column title="Output">
                <c:url var="dataDirLink" value="showAllActs.jsp">
                    <c:param name="hdwId" value="${hardwareId}"/>     
                    <c:param name="travActId" value="${row.activityId}"/>
                    <c:param name="travName" value="${row.processName}"/>
                    <c:param name="runNum" value="${row.runNumber}"/>
                </c:url>
                <a href="${dataDirLink}" target="_blank"><c:out value="Get Data"/></a>
            </display:column>
        </c:when>
        <c:otherwise>
            <display:column title="Output">

            <sql:query var="downloadQuery" scope="page">
                SELECT virtualPath FROM FilepathResultHarnessed 
                WHERE FilepathResultHarnessed.activityId=?<sql:param value="${row.activityId}"/>
            </sql:query>
            <c:choose>
            <c:when test="${downloadQuery.rowCount>0}" >
                <c:set var="firstRow" value="${downloadQuery.rows[0]}" />
                <c:set var="curPath" value="${portal:truncateString(firstRow.virtualPath,'/')}" />
                <c:choose>
                    <c:when test="${curPath != null}" >
                        <c:url var="dcLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="folderPath" value="${curPath}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                            <c:param name="showFileList" value="true"/>
                        </c:url>
                        <a href="${dcLink}" style="color: rgb(6,82,32)" target="_blank"><c:out value="Download Files"/></a>
                    </c:when>
                    <c:otherwise>
                        <c:out value="EMPTY"/>
                    </c:otherwise>
                </c:choose>

            </c:when>
            <c:otherwise>
                <c:out value="NA"/>
            </c:otherwise>
            </c:choose>
                </display:column>
           
        </c:otherwise>
    </c:choose>

</display:table>        

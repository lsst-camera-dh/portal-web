<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="etapiclient" uri="http://camera.lsst.org/etapiclient" %>
<%@taglib prefix="sensorutils" uri="http://camera.lsst.org/sensorutils" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sensor Summary Table</title>
    </head>
    <body>
        <h1>Sensor Summary Table</h1>

        <%--
        <c:set var="callrest" value="${etapiclient:getRunInfo(appVariables.dataSourceMode, false)}"/>
        
    <display:table name="${callrest.entrySet()}" id="callrest"/>

        --%>
    <%--
         <c:set var="manuapi" value="${etapiclient:getManufacturerId(appVariables.dataSourceMode,false)}"/>
    <display:table name="${manuapi.entrySet()}" id="manuapi"/>  

    
     <c:set var="schemaapi" value="${etapiclient:getRunSchemaResults(appVariables.dataSourceMode,false)}"/>
    <display:table name="${schemaapi.entrySet()}" id="schemaapi"/>  

     <c:set var="jhapi" value="${etapiclient:getResultsJH(appVariables.dataSourceMode,false)}"/>
    <display:table name="${jhapi.entrySet()}" id="jhapi"/> 
    --%>
  <%--
     <c:set var="jhschemaapi" value="${etapiclient:getResultsJH_schema(appVariables.dataSourceMode,false,'SR-EOT-1','ITL-CCD','read_noise','read_noise','ITL-3800C-021')}"/> 

    <display:table name="${jhschemaapi.entrySet()}" id="jhschemaapi"/> 
  --%>
    
  
  <c:set var="sensorSummaryTable" value="${sensorutils:getSensorSummaryTable(pageContext.session,appVariables.dataSourceMode)}"/>
  <display:table name="${sensorSummaryTable}" id="curSensor" defaultsort="1" class="datatable" export="true" >
      <display:column title="LSST_NUM" sortable="true" sortProperty="lsstId" >
          <c:url var="hdwLink" value="/device.jsp">
              <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
              <c:param name="lsstId" value="${curSensor.lsstId}"/>
          </c:url>
          <a href="${hdwLink}" target="_blank"><c:out value="${curSensor.lsstId}"/></a>
      </display:column>
      <display:column title="Specs<br>Passed<br>15" sortable="true" >
          <c:choose>
              <c:when test="${curSensor.numTestsPassed == 15}">
                  <font color="green">
                  ${curSensor.numTestsPassed}
                  </font>
              </c:when>
              <c:otherwise>
                  <font color="red">
                  ${curSensor.numTestsPassed}
                  </font>
              </c:otherwise>
          </c:choose>
      </display:column>
      <display:column title="HCTI<br>Value/Channel" >
          <c:choose>
              <c:when test="${curSensor.passedHCTI}">
                  <font color="green">
                  ${curSensor.worstHCTI} / ${curSensor.worstHCTIChannel}
                  </font>
              </c:when>
              <c:otherwise>
                  <font color="red">
                  ${curSensor.worstHCTI} / ${curSensor.worstHCTIChannel}
                  </font>
              </c:otherwise>
          </c:choose>
      </display:column>
      <display:column title="VCTI<br>Value/Channel" >
          <c:choose>
              <c:when test="${curSensor.passedVCTI}">
                  <font color="green">
                  ${curSensor.worstVCTI} / ${curSensor.worstVCTIChannel}
                  </font>
              </c:when>
              <c:otherwise>
                  <font color="red">
                  ${curSensor.worstVCTI} / ${curSensor.worstVCTIChannel}
                  </font>
              </c:otherwise>
          </c:choose>        
      </display:column>
      <display:column title="Percent Defects" >
          <c:choose>
              <c:when test="${curSensor.passedPercentDefects}">
                  <font color="green">
                  ${curSensor.percentDefects}
                  </font>
              </c:when>
              <c:otherwise>
                  <font color="red">
                  ${curSensor.percentDefects}
                  </font>
              </c:otherwise>
          </c:choose>      
      </display:column>
      <display:column title="Max Read Noise" sortable="true" >
          <c:choose>
              <c:when test="${curSensor.passedReadNoise}">
                  <font color="green">
                  ${curSensor.maxReadNoise}
                  </font>
              </c:when>
              <c:otherwise>
                  <font color="red">
                  ${curSensor.maxReadNoise}
                  </font>
              </c:otherwise>
          </c:choose>

      </display:column>
      <display:column title="Max Read Noise<br/>Channel" sortable="true" >${curSensor.maxReadNoiseChannel}</display:column>
      <display:column title="Sensor Acceptance<br>Link" > 
          <c:url var="acceptanceLink" value="SensorAcceptanceReport.jsp">
              <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
              <c:param name="lsstId" value="${curSensor.lsstId}"/>
          </c:url>
          <a href="${acceptanceLink}" target="_blank"><c:out value="link"/></a>
      </display:column>
      <display:column title="Data Source" sortable="true">${curSensor.dataSource}</display:column>
  </display:table>





    </body>
</html>


<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sos="http://www.opengis.net/sos/2.0" xmlns:swes="http://www.opengis.net/swes/2.0"
    xmlns:sml="http://www.opengis.net/sensorml/2.0" xmlns:swe="http://www.opengis.net/swe/2.0"
    xmlns:swe1="http://www.opengis.net/swe/1.0.1" xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:om="http://www.opengis.net/om/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0"
    xmlns:sf="http://www.opengis.net/sampling/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="swe1">
    <!-- Created By: Alessandro Oggioni & Paolo Tagliolato - CNR IREA in Milano - 2018-06-04T00:00:00Z -->
    <!-- Licence CC By SA 3.0  http://creativecommon.org/licences/by-SA/3.0 -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="yes" indent="yes"
        media-type="text/xml"/>

    <!-- Valori presi da describeSensor (documento in input)-->
    <xsl:variable name="PROCEDURE_ID" select="//gml:identifier/text()"/>
    <xsl:variable name="OFFERING_ID"
        select="//sml:capabilities[@name='offerings']//swe:value"/>

    <xsl:param name="SK_DOMAIN_NAME">
        <xsl:value-of
            select="substring-before(substring-after($PROCEDURE_ID, 'sensors/'), '/procedure')"/>
    </xsl:param>
    <xsl:param name="EXISTING_FOI_ID"/>
    <xsl:variable name="SPATIAL_SAMPLING_POINT_X"
        select="//sml:position/swe:Vector/swe:coordinate[1]/swe:Quantity/swe:value/text()"/>
    <xsl:variable name="SPATIAL_SAMPLING_POINT_Y"
        select="//sml:position/swe:Vector/swe:coordinate[2]/swe:Quantity/swe:value/text()"/>
    <xsl:variable name="SRS_NAME">http://www.opengis.net/def/crs/EPSG/0/4326</xsl:variable>
    <!--xsl:param name="SRS_NAME"/-->
    <xsl:variable name="SAMPLED_FEATURE_URL" select="//sml:featuresOfInterest/sml:FeatureList/sml:feature/@xlink:href" />
    <xsl:variable name="FOI_NAME" select="//sml:featuresOfInterest/sml:FeatureList/swe1:label/text()" />

    <xsl:variable name="BASEURL_SP7" select="'http://www.get-it.it/'"/>
    <xsl:variable name="APP_NAME" select="'sensors'"/>
    <xsl:variable name="SRS" select="concat('EPSG:',substring-after($SRS_NAME,'/def/crs/EPSG/0/'))"/>
    <xsl:variable name="FOI_ID">
        <xsl:choose>
            <xsl:when test="$EXISTING_FOI_ID">
                <xsl:value-of select="$EXISTING_FOI_ID"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$BASEURL_SP7"/><xsl:value-of select="$APP_NAME"
                    />/<xsl:value-of select="$SK_DOMAIN_NAME"/>/foi/SSF/SP/<xsl:value-of
                    select="$SRS"/>/<xsl:value-of select="$SPATIAL_SAMPLING_POINT_X"/>/<xsl:value-of
                    select="$SPATIAL_SAMPLING_POINT_Y"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="OBSERVATION_TYPE"
        select="'http://www.opengis.net/def/observationType/OGC-OM/2.0/OM_SWEArrayObservation'"/>

    <xsl:template match="/">

        <!-- costanti di utilita' -->
        <!-- ****** TODO: capire se sia obbligatorio! (che senso ha in template??) -->
        <xsl:variable name="OBSERVATION_ID" select="'o1'"/>

        <xsl:variable name="PHENOMENON_TIME_DEFINITION">
            <swe:Time definition="http://www.opengis.net/def/property/OGC/0/PhenomenonTime">
                <swe:uom xlink:href="http://www.opengis.net/def/uom/ISO-8601/0/Gregorian"/>
            </swe:Time>
        </xsl:variable>

        <!-- Inizio output -->
        <xsl:for-each select="//sml:outputs/sml:OutputList/sml:output[position()>1]">
            <sos:InsertResultTemplate service="SOS" version="2.0.0"
                xsi:schemaLocation="http://www.opengis.net/sos/2.0 http://schemas.opengis.net/sos/2.0/sosInsertResultTemplate.xsd http://www.opengis.net/om/2.0 http://schemas.opengis.net/om/2.0/observation.xsd  http://www.opengis.net/samplingSpatial/2.0 http://schemas.opengis.net/samplingSpatial/2.0/spatialSamplingFeature.xsd">
                <sos:proposedTemplate>
                    <sos:ResultTemplate>
                        <!-- NOTA: ID VA INDICATO: questo servira' dopo per effettuare inserimenti con FOI variabile -->
                        <!-- Ale: aggiunto il valore di <sml:output> atributo name al posto di compound -->
                        <swes:identifier>
                            <xsl:value-of select="$PROCEDURE_ID"
                                />/template/observedProperty/<xsl:value-of select="./@name"
                                />/foi/SSF/SP/<xsl:value-of select="$SRS"/>/<xsl:value-of
                                select="$SPATIAL_SAMPLING_POINT_Y"/>/<xsl:value-of
                                select="$SPATIAL_SAMPLING_POINT_X"/>
                        </swes:identifier>

                        <!-- VAL ID DELLA OFFERING -->
                        <sos:offering>
                            <xsl:value-of select="$OFFERING_ID"/>
                        </sos:offering>

                        <sos:observationTemplate>
                            <!-- GMLID DELL'OSSERVAZIONE (ma ?? obbligatorio !?) -->
                            <!--  om:OM_Observation gml:id="sensor2obsTemplate">-->
                            <om:OM_Observation gml:id="{$OBSERVATION_ID}">

                                <!--  gestiamo solo un tipo di osservazione, come dichiarato -->
                                <om:type xlink:href="{$OBSERVATION_TYPE}"/>

                                <!-- DUBBIO: i nilreason significano che i valori non ci sono perch?? ?? template ?!!  -->
                                <om:phenomenonTime nilReason="template"/>
                                <!-- qui in insertObservation avrei gml:TimePeriod/gml:beginPosition e endPosition -->
                                <om:resultTime nilReason="template"/>
                                <!-- come sopra ma solo un timeposition  -->

                                <!-- VAL: PROCEDURE  -->
                                <om:procedure xlink:href="{$PROCEDURE_ID}"/>

                                <!--  COMPOUND_OBSERVED_PROPERTY -->
                                <om:observedProperty>
                                    <xsl:attribute name="xlink:href">
                                        <xsl:value-of select="./swe:Quantity/@definition" />
                                    </xsl:attribute>
                                </om:observedProperty>
                                <om:featureOfInterest>
                                    <sams:SF_SpatialSamplingFeature gml:id="SSF_1">
                                        <gml:identifier codeSpace="">
                                            <xsl:value-of select="$FOI_ID"/>
                                        </gml:identifier>
                                        <gml:name>
                                            <xsl:value-of select="//sml:featuresOfInterest"/>
                                        </gml:name>
                                        <sf:type
                                            xlink:href="http://www.opengis.net/def/samplingFeatureType/OGC-OM/2.0/SF_SamplingPoint"/>
                                        <sf:sampledFeature xlink:href="{$SAMPLED_FEATURE_URL}"/>
                                        <sams:shape>
                                            <gml:Point>
                                                <xsl:attribute name="gml:id">
                                                  <xsl:value-of select="concat('point', position())"/>
                                                </xsl:attribute>
                                                <gml:pos srsName="{$SRS_NAME}">
                                                  <xsl:value-of select="$SPATIAL_SAMPLING_POINT_Y"/>
                                                  <xsl:value-of select="' '"/>
                                                  <xsl:value-of select="$SPATIAL_SAMPLING_POINT_X"/>
                                                </gml:pos>
                                            </gml:Point>
                                        </sams:shape>
                                    </sams:SF_SpatialSamplingFeature>
                                </om:featureOfInterest>

                                <om:result/>
                            </om:OM_Observation>
                        </sos:observationTemplate>

                        <!-- *** FINAL *** -->
                        <!-- scelta la coppia offering,property (property qui e'compound) resultStructure non varia tra i vari template -->
                        <!-- result structure e' l'unica parte restituita da getResultTemplate -->
                        <sos:resultStructure>
                            <swe:DataRecord>

                                <!-- ad ogni sml:output in sensorML faccio corrispondere un swe:field per il dataRecord-->
                                <!-- nota: qui devo usare il prefisso swe1 per gli xpath che cercano in sensorML (usa swe versione 1.0.1) 
									uso invece il prefisso swe per gli elementi che compariranno in sos:InsertResultTemplate (sos 2 usa swe versione 2)
						        -->
                                <!-- escludo output phenomenonTime (messo prima cmq) -->
                                <!--  se e' presente inserisco phenomenon time e result time qui -->
                                <xsl:if test="//sml:output[@name='phenomenonTime']">
                                    <swe:field name="phenomenonTime">
                                        <xsl:copy-of select="$PHENOMENON_TIME_DEFINITION"/>
                                        <!-- <swe:Time definition="http://www.opengis.net/def/property/OGC/0/PhenomenonTime">
						                  <swe:uom xlink:href="http://www.opengis.net/def/uom/ISO-8601/0/Gregorian"/>
						                </swe:Time> -->
                                    </swe:field>
                                </xsl:if>
                                <swe:field>
                                    <xsl:attribute name="name">
                                        <xsl:value-of select="@name"/>
                                    </xsl:attribute>
                                    <swe:Quantity>
                                        <xsl:attribute name="definition">
                                            <xsl:value-of select="./swe:Quantity/@definition"/>
                                        </xsl:attribute>
                                        <swe:uom>
                                            <xsl:attribute name="code">
                                                <xsl:value-of
                                                  select="./swe:Quantity/swe:uom/@code"/>
                                            </xsl:attribute>
                                            <xsl:if test="./swe:Quantity/swe:uom/@xlink:href">
                                                <xsl:attribute name="xlink:href">
                                                  <xsl:value-of
                                                  select="./swe:Quantity/swe:uom/@xlink:href"/>
                                                </xsl:attribute>
                                            </xsl:if>
                                        </swe:uom>
                                    </swe:Quantity>
                                </swe:field>
                            </swe:DataRecord>
                        </sos:resultStructure>
                        <sos:resultEncoding>
                            <!-- COSTANTE da decidere -->
                            <swe:TextEncoding tokenSeparator="#" blockSeparator="@"/>
                        </sos:resultEncoding>
                    </sos:ResultTemplate>
                </sos:proposedTemplate>
            </sos:InsertResultTemplate>
        </xsl:for-each>
        <!--  -->
    </xsl:template>
</xsl:stylesheet>

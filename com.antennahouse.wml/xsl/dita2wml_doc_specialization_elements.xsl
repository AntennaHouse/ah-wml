<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Specialization element Templates
**************************************************************
File Name : dita2wml_specialization_elements.xsl
**************************************************************
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="3.0">
    
    <!--
    function:   boolean template
    param:      none
    return:     w:r
    note:       
    -->
    <xsl:template match="*[@class => contains-token('topic/boolean')]" as="element(w:r)">
        <xsl:call-template name="processText">
            <xsl:with-param name="prmText">
                <xsl:call-template name="getVarValueWithLang">
                    <xsl:with-param name="prmVarName">
                        <xsl:choose>
                            <xsl:when test="string(@state) eq 'yes'">
                                <xsl:sequence select="'Boolean_Yes'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="'Boolean_No'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
    function:   data template
    param:      none
    return:     empty
    note:       
    -->
    <xsl:template match="*[@class => contains-token('topic/data')]" as="empty-sequence()"/>

    <!--
    function:   data template for QR code
    param:      none
    return:     DISPLAYBARCODE field
    note:       
    -->
    <xsl:template match="*[@class => contains-token('topic/data')][string(@name) eq 'qrcode'][string(@href)]" as="element(w:r)*" priority="5">
        <xsl:variable name="href" as="xs:string" select="concat('&quot;',string(@href),'&quot;')"/>
        <xsl:variable name="barcodeType" as="xs:string" select="'QR'"/>
        <xsl:variable name="qrCodeHeightDefault" as="xs:string">
            <xsl:variable name="qrCodeHeightDefaultStr" as="xs:string">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'QrCodeHeightDefault'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="ahf:toTwipStr($qrCodeHeightDefaultStr)"/>
        </xsl:variable>
        <xsl:variable name="qrCodeFoContentSpec" as="xs:string?">
            <xsl:variable name="foProp" as="attribute()*" select="ahf:getFoProperty(.)"/>
            <xsl:choose>
                <xsl:when test="$foProp[name(.) eq 'content-height']">
                    <xsl:sequence select="ahf:toTwipStr($foProp[name(.) eq 'content-height'])"/>
                </xsl:when>
                <xsl:when test="$foProp[name(.) eq 'content-width']">
                    <xsl:sequence select="ahf:toTwipStr($foProp[name(.) eq 'content-width'])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="qrCodeScaleDefault" as="xs:string">
            <xsl:variable name="qrCodeScaleDefaultStr" as="xs:string">
                <xsl:call-template name="getVarValue">
                    <xsl:with-param name="prmVarName" select="'QrCodeScaleDefault'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="$qrCodeScaleDefaultStr"/>
        </xsl:variable>
        <xsl:variable name="qrCodeScaleSpec" as="xs:string?">
            <xsl:variable name="foProp" as="attribute()*" select="ahf:getFoProperty(.)"/>
            <xsl:choose>
                <xsl:when test="$foProp[name(.) eq 'ahs:scale']">
                    <xsl:sequence select="string($foProp[name(.) eq 'ahs:scale'])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--xsl:message select="'$qrCodeFoContentSpec=',$qrCodeFoContentSpec"/-->
        <xsl:variable name="fieldOpt" as="xs:string">
            <xsl:call-template name="getVarValueReplacing">
                <xsl:with-param name="prmVarName" select="'QrCodeOpt'"/>
                <xsl:with-param name="prmSrc" select="('%height','%scale')"/>
                <xsl:with-param name="prmDst" select="(if (exists($qrCodeFoContentSpec)) then $qrCodeFoContentSpec else $qrCodeHeightDefault,if (exists($qrCodeScaleSpec)) then $qrCodeScaleSpec else $qrCodeScaleDefault)"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="getWmlObjectReplacing">
            <xsl:with-param name="prmObjName" select="'wmlQrCodeField'"/>
            <xsl:with-param name="prmSrc" select="('%field-opt')"/>
            <xsl:with-param name="prmDst" select="(string-join(($href,$barcodeType,$fieldOpt),' '))"/>
        </xsl:call-template>
    </xsl:template>
    
    <!--
    function:   data-about template
    param:      none
    return:     empty
    note:       
    -->
    <xsl:template match="*[@class => contains-token('topic/data-about')]" as="empty-sequence()"/>
    
    <!--
    function:   foreign template
    param:      none
    return:     empty
    note:       
    -->
    <xsl:template match="*[@class => contains-token('topic/foreign')]" as="empty-sequence()"/>
    
    <!--
    function:   indexbase template
    param:      none
    return:     empty
    note:       
    -->
    <xsl:template match="*[@class => contains-token('topic/indexbase')]" as="empty-sequence()"/>

    <!--
    function:   state template
    param:      none
    return:     w:r
    note:       @name, @value is defined as required.
    -->
    <xsl:template match="*[@class => contains-token('topic/state')]" as="element(w:r)">
        <xsl:call-template name="processText">
            <xsl:with-param name="prmText" select="concat(string(@name),'=',string(@value))">
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!--
    function:   unknown template
    param:      none
    return:     empty
    note:       
    -->
    <xsl:template match="*[@class => contains-token('topic/unknown')]" as="empty-sequence()"/>

    <!-- 
     function:	itemgroup
     param:		none
     return:	under-laying result
     note:		
     -->
    <xsl:template match="*[@class => contains-token('topic/itemgroup')]">
        <xsl:apply-templates/>
    </xsl:template>
    

</xsl:stylesheet>
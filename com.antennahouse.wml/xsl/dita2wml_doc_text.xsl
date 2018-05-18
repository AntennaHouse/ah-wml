<?xml version="1.0" encoding="UTF-8"?>
<!--
**************************************************************
DITA to WordprocessingML Stylesheet
Document.xml text Templates
**************************************************************
File Name : dita2wml_document_text.xsl
**************************************************************
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.com/
**************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    version="2.0">

    <!-- 
     function:	text() processing
     param:		none
     return:	
     note:      - Multiple occurrence of inline style elements are permitted in Open XML specification.
                  So $prmRunProps is simply copied into w:rPr.
                  xml:space="preserve" is also effective in XSLT stylesheets. So w:t should not contain redundant white-spaces.
                - If text() is under the pre element, U+000A is hornored and converted into <br/>.
                - By setting $prmText, this template can be called for any literal output.
     -->
    <xsl:template match="text()" name="processText" as="element(w:r)+">
        <xsl:param name="prmRunProps" tunnel="yes" required="no" as="element()*" select="()"/>
        <xsl:param name="prmInPre" tunnel="yes" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="prmInLines" tunnel="yes" required="no" as="xs:boolean" select="false()"/>
        <xsl:param name="prmText" as="xs:string" required="no" select="string(.)"/>
        <xsl:choose>
            <xsl:when test="$prmInPre">
                <xsl:analyze-string select="$prmText" regex="[\n]">
                    <xsl:matching-substring>
                        <w:r>
                            <w:br/>
                        </w:r>                        
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <w:r>
                            <xsl:if test="exists($prmRunProps)">
                                <w:rPr>
                                    <xsl:copy-of select="$prmRunProps"/>
                                </w:rPr>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$prmInLines">
                                    <w:t xml:space="default"><xsl:value-of select="."/></w:t>
                                </xsl:when>
                                <xsl:otherwise>
                                    <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
                                </xsl:otherwise>
                            </xsl:choose>
                        </w:r>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <w:r>
                    <xsl:if test="exists($prmRunProps)">
                        <w:rPr>
                            <xsl:copy-of select="$prmRunProps"/>
                        </w:rPr>
                    </xsl:if>
                    <w:t xml:space="preserve"><xsl:value-of select="$prmText"/></w:t>
                </w:r>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ==== END OF STYLESHEET === -->

</xsl:stylesheet>
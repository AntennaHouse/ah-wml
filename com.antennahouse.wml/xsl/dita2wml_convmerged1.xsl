<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Merged file conversion templates (1)
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!-- This stylesheet has following functions:
         1. Handle topicref/@print="no".
         2. Handle multiplly referenced topics.
         3. Remove non needed nodes such as comments or processing instructions in topic.
      -->

    <xsl:variable name="root"  as="element()" select="/*[1]"/>
    <xsl:variable name="map"  as="element()" select="$root/*[contains(@class,' map/map ')][1]"/>
    <xsl:variable name="isBookMap" as="xs:boolean" select="exists($map[contains(@class,' bookmap/bookmap ')])"/>
    <xsl:variable name="isMap" as="xs:boolean" select="not($isBookMap)"/>
    
    <!-- Debug -->
    <xsl:param name="PRM_OMIT_ATT" as="xs:boolean" select="false()"/>
    
    <!-- All topiref-->
    <xsl:variable name="allTopicRefs" as="element()*" select="$map//*[contains(@class,' map/topicref ')][not(ancestor::*[contains(@class,' map/reltable ')])]"/>
    
    <!-- topicref that has @print="no"-->
    <xsl:variable name="noPrintTopicRefs" as="element()*" select="$allTopicRefs[ancestor-or-self::*[string(@print) eq 'no']]"/>
    
    <!-- Normal topicref -->
    <xsl:variable name="normalTopicRefs" as="element()*" select="$allTopicRefs except $noPrintTopicRefs"/>
    
    <!-- @href of topicref that has @print="no"-->
    <xsl:variable name="noPrintHrefs" as="xs:string*">
        <xsl:for-each select="$noPrintTopicRefs">
            <xsl:if test="exists(@href)">
                <xsl:sequence select="string(@href)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- @href of noraml topicref -->
    <xsl:variable name="normalHrefs" as="xs:string*">
        <xsl:for-each select="$normalTopicRefs">
            <xsl:if test="exists(@href)">
                <xsl:sequence select="string(@href)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <!-- topicrefs that references same topic -->
    <xsl:variable name="duplicateTopicRefs" as="element()*">
        <xsl:for-each select="$map//*[contains(@class,' map/topicref ')][exists(@href)][empty(ancestor::*[contains(@class,' map/reltable ')])]">
            <xsl:variable name="topicRef" as="element()" select="."/>
            <xsl:variable name="href" as="xs:string" select="string(@href)"/>
            <xsl:if test="$allTopicRefs[. &lt;&lt; $topicRef][exists(@href)][string(@href) eq $href][empty($noPrintTopicRefs[. is $topicRef])]">
                <xsl:sequence select="$topicRef"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="hasDupicateTopicRefs" as="xs:boolean" select="exists($duplicateTopicRefs)"/>

    <!-- key -->
    <xsl:key name="topicById"  match="/*//*[contains(@class, ' topic/topic')]" use="@id"/>

    <!-- 
     function:	root element template
     param:		none
     return:	copied result
     note:		
     -->
    <xsl:template match="dita-merge">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:if test="$hasDupicateTopicRefs">
                <xsl:call-template name="outputDuplicateTopic"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- 
     function:	Map template
     param:		none
     return:	copied result
     note:		Generate frontmatter/booklists/toc, backmatter/booklists/indexlist if needed.
     -->
    <xsl:template match="*[contains(@class,' map/map ')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$isMap and $pMakeTocForMap">
                <frontmatter class="- map/topicref bookmap/frontmatter " xtrc="{@xtrc}" xtrf="{@xtrf}">
                    <booklists class="- map/topicref bookmap/booklists " xtrc="{@xtrc}" xtrf="{@xtrf}">
                        <toc class="- map/topicref bookmap/toc " xtrc="{@xtrc}" xtrf="{@xtrf}"/>
                    </booklists>
                </frontmatter>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="$isMap and $pMakeIndexForMap">
                <backmatter class="- map/topicref bookmap/backmatter " xtrc="{@xtrc}" xtrf="{@xtrf}">
                    <booklists class="- map/topicref bookmap/booklists " xtrc="{@xtrc}" xtrf="{@xtrf}">
                        <indexlist class="- map/topicref bookmap/indexlist " xtrc="{@xtrc}" xtrf="{@xtrf}"/>
                    </booklists>
                </backmatter>
            </xsl:if>
        </xsl:copy>
    </xsl:template>    





    <!-- 
     function:	General template for all element
     param:		none
     return:	copied result
     note:		
     -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:choose>
            <xsl:when test="$PRM_OMIT_ATT">
                <xsl:if test="name() eq 'class'">
                    <xsl:copy/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	topicgroup
     param:		none
     return:	descendant element
     note:		An topicgroup is redundant for document structure.
                It sometimes bothers counting the nesting level of topicref.
     -->
    <xsl:template match="*[contains(@class, ' mapgroup-d/topicgroup ')]" priority="2">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--
     function:	topicref
     param:		none
     return:	self and descendant element or none
     note:		if @print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')]">
        <xsl:variable name="topicRef" as="element()" select="."/>
    	<xsl:choose>
    		<xsl:when test="string(@print) eq 'no'" >
    		    <xsl:for-each select="descendant-or-self::*[contains(@class,' map/topicref ')]">
    		        <xsl:if test="exists(@href)">
    		            <xsl:call-template name="warningContinue">
    		                <xsl:with-param name="prmMes" select="ahf:replace($stMes1001,('%href','%ohref'),(string(@href),string(@ohref)))"/>
    		            </xsl:call-template>
    		        </xsl:if>
    		    </xsl:for-each>
    		</xsl:when>
    	    <xsl:when test="empty(ancestor::*[contains(@class,' map/reltable ')]) and $duplicateTopicRefs[. is $topicRef]">
    	        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
    	        <xsl:variable name="duplicateCount" as="xs:integer" select="count($topicRef|$allTopicRefs[. &lt;&lt; $topicRef][string(@href) eq $href])"/>
    	        <xsl:copy>
    	            <xsl:apply-templates select="@*">
    	                <xsl:with-param name="prmTopicRefNo" select="$duplicateCount"/>
    	            </xsl:apply-templates>
    	            <xsl:apply-templates/>
    	        </xsl:copy>
    	    </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- template for topicref/@href is limited for create new value -->
    <xsl:template match="*[contains(@class,' map/topicref ')]/@href" priority="5">
        <xsl:param name="prmTopicRefNo" required="no" as="xs:integer" select="0"/>
        <xsl:variable name="href" as="xs:string" select="string(.)"/>
        <xsl:attribute name="href" select="if ($prmTopicRefNo gt 0) then concat($href,'_',string($prmTopicRefNo)) else $href"/>
    </xsl:template>

    <!--
     function:	output duplicate topic changing topic/@id
     param:		none
     return:	self and descendant element 
     note:		
     -->
    <xsl:template name="outputDuplicateTopic">
        <xsl:for-each select="$duplicateTopicRefs">
            <xsl:variable name="topicRef" as="element()" select="."/>
            <xsl:variable name="href" as="xs:string" select="string(@href)"/>
            <xsl:variable name="duplicateCount" as="xs:integer" select="count($topicRef|$allTopicRefs[. &lt;&lt; $topicRef][string(@href) eq $href])"/>
            <xsl:variable name="topicContent" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
            <xsl:choose>
                <xsl:when test="empty($topicContent)">
                    <xsl:call-template name="warningContinue">
                        <xsl:with-param name="prmMes" select="ahf:replace($stMes1009,('%href','%xtrf'),(string(@href),string(@xtrf)))"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$topicContent">
                        <xsl:with-param name="prmTopicRefNo" tunnel="yes" select="$duplicateCount"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	Get topic from topicref 
     param:		prmTopicRef
     return:	xs:element?
     note:		
     -->
    <xsl:function name="ahf:getTopicFromTopicRef" as="element()?">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="id" select="substring-after($prmTopicRef/@href, '#')" as="xs:string"/>
        <xsl:variable name="topicContent" select="if (string($id)) then key('topicById', $id, $root)[1] else ()" as="element()?"/>
        <xsl:sequence select="$topicContent"/>
    </xsl:function>
    

    <!--
     function:	topic
     param:		none
     return:	self and descendant element or none
     note:		if @id is pointed from the topicref that has print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' topic/topic ')]">
        <xsl:param name="prmTopicRefNo" required="no" tunnel="yes" as="xs:integer" select="0"/>
        <xsl:variable name="id" as="xs:string" select="concat('#',string(@id))"/>
        <xsl:choose>
            <xsl:when test="exists(index-of($noPrintHrefs,$id)) and empty(index-of($normalHrefs,$id))">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1002,('%id','%xtrf'),(string(@id),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$prmTopicRefNo gt 0">
                <xsl:copy>
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="prmTopicRefNo" select="$prmTopicRefNo"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- template for topic/@id is limited for create new value -->
    <xsl:template match="*[contains(@class,' topic/topic ')]/@id">
        <xsl:param name="prmTopicRefNo" required="no" as="xs:integer" select="0"/>
        <xsl:variable name="id" as="xs:string" select="string(.)"/>
        <xsl:attribute name="id" select="if ($prmTopicRefNo gt 0) then concat($id,'_',string($prmTopicRefNo)) else $id"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/topic ')]/@oid">
        <xsl:param name="prmTopicRefNo" required="no" as="xs:integer" select="0"/>
        <xsl:variable name="oid" as="xs:string" select="string(.)"/>
        <xsl:attribute name="oid" select="if ($prmTopicRefNo gt 0) then concat($oid,'_',string($prmTopicRefNo)) else $oid"/>
    </xsl:template>
    
    <!--
     function:	link
     param:		none
     return:	self and descendant element or none
     note:		if link@href points to the topicref that has print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' topic/link ')]">
        <xsl:param name="prmDitaValFlagStyle" tunnel="yes" required="no" select="''"/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:choose>
            <xsl:when test="exists(index-of($noPrintHrefs,$href)) and empty(index-of($normalHrefs,$href))">
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1003,('%href'),($href))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
     function:	xref
     param:		none
     return:	self and descendant element or none
     note:		if xref@href points to the topic that has print="no", ignore it.
     -->
    <xsl:template match="*[contains(@class,' topic/xref ')][string(@format) eq 'dita']">
        <xsl:param name="prmTopicRefNo" required="no" tunnel="yes" as="xs:integer" select="0"/>
        <xsl:variable name="xref" as="element()" select="."/>
        <xsl:variable name="href" as="xs:string" select="string(@href)"/>
        <xsl:variable name="isLocalHref" as="xs:boolean" select="starts-with($href,'#')"/>
        <xsl:variable name="refTopicHref" as="xs:string">
            <xsl:choose>
                <xsl:when test="$isLocalHref">
                    <xsl:choose>
                        <xsl:when test="contains($href,'/')">
                            <xsl:sequence select="substring-before($href,'/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="string($refTopicHref) and exists(index-of($noPrintHrefs,$refTopicHref)) and empty(index-of($normalHrefs,$refTopicHref))" >
            <xsl:message select="'[convmerged 1004W] Warning! Xref refers to removed topic. href=',string(@href)"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$isLocalHref and ($prmTopicRefNo gt 0)">
                <xsl:variable name="refTopicId" as="xs:string" select="substring-after($refTopicHref,'#')"/>
                <xsl:variable name="refElemId" as="xs:string" select="if (contains($href,'/')) then substring-after($href,'/') else ''"/>
                <xsl:variable name="topIds" as="xs:string+" select="for $id in $xref/ancestor::*[contains(@class,' topic/topic ')][last()]/descendant-or-self::*[contains(@class,' topic/topic ')]/@id return string($id)"/>
                <xsl:choose>
                    <xsl:when test="exists($topIds[. eq $refTopicId])">
                        <xsl:copy>
                            <xsl:apply-templates select="@*">
                                <xsl:with-param name="prmNewXrefHref">
                                    <xsl:choose>
                                        <xsl:when test="string($refElemId)">
                                            <xsl:sequence select="concat($refTopicHref,'_',string($prmTopicRefNo),'/',$refElemId)"/>        
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="concat($refTopicHref,'_',string($prmTopicRefNo))"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:apply-templates>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/xref ')]/@href">
        <xsl:param name="prmNewXrefHref" required="no" as="xs:string" select="''"/>
        <xsl:choose>
            <xsl:when test="string($prmNewXrefHref)">
                <xsl:attribute name="href" select="$prmNewXrefHref"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	comment template
     param:		none
     return:	comment or empty
     note:		none
     -->
    <xsl:template match="comment()[ancestor::*[contains(@class,' topic/topic ')]]"/>

    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
    
    <!-- 
     function:	processing-instruction template
     param:		none
     return:	processing-instruction or empty
     note:		
     -->
    <xsl:template match="processing-instruction()[ancestor::*[contains(@class,' topic/topic ')]]"/>
    
    <xsl:template match="processing-instruction()">
        <xsl:copy/>
    </xsl:template>

    <!-- 
     function:	required-cleanup template
     param:		none
     return:	none or itself 
     note:		If not output required-cleanup, remove it at this template.
     -->
    <xsl:template match="*[contains(@class,' topic/required-cleanup ')][not($pOutputRequiredCleanup)]"/>
    
    <!-- 
     function:	draft-comment template
     param:		none
     return:	none or itself 
     note:		If not output draft-comment, remove it at this template.
     -->
    <xsl:template match="*[contains(@class,' topic/draft-comment ')][not($pOutputDraftComment)]"/>

</xsl:stylesheet>

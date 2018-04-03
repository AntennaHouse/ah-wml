<?xml version="1.0" encoding="UTF-8"?>
<!--
****************************************************************
DITA to WordprocessingML Stylesheet
Module: Making docProps/custom.xml main stylesheet.
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
    exclude-result-prefixes="xs"
    version="3.0">

    <!-- Set only dummy entry -->
    <xsl:template match="/">
        <Properties/>
    </xsl:template>

</xsl:stylesheet>
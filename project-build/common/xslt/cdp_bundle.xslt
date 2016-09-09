<?xml version="1.0" standalone="yes"?> 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xslt="http://xml.apache.org/xslt">
	<!-- Get params from ANT -->
	<xsl:param name="cdp_dir"/>

	<xsl:import href="bundle_include.xslt"/>
	
	<xsl:output method="xml" encoding="UTF-8" indent="yes" xslt:indent-amount="4"/>
	
	<!--  Find matching nested <bundle><cdp> tags -->
	<xsl:template match="bundle">
		<xsl:element name="bundle">
		
			<xsl:call-template name="header"/>

			<xsl:element name="monitors">
				<xsl:element name="fileset">
					<xsl:apply-templates select="cdp"/>
				</xsl:element>
			</xsl:element>

			<xsl:apply-templates select="block-catalogs"/>
			<xsl:apply-templates select="function-catalogs"/>
			<xsl:apply-templates select="dashboard-files"/>
			<xsl:apply-templates select="events"/>
			<xsl:apply-templates select="dependencies"/>

		</xsl:element>
	</xsl:template>

	<!--  The template to use for 'cdp' -->
	<xsl:template match="cdp">
		<!-- Loop through each 'fileset' tag -->
		<xsl:for-each select="fileset">
			<xsl:attribute name="dir"><xsl:value-of select="$cdp_dir"/></xsl:attribute>
			<!-- Loop through each 'include' tag -->
			<xsl:for-each select="include">
				<xsl:element name="include">
					<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
				</xsl:element>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Filter any blank lines -->
	<xsl:template match="text()|@*"/>

</xsl:stylesheet>

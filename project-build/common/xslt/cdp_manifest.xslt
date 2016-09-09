<?xml version="1.0" standalone="yes"?> 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Get params from ANT -->
	<xsl:param name="ext"/>
	<xsl:param name="dir_prefix"/>
	
	<xsl:output omit-xml-declaration="yes" method="text" indent="no"/>
	<xsl:strip-space elements="*"/>
	
	<!--  Find matching nested <bundle><source> tags -->
	<xsl:apply-templates select="/bundle/source"/>

	<!--  The template to use for 'source' -->
	<xsl:template match="source">
		<!-- Pull out the variables from the 'source' tag -->
		<xsl:variable name="sourcepath" select="../@dir"/>
		<xsl:variable name="extension" select="@ext"/>
		
		<!-- Match the ext to the variable extension-->
		<xsl:choose>
			<xsl:when test="$ext = $extension">
				<!-- Loop through each 'fileset' tag -->
				<xsl:for-each select="fileset">
					<xsl:variable name="dir" select="@dir"/>

					<!-- Loop through each 'include' tag -->
					<xsl:for-each select="include">
						<!-- Output source path with '../' removed and EOL -->
						<xsl:value-of select="concat($dir_prefix, substring-after($sourcepath, '../'), '/', $dir, '/', @name)"/><xsl:text>&#10;</xsl:text>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Filter any blank lines -->
	<xsl:template match="text()|@*"/>

</xsl:stylesheet>

<?xml version="1.0" standalone="yes"?> 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xslt="http://xml.apache.org/xslt">
	<xsl:param name="macro_dir"/>

	<!--  The template to use for 'header' -->
	<xsl:template name="header">
		<xsl:comment><xsl:value-of select="concat(' ', @name, ' Bundle ')"/></xsl:comment>
		<xsl:text>&#10;</xsl:text>
		<xsl:if test="@macro">
			<xsl:element name="target">
				<xsl:attribute name="name"><xsl:value-of select="@macro"/></xsl:attribute>
				<xsl:attribute name="depends"><xsl:value-of select="@depends"/></xsl:attribute>
			</xsl:element>
			<xsl:text>&#10;&#10;</xsl:text>
		</xsl:if>
	</xsl:template>

	<!--  The template to use for 'macros' -->
	<xsl:template match="macros">
		<xsl:param name="macro_name"/>
		<!-- Loop through each 'macro' tag -->
		<xsl:for-each select="macro">
			<xsl:choose>
				<xsl:when test="@name = $macro_name">
					<xsl:if test="@unless">
						<xsl:attribute name="unless"><xsl:value-of select="@unless"/></xsl:attribute>
					</xsl:if>
					<xsl:attribute name="depends">
						<xsl:for-each select="depends">
							<xsl:value-of select="@name"/>
							<xsl:if test="position() != last()">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>

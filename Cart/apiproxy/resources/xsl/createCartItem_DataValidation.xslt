<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="cartId"/>
    <xsl:param name="authfinancialaccountid"/>
    <xsl:param name="tokenScope"/>

    <xsl:template match="/">
        <xsl:variable name="actionCode" select="/cart/@actionCode"/>
        <xsl:variable name="orderType" select="/cart/orderType"/>

        <apiError>
            <statusCode>
                <xsl:value-of select="&quot;400&quot;"/>
            </statusCode>
            <reasonPhrase>
                <xsl:value-of select="&quot;Bad Request&quot;"/>
            </reasonPhrase>
            <errors>
                <xsl:choose>
                    <xsl:when test="string-length($cartId) = 0">
                        <error>
                            <code>
                                <xsl:value-of select="&quot;GENERAL-0001&quot;"/>
                            </code>
                            <userMessage>
                                <xsl:value-of select="&quot;Input Data Invalid&quot;"/>
                            </userMessage>
                            <systemMessage>
                                <xsl:value-of
                                    select="&quot;The Cart ID is missing in path param&quot;"/>
                            </systemMessage>
                        </error>
                    </xsl:when>

                    <xsl:when test="matches($cartId, '[^a-zA-Z0-9]')">
                        <error>
                            <code>
                                <xsl:value-of select="&quot;GENERAL-0001&quot;"/>
                            </code>
                            <userMessage>
                                <xsl:value-of select="&quot;Input Data Invalid&quot;"/>
                            </userMessage>
                            <systemMessage>
                                <xsl:value-of
                                    select="&quot;Only letters and numbers are allowed for CartID&quot;"
                                />
                            </systemMessage>
                        </error>
                    </xsl:when>

                    <xsl:when
                        test="
                            not(contains($actionCode, 'SAVE') or contains($actionCode, 'REMOVE') or contains($actionCode, 'CHANGE')
                            or contains($actionCode, 'REVIEW') or contains($actionCode, 'CHECKOUT') or contains($actionCode, 'EXISTING') or contains($actionCode, 'ADD'))">
                        <error>
                            <code>
                                <xsl:value-of select="&quot;GENERAL-0001&quot;"/>
                            </code>
                            <userMessage>
                                <xsl:value-of select="&quot;Input Data Invalid&quot;"/>
                            </userMessage>
                            <systemMessage>
                                <xsl:value-of select="&quot;Invalid actionCode&quot;"/>
                            </systemMessage>
                        </error>
                    </xsl:when>

                    <xsl:when test="string-length($orderType) = 0">
                        <error>
                            <code>
                                <xsl:value-of select="&quot;GENERAL-0001&quot;"/>
                            </code>
                            <userMessage>
                                <xsl:value-of select="&quot;Input Data Invalid&quot;"/>
                            </userMessage>
                            <systemMessage>
                                <xsl:value-of select="&quot;actionCode is invalid&quot;"/>
                            </systemMessage>
                        </error>
                    </xsl:when>
                    <xsl:when test="$tokenScope = 'logged-in' and $authfinancialaccountid != ''">
                        <xsl:variable name="fanNumber1">
                            <xsl:for-each
                                select="/cart/cartItem[financialAccount/financialAccountNumber != '']">
                                <xsl:choose>
                                    <xsl:when
                                        test="$authfinancialaccountid = financialAccount/financialAccountNumber/text()">
                                        <xsl:value-of select="'true'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'false'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="fanNumber2">
                            <xsl:choose>
                                <xsl:when test="contains($fanNumber1, 'true')">
                                    <xsl:value-of select="$fanNumber1"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each
                                        select="/cart/cartItem[lineOfService/financialAccountNumber != '']">
                                        <xsl:choose>
                                            <xsl:when
                                                test="$authfinancialaccountid = lineOfService/financialAccountNumber/text()">
                                                <xsl:value-of select="'true'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'false'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:if
                            test="($fanNumber2 != '' or $fanNumber1 != '') and not(contains($fanNumber2,'true'))">
                            <error>
                                <code>
                                    <xsl:value-of select="&quot;SECURITY-0054&quot;"/>
                                </code>
                                <userMessage>
                                    <xsl:value-of
                                        select="&quot;Insufficient permission on the requested Financial Account&quot;"
                                    />
                                </userMessage>
                                <systemMessage>
                                    <xsl:value-of
                                        select="&quot;Insufficient permission on the requested Financial Account&quot;"
                                    />
                                </systemMessage>
                            </error>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </errors>
        </apiError>
    </xsl:template>

</xsl:stylesheet>

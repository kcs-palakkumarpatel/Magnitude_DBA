-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <12 Sep 2016>
-- Description:	<Check Uniq and Common Keyword with GroupKeyword>
-- =============================================
CREATE PROCEDURE [dbo].[IsUniqAndCommonKeywordExists]
    @Id BIGINT ,
    @UniqSMSKeyword NVARCHAR(50) ,
    @IsUniq BIT
AS

    BEGIN
	    IF ( @IsUniq = 1 )
            BEGIN
                SELECT  E.UniqueSMSKeyword ,
                        E.CommonSMSKeyword ,
                        G.GroupKeyword
                FROM    dbo.Establishment E
                        INNER JOIN dbo.[Group] G ON G.Id = E.GroupId
                WHERE   E.Id != @Id
                        AND ( E.UniqueSMSKeyword = @UniqSMSKeyword
                              OR G.GroupKeyword = @UniqSMSKeyword
                            )
                        AND E.IsDeleted = 0
                        AND G.IsDeleted = 0;
            END;
        ELSE
            BEGIN
                SELECT  E.UniqueSMSKeyword ,
                        E.CommonSMSKeyword ,
                        G.GroupKeyword
                FROM    dbo.Establishment E
                        INNER JOIN dbo.[Group] G ON G.Id = E.GroupId
                WHERE   E.Id != @Id
                        AND G.GroupKeyword = @UniqSMSKeyword 
                        AND E.IsDeleted = 0
                        AND G.IsDeleted = 0;
            END;
                
    END;
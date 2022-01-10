-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <08 Sep 2016>
-- Description:	<Check Key word exist or not>
-- Call: IskeywordExist 'test'
-- =============================================
CREATE PROCEDURE [dbo].[IskeywordExist] 
	@Keyword NVARCHAR(50),
	@Id BIGINT
AS
    BEGIN
        SELECT  1 AS Keyword
        FROM    dbo.[Group]
        WHERE   groupkeyword = @Keyword AND id != @Id
        UNION
        SELECT  1 AS Keyword
        FROM    dbo.Establishment
        WHERE   UniqueSMSKeyword = @Keyword
        UNION
        SELECT  1 AS Keyword
        FROM    dbo.Establishment
        WHERE   CommonSMSKeyword = @Keyword;
    END;
-- =============================================
-- Author:      <Author, , Anant>
-- Create Date: <Create Date, , 02 jul-2019>
-- Description: <Description, , get Database refernce option List >
-- =============================================
/*
drop procedure GetDatabaseReferenceOptionListOfflineafterAddNewoption_101120

EXEC GetDatabaseReferenceOptionListOfflineafterAddNewoption_101120 20573,'1970-01-01 00:00:00',1
*/
CREATE PROCEDURE [dbo].[GetDatabaseReferenceOptionListOfflineafterAddNewoption_101120]
	@QuestionsId BIGINT,
	@Datetime NVARCHAR(MAX),
	@IsMobi BIT
AS
BEGIN
    IF (@IsMobi = 0)
    BEGIN
        SELECT Id, RTRIM(LTRIM(Name)) AS OptionName
        FROM dbo.SeenClientOptions
        WHERE QuestionId = @QuestionsId
        AND IsDeleted = 0
        ORDER BY Id ASC;
    END;
    ELSE
    BEGIN
        SELECT Id, RTRIM(LTRIM(Name)) AS OptionName
        FROM dbo.Options
        WHERE QuestionId = @QuestionsId
        AND IsDeleted = 0
        ORDER BY Id ASC;
    END;
END;


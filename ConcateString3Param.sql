-- =============================================    
-- Author:  <Disha>    
-- Create date: <13-SEP-2014>    
-- Description: <get concated string values>    
-- Calls :select dbo.ConcateString3Param ('ContactGroupDetail',4600, 467,'226263,226265,226266,4538,4539,4541,4542,4598,4599')   
-- =============================================    
CREATE FUNCTION [dbo].[ConcateString3Param]
(
    @Table NVARCHAR(50) = 'SeenClientAnswers',
    @ContactMasterId BIGINT,
    @ContactQuestionId BIGINT,
    @ContactMasterIdList NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @listStr NVARCHAR(MAX);
    DECLARE @AppndChars NVARCHAR(10);
    DECLARE @NewLineChar AS CHAR(2);
    DECLARE @listStrQuestion NVARCHAR(MAX);

    SET @NewLineChar = CHAR(13) + CHAR(10);
    SET @AppndChars = '\n';

    IF (@Table = 'ContactGroupDetail')
    BEGIN


        IF NOT EXISTS
        (
            SELECT *
            FROM ContactDetails
            WHERE ContactQuestionId = @ContactQuestionId
        )
        BEGIN
		
            SELECT @listStr =
            (
                SELECT TOP 1
                    Detail
                FROM dbo.SeenClientAnswers
                WHERE SeenClientAnswerMasterId = @ContactMasterId
                      AND QuestionId = @ContactQuestionId
            );
        END;
        ELSE
		
            SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(Detail, ''))
            FROM
            (
                SELECT Detail,
                       Cq.Position
                FROM dbo.ContactDetails AS Cd
                    INNER JOIN dbo.ContactQuestions AS Cq
                        ON Cd.ContactQuestionId = Cq.Id
                    LEFT JOIN dbo.ContactGroupRelation Cgr
                        ON Cgr.ContactMasterId = Cd.ContactMasterId
                    INNER JOIN
                    (SELECT Data FROM dbo.Split(@ContactMasterIdList, ',') ) AS R
                        ON R.Data = Cgr.ContactMasterId
                WHERE Cgr.ContactGroupId = @ContactMasterId
                      AND Cd.IsDeleted = 0
                      AND Cq.IsDeleted = 0
                      AND Cd.ContactQuestionId = @ContactQuestionId
                      AND Cgr.IsDeleted = 0
            ) AS R
            ORDER BY R.Position;
    END;
    RETURN ISNULL(@listStr, '');
END;

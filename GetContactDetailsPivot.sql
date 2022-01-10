-- =============================================
-- Author:		<Author,,Anant Bhatt>
-- Create date: <Create Date,, 15 may 2018>
-- Description:	<Description,,GetContactDetails>
-- Call SP    :	GetContactDetailsPivot 3929
-- =============================================
CREATE PROCEDURE [dbo].[GetContactDetailsPivot] @ContactMasterId BIGINT
AS
DECLARE @MasterIdByGroupContact NVARCHAR(MAX);

SELECT @MasterIdByGroupContact = COALESCE(@MasterIdByGroupContact, '') + CAST(ContactMasterId AS NVARCHAR(MAX)) + ','
FROM dbo.ContactGroupRelation
WHERE ContactGroupId = @ContactMasterId;

IF @MasterIdByGroupContact != ''
BEGIN

    SELECT ContactMasterId,
           [Name],
           Cell,
           Email
    FROM
    (
        SELECT CD.[ContactMasterId] AS ContactMasterId,
               CD.[Detail] AS Details,
               CQ.QuestionTitle
        FROM dbo.[ContactDetails] CD
            LEFT JOIN dbo.ContactQuestions CQ
                ON CD.ContactQuestionId = CQ.Id
                   AND CQ.IsDeleted = 0
        WHERE CD.IsDeleted = 0
              AND CD.ContactMasterId IN (
                                            SELECT Data FROM dbo.Split(@MasterIdByGroupContact, ',')
                                        )
    ) up
    PIVOT
    (
        MAX(Details)
        FOR QuestionTitle IN ([Name], Cell, Email)
    ) AS pvt
    ORDER BY ContactMasterId;


END;
ELSE
BEGIN
    SELECT ContactMasterId,
           [Name],
           Cell,
           Email
    FROM
    (
        SELECT CD.[ContactMasterId] AS ContactMasterId,
               CD.[Detail] AS Details,
               CQ.QuestionTitle
        FROM dbo.[ContactDetails] CD
            LEFT JOIN dbo.ContactQuestions CQ
                ON CD.ContactQuestionId = CQ.Id
                   AND CQ.IsDeleted = 0
        WHERE CD.IsDeleted = 0
              AND ContactMasterId = @ContactMasterId
    --ORDER BY ContactMasterId 
    ) up
    PIVOT
    (
        MAX(Details)
        FOR QuestionTitle IN ([Name], Cell, Email)
    ) AS pvt
    ORDER BY ContactMasterId;
END;

-- =============================================
-- Author:		<Author,,Anant Bhatt>
-- Create date: <Create Date,, 15 may 2018>
-- Description:	<Description,,GetContactDetails>
-- Call SP    :	GetContactDetails 736
-- =============================================
CREATE PROCEDURE [dbo].[GetContactDetails]
    @ContactMasterId BIGINT
AS
    DECLARE @MasterIdByGroupContact NVARCHAR(MAX);

    SELECT  @MasterIdByGroupContact = COALESCE(@MasterIdByGroupContact, '')
            + CAST(ContactMasterId AS NVARCHAR(MAX)) + ','
    FROM    dbo.ContactGroupRelation
    WHERE   ContactGroupId = @ContactMasterId;

    IF @MasterIdByGroupContact != ''
        BEGIN
            SELECT  dbo.[ContactDetails].[Id] AS Id ,
                    dbo.[ContactDetails].[ContactMasterId] AS ContactMasterId ,
                    dbo.[ContactDetails].[ContactQuestionId] AS ContactQuestionId ,
                    dbo.[ContactDetails].[QuestionTypeId] AS QuestionTypeId ,
                    dbo.[ContactDetails].[Detail] AS Details
            FROM    dbo.[ContactDetails]
            WHERE   dbo.[ContactDetails].IsDeleted = 0
                    AND dbo.[ContactDetails].ContactMasterId IN(SELECT Data FROM dbo.Split(@MasterIdByGroupContact,','))
            ORDER BY Id;
        END;
	ELSE
    BEGIN
        SELECT  dbo.[ContactDetails].[Id] AS Id ,
                dbo.[ContactDetails].[ContactMasterId] AS ContactMasterId ,
                dbo.[ContactDetails].[ContactQuestionId] AS ContactQuestionId ,
                dbo.[ContactDetails].[QuestionTypeId] AS QuestionTypeId ,
                dbo.[ContactDetails].[Detail] AS Details
        FROM    dbo.[ContactDetails]
        WHERE   dbo.[ContactDetails].IsDeleted = 0
                AND ContactMasterId = @ContactMasterId
        ORDER BY Id;
    END;

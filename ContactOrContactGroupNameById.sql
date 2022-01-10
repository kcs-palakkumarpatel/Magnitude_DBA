-- =============================================      
-- Author:			Sunil Vaghasiya
-- Create date:		23-JUNE-2017      
-- Description:		Get Contact Name Or ContactGroupName By ContactMasterId or ContactGroupId
-- Calls :				SELECT dbo.ContactOrContactGroupNameById(132)
-- =============================================      
CREATE FUNCTION [dbo].[ContactOrContactGroupNameById] ( @ReportId BIGINT )
RETURNS NVARCHAR(500)
AS
    BEGIN      
        DECLARE @listStr NVARCHAR(500) ,
            @MasterId BIGINT ,
            @IsGroup BIT;

        SELECT  @IsGroup = IsSubmittedForGroup ,
                @MasterId = ( CASE WHEN IsSubmittedForGroup = 1 THEN ContactGroupId ELSE ContactMasterId END )
        FROM    dbo.SeenClientAnswerMaster
        WHERE   Id = @ReportId;

        IF @IsGroup = 1
            BEGIN
                SELECT TOP 1
                        @listStr = ContactGropName
                FROM    dbo.ContactGroup
                WHERE   Id = @MasterId;
            END;
        ELSE
            BEGIN
                SELECT TOP 1
                        @listStr = CONVERT(NVARCHAR(100), ISNULL(Detail, ''))
                FROM    dbo.ContactDetails AS Cd
                        INNER JOIN dbo.ContactQuestions AS Cq ON Cd.ContactQuestionId = Cq.Id
                WHERE   ContactMasterId = @MasterId
                        AND Cd.IsDeleted = 0
                        AND Cq.IsDeleted = 0
                        AND IsDisplayInSummary = 1
                        AND Detail <> ''
                ORDER BY Cq.Position ASC;
            END;

        RETURN  ISNULL(@listStr, '');  
    END;

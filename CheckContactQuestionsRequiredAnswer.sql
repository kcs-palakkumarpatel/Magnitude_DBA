﻿-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	30-Mar-2017
-- Description:	
-- Call:					dbo.CheckContactQuestionsRequiredAnswer 330, 464, 1
-- =============================================
CREATE PROCEDURE [dbo].[CheckContactQuestionsRequiredAnswer]
    @SeenClientId BIGINT ,
    @ContactMasterId BIGINT ,
    @IsContactGroup BIT
AS
    BEGIN
	DECLARE     @ActivityId BIGINT ;
	SELECT @ActivityId=Id FROM dbo.EstablishmentGroup WHERE SeenClientId=@SeenClientId AND IsDeleted = 0

   IF @IsContactGroup = 1
            BEGIN

SELECT  CD.ContactMasterId AS ContactMasterId ,
        CQ.QuestionTitle AS QuestionTitle ,
        ISNULL(CD.Detail, '') AS Answer
FROM    dbo.ContactQuestions AS CQ
        LEFT JOIN dbo.ContactDetails AS CD ON CD.ContactQuestionId = CQ.Id
WHERE   CD.ContactMasterId IN ( SELECT  ContactMasterId FROM    dbo.ContactGroupRelation WHERE   ContactGroupId = @ContactMasterId AND IsDeleted = 0 )
        AND CQ.IsDeleted = 0
        AND CQ.[Required] = 1
        AND CQ.Id IN ( SELECT   Data FROM     dbo.Split(( SELECT  ContactQuestion FROM    dbo.EstablishmentGroup WHERE   Id = @ActivityId ), ',') )
ORDER BY Position;

            END;
        ELSE
            BEGIN

SELECT  CD.ContactMasterId AS ContactMasterId ,
        CQ.QuestionTitle AS QuestionTitle ,
        ISNULL(CD.Detail, '') AS Answer
FROM    dbo.ContactQuestions AS CQ
        LEFT JOIN dbo.ContactDetails AS CD ON CD.ContactQuestionId = CQ.Id AND CD.ContactMasterId = @ContactMasterId
WHERE   CQ.IsDeleted = 0
AND CQ.[Required] = 1
        AND CQ.Id IN ( SELECT   Data FROM     dbo.Split(( SELECT  ContactQuestion FROM    dbo.EstablishmentGroup WHERE   Id = @ActivityId ), ',') )
ORDER BY Position;
    END
    END;


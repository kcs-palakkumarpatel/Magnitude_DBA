-- =============================================
-- Author:			D3
-- Create date:	18-Oct-2017
-- Description:	
-- Call:					dbo.CheckContactInformationCorrect 330, 464, 1
-- =============================================
CREATE PROCEDURE [dbo].[CheckContactInformationCorrect]
    @ActivityId BIGINT ,
    @ContactMasterId BIGINT ,
    @HasContactGroup BIT = 0
AS
    BEGIN
	DECLARE @DataTable TABLE
            (
				ContactMasterId BIGINT NULL ,
              ContactQuestionId BIGINT NULL ,
              ContactDetailContactQuestionId BIGINT NULL
            );

	IF @HasContactGroup = 1
	BEGIN
	
		INSERT INTO @DataTable ( ContactMasterId,  ContactQuestionId , ContactDetailContactQuestionId )
    SELECT DISTINCT
            Z.* ,
            X.Id AS ContactDetailId
    FROM    ( SELECT    CD.ContactMasterId ,
                        Q.Id AS ContactQuestionId
              FROM      ( SELECT    CAST(Data AS BIGINT) AS Id
                          FROM      dbo.Split(( SELECT  ContactQuestion
                                                FROM    dbo.EstablishmentGroup
                                                WHERE   Id = @ActivityId
                                              ), ',') Z
                        ) Q
                        CROSS JOIN dbo.ContactDetails CD
              WHERE     ContactMasterId IN ( SELECT  ContactMasterId  FROM dbo.ContactGroupRelation WHERE ContactGroupId=@ContactMasterId AND IsDeleted=0 )
            ) Z
            LEFT JOIN ( SELECT  CD.Id ,
                                CD.ContactMasterId ,
                                CD.ContactQuestionId
                        FROM    dbo.ContactDetails CD
                        WHERE   ContactMasterId IN ( SELECT  ContactMasterId  FROM dbo.ContactGroupRelation WHERE ContactGroupId=@ContactMasterId AND IsDeleted=0 )
                      ) X ON X.ContactMasterId = Z.ContactMasterId
                             AND X.ContactQuestionId = Z.ContactQuestionId
    ORDER BY Z.ContactMasterId;
	END
ELSE
	BEGIN
			INSERT INTO @DataTable ( ContactMasterId, ContactQuestionId , ContactDetailContactQuestionId )
			SELECT  @ContactMasterId, CQ.Id, CD.ContactQuestionId FROM dbo.ContactQuestions	AS CQ
				LEFT JOIN dbo.ContactDetails AS CD ON CD.ContactQuestionId  = CQ.Id AND CD.ContactMasterId = @ContactMasterId
				WHERE   CQ.IsDeleted = 0 AND CQ.Id IN (SELECT  Data FROM dbo.Split((SELECT  ContactQuestion FROM dbo.EstablishmentGroup WHERE Id=@ActivityId), ',')) ORDER BY Position;
	END;
		
		SELECT * FROM @DataTable ORDER BY ContactMasterId ASC
    END;

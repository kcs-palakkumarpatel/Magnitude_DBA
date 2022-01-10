--GetDefaultContactActivities_palak 651, 18484 
CREATE PROCEDURE dbo.GetDefaultContactActivities
    @GroupId BIGINT ,
    @AppUserId BIGINT
AS
    BEGIN
        
IF OBJECT_ID('dbo.TEST_ACTIVITY', 'U') IS NOT NULL  
  DROP TABLE dbo.TEST_ACTIVITY;  

CREATE TABLE dbo.TEST_ACTIVITY
(
DefaultContactId BIGINT,
ContactMasterId BIGINT,
ContactName NVARCHAR(255),
ActivityId BIGINT,
ActivityName NVARCHAR(100),
CreatedOn DATETIME
);
INSERT INTO TEST_ACTIVITY
        SELECT  
	          DISTINCT
				ISNULL(DC.Id, 0) AS DefaultContactId ,
				ISNULL(DC.ContactId, 0) AS ContactMasterId ,
				CASE WHEN DC.IsGroup = 1
				THEN
				(SELECT ContactGropName FROM dbo.ContactGroup WHERE Id=DC.ContactId)
				ELSE
               ISNULL((STUFF(( SELECT    ',' + CD.Detail
                                      FROM      dbo.ContactDetails AS CD
                                                INNER JOIN dbo.ContactQuestions
                                                AS CQ ON CQ.Id = CD.ContactQuestionId
                                      WHERE     CD.ContactMasterId =  DC.ContactId
                                                AND CQ.ContactId = GP.ContactId
                                                AND CQ.IsDeleted = 0
                                                AND CQ.IsDisplayInSummary = 1
                                      ORDER BY  CQ.Position ASC
                                    FOR
                                      XML PATH('')
                                    ), 1, 1, '') ), '')
				END
				 AS ContactName ,
				ISNULL( EG.Id , 0)AS ActivityId ,
                ISNULL(EG.EstablishmentGroupName, '') AS ActivityName,
				DC.CreatedOn
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS EG ON E.EstablishmentGroupId = EG.Id
				INNER JOIN dbo.[Group]	AS GP ON GP.Id = E.GroupId AND GP.Id = EG.GroupId
                LEFT JOIN dbo.DefaultContact AS DC ON EG.Id = DC.ActivityId AND DC.AppUserId = @AppUserId AND DC.IsDeleted = 0 --AND Dc.CreatedBy = @AppUserId
        WHERE  
		 EG.GroupId = @GroupId
		 AND GP.Id = @GroupId
                AND EG.EstablishmentGroupType = 'Sales'
                AND EG.IsDeleted = 0
                AND UE.AppUserId = @AppUserId
                AND UE.IsDeleted = 0
    

	
	SELECT * FROM dbo.VW_TEST_ACTIVITY

END;

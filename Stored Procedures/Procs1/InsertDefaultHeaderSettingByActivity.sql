-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 19 Dec 2016>
-- Description:	<Description,,>
-- Call SP    :		dbo.InsertDefaultHeaderSettingByActivity
-- =============================================
CREATE PROCEDURE dbo.InsertDefaultHeaderSettingByActivity
    @GroupId BIGINT ,
    @UserId BIGINT
AS
    BEGIN	        IF @GroupId > 0
            AND @GroupId IS NOT NULL
            BEGIN
                INSERT  INTO dbo.HeaderSetting
                        ( GroupId ,
                          EstablishmentGroupId ,
                          HeaderId ,
                          HeaderName ,
                          HeaderValue ,
                          CreatedOn ,
                          CreatedBy 
                        )
                        SELECT  EG.GroupId ,
                                EG.Id AS ActivityId ,
                                WAH.Id AS HeaderId ,
                                LabelName AS HeaderName ,
                                CASE WHEN LabelName = 'OUT Form Section'
                                     THEN 'OUT'
                                     WHEN LabelName = 'IN Form Section'
                                     THEN 'IN'
									 WHEN LabelName = 'Action Screen'
                                     THEN 'Action'
									 WHEN LabelName = 'Map Screen'
                                     THEN 'Map'
									 WHEN LabelName = 'Select Establishment'
                                     THEN 'Establishment'
									 WHEN LabelName = 'Select User'
                                     THEN 'User'
                                     ELSE LabelName
                                END AS HeaderValue ,
                                GETDATE() AS CreatedOn ,
                                @UserId AS CreatedBy
                        FROM    dbo.WebAppHeaders AS WAH
                                INNER JOIN dbo.EstablishmentGroup AS EG ON EG.GroupId = @GroupId
                        WHERE   WAH.IsDeleted = 0
                                AND EG.IsDeleted = 0
                        ORDER BY EG.Id ,
                                WAH.Id ASC;

---------------------------------------------------------------------------------------------------------------------------------------------
                SELECT  SCOPE_IDENTITY() AS InsertedId;                INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted
                        )
                VALUES  ( @UserId ,
                          40 ,
                          'Insert record in table HeaderSetting' ,
                          'HeaderSetting' ,
                          1 ,
                          GETDATE() ,
                          @UserId ,
                          0
                        );
            END;    END;

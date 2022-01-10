
/****** Object:  StoredProcedure [dbo].[SearchEstablishment]    Script Date: 28-10-2016 11:42:14 ******/

/*
 =============================================
 Author:		Disha Patel
 Create date: 28-OCT-2016
 Description:	Get all establishments by ActivityId
 Call SP    :	SearchEstablishmentsByActivityId '','EstablishmentName ASC','1948,1947'
 =============================================
*/

CREATE PROCEDURE [dbo].[SearchEstablishmentsByActivityId]
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
    @ActivityId NVARCHAR(2000)
AS
    BEGIN
        SET NOCOUNT ON
        SELECT  Id ,
                EstablishmentName ,
                ActivityType
        FROM    ( SELECT    E.[Id] AS Id ,
                            E.[EstablishmentName] AS EstablishmentName ,
                            EG.EstablishmentGroupType AS ActivityType ,
                            ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'EstablishmentName ASC'
                                                              THEN E.[EstablishmentName]
                                                         END ASC, CASE
                                                              WHEN @Sort = 'EstablishmentName DESC'
                                                              THEN E.[EstablishmentName]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'ActivityType ASC'
                                                              THEN EG.EstablishmentGroupType
                                                              END ASC, CASE
                                                              WHEN @Sort = 'ActivityType DESC'
                                                              THEN EG.EstablishmentGroupType
                                                              END DESC ) AS RowNum
                  FROM      dbo.Establishment E
                            INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
                            INNER JOIN dbo.Split(@ActivityId, ',') S ON S.Data = E.EstablishmentGroupId
                  WHERE     E.IsDeleted = 0
                            AND ( E.EstablishmentName LIKE '%' + @Search + '%' )
                ) AS T
        ORDER BY T.RowNum ASC
        SET NOCOUNT OFF
    END;
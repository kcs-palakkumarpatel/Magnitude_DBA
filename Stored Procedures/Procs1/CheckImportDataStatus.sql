
CREATE PROCEDURE [dbo].[CheckImportDataStatus]
AS
    BEGIN
        SET NOCOUNT ON;
        IF NOT EXISTS ( SELECT  1
                        FROM    dbo.Scheduler
                        WHERE   IsRunning = 1 )
            BEGIN

                UPDATE  dbo.Scheduler
                SET     IsRunning = 1
                WHERE   Id = ( SELECT TOP 1
                                        Id
                               FROM     dbo.Scheduler
                               WHERE    IsRunning = 0
                                        AND ( GETDATE() BETWEEN StartTime AND EndTime )
                                        AND ( ( LastRunTime IS NULL )
                                              OR GETDATE() > ( CASE
                                                              WHEN IntervalType = 'Minutes'
                                                              THEN ( DATEADD(MINUTE,
                                                              Interval,
                                                              LastRunTime) )
                                                              ELSE ( DATEADD(HOUR,
                                                              Interval,
                                                              LastRunTime) )
                                                              END )
                                            )
                             ); -- Where condition is remaining, this is only for testing purpose.

                SELECT  CM.* ,
                        db.DatabaseTypeId ,
                        db.ConnectionString
                FROM    dbo.ColumnMapping AS CM
                        INNER JOIN dbo.DatabaseConnection AS db ON CM.DbConnectionId = db.Id
                WHERE   CM.Id = ( SELECT TOP 1
                                            MappingId
                                  FROM      dbo.Scheduler
                                  WHERE     IsRunning = 1
                                );
            END;
    END;
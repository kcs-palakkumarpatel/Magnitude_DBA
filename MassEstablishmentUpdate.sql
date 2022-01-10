/*
 =============================================
 Author:		Disha Patel
 Create date: 28-OCT-2016
 Description:	Mass Establishment Update - Update All or Selected Establishments values
 Call SP    :	MassEstablishmentUpdate '12593,12594',2011,'EscalationTime','0',2,40,null,'100:30',null
 =============================================
*/

CREATE PROCEDURE dbo.MassEstablishmentUpdate
    @EstablishmentIds NVARCHAR(MAX),
    @ActivityId BIGINT,
    @FieldName NVARCHAR(100),
    @FieldValue NVARCHAR(MAX),
    @UserId BIGINT,
    @PageId BIGINT,
    @SchedulerTime DATETIME,
    @SchedulerTimeString NVARCHAR(50),
    @SchedulerDay NVARCHAR(10)
AS
BEGIN
    DECLARE @SqlStr NVARCHAR(MAX) = '';
    SELECT CAST(1 AS INT) AS Updated;

    IF (@FieldName = 'CaptureUnallocateNotificationAlert')
    BEGIN
        SET @FieldName = 'CaptureUnallocatedNotificationAlert';
    END;

    IF (@EstablishmentIds = '0')
    BEGIN
        IF (@FieldName = 'SeenClientEscalationTime')
        BEGIN
            SET @SqlStr
                = 'UPDATE Establishment SET ' + @FieldName + ' = ''' + @FieldValue + ''', SeenClientSchedulerTime = '''
                  + CASE
                        WHEN @SchedulerTime IS NULL THEN
                            ''
                        ELSE
                            CAST(@SchedulerTime AS NVARCHAR(50))
                    END + ''' ,
							 SeenClientSchedulerTimeString = ''' + CASE
                                                                       WHEN @SchedulerTimeString IS NULL THEN
                                                                           ''
                                                                       ELSE
                                                                           @SchedulerTimeString
                                                                   END + ''' WHERE EstablishmentGroupId = '
                  + CAST(@ActivityId AS NVARCHAR(20));
        END;
        ELSE IF (@FieldName = 'EscalationTime')
        BEGIN
            SET @SqlStr
                = 'UPDATE Establishment SET ' + @FieldName + ' = ''' + @FieldValue + ''', EscalationSchedulerTime = '''
                  + CASE
                        WHEN @SchedulerTime IS NULL THEN
                            ''
                        ELSE
                            CAST(@SchedulerTime AS NVARCHAR(50))
                    END + ''' ,
								EscalationSchedulerTimeString = ''' + CASE
                                                                          WHEN @SchedulerTimeString IS NULL THEN
                                                                              ''
                                                                          ELSE
                                                                              @SchedulerTimeString
                                                                      END + ''' ,
								EscalationSchedulerDay = ''' + CASE
                                                                   WHEN @SchedulerDay IS NULL THEN
                                                                       ''
                                                                   ELSE
                                                                       @SchedulerDay
                                                               END + ''' WHERE EstablishmentGroupId = '
                  + CAST(@ActivityId AS NVARCHAR(20));
        END;
        ELSE IF (@FieldName = 'OutEscalationTime')
        BEGIN
            SET @SqlStr
                = 'UPDATE Establishment SET ' + @FieldName + ' = ''' + @FieldValue
                  + ''', OutEscalationSchedulerTime = ''' + CASE
                                                                WHEN @SchedulerTime IS NULL THEN
                                                                    ''
                                                                ELSE
                                                                    CAST(@SchedulerTime AS NVARCHAR(50))
                                                            END + ''' ,
								OutEscalationSchedulerTimeString = ''' + CASE
                                                                             WHEN @SchedulerTimeString IS NULL THEN
                                                                                 ''
                                                                             ELSE
                                                                                 @SchedulerTimeString
                                                                         END
                  + ''' ,
								OutEscalationSchedulerDay = ''' + CASE
                                                                      WHEN @SchedulerDay IS NULL THEN
                                                                          ''
                                                                      ELSE
                                                                          @SchedulerDay
                                                                  END + ''' WHERE EstablishmentGroupId = '
                  + CAST(@ActivityId AS NVARCHAR(20));
        END;
        ELSE
        BEGIN
            SET @SqlStr
                = 'UPDATE Establishment SET ' + @FieldName + ' = ''' + @FieldValue + ''' WHERE EstablishmentGroupId = '
                  + CAST(@ActivityId AS NVARCHAR(20));
        END;

        EXECUTE sp_executesql @SqlStr;

        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId,
         @PageId,
         'Update record in table Establishment',
         'Establishment',
         @EstablishmentIds,
         GETUTCDATE(),
         @UserId,
         0
        );
    END;
    ELSE
    BEGIN
        IF (@FieldName = 'SeenClientEscalationTime')
        BEGIN
            SET @SqlStr
                = 'UPDATE E SET ' + @FieldName + ' = ''' + @FieldValue + ''', SeenClientSchedulerTime = '''
                  + CASE
                        WHEN @SchedulerTime IS NULL THEN
                            ''
                        ELSE
                            CAST(@SchedulerTime AS NVARCHAR(50))
                    END + ''' ,
							 SeenClientSchedulerTimeString = ''' + CASE
                                                                       WHEN @SchedulerTimeString IS NULL THEN
                                                                           ''
                                                                       ELSE
                                                                           @SchedulerTimeString
                                                                   END
                  + ''' FROM Establishment E INNER JOIN dbo.Split(''' + @EstablishmentIds
                  + ''','','') S ON S.Data = E.Id';
        END;
        ELSE IF (@FieldName = 'EscalationTime')
        BEGIN
            SET @SqlStr
                = 'UPDATE E SET ' + @FieldName + ' = ''' + @FieldValue + ''', EscalationSchedulerTime = '''
                  + CASE
                        WHEN @SchedulerTime IS NULL THEN
                            ''
                        ELSE
                            CAST(@SchedulerTime AS NVARCHAR(50))
                    END + ''' ,
								EscalationSchedulerTimeString = ''' + CASE
                                                                          WHEN @SchedulerTimeString IS NULL THEN
                                                                              ''
                                                                          ELSE
                                                                              @SchedulerTimeString
                                                                      END + ''' ,
								EscalationSchedulerDay = ''' + CASE
                                                                   WHEN @SchedulerDay IS NULL THEN
                                                                       ''
                                                                   ELSE
                                                                       @SchedulerDay
                                                               END + ''' FROM Establishment E INNER JOIN dbo.Split('''
                  + @EstablishmentIds + ''','','') S ON S.Data = E.Id';
        END;
        ELSE IF (@FieldName = 'OutEscalationTime')
        BEGIN
            SET @SqlStr
                = 'UPDATE E SET ' + @FieldName + ' = ''' + @FieldValue + ''', OutEscalationSchedulerTime = '''
                  + CASE
                        WHEN @SchedulerTime IS NULL THEN
                            ''
                        ELSE
                            CAST(@SchedulerTime AS NVARCHAR(50))
                    END + ''' ,
								OutEscalationSchedulerTimeString = ''' + CASE
                                                                             WHEN @SchedulerTimeString IS NULL THEN
                                                                                 ''
                                                                             ELSE
                                                                                 @SchedulerTimeString
                                                                         END
                  + ''' ,
								OutEscalationSchedulerDay = ''' + CASE
                                                                      WHEN @SchedulerDay IS NULL THEN
                                                                          ''
                                                                      ELSE
                                                                          @SchedulerDay
                                                                  END
                  + ''' FROM Establishment E INNER JOIN dbo.Split(''' + @EstablishmentIds
                  + ''','','') S ON S.Data = E.Id';
        END;
        ELSE
        BEGIN
            SET @SqlStr
                = 'UPDATE E SET ' + @FieldName + ' = ''' + @FieldValue
                  + ''' FROM Establishment E INNER JOIN dbo.Split(''' + @EstablishmentIds
                  + ''','','') S ON S.Data = E.Id';
        END;

        PRINT @SqlStr;

        EXECUTE sp_executesql @SqlStr;

        INSERT INTO dbo.ActivityLog
        (
            UserId,
            PageId,
            AuditComments,
            TableName,
            RecordId,
            CreatedOn,
            CreatedBy,
            IsDeleted
        )
        VALUES
        (@UserId,
         @PageId,
         'Update record in table Establishment',
         'Establishment',
         @EstablishmentIds,
         GETUTCDATE(),
         @UserId,
         0
        );
    END;

END;

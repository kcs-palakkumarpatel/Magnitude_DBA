-- Stored Procedure

-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,03 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		GetPendingEmailListByModule 1
-- =============================================
CREATE PROCEDURE [dbo].[GetPendingEmailListByModule_20200705] @ModuleId BIGINT
AS
BEGIN
    UPDATE dbo.PendingEmail
    SET IsDeleted = 1
    WHERE EmailId = ''
          OR EmailId IS NULL
          OR LEN(EmailId) <= 5;

    IF (@ModuleId = 2 OR @ModuleId = 7)
    BEGIN

        SELECT PendingEmail.Id,
               ModuleId,
               EmailId,
               EmailSubject,
               EmailText,
               IsSent,
               SentDate,
               RefId,
               ScheduleDateTime,
               ISNULL(ReplyTo, '') AS ReplyTo,
               Counter,
               ISNULL(   GroupName,
               (
                   SELECT GroupName
                   FROM dbo.[Group]
                   WHERE Id =
                   (
                       SELECT GroupId
                       FROM dbo.Establishment
                       WHERE Id =
                       (
                           SELECT EstablishmentId
                           FROM dbo.AnswerMaster
                           WHERE Id = dbo.PendingEmail.RefId
                       )
                   )
               )
                     ) AS GroupName,
               PendingEmail.Attachment,
               AM.Id AS 'ReportId',
               E.EstablishmentGroupId AS 'ActivityId',
               CONVERT(BIT, 0) AS 'IsOut',
               dbo.PendingEmail.CreatedBy AS 'AppUserId'
        FROM PendingEmail
            INNER JOIN dbo.AnswerMaster AM
                ON dbo.PendingEmail.RefId = AM.Id
            INNER JOIN dbo.Establishment E
                ON AM.EstablishmentId = E.Id
            LEFT OUTER JOIN dbo.AppUser
                ON AppUser.Id = PendingEmail.CreatedBy
                   AND dbo.AppUser.IsDeleted = 0
            LEFT OUTER JOIN dbo.[Group]
                ON [Group].Id = AppUser.GroupId
                   AND [Group].IsDeleted = 0
        WHERE (IsSent = 0)
              AND (ScheduleDateTime <= GETUTCDATE())
              AND (PendingEmail.IsDeleted = 0)
              AND ModuleId = @ModuleId
              AND EmailId <> ''
              AND Counter < 1;
    END;
    ELSE IF (@ModuleId = 3 OR @ModuleId = 8)
    BEGIN
        --SELECT PendingEmail.Id,
        --       ModuleId,
        --       EmailId,
        --       EmailSubject,
        --       EmailText,
        --       IsSent,
        --       SentDate,
        --       RefId,
        --       ScheduleDateTime,
        --       ISNULL(ReplyTo, '') AS ReplyTo,
        --       Counter,
        --       ISNULL(GroupName, 'Magnitude') AS GroupName,
        --       PendingEmail.Attachment
        --FROM PendingEmail
        --    LEFT OUTER JOIN dbo.AppUser
        --        ON AppUser.Id = PendingEmail.CreatedBy
        --           AND dbo.AppUser.IsDeleted = 0
        --    LEFT OUTER JOIN dbo.[Group]
        --        ON [Group].Id = AppUser.GroupId
        --           AND [Group].IsDeleted = 0
        --WHERE (IsSent = 0)
        --      AND (ScheduleDateTime <= GETUTCDATE())
        --      AND (PendingEmail.IsDeleted = 0)
        --      AND ModuleId = @ModuleId
        --      AND EmailId <> ''
        --      AND Counter < 2;

        SELECT   PendingEmail.Id,
               ModuleId,
               EmailId,
               EmailSubject,
               EmailText,
               IsSent,
               SentDate,
               RefId,
               ScheduleDateTime,
               ISNULL(ReplyTo, '') AS ReplyTo,
               Counter,
               ISNULL(GroupName, 'Magnitude') AS GroupName,
               PendingEmail.Attachment,
               SCAM.Id AS 'ReportId',
               E.EstablishmentGroupId AS 'ActivityId',
               CONVERT(BIT, 1) AS 'IsOut',
               dbo.PendingEmail.CreatedBy AS 'AppUserId'
        FROM PendingEmail
            INNER JOIN dbo.SeenClientAnswerMaster SCAM
                ON dbo.PendingEmail.RefId = SCAM.Id
            INNER JOIN dbo.Establishment E
                ON SCAM.EstablishmentId = E.Id
            LEFT OUTER JOIN dbo.AppUser
                ON AppUser.Id = PendingEmail.CreatedBy
                   AND dbo.AppUser.IsDeleted = 0
            LEFT OUTER JOIN dbo.[Group]
                ON [Group].Id = AppUser.GroupId
                   AND [Group].IsDeleted = 0
        WHERE (IsSent = 0)
              AND (ScheduleDateTime <= GETUTCDATE())
              AND (PendingEmail.IsDeleted = 0)
              AND ModuleId = @ModuleId
              AND EmailId <> ''
              AND Counter < 1;
    END;
    ELSE
    BEGIN

        SELECT  PendingEmail.Id,
               ModuleId,
               EmailId,
               EmailSubject,
               EmailText,
               IsSent,
               SentDate,
               RefId,
               ScheduleDateTime,
               ISNULL(ReplyTo, '') AS ReplyTo,
               Counter,
               CASE
                   WHEN PendingEmail.CreatedBy = 1 THEN
                       'Magnitude Gold'
                   ELSE
                       ISNULL(   GroupName,
                       (
                           SELECT GroupName
                           FROM dbo.[Group]
                           WHERE Id =
                           (
                               SELECT GroupId
                               FROM dbo.Establishment
                               WHERE Id =
                               (
                                   SELECT EstablishmentId
                                   FROM dbo.AnswerMaster
                                   WHERE Id = dbo.PendingEmail.RefId
                               )
                           )
                       )
                             )
               END AS GroupName,
               PendingEmail.Attachment,
               CONVERT(BIGINT, 0) AS 'ReportId',
               CONVERT(BIGINT, 0) AS 'ActivityId',
               CONVERT(BIT, 1) AS 'IsOut',
               CONVERT(BIGINT, 0) AS 'AppUserId'
        FROM PendingEmail
            LEFT OUTER JOIN dbo.AppUser
                ON AppUser.Id = PendingEmail.CreatedBy
                   AND dbo.AppUser.IsDeleted = 0
            LEFT OUTER JOIN dbo.[Group]
                ON [Group].Id = AppUser.GroupId
                   AND [Group].IsDeleted = 0
        WHERE (IsSent = 0)
              AND (ScheduleDateTime <= GETUTCDATE())
              AND (PendingEmail.IsDeleted = 0)
              AND ModuleId = @ModuleId
              AND EmailId <> ''
              AND Counter < 1;

    END;


END;

﻿CREATE PROCEDURE [dbo].[GetContactRoleById]
        + CONVERT(NVARCHAR(10), dbo.ContactRoleActivity.ActivityId)
FROM    dbo.ContactRoleActivity
WHERE   ContactRoleId = @Id;
        + CONVERT(NVARCHAR(10), dbo.ContactRoleEstablishment.EstablishmentId)
FROM    dbo.ContactRoleEstablishment
WHERE   ContactRoleId = @Id;
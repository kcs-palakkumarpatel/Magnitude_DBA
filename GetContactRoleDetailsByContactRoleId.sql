﻿CREATE PROC [dbo].[GetContactRoleDetailsByContactRoleId]	@Id bigintASSET NOCOUNT ONSELECT [Id], 	[ContactRoleId], 	[AppUserId], 	[CreatedOn], 	[CreatedBy], 	[UpdatedOn], 	[UpdatedBy], 	[DeletedOn], 	[DeletedBy], 	[IsDeleted]FROM ContactRoleDetailsWHERE [ContactRoleId] = @IdSET NOCOUNT OFF
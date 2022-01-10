CREATE PROCEDURE dbo.CheckUserExistsWithSame
(
	@UserName varchar(50),
	@Email varchar(50)
)
AS
BEGIN
		DECLARE @ExistEmail varchar(50),@ExistsUser varchar(50)
		DECLARE @UserId int = 0;

		Set @UserId =  (select Id from AppUser where UserName = @UserName AND Email = @Email AND IsDeleted = 0)

		IF(@UserId > 0)
		BEGIN
			select  1 as ReturnValue
		END
		ELSE
		BEGIN
			Set @UserId =  (select Id from AppUser where UserName = @UserName AND IsDeleted = 0)
			IF(@UserId > 0)
			BEGIN
				Set @UserId =  (select Id from AppUser where UserName = @UserName AND Email <> @Email  AND IsDeleted = 0)	
				IF (@UserId > 0)
				BEGIN
					select  0 as ReturnValue
				END				
				ELSE
				BEGIN
					Set @UserId =  (select Id from AppUser where Email = @Email AND UserName <> @UserName AND IsDeleted = 0)	
					IF (@UserId > 0)
					BEGIN
						select  0 as ReturnValue
					END			
					ELSE
					BEGIN
						select  1 as ReturnValue
					END
				END
			END	
			ELSE
			BEGIN
				Set @UserId =  (select Id from AppUser where Email = @Email AND  UserName <> @UserName  AND IsDeleted = 0 )	
				IF(@UserId > 0)
				BEGIN
					select  0 as ReturnValue
				END
				ELSE
				BEGIN
					select  1 as ReturnValue
				END
			END
		END



END

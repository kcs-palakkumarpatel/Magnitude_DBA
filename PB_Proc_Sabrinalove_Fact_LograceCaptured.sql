
CREATE Procedure [dbo].[PB_Proc_Sabrinalove_Fact_LograceCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Sabrinalove_Fact_LograceCaptured','Sabrinalove_Fact_LograceCaptured Start','Sabrina Love'

	Truncate table dbo.Sabrinalove_Fact_LograceCaptured

	
	Insert into Sabrinalove_Fact_LograceCaptured(ResponseDate,[Logged Date],Responsereference,[Full Name],[Mobile],[Please select your],[ID/Passport number],
[Gender],[Race Type ],[Trail Run],[Mountain Bike],[Hours],[Minutes],[Seconds],[Time taken to complete],
[Time taken in time],latitude,longitude )
	select ResponseDate,[Logged Date],Responsereference,[Full Name],[Mobile],[Please select your],[ID/Passport number],
[Gender],[Race Type ],[Trail Run],[Mountain Bike],[Hours],[Minutes],[Seconds],[Time taken to complete],
[Time taken in time],latitude,longitude 
	 from [PB_VW_Sabrinalove_Fact_LograceCaptured]

	Select @Desc = 'Sabrinalove_Fact_LograceCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Sabrinalove_Fact_LograceCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Sabrinalove_Fact_LograceCaptured',@Desc,'Sabrina Love'
----------------------------------------------------------------------------------------------------------	
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_SabrinaLograce','Dim_UpdateDateTime_SabrinaLograce Start','Sabrina Love'


	Truncate table dbo.Dim_UpdateDateTime_SabrinaLograce

	Insert Into dbo.Dim_UpdateDateTime_SabrinaLograce
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime_SabrinaLograce Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_SabrinaLograce',@Desc,'Sabrina Love'
	Set NoCount OFF;
END

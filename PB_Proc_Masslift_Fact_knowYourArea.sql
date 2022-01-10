
Create Procedure [dbo].[PB_Proc_Masslift_Fact_knowYourArea]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_knowYourArea','Masslift_Fact_knowYourArea Start','Masslift'

	Truncate table dbo.Masslift_Fact_knowYourArea

	
	Insert into Masslift_Fact_knowYourArea(	EstablishmentName,	CapturedDate,
	ReferenceNo,	IsPositive,	Status,	PI,	Longitude,	Latitude,	UserId,	UserName 	,	[Company Name], 
	[Address],	[Website:],	[Name:],	[Surname],	[Contact number:],	[Type of applicatio] ,	[Prospect engagemen],
	[Make Contact Date],	ResponseDate ,	CustomerName ,	CustomerCompany,	CustomerEmail ,	CustomerMobile,
		[Status:] )
	select 	EstablishmentName,	CapturedDate,
	ReferenceNo,	IsPositive,	Status,	PI,	Longitude,	Latitude,	UserId,	UserName 	,	[Company Name], 
	[Address],	[Website:],	[Name:],	[Surname],	[Contact number:],	[Type of applicatio] ,	[Prospect engagemen],
	[Make Contact Date],	ResponseDate ,	CustomerName ,	CustomerCompany,	CustomerEmail ,	CustomerMobile,
		[Status:] 
	 from [PB_VW_Masslift_Fact_KnowYourArea]

	Select @Desc = 'Masslift_Fact_knowYourArea Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_knowYourArea(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_knowYourArea',@Desc,'Masslift'

	Set NoCount OFF;
END


Create Procedure [dbo].[PB_Proc_Masslift_Fact_FMD]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_FMD','Masslift_Fact_FMD Start','Masslift'

	Truncate table dbo.Masslift_Fact_FMD

	
	Insert into Masslift_Fact_FMD(EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,

[Customer Name ],
[Contact Number ],
[POP Before Deliver],
[Special terms (MD ],
[Applicable ],
[Bank ],
[Contact Name ],
[Bank Contact Number],
[Buy back option ],
[Sourced Funding Applicable],
[Customer],
[Funding period ],
[Residual Value % ],
[Audited accounts ],
[Management account],
[Company documents ],
[Director],
[Insurance ],
[PMA rate ],
[3 year service pla],
[All in maintenance],
[Period ],
[Minimum monthly ho],
[Excess hours ],
[If other, please s],
[Standard ],
[Other ],
[Inclusions/exclusi],
[Required by],
[Short term hire un],
[Loan unit rate (Ma],
[Delivery address ],
[FMX contact name &],
[SITE contact name ],
[Other delivery req],ResponseDate,
CustomerName, CustomerSurname,
CustomerCompany,CustomerEmail,CustomerMobile,
[Info Correct ],
[If no, please corr])
	select EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,

[Customer Name ],
[Contact Number ],
[POP Before Deliver],
[Special terms (MD ],
[Applicable ],
[Bank ],
[Contact Name ],
[Bank Contact Number],
[Buy back option ],
[Sourced Funding Applicable],
[Customer],
[Funding period ],
[Residual Value % ],
[Audited accounts ],
[Management account],
[Company documents ],
[Director],
[Insurance ],
[PMA rate ],
[3 year service pla],
[All in maintenance],
[Period ],
[Minimum monthly ho],
[Excess hours ],
[If other, please s],
[Standard ],
[Other ],
[Inclusions/exclusi],
[Required by],
[Short term hire un],
[Loan unit rate (Ma],
[Delivery address ],
[FMX contact name &],
[SITE contact name ],
[Other delivery req],ResponseDate,
CustomerName, CustomerSurname,
CustomerCompany,CustomerEmail,CustomerMobile,
[Info Correct ],
[If no, please corr]

	 from [PB_VW_Masslift_Fact_FMD]

	Select @Desc = 'Masslift_Fact_FMD Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_FMD(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_FMD',@Desc,'Masslift'

	Set NoCount OFF;
END

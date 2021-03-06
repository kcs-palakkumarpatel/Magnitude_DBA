Create Procedure [dbo].[PB_Proc_Masslift_Fact_SiteAssessment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_SiteAssessment','Masslift_Fact_SiteAssessment Start','Masslift'

	Truncate table dbo.Masslift_Fact_SiteAssessment

	
	Insert into Masslift_Fact_SiteAssessment(EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,

[Mast type:],
[Height (mm)],
[Length (mm)],
[Width (mm)],
[Load centre (mm)],
[Weight (kg)],
[Stacking height (m],
[Pallet Handling (S],
[OL Mast type:],
[OL height (mm)],
[OL length (mm)],
[OL width],
[OL load centre],
[OL Weight (kg)],
[OL stacking height],
[OL Pallet Handling (S],
[Description ],
[Mast height ],
[Fork dimensions],
[Brand],
[Type ],
[Capacity ],
[Kg at ...],
[mm],
[Lost load ],
[Dead weight (kg)],
[Residual carrying ],
[Centre of gravity ],
[Applications Detai],
[Max rise (mm)],
[Max length (mm)],
[Drive through (mm)],
[Handling loads (mm],
[Narrowest drive th],
[Towing trailer etc],
[Floor / yard condi],
[Environment ],
[Max C],
[Min C],
[Specifications of ],
[Days per week],
[Shifts per day],
[Hours per shift],
[Seasonal ],
[High cycle],
[Estimated operatin],
[Operator(s)],
[On incentive ],
[Superviser ],
[Good Maintenance ],
[Customer mechanic],
[Familiar Equipment],
[Daily inspection],
[Maintenance superv],
[Kms ],
[Hrs],
[Dealer branch ],
[Dealer mechanic ],ResponseDate,
 CustomerName,CustomerSurname,CustomerCompany, CustomerEmail,CustomerMobile,
[Correct Information],
[If no, please corr])
	select EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,

[Mast type:],
[Height (mm)],
[Length (mm)],
[Width (mm)],
[Load centre (mm)],
[Weight (kg)],
[Stacking height (m],
[Pallet Handling (S],
[OL Mast type:],
[OL height (mm)],
[OL length (mm)],
[OL width],
[OL load centre],
[OL Weight (kg)],
[OL stacking height],
[OL Pallet Handling (S],
[Description ],
[Mast height ],
[Fork dimensions],
[Brand],
[Type ],
[Capacity ],
[Kg at ...],
[mm],
[Lost load ],
[Dead weight (kg)],
[Residual carrying ],
[Centre of gravity ],
[Applications Detai],
[Max rise (mm)],
[Max length (mm)],
[Drive through (mm)],
[Handling loads (mm],
[Narrowest drive th],
[Towing trailer etc],
[Floor / yard condi],
[Environment ],
[Max C],
[Min C],
[Specifications of ],
[Days per week],
[Shifts per day],
[Hours per shift],
[Seasonal ],
[High cycle],
[Estimated operatin],
[Operator(s)],
[On incentive ],
[Superviser ],
[Good Maintenance ],
[Customer mechanic],
[Familiar Equipment],
[Daily inspection],
[Maintenance superv],
[Kms ],
[Hrs],
[Dealer branch ],
[Dealer mechanic ],ResponseDate,
 CustomerName,CustomerSurname,CustomerCompany, CustomerEmail,CustomerMobile,
[Correct Information],
[If no, please corr]

	 from [PB_VW_Masslift_Fact_SiteAssessment]

	Select @Desc = 'Masslift_Fact_SiteAssessment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_SiteAssessment(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_SiteAssessment',@Desc,'Masslift'

	Set NoCount OFF;
END

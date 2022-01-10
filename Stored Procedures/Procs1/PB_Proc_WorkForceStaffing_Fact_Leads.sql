CREATE Procedure [dbo].[PB_Proc_WorkForceStaffing_Fact_Leads]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'WorkForceStaffing_Fact_Leads','WorkForceStaffing_Fact_Leads','WorkForce Staffing'

	Truncate table dbo.WorkForceStaffing_Fact_Leads

	
	Insert into WorkForceStaffing_Fact_Leads(EstablishmentName,CapturedDate,ReferenceNo,Status,RepeatCount,[Name],[Surname],[Mobile],[Landline],
[Email],[Company],[Your Designation/Title],[Department],[Preferred method of communication],[Industry],[Agricultural Role],
[Aviation Role],[Construction Role],[Food Manufacturing Role],[Hospitality Role],[Logistics Role],[Manufacturing Role],
[Mining Sector],[Mining Role],[Office Support Role],[Power, Oil or Gas Role],[Print Media Role],[Retail Role],
[Renewable Energy Solutions],[Telecommunications Role],[Waste Management Role],[(OTHER) - Detail or Description],
[Quantity],[Address or Location where the staff are required],[Special Requests or Notes we should consider],
[Attach a copy of the job specification (Optional)],[Date Required (Start)],[Date Required (End)])
	select EstablishmentName,CapturedDate,ReferenceNo,Status,RepeatCount,[Name],[Surname],[Mobile],[Landline],
[Email],[Company],[Your Designation/Title],[Department],[Preferred method of communication],[Industry],[Agricultural Role],
[Aviation Role],[Construction Role],[Food Manufacturing Role],[Hospitality Role],[Logistics Role],[Manufacturing Role],
[Mining Sector],[Mining Role],[Office Support Role],[Power, Oil or Gas Role],[Print Media Role],[Retail Role],
[Renewable Energy Solutions],[Telecommunications Role],[Waste Management Role],[(OTHER) - Detail or Description],
[Quantity],[Address or Location where the staff are required],[Special Requests or Notes we should consider],
[Attach a copy of the job specification (Optional)],[Date Required (Start)],[Date Required (End)]
	 from [PB_VW_WorkForceStaffing_Fact_Leads]

	Select @Desc = 'WorkForceStaffing_Fact_Leads Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.WorkForceStaffing_Fact_Leads(NoLock) 
	Exec dbo.PB_Log_Insert 'WorkForceStaffing_Fact_Leads',@Desc,'WorkForce Staffing'

	Set NoCount OFF;
END



CREATE Procedure [dbo].[PB_Proc_DFC_FactCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'DFC_FactCaptured','DFC_FactCaptured Start','DFC'

	Truncate table dbo.DFC_FactCaptured

	Insert Into dbo.DFC_FactCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,ResolvedDate,RepeatCount,
[Pipeline/Forecast],[Customer],[Forecast based on],[Warehouse],[End Customer],[FORECAST RISK],[NOTE: Special Note],[Product at Risk],
[Atval Sector],[Select ATVAL Size ],[ATVAL Pressure],[ATVAL Actuation],[ATVAL Model],[ATVAL QTY FORECAST],[ATVAL Close Month],
[Biman Sector],[Select BIMAN Size ],[BIMAN Air Pressure],[BIMAN Line],[Biman Actuator],[BIMAN ],[BIMAN QTY FORECAST],[BIMAN Close Month],[RF Pinch Sector],
[RF PINCH Size],[RF PINCH Pressure],[RF Pinch Actuation],[RF PINCH Model],[RF PINCH QTY],[RF Pinch Close],[Insamcor Sector],[INSAMCOR Size],[INSAMCOR Pressure],
[INSAMCOR Model],[Insamcor Actuation],[INSAMCOR QTY],[INSAMCOR Close],[VOM NCV Sector],[VOM NCV Size],[VOM NCV Pressure],[VOM NCV Model],[VOM NCV QTY],
[VOM NCV Close],[VOM AIR Sector],[VOM AIR Siz],[VOM AIR Pressure],[VOM AIR Model],[VOM AIR QTY],[VOM AIR Close],[Saunders Sector],[SAUNDERS Size],[Saunders Drilling ],
[Saunders Diaphragm],[Saunders Material],[Saunders MOdel],[SAUNDERS QTY],[SAUNDERS Close],[SKG Sector],[SKG Size ],[SKG Pressure],[SKG Actuation Type],[Select SKG Model],[Blade Type],[SKG QTY FORECAST],
[SKG Close Month],[VOSA Sector],[VOSA Size ],[VOSA Pressure],[VOSA Model],[VOSA Specs],[VOSA QTY FORECAST],[VOSA Close Month],[Dragflow Sector],[DRAGFLOW Outlet],
[DRAGFLOW Power],[DRAGFLOW Model],[DRAGFLOW QTY],[DRAGFLOW Close],[Components],[Other Components],[Component Descript],[Component QTY],[COMPONENTS Month]) 
	Select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,ResolvedDate,RepeatCount,
[Pipeline/Forecast],[Customer],[Forecast based on],[Warehouse],[End Customer],[FORECAST RISK],[NOTE: Special Note],[Product at Risk],
[Atval Sector],[Select ATVAL Size ],[ATVAL Pressure],[ATVAL Actuation],[ATVAL Model],[ATVAL QTY FORECAST],[ATVAL Close Month],
[Biman Sector],[Select BIMAN Size ],[BIMAN Air Pressure],[BIMAN Line],[Biman Actuator],[BIMAN ],[BIMAN QTY FORECAST],[BIMAN Close Month],[RF Pinch Sector],
[RF PINCH Size],[RF PINCH Pressure],[RF Pinch Actuation],[RF PINCH Model],[RF PINCH QTY],[RF Pinch Close],[Insamcor Sector],[INSAMCOR Size],[INSAMCOR Pressure],
[INSAMCOR Model],[Insamcor Actuation],[INSAMCOR QTY],[INSAMCOR Close],[VOM NCV Sector],[VOM NCV Size],[VOM NCV Pressure],[VOM NCV Model],[VOM NCV QTY],
[VOM NCV Close],[VOM AIR Sector],[VOM AIR Siz],[VOM AIR Pressure],[VOM AIR Model],[VOM AIR QTY],[VOM AIR Close],[Saunders Sector],[SAUNDERS Size],[Saunders Drilling ],
[Saunders Diaphragm],[Saunders Material],[Saunders MOdel],[SAUNDERS QTY],[SAUNDERS Close],[SKG Sector],[SKG Size ],[SKG Pressure],[SKG Actuation Type],[Select SKG Model],[Blade Type],[SKG QTY FORECAST],
[SKG Close Month],[VOSA Sector],[VOSA Size ],[VOSA Pressure],[VOSA Model],[VOSA Specs],[VOSA QTY FORECAST],[VOSA Close Month],[Dragflow Sector],[DRAGFLOW Outlet],
[DRAGFLOW Power],[DRAGFLOW Model],[DRAGFLOW QTY],[DRAGFLOW Close],[Components],[Other Components],[Component Descript],[Component QTY],[COMPONENTS Month] From dbo.VW_PB_DFC_FactCaptured


	Select @Desc = 'DFC_FactCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.DFC_FactCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'DFC_FactCaptured',@Desc,'DFC'


	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeDFC','Dim_UpdateDateTimeDFC Start','DFC'


	Truncate table dbo.Dim_UpdateDateTimeDFC

	Insert Into dbo.Dim_UpdateDateTimeDFC
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeDFC Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeDFC',@Desc,'DFC'

	Set NoCount OFF;
END


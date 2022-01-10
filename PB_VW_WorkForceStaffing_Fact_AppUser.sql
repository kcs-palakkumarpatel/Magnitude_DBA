

--EXECUTE dbo.PB_Proc_WorkForceStaffing_Fact_AppUser
CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_AppUser]
AS
SELECT  CASE WHEN
EstablishmentName='Escourt' OR  
EstablishmentName='Isithebe' OR 
EstablishmentName='Jacobs' OR
EstablishmentName='Margate' OR
EstablishmentName='Durban' OR
EstablishmentName='Port Shepstone / Kokstad' OR
EstablishmentName='Kokstad' OR
EstablishmentName='Pietermaritzburg' OR
EstablishmentName='Pinetown' OR 
EstablishmentName='Springfield' OR
EstablishmentName='Vryheid' OR
EstablishmentName='Corporate Team' OR 
EstablishmentName='National Sales' OR 
EstablishmentName='Ladysmith'  OR 
EstablishmentName='Newcastle'  OR 
EstablishmentName='Richards Bay'            THEN 'KZN'

WHEN
EstablishmentName='Technical Specialist NC' 			THEN 'Technical NC'  

WHEN
EstablishmentName='Technical Specialist GP.C'		THEN 'Technical JHB Central'

WHEN
EstablishmentName='Technical Specialist WC'			THEN 'Technical WC'

WHEN
EstablishmentName='Technical Specialist GP.N'		THEN 'Technical JHB North'

WHEN
EstablishmentName='Technical Specialist EC'			THEN 'Technical EC'

WHEN
EstablishmentName='Technical Specialist KZN'			THEN 'Technical KZN'


WHEN 
EstablishmentName='Epping'  OR 
EstablishmentName='Montague Gardens' OR
EstablishmentName='Airport/Bellvile' OR 
EstablishmentName='Paarl/Worcester' OR 
EstablishmentName='George' 						THEN 'WC'

WHEN
EstablishmentName='Bloemfontein' OR
EstablishmentName='Upington' OR 
EstablishmentName='Kathu'						THEN 'NC'

WHEN 
EstablishmentName='East London' OR 
EstablishmentName='Port Elizabeth'				THEN 'EC'

WHEN 
EstablishmentName='Benoni' OR
EstablishmentName='Kempton Park'OR 
EstablishmentName='Alberton'OR
EstablishmentName='Cresta'OR 
EstablishmentName='Vanderbiljpark' OR 
EstablishmentName='Wadeville ' OR 
EstablishmentName='Witbank' OR 
EstablishmentName='Secunda' OR 
EstablishmentName='Klerksdorp' 	OR
EstablishmentName='Van der Bijl'				THEN 'JHB-Central'

WHEN 
EstablishmentName='Louis Trichardt' OR 
EstablishmentName='GM Sales (BDM)' OR 
EstablishmentName='Nelspruit'  OR 
EstablishmentName='Polokwane' OR
EstablishmentName='Centurion' OR
EstablishmentName='Rustenburg' OR
EstablishmentName='Gauteng North BDM' 					THEN 'JHB-North'

ELSE'NA' END AS Region ,EstablishmentName,Name,UserName FROM(
SELECT DISTINCT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(E.EstablishmentName,'WF Quote - ',''),'WF New Call - ',''),'WF Follow Up - ',''),'WF Prospect Engagement - ',''),'Client Track - ',''),'Lead Allocation - ',''),'Monthly Plan - ',''),'Service Review - ',''),'KZN [Isithebe]','Isithebe'),'Gauteng North [Crown Chicken]','Crown Chicken'),'KZN [Jacobs]','Jacobs'),'KZN [Ladysmith]','Ladysmith'),'KZN [Pietermaritzburg]','Pietermaritzburg'),'KZN [Springfield]','Springfield'),'KZN [Dunlop]','Dunlop'),'Gauteng North [Centurion]','Centurion'),'Gauteng North [Rustenburg]','Rustenburg'),'Gauteng North [Nelspruit]','Nelspruit'),'Gauteng North [Polokwane]','Polokwane'),'Gauteng North [Louis Trichardt]','Louis Trichardt'),'KZN [Margate]','Margate'),'KZN [Pinetown]','Pinetown'),'KZN [Vryheid]','Vryheid'),'KZN [Richards Bay]','Richards Bay'),'KZN [Newcastle]','Newcastle'),'KZN [Estcourt]','Escourt') AS EstablishmentName,U.Name,U.UserName FROM AppUserEstablishment AU
INNER JOIN Establishment E ON E.id=AU.Establishmentid
INNER JOIN Appuser U ON U.id=AU.AppUserid
WHERE U.Groupid=494 AND isUserActive=1 AND AU.EstablishmentType='Sales' 
)A 



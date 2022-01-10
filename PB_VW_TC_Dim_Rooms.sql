create view PB_VW_TC_Dim_Rooms as
Select Id, EstablishmentName 
from Establishment where Establishmentgroupid=5185 and isdeleted=0 

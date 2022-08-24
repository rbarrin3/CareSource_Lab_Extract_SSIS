/******************************************************************************************************************************
**               AUTHOR    : Sid G
**        CREATION DATE    : 03/17/2022
**              VERSION    : 1.0
**          DATABASE(S)    : Clarity
**          WRITTEN FOR    : Sentry
**        SQL FILE NAME    : Sentry Patient Encounter
**          TEMPLATE ID    : 
**             TICKET #    : 
**              PURPOSE    : Sentry Patient Encounter Extract
** BI DOCUMENT LOCATION    : Teams > Epic EMR Project - DTAS > General > Cogito > Extract Specifications > SentryDataSystems >
**                           Sentry Data Specification Data Map - Epic 20220110.xlsx
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		04/07/2022 XXXX	        Sid	        1.X			Modified Updated Missing Fields.
*******************************************************************************************************************************/
CREATE PROCEDURE dbo.GetPatientEncounterDetails
AS

DECLARE @StartDate AS DATETIME = EPIC_UTIL.EFN_DIN('MB-1');
DECLARE @EndDate AS DATETIME = DATEADD(S, 86399, EPIC_UTIL.EFN_DIN('ME-1')); 



select 
hsp.HSP_ACCOUNT_ID as "Account Number",
pat.PAT_MRN_ID as "Medical Record Number",
pat.PAT_LAST_NAME as "Patient Last Name",
pat.PAT_FIRST_NAME as "Patient First Name" ,
replace(convert(varchar(10), pat.BIRTH_DATE,101),'/','') as "Patient Date of Birth",
ISNULL (sex.ABBR,'') as "Gender",
ISNULL(pat.ADD_LINE_1, '') as "Address Line 1",
ISNULL (pat.ADD_LINE_2, '') as "Address Line 2",
ISNULL (pat.CITY,'') as "City",
ISNULL (pas.ABBR,'') as "State",
ISNULL(convert(varchar(11), pat.ZIP),'') as "Zip code",
ISNULL(replace(convert(varchar(10), hsp.ADM_DATE_TIME,101),'/',''),'') as "Service Date",
ISNULL(convert(varchar(10),ser.PROV_ID),'') as "Internal Provider ID",
ISNULL(convert(varchar(10), ser1.npi),'') as "Provider NPI",
ISNULL(convert(varchar(8), ser.DEA_NUMBER),'') as "Provider DEA",
--loc.loc_name as "Location of Service"
ISNULL(CONVERT(varchar(25), dep.DEPT_ABBREVIATION),'') as "Location of Service"

from HSP_ACCOUNT hsp
left outer join PATIENT pat on hsp.PAT_ID = pat.PAT_ID
left outer join ZC_SEX sex on pat.SEX_C = sex.RCPT_MEM_SEX_C
left outer join ZC_STATE pas on pat.STATE_C = pas.STATE_C
--left outer join CLARITY_SER ser on hsp.ATTENDING_PROV_ID = ser.PROV_ID
--left outer join CLARITY_SER ser on hsp.ADM_PROV_ID = ser.PROV_ID
left outer join Clarity_ser ser on pat.CUR_PCP_PROV_ID = ser.PROV_ID
left outer join CLARITY_SER_2 ser1 on ser.PROV_ID = ser1.PROV_ID
left outer join CLARITY_DEP dep on hsp.ADM_DEPARMENT_ID = dep.DEPARTMENT_ID
left outer join CLARITY_LOC loc on hsp.LOC_ID = loc.LOC_ID

 
/******************************************************************************************************************************
**               AUTHOR    : Sid G
**        CREATION DATE    : 03/17/2022
**              VERSION    : 1.0
**          DATABASE(S)    : Clarity
**          WRITTEN FOR    : Sentry
**        SQL FILE NAME    : Sentry HIS Provider
**          TEMPLATE ID    : 
**             TICKET #    : 
**              PURPOSE    : Sentry  HIS Provider Extract
** BI DOCUMENT LOCATION    : Teams > Epic EMR Project - DTAS > General > Cogito > Extract Specifications > SentryDataSystems >
**                           Sentry Data Specification Data Map - Epic 20220110.xlsx
*******************************************************************************************************************************
** CHANGES:
**      Date       Ticket #	    Changes By			Revision #	Comments  
**      ---------- -----------	----------------	----------	------------------------------------
**		04/07/2022 XXXX	        Sid	        1.X			Modified Updated Missing Fields.
*******************************************************************************************************************************/
CREATE PROCEDURE dbo.GetHISProviderDetailsDetails
AS
DECLARE @StartDate AS DATETIME = EPIC_UTIL.EFN_DIN('MB-1');
DECLARE @EndDate AS DATETIME = DATEADD(S, 86399, EPIC_UTIL.EFN_DIN('ME-1')); 

select 
distinct ser.prov_id as "Internal ID Number",
--ISNULL(ser.PROV_NAME,'') as "Full Name",
ISNULL(
     CASE
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) < 1)
            THEN ser.prov_name
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) < 1)
            THEN SUBSTRING(ser.prov_name,1, CHARINDEX(',',ser.prov_name) -1)
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) > 0)
            THEN SUBSTRING(ser.prov_name,1, CHARINDEX(',',ser.prov_name) -1)
         WHEN  (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) > 0)
            THEN SUBSTRING(ser.prov_name,1, CHARINDEX(' ',ser.prov_name) -1)
       END, '') AS "Last Name",
ISNULL(
      CASE
         WHEN
           (CHARINDEX(' ',
              (LTRIM(CASE
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN ' '
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(' ',ser.prov_name) + 1,30)
       END)))) > 0
             THEN SUBSTRING(
  LTRIM(CASE
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN ' '
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(' ',ser.prov_name) + 1,30)
        END),1,
          CHARINDEX(' ',
              (LTRIM(CASE
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN ' '
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(' ',ser.prov_name) + 1,30)
         END))))
  ELSE LTRIM(CASE
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN ' '
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) < 1)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) > 0) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(',',ser.prov_name) + 1,30)
         WHEN (CHARINDEX(',',ser.prov_name) < 1) AND (CHARINDEX(' ',ser.prov_name) > 0)
             THEN SUBSTRING(ser.prov_name, CHARINDEX(' ',ser.prov_name) + 1,30)
         END)
        END, '') AS "First Name",
ISNULL(
   CASE
         WHEN CHARINDEX(',',ser.prov_name) > 0 AND CHARINDEX(' ', SUBSTRING (ser.prov_name,CHARINDEX(',',ser.prov_name)+2, LEN(ser.prov_name)-CHARINDEX(',',ser.prov_name)-1), 1) <=0
             THEN ''
         WHEN CHARINDEX(',',ser.prov_name) > 0 AND CHARINDEX(' ', SUBSTRING (ser.prov_name,CHARINDEX(',',ser.prov_name)+2, LEN(ser.prov_name)-CHARINDEX(',',ser.prov_name)-1), 1) >0
             THEN
             SUBSTRING (
              SUBSTRING (ser.prov_name,CHARINDEX(',',ser.prov_name)+2, LEN(ser.prov_name)-CHARINDEX(',',ser.prov_name)-1)
            , CHARINDEX(' ', SUBSTRING (ser.prov_name,CHARINDEX(',',ser.prov_name)+2, LEN(ser.prov_name)-CHARINDEX(',',ser.prov_name)-1), 1) +1
            , LEN(SUBSTRING (ser.prov_name,CHARINDEX(',',ser.prov_name)+2, LEN(ser.prov_name)-CHARINDEX(',',ser.prov_name)-1))
            - CHARINDEX(' ', SUBSTRING (ser.prov_name,CHARINDEX(',',ser.prov_name)+2, LEN(ser.prov_name)-CHARINDEX(',',ser.prov_name)-1), 1)
)
ELSE ''
         END, '') AS "Middle Name ",

ISNULL(replace(convert(varchar(10),ser.BIRTH_DATE,101),'/',''),'') as "Date of Birth" ,

ISNULL(zcs.abbr,'') as "Sex",
ISNULL(addr1.ADDR_LINE_1,'') as "Primary Office Address Line 1",
ISNULL(addr1.ADDR_LINE_2,'') as "Primary Office Address Line 2",
--ISNULL(addr1.ADDR_LINE_3,'') as "Primary Office Address Line 3",
ISNULL(addr1.CITY,'') as "Primary Office City",
ISNULL(zst1.NAME,'') as "Primary Office State",
ISNULL(addr1.ZIP,'') as "Primary Office Zip code",
ISNULL(addr1.PHONE,'') as "Primary Office Phone Number",
ISNULL(addr1.FAX,'') as "Primary Office Fax Number",

ISNULL(addr2.ADDR_LINE_1,'') as "Secondary Office Address Line 1",
ISNULL(addr2.ADDR_LINE_2,'') as "Secondary Office Address Line 2",
--ISNULL(addr2.ADDR_LINE_3,'') as "Secondary Office Address Line 3",
ISNULL(addr2.CITY,'') as "Secondary Office City",
ISNULL(zst2.NAME,'') as "Secondary Office State",
ISNULL(addr2.ZIP,'') as "Secondary Office Zip code",
ISNULL(addr2.PHONE,'') as "Secondary Office Phone Number",
ISNULL(addr2.FAX,'') as "Secondary Office Fax Number",
ISNULL(zs1.name,'') as "Primary Specialty",
ISNULL(zs2.name,'') as "Secondary Specialty",
ISNULL(ser.DEA_Number,'') as "DEA Number",
''                      as "DEA Expiration Date",
ISNULL(csl.LICENSE_NUM,'') as "State License Number",
ISNULL(replace(Convert(VARCHAR(20),csl.LICENSE_EXP_DATE, 101),'/',''),'') AS "State License Expiration Date",
ISNULL(ser.UPIN,'') as "UPIN Number",
ISNULL(convert(varchar(10),ser1.npi),'') as 	"NPI Number",
ISNULL(case when addr1.ACTIVE_YN =1 then 'Y'
     when addr1.ACTIVE_YN =2 then 'N'
	 else NULL
	 end,'') as  "Current Status" ,
'' as "Inactive date",
ISNULL(zpt.Name,'')	as "Provider Type",
'' as "Provider Type Description",
ISNULL(ser1.ADT_ADMT_PROVIDER_YN,'') as "Admitting Privileges",
'' as "Facility Code",
ISNULL(zst.NAME,'') as "On-Staff",
ISNULL(ser.ORDS_AUTH_PROV_YN,'') as "Ordering Privileges", 
'' as "Other Provider"


from clarity_ser ser
left join ZC_SEX zcs on ser.SEX_C = zcs.RCPT_MEM_SEX_C
left join CLARITY_SER_ADDR addr1 on ser.PROV_ID = addr1.PROV_ID and addr1.LINE =1
left join CLARITY_SER_ADDR addr2 on ser.PROV_ID = addr2.PROV_ID and addr2.LINE = 2
left join ZC_STATE zst1 on addr1.STATE_C = zst1.STATE_C
left join ZC_STATE zst2 on addr2.STATE_C = zst2.STATE_C
left join CLARITY_SER_SPEC spc1 on ser.prov_id = spc1.prov_id and spc1.line=1
left join CLARITY_SER_SPEC spc2 on ser.prov_id = spc2.PROV_ID and spc2.LINE=2
left join ZC_SPECIALTY zs1 on spc1.SPECIALTY_C = zs1.SPECIALTY_C
left join ZC_SPECIALTY zs2 on spc2.SPECIALTY_C =zs2.SPECIALTY_C
left join CLARITY_SER_LICEN2 csl on ser.PROV_ID = csl.prov_id
left join clarity_ser_2 ser1 on ser.prov_id = ser1.prov_id
left join ZC_PROV_TYPE zpt on ser.PROVIDER_TYPE_C = zpt.PROV_TYPE_C
left join ZC_REF_SOURCE_TYPE zst on ser.Referral_Source_TYPE_C = zst.Ref_source_type_c



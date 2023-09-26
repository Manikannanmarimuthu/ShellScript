# Taking Backup existsing Table
-- CREATE TABLE uamconf_role_bk01 AS SELECT * FROM hlfdxp_pras_sys.uamconf_role;
-- CREATE TABLE usersecurityprofile_bk01 AS SELECT * FROM hlfdxp_pras_sys. usersecurityprofile;
-- CREATE TABLE usersecurityprofile_mc_bk01 AS SELECT * FROM hlfdxp_pras_sys.usersecurityprofile_mc;
-- CREATE TABLE usersecurityprofileobject_bk01 AS SELECT * FROM hlfdxp_pras_sys.usersecurityprofileobject;
-- CREATE TABLE usersecurityprofileobject_mc_bk01 AS SELECT * FROM hlfdxp_pras_sys.usersecurityprofileobject_mc;
-- CREATE TABLE usersecuritytable_bk01 AS SELECT * FROM hlfdxp_pras_sys.usersecuritytable;

# Delete Query 
-- Delete from hlfdxp_pras_sys.uamconf_role WHERE Name NOT IN ('Admin', 'UserSecProfMaker', 'UserSecProfChecker', 'Blank');
-- Delete from hlfdxp_pras_sys. usersecurityprofile where USER_SECURITY_PROFILE NOT IN ('BatchAdminUIUser','Super','Console Normal','ConsoleUIAdmin','ConsoleUIUser');
-- Delete from hlfdxp_pras_sys.usersecurityprofile_mc where  USER_SECURITY_PROFILE NOT IN ('BatchAdminUIUser','Super','Console Normal','ConsoleUIAdmin','ConsoleUIUser');
-- Delete from hlfdxp_pras_sys.usersecurityprofileobject where PROFILE_ID NOT IN (47,37,43,42,1);
-- Delete from  hlfdxp_pras_sys.usersecurityprofileobject_mc where PROFILE_ID NOT IN (47,37,43,42,1);
-- Delete from hlfdxp_pras_sys.usersecuritytable where login_id NOT IN ('dxp adm stg','dxp ops stg');

SELECT * FROM hlfdxp_pras_sys.uamconf_role ;
SELECT * FROM hlfdxp_pras_sys.uamconf_role WHERE Name NOT IN ('Admin', 'UserSecProfMaker', 'UserSecProfChecker', 'Blank');

Select * from hlfdxp_pras_sys. usersecurityprofile;
Select * from hlfdxp_pras_sys. usersecurityprofile where USER_SECURITY_PROFILE NOT IN ('BatchAdminUIUser','Super','Console Normal','ConsoleUIAdmin','ConsoleUIUser');

Select * from hlfdxp_pras_sys.usersecurityprofile_mc ;
Select * from hlfdxp_pras_sys.usersecurityprofile_mc where  USER_SECURITY_PROFILE NOT IN ('BatchAdminUIUser','Super','Console Normal','ConsoleUIAdmin','ConsoleUIUser');

Select * from hlfdxp_pras_sys.usersecurityprofileobject where PROFILE_ID NOT IN (47,37,43,42,1);


Select * from hlfdxp_pras_sys.usersecurityprofileobject_mc where PROFILE_ID NOT IN (47,37,43,42,1);

Select * from hlfdxp_pras_sys.usersecuritytable;

Select * from hlfdxp_pras_sys.usersecuritytable;

Select * from hlfdxp_pras_sys.usersecuritytable where login_id NOT IN ('dxp adm stg','dxp ops stg');

Delete from hlfdxp_pras_sys.usersecuritytable where login_id NOT IN ('dxp adm stg','dxp ops stg');

Select * from hlfdxp_pras_sys. usersecurityprofile where USER_SECURITY_PROFILE IN ('BatchAdminUIUser');
UPDATE `hlfdxp_pras_sys`.`usersecurityprofileobject` SET `OBJ_TYPE` = 'BATCHADMINUI' WHERE (`PROFILE_ID` = '47') and (`OBJ_ID` = 'HOME') and (`OBJ_SUB_ID` = '*') and (`OBJ_TYPE` = 'HLFBATCHADMINUI') and (`OBJ_SUB_TYPE` = '*');
UPDATE `hlfdxp_pras_sys`.`usersecurityprofileobject` SET `OBJ_TYPE` = 'BATCHADMINUI' WHERE (`PROFILE_ID` = '47') and (`OBJ_ID` = 'VIEW_BATCH_EXECUTIONS') and (`OBJ_SUB_ID` = '*') and (`OBJ_TYPE` = 'HLFBATCHADMINUI') and (`OBJ_SUB_TYPE` = '*');
UPDATE `hlfdxp_pras_sys`.`usersecurityprofileobject` SET `OBJ_TYPE` = 'BATCHADMINUI' WHERE (`PROFILE_ID` = '47') and (`OBJ_ID` = 'VIEW_BATCH_JOBS') and (`OBJ_SUB_ID` = '*') and (`OBJ_TYPE` = 'HLFBATCHADMINUI') and (`OBJ_SUB_TYPE` = '*');

INSERT INTO `hlfdxp_pras_sys`.`usersecuritytable` (`LOGIN_ID`, `USER_ID`, `USER_NAME`, `USER_GROUP`, `USER_DEPARTMENT`, `USER_PASSWORD`, `USERUSED`, `USER_EMAIL_ID`, `USER_SECURITY_PROFILE`, `USER_RETRY_TIMES`, `LAST_SUC_LOGIN_TIMESTAMP`, `LAST_FAIL_LOGIN_TIMESTAMP`, `LAST_UPDATE_TIMESTAMP`, `LAST_UPDATE_USER`, `PWD_UPD_DATE`, `DEFAULT_ENVIRON_ID`, `USER_STATUS`, `SYS_ACCT_STTS`, `WEBUI_ROLE_ID`, `FIRST_LOGIN_DT`, `LAST_LOGOUT_DT`, `LAST_LOGIN_IP`, `MC_STATUS`, `MC_OPT`, `REMARKS`, `MAKER_USER`, `MAKER_DT`, `CHECKER_USER`, `CHECKER_DT`, `P_USER_NAME`, `P_USER_GROUP`, `P_USER_DEPARTMENT`, `P_USER_EMAIL_ID`, `P_USER_SECURITY_PROFILE`, `P_DEFAULT_ENVIRON_ID`, `P_DEFAULT_LOCALE`, `P_USER_STATUS`, `P_SYS_ACCT_STTS`, `P_WEBUI_ROLE_ID`, `DEFAULT_LOCALE`, `P_2FA_FLAG`, `2FA_FLAG`) VALUES ('dxp ops stg', 'dxp ops stg', 'dxp ops stg', 'Admin', '', 'LBBJQJPbY6o3AUdbWpnLD5vNvuqow9HUp4JVIuPYgvlppEF2b46bb2a0Fc4706A6563480Cb1d9d375a0DaB02DCd7e8fB4dhFC3S7kYpDVrlyxM6rh454CEmntq+1GX0g36fsWyg==', '1852', 'karthik@mvitech.com', 'BatchAdminUIUser', '0', '2023-07-05 19:30:07', '2022-08-05 17:48:55', '2023-07-05 19:30:07', 'hlfspguser', '2019-10-24 21:23:05', 'PRA1_CMM', 'A', 'NR', '10', '2018-05-16 15:33:16', '2017-09-18 13:45:54', '10.161.30.221', 'Approved', 'UPDATE', '', 'pmaker', '2017-09-18 13:43:25', 'pchecker', '2017-09-18 13:45:05', 'hlbspguser', 'Admin', '', 'hlbspguser@mvitech.com', 'BatchAdminUIUser', 'PRA1_CMM', 'en-US', 'A', 'NR', '10', 'EN-US', 'N', 'N');

Select * from hlfdxp_pras_sys.usersecurityprofileobject where PROFILE_ID IN (47);

-- 1,6,7 & 10;
-- PWD-UPD-DATE
-- Password Fields 
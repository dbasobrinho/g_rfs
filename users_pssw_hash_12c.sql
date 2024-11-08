-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : users_pssw_hash_12c.sql                                         |
-- | CREATOR  : ROBERTO FERNANDES SOBRINHO                                      |
-- | DATE     : 21/02/2019 (amanha e meu aniversario, VIVA!)                    |
-- +----------------------------------------------------------------------------+
set linesize 2000;
set pagesize 1000;
set long 9999999;
set longchunksize 500
set TRIMS on;
set ECHO off;rm -f 
set FEED off; 
set HEAD off;
SET VERIFY      OFF;     
COLUMN DDL  FORMAT a400;
COLUMN comm FORMAT a400;
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | HASH USERNAME ORACLE 12C >                   [users_pssw_hash_12c.sql] |
PROMPT +------------------------------------------------------------------------+
PROMPT
ACCEPT UUXX     char   PROMPT 'USER NAME = '
select dbms_metadata.get_ddl('USER','&&UUXX') from dual
/
PROMPT.
PROMPT.
PROMPT.
--select 'ALTER USER '||'UUXX'||' IDENTIFIED BY VALUES '''||spare4||''';'comm  from sys.user$ where name = 'NIMMON';
select 'alter user '||username||' identified by values '||
       REGEXP_SUBSTR(DBMS_METADATA.get_ddl ('USER',USERNAME), '''[^'']+''')||';' as DDL 
  from dba_users where username = '&&UUXX'
/
set FEED on;
set HEAD on;
set time on;
SET FEEDBACK on                
PROMPT.                                                                                ______ _ ___ 
PROMPT.                                                                               |_  / _` / __| +-+-+-+-+-+-+-+-+-+-+
PROMPT.                                                                    _   _   _   / / (_| \__ \ |r|f|s|o|b|r|i|n|h|o|
PROMPT.                                                                   (_) (_) (_) /___\__,_|___/ +-+-+-+-+-+-+-+-+-+-+
PROMPT 
set FEED on; 
set HEAD on;


-----NIMMON
-----
-----
-----select spare4 from sys.user$ where name = 'x';
-----
-----create user x identified by x;
-----
-----
-----select dbms_metadata.get_ddl('USER','NIMMON') from dual;
-----
-----
-----
-----
-----   CREATE USER "X" IDENTIFIED BY VALUES 'S:EC1F07DD01FA6973A633E93118D4F33B3B91B976E56CC36A52419B99C73A;T:EA9B3A822BB643123A5EECE09A56F52A96092CD44F284404855D1EF3BA0AA24B7F3909CEAC953DEA3A6296D58E1C68486574BAE86BA8F3C340F1F782545A89160569C683737C8847BBDCE010C61115A4'
-----      DEFAULT TABLESPACE "USERS"
-----      TEMPORARY TABLESPACE "TEMP"
-----	  
-----
-----alter user X identified by values 'S:EC1F07DD01FA6973A633E93118D4F33B3B91B976E56CC36A52419B99C73A;T:EA9B3A822BB643123A5EECE09A56F52A96092CD44F284404855D1EF3BA0AA24B7F3909CEAC953DEA3A6296D58E1C68486574BAE86BA8F3C340F1F782545A89160569C683737C8847BBDCE010C61115A4';
-----
-----
----- ALTER USER X IDENTIFIED BY VALUES IDENTIFIED BY VALUES 'S:EC1F07DD01FA6973A633E93118D4F33B3B91B976E56CC36A52419B99C73A;T:EA9B3A822BB643123A5EECE09A56F52A96092CD44F284404855D1EF3BA0AA24B7F3909CEAC953DEA3A6296D58E1C68486574BAE86BA8F3C340F1F782545A89160569C683737C8847BBDCE010C61115A4'


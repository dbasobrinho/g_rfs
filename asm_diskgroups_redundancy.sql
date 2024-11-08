-- +--------------------------------------------------------------------------------------+
-- | Goal        : ASM free space according to the redundancy level of the disks          |
-- | Reference   : https://sgbdbrasil.wordpress.com/2022/06/07/asm-disk-group-free-space/ |
-- | Modified by : Marcelo de Siqueira                                                    |
-- +--------------------------------------------------------------------------------------+

SET SERVEROUTPUT ON
SET LINES 155
SET PAGES 0
SET TRIMSPOOL ON
 
DECLARE
   v_space_reserve_factor NUMBER := 0.15;
   v_num_disks    NUMBER;
   v_group_number   NUMBER;
   v_max_total_mb   NUMBER;
   v_max_used_mb    NUMBER;
   v_fg_count   NUMBER;
 
   v_required_free_mb   NUMBER;
   v_usable_mb      NUMBER;
   v_cell_usable_mb   NUMBER;
   v_one_cell_usable_mb   NUMBER;
   v_enuf_free      BOOLEAN := FALSE;
   v_enuf_free_cell   BOOLEAN := FALSE;
 
   v_req_mirror_free_adj_factor   NUMBER := 1.10;
   v_req_mirror_free_adj         NUMBER := 0;
   v_one_cell_req_mir_free_mb     NUMBER  := 0;
 
   v_disk_desc      VARCHAR(10) := 'SINGLE';
   v_offset      NUMBER := 50;
   v_inst_name    VARCHAR2(16);
 
   v_dg_pct_msg   VARCHAR2(500);
   v_cfc_fail_msg VARCHAR2(500);
   

 
BEGIN

SELECT instance_name INTO v_inst_name FROM v$instance;

DBMS_OUTPUT.PUT_LINE('+--------------------------------------------------------------------------------------------------------------------------+');
DBMS_OUTPUT.PUT_LINE('| REPORT        - ASM Diskgroups                                                                                           |');
DBMS_OUTPUT.PUT_LINE('| INSTANCE NAME - '||rpad(v_inst_name,105)||'|');
 
-- Set up headings
      DBMS_OUTPUT.PUT_LINE('+--------------------------------------------------------------------------------------------------------------------------+');
      DBMS_OUTPUT.PUT('| DG NAME  ');
      DBMS_OUTPUT.PUT('| TYPE    ');
      DBMS_OUTPUT.PUT('| FG  ');
      DBMS_OUTPUT.PUT('| NUM DISKS ');
      DBMS_OUTPUT.PUT('| OS DISK SIZE   ');
      DBMS_OUTPUT.PUT('| DISKGROUP SIZE ');
      DBMS_OUTPUT.PUT('| DISKGROUP USED ');
      DBMS_OUTPUT.PUT('| DISKGROUP FREE ');
      DBMS_OUTPUT.PUT('| PCT UTIL  ');	  
      DBMS_OUTPUT.PUT_LINE('    |');
      DBMS_OUTPUT.PUT('|          ');
      DBMS_OUTPUT.PUT('|         ');
      DBMS_OUTPUT.PUT('|     ');
      DBMS_OUTPUT.PUT('|           ');
      DBMS_OUTPUT.PUT('| MB             ');  
      DBMS_OUTPUT.PUT('| MB             ');
      DBMS_OUTPUT.PUT('| MB             ');
      DBMS_OUTPUT.PUT('| MB             ');
      DBMS_OUTPUT.PUT('|           ');
      DBMS_OUTPUT.PUT_LINE('    |');
      DBMS_OUTPUT.PUT_LINE('+--------------------------------------------------------------------------------------------------------------------------+');
 
   FOR dg IN (SELECT name, type, group_number, total_mb, free_mb, required_mirror_free_mb FROM v$asm_diskgroup ORDER BY name) LOOP
 
      v_enuf_free := FALSE;
 
      -- Find largest amount of space allocated to a cell
      SELECT sum(disk_cnt), max(max_total_mb), max(sum_used_mb), count(distinct failgroup)
     INTO v_num_disks,v_max_total_mb, v_max_used_mb, v_fg_count
      FROM (SELECT failgroup, count(1) disk_cnt, max(total_mb) max_total_mb, sum(total_mb - free_mb) sum_used_mb
      FROM v$asm_disk
     WHERE group_number = dg.group_number and failgroup_type = 'REGULAR'
     GROUP BY failgroup);
 
   v_required_free_mb := v_space_reserve_factor * dg.total_mb;
   IF dg.free_mb > v_required_free_mb THEN v_enuf_free := TRUE; END IF;
 
    IF dg.type = 'NORMAL' THEN
 
         -- DISK usable file MB
         v_usable_mb := ROUND((dg.free_mb - v_required_free_mb)/2);
 
    ELSIF dg.type = 'HIGH' THEN
         -- HIGH redundancy
         -- DISK usable file MB
         v_usable_mb := ROUND((dg.free_mb - v_required_free_mb)/3);
          
    ELSIF dg.type = 'EXTEND' THEN
         -- EXTENDED redundancy for stretch clusters
 
         -- DISK usable file MB
         v_usable_mb := ROUND((dg.free_mb - v_required_free_mb)/4);
 
     ELSE
        -- We don't know this type...maybe FLEX DG - not enough info to say 
        v_usable_mb := NULL;
 
    END IF;
       
      DBMS_OUTPUT.PUT('|'||RPAD(dg.name,v_offset-40));
      DBMS_OUTPUT.PUT('|'||RPAD(nvl(dg.type,'  '),v_offset-41));
      DBMS_OUTPUT.PUT('|'||LPAD(TO_CHAR(v_fg_count),v_offset-45));
      DBMS_OUTPUT.PUT('|'||LPAD(TO_CHAR(v_num_disks),v_offset-39));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(v_max_total_mb,'999,999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(dg.total_mb,'999,999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(dg.total_mb - dg.free_mb,'999,999,999,999'));
      DBMS_OUTPUT.PUT('|'||TO_CHAR(dg.free_mb,'999,999,999,999'));
 
     -- Calc Disk Utilization Percentage
      IF dg.total_mb > 0 THEN
         DBMS_OUTPUT.PUT_LINE('|        '||TO_CHAR((((dg.total_mb - dg.free_mb)/dg.total_mb)*100),'999.9')||CHR(37)||'|');
      ELSE
         DBMS_OUTPUT.PUT_LINE('|               |');
      END IF;
 
	  --IF v_enuf_free THEN
	  --DBMS_OUTPUT.PUT('|');
	  --ELSE
	  --DBMS_OUTPUT.PUT('|');
	  --END IF;
 
   END LOOP;
 
     DBMS_OUTPUT.PUT_LINE('+--------------------------------------------------------------------------------------------------------------------------+');
   <<the_end>>
 
   DBMS_OUTPUT.PUT_LINE(v_dg_pct_msg);
 
END;
/
WHENEVER SQLERROR EXIT FAILURE;

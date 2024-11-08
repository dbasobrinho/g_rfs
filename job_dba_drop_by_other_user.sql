-- apagar job de outro usuario
begin
  dbms_ijob.remove(&NUMERO_JOB);
end;
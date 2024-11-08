-- apagar job somente do usuario logado 
begin    
    DBMS_JOB.REMOVE(&NUMERO_JOB);
end;
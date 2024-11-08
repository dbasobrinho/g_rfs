latch_shared_pool_sumulation

declare
  i number;
begin
  for i in 1 .. 100000000 loop
    for i in 1 .. 100000000 loop
      for i in 1 .. 100000000 loop
        for i in 1 .. 100000000 loop
          for i in 1 .. 100000000 loop
            execute immediate 'begin dbms_application_info.set_client_info(''mutex'');end;';
          end loop;
        end loop;
      end loop;
    end loop;
  end loop;
end;
/

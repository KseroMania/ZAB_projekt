%macro Liczba_brakow_danych(input);
%global colnames;
proc datasets lib=work nolist;
delete temp Wynik_liczba_brakow_danych;
run;

proc sql noprint;
select name into :colnames separated by " "
from dictionary.columns
where upcase(libname)=upcase("%scan(&input,1,'.')") 
and upcase(MEMNAME)=upcase("%scan(&input,2,'.')");
quit;
%let obs=&sqlobs;
%do i=1 %to &obs;
  %let var=%scan(&colnames, &i, ' ');
  proc sql;
  create table temp as
  select &var is null as czy_null
    , "&var" as Zmienna length=100,
    count(*) as CNT
  from &input
  group by 1
  ;quit;
  
  proc append base=Wynik_liczba_brakow_danych data=temp;
  run;
%end;
proc sort data=Wynik_liczba_brakow_danych;
by descending czy_null descending cnt;
run;

proc delete data=temp;
run;
%mend;


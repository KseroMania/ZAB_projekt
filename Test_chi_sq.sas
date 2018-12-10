/*W outpucie zwraca �adn� tabel� kt�ra nie wymaga wiele obr�bki przed przeniesieniem*/
%macro Test_chi_sq(input, target, variables);
proc delete data=WynikChiSq;
run;

%do i=1 %to %sysfunc(countw(&variables));
/*%do i=1 %to 1;*/
  %let var=%scan(&variables,&i);
  ods output ChiSq=Chisq;

  proc freq data=&input;
  title "Test niezale�no�ci chi-square zale�no�ci mi�dzy &target a &var";
  title2 "H0: Nie ma zale�no�ci mi�dzy zmiennymi H1: Jest zale�no��.";
  tables &target*&var / norow nocol nopercent chisq noprint;
  run;
  proc sql;
  create table temp as
  select 
    compress(scan(table,-1,'*')) as zmienna
    , statistic as Statystyka
    , df as Stopnie_swobody
    , value as Wartosc_statystyki_testowej
    , prob as P_value
  from chisq
  where statistic in ("Chi-kwadrat", "V Cramera", "Chi-Square", "Cramer's V");
  quit;

  proc append base=WynikChiSq data=temp;
  run;
  
%end;
proc datasets lib=work;
delete temp chisq;
run;

proc sql noprint;
create table wynikchisq as
select t1.*, t2.label
from wynikchisq t1
left join dictionary.columns t2
on upcase(t1.zmienna) = upcase(t2.name) and upcase(t2.memname)=upcase(scan("&input", 2, '.'))
order by Statystyka, Wartosc_statystyki_testowej descending
;quit;

%mend;
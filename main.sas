%let lokalizacja=C:\Projekty\ZAB\Projekt_ZAB;
libname IN "&lokalizacja";
%include "&lokalizacja\Liczba_brakow_danych.sas";
%include "&lokalizacja\Test_chi_sq.sas";



proc sql noprint;
create table temp1 as
select distinct mnactic, coalesce(mnactic)
from in.ESSPL
;quit;

proc sql noprint;
create table PRE_1 as
select 
case 
  when HINCTNTA >= 9 then 1
  when HINCTNTA = . then .
  else 0
end as CZY_90_PERC,
case when eisced in (1,2) then 'Podstawowe/gimnazjalne'
    when eisced in (3,4) then 'Srednie'
    when eisced in (5) then 'Srednie zawodowe'
    when eisced in (6, 7) then 'Wyzsze'
  end as edukacja,
case when eisced in (1,2,3,4,5) then 0
    when eisced in (6, 7) then 1
  end as czy_wyzsze,
eisced,
case when netusoft in (1,2) then 0
    when netusoft in (3,4,5) then 1
end as czy_uzywa_internetu,
netusoft,
case when smdfslv in (1,2,3) then 1
      when smdfslv in (4,5) then 0
end as czy_rownosciowy,
case when lvgptnea = 1 then 1
    when lvgptnea = 2 then 0
end as konkubinat,
agea as wiek
from in.ESSPL
;quit;

%Liczba_brakow_danych(WORK.PRE_1);
%Test_chi_sq(WORK.PRE_1, CZY_90_PERC, 
czy_wyzsze
wiek
czy_uzywa_internetu
czy_rownosciowy
konkubinat
);
title '';
ods pdf file="&lokalizacja.\wyniki.pdf";
proc mi data = PRE_1 out = POST_1 nimpute = 5 seed = 35399;

class CZY_90_PERC czy_wyzsze
czy_uzywa_internetu
czy_rownosciowy
konkubinat;
var  czy_wyzsze wiek  
czy_uzywa_internetu
czy_rownosciowy
konkubinat CZY_90_PERC;


fcs logistic(CZY_90_PERC czy_wyzsze  czy_uzywa_internetu czy_rownosciowy konkubinat) reg(wiek);
run;
ods output ParameterEstimates=lgparms;
proc logistic data=work.post_1;
class 
czy_wyzsze
czy_uzywa_internetu
czy_rownosciowy
konkubinat
;
model CZY_90_PERC(event='1') = 
czy_wyzsze
wiek
/*wiek_2*/
czy_uzywa_internetu
czy_rownosciowy
konkubinat
;
by _imputation_;
run;

proc mianalyze parms=lgparms;
modeleffects Intercept czy_wyzsze
wiek
czy_uzywa_internetu
czy_rownosciowy
konkubinat;
run;

ods pdf close;
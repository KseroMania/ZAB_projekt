
%macro sprawdzaj_zm(variables);
proc delete data=wynik_dodawania;
run;
%do i=1 %to %sysfunc(countw(&variables));
/*%do i=1 %to 2;*/
  %let var=%scan(&variables,&i);
  ods output Association=myAssociation( where=(Label2 = "Somers' D") keep=Label2 nValue2);
  proc logistic data=work.pre_1;
  class 
  czy_wyzsze
  czy_uzywa_internetu
  czy_rownosciowy
  czy_zyl_w_konkubinacie
  &var
  ;
  model CZY_90_PERC(event='1') = 
  czy_wyzsze

  czy_uzywa_internetu
  czy_rownosciowy
  czy_zyl_w_konkubinacie
  &var
  ;
  run;
  ods output close;
  data myAssociation;
  length var $100;
  set myAssociation;
  var="&var";
  run;
  proc append base=wynik_dodawania data=myAssociation;
  run;
%end;
proc sort data=wynik_dodawania;
by descending nvalue2 ;
run;
%mend;
%sprawdzaj_zm(&zmienne);
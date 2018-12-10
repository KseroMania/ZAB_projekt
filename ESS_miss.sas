* MISSING VALUES;
*data ;
*set  ;
array n _numeric_;
array c _character_;
do over n;
  if prxmatch("/Not .p+lic+able/", vvalue(n)) then n=. ;
  if prxmatch("/Refus../", vvalue(n)) then n=. ;
  if prxmatch("/Don.?t .now/", vvalue(n)) then n=. ;
  if prxmatch("/(No .nswer)|(Not .vailable)/", vvalue(n)) then n=. ;
end;
do over c;
  if prxmatch("/(Not .p+lic+able)|(Refus..)|(Don.?t .now)|(No .nswer)|(Not .vailable)/",vvalue(c)) then c="   ";
end;
run;


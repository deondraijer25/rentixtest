unit ClientRunMode;

interface

{
 run parameters:

 /auto  automatische mode = 1
 /beheer     beheer mode = 2
 /admin      admin-mode = 3
 /adminAuto  admin-mode = 4
}


type
  TRunmode = (rmNone, rmAuto, rmBeheer, rmAdmin, rmAdminAuto, rmStil);

var
  Runmode : TRunMode;
  StilleMode : Boolean;

const
  rmAutoString = '/auto';
  rmBeheerString = '/beheer';
  rmAdminString = '/admin';
  rmAdminAutoString = '/adminauto';
  rmStilString = '/stil';

procedure CheckRunMode; forward;
procedure Melding(s:string; Show : boolean = true);
procedure AddToLog(s:string);

implementation

uses
  SysUtils, Dialogs, u_Utility;

procedure CheckRunMode;
var
  s:string;
begin
  StilleMode := False;
  if ParamCount >0 then begin
    s := lowercase(ParamStr(1));
    runmode := rmNone;
    if s = rmAutoString then runmode := rmauto;
    if s = rmBeheerString then runmode := rmBeheer;
    if s = rmAdminString then runmode := rmAdmin;
    if s = rmAdminAutoString then runmode := rmAdminAuto;
  end;
  if ParamCount >1 then begin
    s := lowercase(ParamStr(2));
    if s = rmStilString then StilleMode := True;
  end;
end;

procedure AddToLog(s:string);
var
  f:textfile;
  fn:string;
  t:string;
  code: integer;
  i:integer;
begin
//ShowMessage('AddToLog   ' + s);
  t := DateTimeToStr(now);
  code := 0;
  for i := 1 to length(t) do begin
    if t[i] in ['0'..'9'] then begin
      code := code + ord(t[i]) - 48;
    end;
  end;
  s := t + ' (' + inttostr(code) + ') ' + s;
  fn := IncludeTrailingPathDelimiter(TUtility.AppRoot) + 'rentix.log';
  AssignFile(f,  fn);
  try
    if not FileExists(fn) then begin
      Rewrite(f);
      writeln(f, t + ' Log gestart.');
      Closefile(f);
    end;
    Append(f);
    writeln(f, s);
    Closefile(f);
  except
    on e:exception do begin
      if not StilleMode then begin
        ShowMessage('Rentixlog kan niet worden beschreven.'#13'Filenaam: ' + fn + #13 + e.message);
      end;
    end;
  end;
end;

procedure Melding(s:string; Show : boolean = true);
begin
  AddToLog(s);
  //if (not StilleMode) and show then begin
    //ShowMessage(s);
  //end;
end;


end.

unit RentixLicentie;

interface

uses
  Classes;

const
  licdir = 'licentie\';
  licext = '.lic';
  sectie = 'Licentie';

{
Het idee van de licenties in de Rentix webservice is dat elke licentie zijn
eigen ini-bestand heeft. Deze bestanden staan in de directory ../licentie

Reden voor losse bestanden: als elke licentie in hetzelfde file staat komt
de multi-using in gevaar. Nu is dat veel eenvoudiger.

De ini heet naar het RentixID van de klant indien deze al geactiveerd is.
Ongeactiveerde klantlicenties heten naar hun licentienummer.
Beide bestanden hebben extensie .lic en staan in de subdirectory "licentie"

Dit zou natuurlijk eenvoudig opgelost kunnen worden door een access-database
maar omdat dit eisen legt aan de webserver, wil ik dit niet doen.

[edit] ik weet nu dat benaderen van een access-database geen enkel probleem is
op de server....maar ik laat het maar even zo
}

Function CreateID(LicentieCode:string; WindowsID:string) : String; forward;
Function GetLastDatum(RentixID:string):TdateTime;   forward;
Function SetLastDatum(RentixID:string; aDatum:TdateTime; LogMelding:boolean=true) :boolean; forward;
Function AddNewLicentie(Naam:string; LicentieCode:string; var fout:integer) :boolean;forward;
Function ActiveerLicentie(LicentieCode:string; WindowsID:string) : String; forward;
function ControleerRentixID(aRentixID:string; var Fout : integer) : boolean; forward;
function ResetLicentieCode(Licentiecode:string) : boolean; forward;
function KillLicentieCode(Licentiecode:string) : boolean; forward;
function RenameLicentieCode(OudRentixID:string; NieuwePrefix : string) : boolean; forward;
function Extractlicentie(aRentixID:string) : string; forward;

implementation

uses
  RentixLog, WebserviceLock, SysUtils, inifiles, DateUtils;


function Extractlicentie(aRentixID:string) : string;
var
  i:integer;
begin
  result :='';
  for i:= 1 to length(aRentixID) do begin
    if odd(i) then begin
      result := result + aRentixID[i];
    end;
  end;
end;



function CodeerDatumTijd(aDatum:TDateTime) : string;
var
  r:string;
  y,m,d,h,n,s,s100:word;
begin
  DecodeDateTime(aDatum,y,m,d,h,n,s,s100);
  r := inttostr(y) + ',';
  r := r + inttostr(m) + ',';
  r := r + inttostr(d) + ',';
  r := r + inttostr(h) + ',';
  r := r + inttostr(n) + ',';
  r := r + inttostr(s) + ',';
  result := r;
end;

function DecodeerDatumTijd(r:String) : TDateTime;
  function part(var s:string; def:integer) : integer;
    var i:integer;
  begin
    i:= pos(',',s);
    result := strtointdef( copy(s,1,i-1) , def);
    delete(s,1,i);
  end;
var
  y,m,d,h,n,s:word;
begin
  y := part(r, 1980);
  m := part(r, 1);
  d := part(r, 1);
  h := part(r, 12);
  n := part(r, 0);
  s := part(r, 0);
  result := EncodeDateTime(y,m,d,h,n,s,0);
end;

function ControleerRentixID(aRentixID:string; var fout:integer) : boolean;
begin
  result := True;
  fout :=0;
  exit;

  {
  geen controle op aparte rentix-licentie meer nodig !  (rk 7 mrt 2008)

  if FileExists(datapath + licdir + aRentixID + licext) then begin
    if getlastDatum(aRentixID) >= date then begin
      fout := -1;
    end else begin
      fout:=0;
      result := true;
    end;
  end else begin
    fout := -2;
  end;
  }
end;

function ActiveerLicentie(LicentieCode, WindowsID: string): String;
var
  f:TIniFile;
  Oke : boolean;
  naam:string;
  RentixID : string;
begin
  if FileExists(datapath + licdir + licentiecode + licext) then begin

    oke := false;

    //lees de naam uit de licentie-file
    try
      f := TIniFile.Create(datapath + licdir + licentiecode + licext);
      Naam := f.ReadString('Licentie', 'Naam', '');
      f.Free;
    except
      Naam := 'Onbekend';
    end;

    try
      RentixID := CreateID( LicentieCode, WindowsID);
      Result := RentixID;

      f := TIniFile.Create(datapath + licdir + RentixID + licext);
      f.WriteString(sectie, 'Licentiecode', LicentieCode);
      f.WriteString(sectie, 'WindowsID', WindowsID);
      f.WriteString(sectie, 'Naam', Naam);
      f.WriteString(sectie, 'RentixID', RentixID );
      f.WriteString(sectie, 'AanmaakDatum', CodeerDatumTijd(now));
      f.WriteString(sectie, 'AccessDatum', CodeerDatumTijd(now -1));
      f.free;

      AddToLogLicentie(LicentieCode, 'Licentie geactiveerd. Naam: ' + Naam + ' Licentiecode: ' + LicentieCode + ' WindowsID: ' + WindowsID + ' RentixID: ' + RentixID);
      AddToLogLicentie('', 'Licentie geactiveerd. Naam: ' + Naam + ' Licentiecode: ' + LicentieCode + ' WindowsID: ' + WindowsID + ' RentixID: ' + RentixID);
      oke:=true;
    except
      AddToLog('', 'Mislukte licentie activatie. Naam: ' + Naam + ' Licentiecode: ' + LicentieCode + ' WindowsID: ' + WindowsID + ' RentixID: ' + RentixID);
      Result := '';
    end;

    if oke then begin
      DeleteFile (datapath + licdir + licentiecode + licext);
    end;

  end else begin
    AddToLog('', 'Mislukte licentie activatie. Het licentiebestand van licentie : ' + licentiecode + ' niet gevonden.');
    result := '';
  end;
end;

function AddNewLicentie(Naam, LicentieCode: string; var fout:integer) : boolean;
var
  f:Tinifile;
begin
  //Server functionality only!
  if FileExists(datapath + licdir + LicentieCode + licext) then begin
    Fout := -1;
    result := false;
  end else begin
    try
      f := TIniFile.Create(datapath + licdir + LicentieCode + licext);
      f.WriteString(sectie, 'Naam', Naam);
      f.WriteString(sectie, 'Licentiecode', LicentieCode);
      f.WriteString(sectie, 'AanmaakDatum', CodeerDatumTijd(now));
      f.free;

      result := (FileExists(datapath + licdir + licentiecode + licext));
      fout := 0;
    except
      fout := -2;
      result :=false;
    end;
  end;
end;

function CreateID(LicentieCode, WindowsID: string): String;
const
  valid = ['a'..'z', '0'..'9', 'A'..'Z',' ','-','_'];
var
  len,i:integer;
begin
  if length(LicentieCode)> length(WindowsID) then begin
    len := length(WindowsID);
  end else begin
    len := Length(LicentieCode);
  end;
  AddToLogLicentie(LicentieCode,'CreateID Licentiecode: ' + LicentieCode + ' WindowsID: ' + WindowsID);
  for i := 1 to len do begin
    if LicentieCode[i] in valid then begin
      result := result + LicentieCode[i];
    end;
    if WindowsID[i] in valid then begin
      result := result + WindowsID[i];
    end;
  end;
end;

function GetLastDatum(RentixID: string): TdateTime;
var
  f:TIniFile;
  tijd : string;
begin
  if FileExists(datapath + licdir + RentixID + licext) then begin
    f := TIniFile.create( datapath + licdir + RentixID  + licext);
    tijd := f.ReadString(sectie, 'AccessDatum', CodeerDatumTijd(30000));
    Result := DecodeerDatumTijd(tijd);
    //AddToLog(RentixID, 'GetLastDatum succesvol.');
  end else begin
    AddToLog('','GetLastDatum mislukt omdat bestand met RentixID : ' + RentixID +' niet gevonden kon worden.');
    AddToLog(RentixID,'GetLastDatum mislukt omdat bestand ' + RentixID + licext + ' niet gevonden kon worden.');
    Result := StrToDate('30000');
  end;
end;

Function SetLastDatum(RentixID: string; aDatum: TdateTime; LogMelding:boolean=true):Boolean;
var
  f:TIniFile;
begin
  if FileExists(datapath + licdir + RentixID + licext) then begin
    f := TIniFile.create( datapath + licdir + RentixID  + licext);
    f.WriteString(sectie, 'AccessDatum', CodeerDatumTijd(aDatum));
    f.Free;
    AddToLog(rentixID, 'SetLastDatum succesvol.');
    if LogMelding then begin
      AddToLog('', 'Einde Rentixupdate van rentixID ' + rentixID);
    end;
    result := true;
  end else begin
    AddToLog(Rentixid, 'SetLastDatum mislukt omdat bestand ' + RentixID + licext +' niet gevonden kon worden.');
    AddToLog('', 'SetLastDatum mislukt omdat bestand met RentixID : ' + RentixID +' niet gevonden kon worden.');
    result := false;
  end;
end;

function ResetLicentieCode(Licentiecode:string) : boolean;
var
  s:TSearchRec;
  nietsmeer, gevonden:boolean;
  f:TIniFile; 
  lic, naam:string;
  aanmaak : string;
begin
  AddToLogLicentie(Licentiecode,  'Licentie reset');
  AddToLog('', 'Licentie reset voor licentiecode ' + Licentiecode);

  gevonden := false;
  nietsmeer := false;
  lic := '';
  if FindFirst(datapath + licdir + '*.lic', faAnyFile, s ) = 0 then begin
    while (not gevonden) and (not nietsmeer) do begin
      f := TIniFile.Create(datapath + licdir +s.Name);
      lic := f.ReadString('licentie', 'licentiecode','');
      naam := f.ReadString('licentie', 'naam','');
      aanmaak := f.ReadString('licentie', 'aanmaakdatum',''); 
      f.Free;
      
      if lowercase(trim(lic)) = lowercase(trim(Licentiecode)) then begin
        if DeleteFile (datapath + licdir + s.Name) then begin
          try
            f := TIniFile.Create(datapath + licdir + Lic + licext);
            f.WriteString(sectie, 'Naam', Naam);
            f.WriteString(sectie, 'Licentiecode', Lic);
            f.WriteString(sectie, 'AanmaakDatum', aanmaak);
            f.free;
          except
            AddToLog('','TIniFile.Create/writeln(f) mag niet');
          end;
        end else begin
          AddToLog('','deletefile mag niet');
        end;

        gevonden := true;
      end;
      nietsmeer := (FindNext(s) <>0);
    end;
    FindClose(s);
  end;
  if lic<>'' then begin
    result := gevonden and (FileExists(datapath + licdir + lic + licext));   
  end else begin
    result := false;
  end;

end;

function RenameLicentieCode(OudRentixID:string; NieuwePrefix : string) : boolean;
var
  oldprefix, newID,fn,OldLic,NewLic : string;
  f:TIniFile;

begin
  result := True;
  fn := datapath + licdir + OudRentixID + '.lic';

  oldlic := Extractlicentie(OudRentixID);
  oldprefix := OudRentixID[1] + OudRentixID[3] + OudRentixID[5];
  newID := OudRentixID;
  newID[1] := nieuweprefix[1];
  newID[3] := nieuweprefix[2];
  newID[5] := nieuweprefix[3];
  NewLic := Extractlicentie(NewID);
  if FileExists(fn) then begin
    f := TIniFile.Create(fn);
    f.WriteString('licentie', 'licentiecode',NewLic);
    f.WriteString('licentie', 'RentixID',newID);
    f.WriteString('licentie', 'PrefixHistory',oldprefix);
    f.WriteString('licentie', 'AccessDatum',CodeerDatumTijd(now));
    f.Free;
    if not RenameFile(fn, datapath + licdir + NewID + '.lic') then begin
      AddToLogLicentie(OudRentixID, 'RenameLicentieCode: Licentiebestand kon niet worden hernoemd.');
      result := false;
    end;
    if FileExists(datapath + licdir + 'RentixLog\' + oldlic + '.txt') then begin
      RenameFile(datapath + licdir + 'RentixLog\' + oldlic + '.txt', datapath + licdir + 'RentixLog\' + NewLic + '.txt');
      AddToLogLicentie(OudRentixID, 'RenameLicentieCode: log van de oude licentie ( '+ oldlic + '.txt ) hernoemd naar nieuwe licentie (' + newlic + '.txt).');
    end;
  end else begin
    //misschien is de licentie nog niet geactiveerd...
    fn := datapath + licdir + oldlic + '.lic';
    if FileExists(fn) then begin
      f := TIniFile.Create(fn);
      f.WriteString('licentie', 'licentiecode', NewLic);
      f.WriteString('licentie', 'PrefixHistory',oldprefix);
      f.free;
      if not RenameFile(fn, datapath + licdir + newlic + '.lic') then begin
        AddToLog('','RenameLicentieCode: Licentiebestand ' +fn + ' kon niet worden hernoemd.');
        result := false;
      end;
    end else begin
      AddToLogLicentie(OudRentixID, 'RenameLicentieCode: oude licentie ' + OudRentixID + '.lic niet gevonden en '+ oldlic + '.lic ook niet.');
      result := false;
    end;
  end;
end;

function KillLicentieCode(Licentiecode:string) : boolean;
var
  s:TSearchRec;
  nietsmeer:boolean;
  f:TIniFile;
  lic, naam:string;
  aanmaak : string;
begin

  AddToLogLicentie(licentiecode, 'Licentie delete/kill');
  AddToLog('', 'Licentie delete/kill voor licentie ' + Licentiecode);
  result := false;
  nietsmeer := false;
  lic := '';
  if FindFirst(datapath + licdir + '*.lic', faAnyFile, s ) = 0 then begin
    while (not result) and (not nietsmeer) do begin
      f := TIniFile.Create(datapath + licdir +s.Name);
      lic := f.ReadString('licentie', 'licentiecode','');
      naam := f.ReadString('licentie', 'naam','');
      aanmaak := f.ReadString('licentie', 'aanmaakdatum','');
      f.Free;

      if lowercase(trim(lic)) = lowercase(trim(Licentiecode)) then begin
        result := true;
        if DeleteFile (datapath + licdir + s.Name) then begin
          AddToLog('','deletefile mag niet');
        end;
      end;
      nietsmeer := (FindNext(s) <>0);
    end;
    FindClose(s);
  end;
end;

end.

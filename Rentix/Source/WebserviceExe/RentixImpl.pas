{ Invokable implementation File for TRentix which implements IRentix }

unit RentixImpl;

interface

uses Windows, InvokeRegistry, Types, XSBuiltIns, RentixIntf, classes;

type

  { TRentix }
  TRentix = class(TInvokableClass, IRentix)
  private
    procedure CheckNieuweRenteUpdates(MaatschappijID:integer;rentepad, patchpad: string);
    procedure CheckNieuweRenteUpdatesV2(FinixID: Widestring; MaatschappijID:integer;rentepad, patchpad: string);
    function Checkfinixlicentie(FinixID:Widestring): boolean;
    function Setlastrentixdatum(FinixID:Widestring): boolean;
    function checkInitRentixed(FinixID: widestring): boolean;
  public
    Function TestMe : WideString; stdcall;
    Function GetRentixID(LicentieCode : Widestring; WindowsID:Widestring) : WideString; stdcall;
    Function GetUpdateLijst(FinixID:Widestring;var fout:integer) : WideString; stdcall;
    Function GetRenteBestand(FinixID:Widestring; MaatschappijID:Integer; var fout:integer) : TSOAPAttachment; stdcall;

    Function GetRenteBestandV2(FinixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : integer; var ServerLaatsteDatum : integer; var fout:integer) : TSOAPAttachment; stdcall;
    Function GetRenteBestandV3(FinixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : TDateTime; var ServerLaatsteDatum : TDateTime; var fout:integer) : TSOAPAttachment; stdcall;
    Function GetRenteBestandV4(FinixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : TDateTime; var ServerLaatsteDatum : TDateTime; var fout:integer) : TSOAPAttachment; stdcall;
    Function GetRenteBestandV5(FinixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : TDateTime; var ServerLaatsteDatum : TDateTime; var fout:integer; NieuweRentesOphalen:boolean) : TSOAPAttachment; stdcall;
    function GetRenteBestandV6(FinixID: Widestring; MaatschappijID: Integer; var fout: integer; NieuweRentesOphalen: boolean): TSOAPAttachment; stdcall;

    Function PutRenteUpdateBestand(aMaatschappijID:integer; aBestand : TSOAPAttachment; aIngangsdatum : TdateTime; Password : string;Gebruiker:string; Overwrite:boolean) : integer; stdcall;
    Function UpdateAccessDatum(FinixID:Widestring) : Boolean; stdcall;
    Function AddLicentie(Naam:Widestring; LicentieCode : Widestring; Password:Widestring; var fout:integer): boolean; stdcall;
    function ResetClientUpdateDatum(FinixID:WideString; Password:Widestring):boolean; stdcall;
    function ResetLicentie(Licentie : widestring; Password: Widestring): boolean; stdcall;
    function KillLicentie(Licentie : widestring; Password: Widestring): boolean; stdcall;
    function GetMetaUpdate(FinixID:Widestring; LastPatch:Integer; var fout:integer) : WideString; stdcall;
    function GetDatabasePatch(FinixID:Widestring; Patchnummer:Integer; var fout:integer) : widestring; stdcall;
    function RenameLicentie(OldRentixID : widestring; NewPrefix : widestring): boolean; stdcall;

    Function GetSheetVersieEnDatum(FinixID:Widestring; MaatschappijID:Integer; Toekomst : boolean; var Ingangsdatum:TdateTime; var fout:integer) : integer; stdcall;
    
  end;

implementation

uses
  RentixLog, SysUtils, RentixLicentie, WebserviceLock, StrUtils, WebBroker,
  RentixLicentieConst, inifiles, DateUtils, DatabaseConnectie;

const
  rentepath = 'rentes\';
  rentenieuwpath = 'rentes\update\';
  rentepatch = 'rentes\patch\';
  validatiepath = 'DBpatch\';

  NIArentepath = 'rentes\STK\';
  NIArentenieuwpath = 'rentes\STK\update\';
  NIArentepatch = 'rentes\STK\patch\';

  STKrentepath = 'rentes\STK\';
  STKrentenieuwpath = 'rentes\STK\update\';
  STKrentepatch = 'rentes\STK\patch\';

  TESTrentepath = 'rentes\test\';
  TESTrentenieuwpath = 'rentes\test\update\';
  TESTrentepatch = 'rentes\test\patch\';

  ADPrentepath = 'rentes\STK\';
  ADPrentenieuwpath = 'rentes\STK\update\';
  ADPrentepatch = 'rentes\STK\patch\';

  RentixServerPassword = '23$zxW8#';
  DBnaam = 'Database/FinixLicentie.mdb';

{ TRentix }

function IsNiaLicentie(FinixID: Widestring) : boolean;
var
  s: string;
begin
  result := false;
  s := FinixID;
  if lowercase(s[1] + s[3] + s[5]) = 'nia' then result := true;
  if lowercase(s[1] + s[3] + s[5]) = 'din' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'nia' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'din' then result := true;
end;

function IsSTKLicentie(FinixID: Widestring) : boolean;
var
  s: string;
begin
  result := false;
  s := FinixID;
  if lowercase(s[1] + s[3] + s[5]) = 'stk' then result := true;
  if lowercase(s[1] + s[3] + s[5]) = 'din' then result := true;
  if lowercase(s[1] + s[3] + s[5]) = 'kmp' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'stk' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'din' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'kmp' then result := true;
end;

function IsADPLicentie(FinixID: Widestring) : boolean;
var
  s: string;
begin
  result := false;
  s := FinixID;
  if lowercase(s[1] + s[3] + s[5]) = 'adp' then result := true;
  if lowercase(s[1] + s[3] + s[5]) = 'ftp' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'adp' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'ftp' then result := true;
end;

function IsTestLicentie(FinixID: Widestring) : boolean;
var
  s: string;
begin
  result := false;
  s := FinixID;
  if lowercase(s[1] + s[3] + s[5]) = 'tst' then result := true;
  if lowercase(copy(FinixID,0,3)) = 'tst' then result := true;
end;


function TRentix.AddLicentie(Naam, LicentieCode, Password: Widestring; var fout:integer): boolean;
begin
  //Server functionality ONLY!
  if Password = RentixPassword then begin
    Result := AddNewLicentie(naam, LicentieCode, fout);
  end else begin
    Result := False;
  end;
end;

procedure TRentix.CheckNieuweRenteUpdates(MaatschappijID: integer;rentepad, patchpad: string);
var
  fnaam :string;
  Updatefile:string;
  d,mnd,j,u,m : integer;
  DTgroep : TDateTime;
  f:TIniFile;
  sourcenaam, targetnaam : pchar;
begin
  UpdateFile := datapath + patchpad + 'ERW_' + inttostr(MaatschappijID) + '_update.ini';
  if FileExists(Updatefile) then begin
    if FileExists(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID)+ '.xml') then begin
      f := TIniFile.Create(Updatefile);
      d := f.ReadInteger('update','dag', 1);
      mnd := f.ReadInteger('update','maand', 1);
      j := f.ReadInteger('update','jaar', 9999);
      u := f.ReadInteger('update','uur', 1);
      m := f.ReadInteger('update','minuut', 1);
      DTgroep := EncodeDateTime(j,mnd,d,u,m,0,0);
      FreeAndNil(f);

      if DTgroep < now then begin
        AddToLog('','----------------------------------------------------------------------------');
        AddToLog('','Actuele rente update gevonden voor maatschappij : ' + inttostr(MaatschappijID));
        fnaam:= datapath + rentepad + 'backup\' + 'ERW_' + inttostr(MaatschappijID)+ '.xml';

        try
          if not deleteFile(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID) + '_update.bak') then begin
            AddToLog('','Oude backup updatefile kan niet worden delete.');
          end;
        except
          AddToLog('','Oude backup updatefile kan niet worden delete.');
        end;

        //backup huidige rentefile (Verplaats file naar sub-dir backup)
        fnaam:= datapath + rentepad + 'ERW_' + inttostr(MaatschappijID)+ '.xml';
        if FileExists(fnaam) then begin
          sourcenaam := pchar(fnaam);
          targetnaam := pchar(datapath + rentepad + 'backup\ERW_' + inttostr(MaatschappijID)+ '.xml');
          if CopyFile(sourcenaam , targetnaam, false) then begin
            if deletefile(sourcenaam) then begin
              addtolog('',' Delete van oude file gelukt');
            end else begin
              addtolog('','WARNING!!! Delete van ' + sourcenaam + ' mislukt. Kopieren naar ' + targetnaam + ' wel gelukt.');
            end;
          end else begin
            AddToLog('','WARNING!!! Huidige rentefile "' + fnaam+ '" kan niet gekopieerd worden naar directory backup.');
          end;
        end;

        //verplaatst nieuw rente file naar rente directory
        sourcenaam := pchar(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID)+ '.xml');
        if FileExists(sourcenaam) then begin
          targetnaam := pchar(fnaam);
          if copyFile(sourcenaam, targetnaam, false) then begin
            AddToLog('','Nieuwe rentefile succesvol verplaatst naar rente-dir.');
            if not DeleteFile(sourcenaam) then begin
              addtolog('','WARNING!!! Delete van ' + sourcenaam + ' mislukt.');
            end;
            sourcenaam := pchar(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID)+ 'teller.ini');
            targetnaam := pchar(datapath + rentepad + 'ERW_' + inttostr(MaatschappijID)+ 'teller.ini');
            if copyFile(sourcenaam, targetnaam, false) then begin
              AddToLog('','Nieuwe renteteller file succesvol verplaatst naar rente-dir.');
            end;
            //hernoem de updatefile om te voorkomen dat er weer een update getriggered wordt
            if not RenameFile(UpdateFile, ChangeFileExt(UpdateFile, '.bak')) then begin
              addtolog('','Rename van ' + Updatefile + ' naar .bak mislukt');
            end;
          end else begin
            AddToLog('','WARNING!!! Nieuwe rentefile kon niet worden gekopieerd.');
          end;
        end; //if FileExists(sourcenaam) then begin

        AddToLog('','----------------------------------------------------------------------------');
      end else begin
        AddToLog('','Update-ini gevonden voor maatschappij ' + inttostr(MaatschappijID)+ ' maar ingangsdatum is pas ' + FormatDateTime('dd-mm-yyyy',dtgroep) +'.');
      end; //if DTgroep > now then begin
    end else begin
      AddToLog('','----------------------------------------------------------------------------');
      AddToLog('','WARNING!!! Update-ini gevonden maar geen nieuwe rentefile. maatschappij ' + inttostr(MaatschappijID));
      AddToLog('','----------------------------------------------------------------------------');
    end;
  end; //if FileExists(Updatefile) then begin
end;

function TRentix.GetDatabasePatch(FinixID:Widestring; Patchnummer:Integer; var fout:integer) : widestring; stdcall;
var
  fnaam:string;
  s:string;
  f:TextFile;
  pad:string;
begin
  AddToLog('','aanroep GetDatabasePatch');
  pad := validatiepath;

  fnaam := datapath + pad + 'patch_' + inttostr(Patchnummer) + '.txt';
  AddToLog('',fnaam);
  if FileExists(fnaam) then begin
    result := '';
    Assignfile(f, fnaam);
    reset(f);
    while not eof(f) do begin
      Readln(f,s);
      if result ='' then result := s
      else result := result  + s;
      result := result + #10;
    end;
    closefile(f);
    fout := 0;
  end else begin
    result :='';
    fout := -1;
  end;
end;

function TRentix.GetMetaUpdate(FinixID: Widestring; LastPatch: Integer; var fout: integer): WideString;
var
  fnaam:string;
  s:string;
  f:TextFile;
  pad:string;
  fout2: integer;
begin
  fout2 := fout;
  pad := rentepatch;
  if IsNiaLicentie(FinixID) then begin
    pad := NIArentepatch;
  end;
  if IstestLicentie(FinixID) then begin
    pad := TESTrentepatch;
  end;
  if IsADPLicentie(FinixID) then begin
    pad := ADPrentepatch;
  end;
  if ControleerRentixID(FinixID, fout) or Checkfinixlicentie(FinixID) then begin
    fout := fout2;
    fnaam := datapath + pad + 'p' + inttostr(LastPatch) + '.ini';
    if FileExists(fnaam) then begin
      result := '';
      Assignfile(f, fnaam);
      reset(f);
      while not eof(f) do begin
        Readln(f,s);
        result := result + '#' + s;
      end;
      closefile(f);
      fout := 0;
    end else begin
      result :='';
      fout := -1;
    end;
  end;
end;

function TRentix.getRenteBestand(FinixID: Widestring; MaatschappijID: Integer; var fout:integer): TSOAPAttachment;
var
  fnaam:string;
  pad, newpad : String;
  fout2: integer;
begin
  fout2 := fout;
  pad := rentepath;
  newpad := rentenieuwpath;
  if IsNiaLicentie(FinixID) then begin
    pad := NIArentepath;
    newpad := NIArentenieuwpath;
  end;
  if IsSTKLicentie(FinixID) then begin
    pad := STKrentepath;
    newpad := STKrentenieuwpath;
  end;
  if IsTestLicentie(FinixID) then begin
    pad := Testrentepath;
    newpad := Testrentenieuwpath;
  end;
  if IsADPLicentie(FinixID) then begin
    pad := ADPrentepath;
    newpad := ADPrentenieuwpath;
  end;
  //doe nieuwe rentes check
  CheckNieuweRenteUpdates(MaatschappijID, pad, newpad );
  //
  if ControleerRentixID(FinixID, fout) or Checkfinixlicentie(FinixID) then begin
    fout := fout2;
    fnaam:= datapath + pad + 'ERW_' + inttostr(MaatschappijID) + '.xml';
    if FileExists(fnaam) then begin
      AddToLog(FinixID,  'Aanroep getRenteBestand voor maatschappijID:' + InttoStr(MaatschappijID));
      Result := TSoapAttachment.Create;
      Result.SetSourceFile(fnaam);
    end else begin
      Result := nil;
      fout := -3;
      AddToLog(FinixID, 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
      AddToLog('', 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
    end;
  end else begin
    result := nil;
    if fout = -1 then AddToLog(FinixID, 'Aanroep getRenteBestand mislukt. Dagelijkse update is al geweest.');
    if fout = -2 then AddToLog('', 'Aanroep getRenteBestand mislukt. RentixID : "' +FinixID + '" bestaat niet.');
  end;
end;

function TRentix.GetRenteBestandV2(FinixID: Widestring; MaatschappijID,
  ClientLaatsteDatum: integer; var ServerLaatsteDatum,
  fout: integer): TSOAPAttachment;
var
  fnaam:string;
  pad, newpad : string;
begin
  pad := rentepath;
  newpad := rentenieuwpath;
  if IsNiaLicentie(FinixID) then begin
    pad :=  NIArentepath;
    newpad := NIArentenieuwpath;
  end;
  if IsSTKLicentie(FinixID) then begin
    pad := STKrentepath;
    newpad := STKrentenieuwpath;
  end;
  if IsTestLicentie(FinixID) then begin
    pad :=  TESTrentepath;
    newpad := TESTrentenieuwpath;
  end;
  if IsADPLicentie(FinixID) then begin
    pad :=  ADPrentepath;
    newpad := ADPrentenieuwpath;
  end;
  //doe nieuwe rentes check
  CheckNieuweRenteUpdates(MaatschappijID, pad, newpad);
  fout := 0;
  if ControleerRentixID(FinixID, fout) or Checkfinixlicentie(FinixID) then begin
    fout := 0;
    fnaam:= datapath + pad + 'ERW_' + inttostr(MaatschappijID) + '.xml';
    if FileExists(fnaam) then begin
      ServerLaatsteDatum := trunc(FileDateToDateTime(FileAge(fnaam)));
      if (ServerLaatsteDatum <> ClientLaatsteDatum) or
         ((date - ServerLaatsteDatum < 4) and (date - ServerLaatsteDatum > 0)) then begin
        //doe het opsturen
        AddToLog(FinixID, 'Aanroep getRenteBestand voor maatschappijID:' + InttoStr(MaatschappijID));
        Result := TSoapAttachment.Create;
        Result.SetSourceFile(fnaam);
        fout := 0;
      end else begin
//        AddToLog(RentixID, 'Rentebestand van maatschappijID:' + InttoStr(MaatschappijID) + ' is al up to date.');
//        AddToLog(RentixID, 'Serverdatum:' + datetoStr(ServerLaatsteDatum ) );
//        AddToLog(RentixID, 'Clientdatum:' + datetoStr(ClientLaatsteDatum ) );
        Result := nil;
        fout := 0;
      end;
    end else begin
      Result := nil;
      fout := -3;
      AddToLog(FinixID , 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
      AddToLog('', 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
    end;
  end else begin
    result := nil;
    if fout = -1 then AddToLog(FinixID, 'Aanroep getRenteBestand mislukt. Dagelijkse update is al geweest.');
    if fout = -2 then AddToLog('', 'Aanroep getRenteBestand mislukt. RentixID : "' +FinixID + '" bestaat niet.');
  end;
end;

function TRentix.GetRenteBestandV3(FinixID: Widestring; MaatschappijID:integer;  ClientLaatsteDatum: TDateTime; var ServerLaatsteDatum: TDateTime;
  var fout: integer): TSOAPAttachment;
var
  fnaam:string;
  pad, newpad : string;
begin
  pad := rentepath;
  newpad := rentenieuwpath;
  if IsNiaLicentie(FinixID) then begin
    pad :=  NIArentepath;
    newpad := NIArentenieuwpath;
  end;
  if IsSTKLicentie(FinixID) then begin
    pad := STKrentepath;
    newpad := STKrentenieuwpath;
  end;
  if IsTestLicentie(FinixID) then begin
    pad :=  TESTrentepath;
    newpad := TESTrentenieuwpath;
  end;
  if IsADPLicentie(FinixID) then begin
    pad :=  ADPrentepath;
    newpad := ADPrentenieuwpath;
  end;
  //doe nieuwe rentes check
  CheckNieuweRenteUpdates(MaatschappijID, pad, newpad);
  fout := 0;
  if ControleerRentixID(FinixID, fout) or Checkfinixlicentie(FinixID) then begin
    fout := 0;
    fnaam:= datapath + pad + 'ERW_' + inttostr(MaatschappijID) + '.xml';

    if FileExists(fnaam) then begin
      ServerLaatsteDatum := FileDateToDateTime(FileAge(fnaam));
      if (ServerLaatsteDatum <> ClientLaatsteDatum) then begin
        //doe het opsturen
        AddToLog(FinixID, 'Aanroep getRenteBestand voor maatschappijID:' + InttoStr(MaatschappijID));
        Result := TSoapAttachment.Create;
        Result.SetSourceFile(fnaam);
        fout := 0;
      end else begin

        AddToLog(FinixID, 'Rentebestand van maatschappijID:' + InttoStr(MaatschappijID) + ' is al up to date. Serverdatum:' + dateTimetoStr(ServerLaatsteDatum ) + ' Clientdatum:' + datetoStr(ClientLaatsteDatum ));

        Result := nil;
        fout := 0;
      end;
    end else begin
      Result := nil;
      fout := -3;
      AddToLog(FinixID , 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
      AddToLog('', 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
    end;
  end else begin
    result := nil;
    if fout = -1 then AddToLog(FinixID, 'Aanroep getRenteBestand mislukt. Dagelijkse update is al geweest.');
    if fout = -2 then AddToLog('', 'Aanroep getRenteBestand mislukt. RentixID : "' +FinixID + '" bestaat niet.');
  end;
end;

function TRentix.GetRenteBestandV4(FinixID: Widestring; MaatschappijID:integer;  ClientLaatsteDatum: TDateTime; var ServerLaatsteDatum: TDateTime;
  var fout: integer): TSOAPAttachment;
var
  fnaam:string;
  pad, newpad : string;
begin
  pad := rentepath;
  newpad := rentenieuwpath;
  if IsNiaLicentie(FinixID) then begin
    pad :=  NIArentepath;
    newpad := NIArentenieuwpath;
  end;
  if IsSTKLicentie(FinixID) then begin
    pad := STKrentepath;
    newpad := STKrentenieuwpath;
  end;
  if IsTestLicentie(FinixID) then begin
    pad :=  TESTrentepath;
    newpad := TESTrentenieuwpath;
  end;
  if IsADPLicentie(FinixID) then begin
    pad :=  ADPrentepath;
    newpad := ADPrentenieuwpath;
  end;
  //doe nieuwe rentes check
  CheckNieuweRenteUpdates(MaatschappijID, pad, newpad);
  fout := 0;
  if ControleerRentixID(FinixID, fout) or Checkfinixlicentie(FinixID) then begin
    fout := 0;
    fnaam:= datapath + pad + 'ERW_' + inttostr(MaatschappijID) + '.xml';

    if FileExists(fnaam) then begin
      ServerLaatsteDatum := FileDateToDateTime(FileAge(fnaam));
      if (ServerLaatsteDatum <> ClientLaatsteDatum) then begin
        //doe het opsturen
        AddToLog(FinixID, 'Aanroep getRenteBestand voor maatschappijID:' + InttoStr(MaatschappijID));
        Result := TSoapAttachment.Create;
        Result.SetSourceFile(fnaam);
        fout := 0;
      end else begin

        AddToLog(FinixID, 'Rentebestand van maatschappijID:' + InttoStr(MaatschappijID) + ' is al up to date. Serverdatum:' + dateTimetoStr(ServerLaatsteDatum ) + ' Clientdatum:' + datetoStr(ClientLaatsteDatum ));

        Result := nil;
        fout := 0;
      end;
    end else begin
      Result := nil;
      fout := -3;
      AddToLog(FinixID , 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
      AddToLog('', 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
    end;
  end else begin
    result := nil;
    if fout = -1 then AddToLog(FinixID, 'Aanroep getRenteBestand mislukt. Dagelijkse update is al geweest.');
    if fout = -2 then AddToLog('', 'Aanroep getRenteBestand mislukt. RentixID : "' +FinixID + '" bestaat niet.');
  end;
end;

Function TRentix.GetRenteBestandV5(FinixID:Widestring; MaatschappijID:Integer; ClientLaatsteDatum : TDateTime; var ServerLaatsteDatum : TDateTime; var fout:integer; NieuweRentesOphalen:boolean) : TSOAPAttachment; stdcall;
var
  fnaam:string;
  pad, newpad : string;
begin
  pad := rentepath;
  newpad := rentenieuwpath;
  if IsNiaLicentie(FinixID) then begin
    pad :=  NIArentepath;
    newpad := NIArentenieuwpath;
  end;
  if IsSTKLicentie(FinixID) then begin
    pad := STKrentepath;
    newpad := STKrentenieuwpath;
  end;
  if IsTestLicentie(FinixID) then begin
    pad :=  TESTrentepath;
    newpad := TESTrentenieuwpath;
  end;
  if IsADPLicentie(FinixID) then begin
    pad :=  ADPrentepath;
    newpad := ADPrentenieuwpath;
  end;

  //doe nieuwe rentes check
  if (NOT NieuweRentesOphalen) then CheckNieuweRenteUpdates(MaatschappijID, pad, newpad);

  fout := 0;
  if ControleerRentixID(FinixID, fout) or Checkfinixlicentie(FinixID) then begin
    fout := 0;


    if NieuweRentesOphalen then
      fnaam:= datapath + newpad + 'ERW_' + inttostr(MaatschappijID) + '.xml'
    else
      fnaam:= datapath + pad + 'ERW_' + inttostr(MaatschappijID) + '.xml';

    if FileExists(fnaam) then begin
      ServerLaatsteDatum := FileDateToDateTime(FileAge(fnaam));
      if (ServerLaatsteDatum <> ClientLaatsteDatum) then begin
        //doe het opsturen
        AddToLog(FinixID, 'Aanroep getRenteBestand voor maatschappijID:' + InttoStr(MaatschappijID));
        Result := TSoapAttachment.Create;
        Result.SetSourceFile(fnaam);
        fout := 0;
      end else begin

        AddToLog(FinixID, 'Rentebestand van maatschappijID:' + InttoStr(MaatschappijID) + ' is al up to date. Serverdatum:' + dateTimetoStr(ServerLaatsteDatum ) + ' Clientdatum:' + datetoStr(ClientLaatsteDatum ));

        Result := nil;
        fout := 0;
      end;
    end
    else
    begin
      if (NOT NieuweRentesOphalen) then
      begin
        Result := nil;
        fout := -3;
        AddToLog(FinixID , 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
        AddToLog('', 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
      end
      else
      begin
        Result := nil;
        fout := 0;
      end;
    end;
  end else begin
    result := nil;
    if fout = -1 then AddToLog(FinixID, 'Aanroep getRenteBestand mislukt. Dagelijkse update is al geweest.');
    if fout = -2 then AddToLog('', 'Aanroep getRenteBestand mislukt. RentixID : "' +FinixID + '" bestaat niet.');
  end;
end;

function TRentix.GetRentixID(LicentieCode, WindowsID: Widestring): WideString;
begin
  result := ActiveerLicentie(LicentieCode, WindowsID);
end;

function TRentix.getUpdateLijst(FinixID: Widestring; var fout:integer): WideString;
var
  s:TSearchRec;
  mID:string;
  i:integer;
  pad : string;
  fout2: integer;
begin
  fout2 := fout;

  if ControleerRentixID(FinixID, fout) or  Checkfinixlicentie(FinixID) then begin
    fout := fout2;
    pad := rentepath;
    if IsNiaLicentie(FinixID) then begin
      pad := NIArentepath;
    end;
    if IsSTKLicentie(FinixID) then begin
      pad := STKrentepath;
    end;
    if IsTestLicentie(FinixID) then begin
      pad := TESTrentepath;
    end;
    if IsADPLicentie(FinixID) then begin
      pad := ADPrentepath;
    end;

    AddToLog(FinixID , 'Aanroep getUpdateLijst');
    result := '';
    if FindFirst(datapath + pad + 'ERW_*' + '.xml', faAnyFile, s) = 0 then begin
      repeat
        i := pos('_',s.name ) + 1;
        mID := copy(s.name , i , posex('.', s.name, i)-i);
        result := result + mID + ';';
      until (FindNext(s)<>0);
    end else begin
      result := '';
    end;
    FindClose(s);
    AddToLog(FinixID, 'Aanroep getUpdateLijst succesvol');
    AddToLog('' , 'Rentix aanroep van ' + FinixID +'.');
  end else begin
    result := '';
    AddToLog('', 'Aanroep getUpdateLijst mislukt (meervoudige aanroep vandaag). RentixID ' + FinixID);
    if fout <> -2 then begin
      AddToLog(FinixID, 'Tweede Rentix-aanroep vandaag. GetUpdateLijst mislukt.');
    end;
  end;
end;


function TRentix.KillLicentie(Licentie, Password: Widestring): boolean;
begin
  if Password = RentixServerPassword then begin
    AddToLogLicentie(Licentie, 'Aanroep KillLicentie. Deze log is niet langer in gebruik.');
    AddToLog('', 'Aanroep KillLicentie voor licentie: ' + Licentie );
    result := KillLicentieCode(licentie);
  end else begin
    result :=false;
  end;
end;

function TRentix.PutRenteUpdateBestand(aMaatschappijID: integer;
  aBestand: TSOAPAttachment; aIngangsdatum: TdateTime;
  Password: string;Gebruiker:string; Overwrite:boolean): integer;
var
  fnaam:string;
  updatenaam:string;
  f:Tinifile;
  s:string;
begin
  AddToLog('','Nieuw rentebestand wordt geplaatst voor maatschappij ' + inttostr(aMaatschappijID) + ' door "'+ Gebruiker +'". Rente wordt actief op ' + DateToStr(aIngangsdatum)+'.');
  result := 0;
  if password = RentixServerPassword then begin
    updatenaam := datapath + rentenieuwpath + 'ERW_' + inttostr(aMaatschappijID) + '_update.ini';
    fnaam:= datapath + rentenieuwpath + 'ERW_' + inttostr(aMaatschappijID) + '.xml';
    if (FileExists(fnaam) or FileExists(updatenaam)) and (not Overwrite) then begin
      result := -1; //File bestaat al en overwrite is uit
    end else begin
      try
        DeleteFile(fnaam);
        DeleteFile(updatenaam);
      except
        AddToLog('','delete van ' + fnaam + ' of ' + updatenaam +' mislukt.');
      end;
      aBestand.SaveToFile(fnaam);
      if FileExists(fnaam) then begin
        f := Tinifile.create(updatenaam);
        f.WriteInteger('update', 'dag' , DayOf(aIngangsdatum));
        f.WriteInteger('update','maand', MonthOf(aIngangsdatum));
        f.writeInteger('update','jaar', yearof(aIngangsdatum));
        f.writeInteger('update','uur', HourOf(aIngangsdatum));
        f.writeInteger('update','minuut', MinuteOf(aIngangsdatum));
        f.WriteString('update','user', gebruiker);
        f.UpdateFile;
        f.Free;
      end else begin
        result := -3;
      end;
    end;
  end else begin
    result := -2; //password fout
  end;
  if result= 0 then begin
    AddToLog('','Nieuw rentebestand succesvol geplaatst.');
  end else begin
    case result of
      -1: s:= '#1 File bestaat al en overwrite is uit.';
      -2: s:= '#2 Password klopt niet.';
      -3: s:= '#3 Wegschrijven van de rente-update-xml is mislukt.';
      else s:='Er zijn vreemde dingen aan de hand...';
    end;
    AddToLog('','WARNING! Nieuw rentebestand plaatsen NIET succesvol. Fout '+s);
  end;

end;

function TRentix.RenameLicentie(OldRentixID, NewPrefix : Widestring): boolean;
begin
  AddToLog(oldrentixid,'RenameLicentie aangeroepen voor oldRentixID : "' +OldRentixID + ' en new prefix: ' + NewPrefix);
  result := RenameLicentieCode(OldRentixID, NewPrefix);
  if not result then begin
    AddToLog(oldrentixid,'RenameLicentie mislukt');
  end;
end;

function TRentix.ResetClientUpdateDatum(FinixID, Password: Widestring): boolean;
begin
  AddToLog(FinixID,'ResetClientUpdateDatum aangeroepen voor FinixID : "' +FinixID + '".  <-- handmatige Rentix activatie');
  if Password = RentixServerPassword then begin
    result := True;
    if NOT Setlastrentixdatum(FinixID) then SetLastDatum(FinixID, date-1, false);
    AddToLog(FinixID,'ResetClientUpdateDatum succesvol');
    AddToLog('','Handmatige Rentix activatie door FinixID ' + FinixID );
  end else begin
    result := false;
    AddToLog(FinixID,'ResetClientUpdateDatum fout');
  end;
end;

function TRentix.ResetLicentie(Licentie : widestring; Password: Widestring): boolean;
begin
  if Password = RentixServerPassword then begin
    AddToLogLicentie (Licentie, 'Aanroep ResetLicentie voor licentie: ' + Licentie );
    result := ResetLicentieCode(licentie);
  end else begin
    result :=false;
  end;
end;

function TRentix.TestMe: WideString;
begin
  result := 'Test gelukt';
end;

function TRentix.UpdateAccessDatum(FinixID: Widestring): Boolean;
begin
  result :=true;
  try
    if NOT Setlastrentixdatum(FinixID) then SetLastDatum(FinixID, now);
  except
    result := false;
  end;
end;

function TRentix.Checkfinixlicentie(FinixID:Widestring): boolean;
var
  LicDB: TControllerDB;
  rs: TAdoRecordset;
  sql: string;
begin
  result := false;

  try
    LicDB := TControllerDB.Create(DBnaam);
    sql := 'select licentie from licentie where licentie=' + QuotedStr(FinixID) + ' and actiefgemaakt=true';
    rs := LicDB.OpenQuery(sql);
    if (not rs.EOF) then result := true;
    FreeAndNil(LicDB);
  except
  end;
end;

function TRentix.checkInitRentixed(FinixID: widestring): boolean;
var
  LicDB: TControllerDB;
  rs: TAdoRecordset;
  sql: string;
  aLastDate: TDateTime;
  aFout: boolean;
begin
  result := false;
  aFout := false;

  try
    LicDB := TControllerDB.Create(DBnaam);
    sql := 'select lastrentixdatum from licentie where licentie=' + QuotedStr(FinixID) + ' and actiefgemaakt=true';
    rs := LicDB.OpenQuery(sql);

    if (not rs.EOF) then
    begin
      aLastDate := ReadDBValue(varDate, rs, 'lastrentixdatum', true, aFout);
      result := (aLastDate > 0);
    end;

    LicDB.CloseQuery(rs);
    FreeAndNil(LicDB);
  except
  end;
end;

function TRentix.Setlastrentixdatum(FinixID:Widestring): boolean;
var
  LicDB: TControllerDB;
  sql: string;
begin
  result := false;

  try
    if Checkfinixlicentie(FinixID) then
    begin
      LicDB := TControllerDB.Create(DBnaam);
      sql := 'update licentie set lastrentixdatum=' + floattostr(now) + ' where licentie=' + QuotedStr(FinixID);
      LicDB.QueryExecute(sql);
      result := true;
      FreeAndNil(LicDB);
    end;
  except
  end;
end;

function TRentix.GetSheetVersieEnDatum(FinixID: Widestring; MaatschappijID: Integer; Toekomst : boolean; var Ingangsdatum: TdateTime; var fout: integer): integer;
var
  fnaam, pad, newpad : string;
  s:string;
  d,m,y : integer;
  t:textfile;
begin
  fout := 0;
  pad := rentepath;
  newpad := rentenieuwpath;
  if IsTestLicentie(FinixID) then begin
    pad := Testrentepath;
    newpad := Testrentenieuwpath;
  end;
  if Toekomst then 
    fnaam:= datapath + newpad + 'ERW_' + inttostr(MaatschappijID) + 'teller.ini'
  else
    fnaam:= datapath + pad + 'ERW_' + inttostr(MaatschappijID) + 'teller.ini';

  result := -1;
  d := -1;
  m := -1;
  y := -1;
  ingangsdatum := 60000;
  
  if FileExists(fnaam) then begin
    assignfile(t, fnaam);
    reset(t);
    while not eof(t) do begin
      readln(t,s);
      s:=lowercase(s);
      if copy(s,1,6) = 'versie' then begin
        try
          result := strtoint(copy(s,8,5));
        except
          fout := -2;
        end;
      end;
      if copy(s,1,4) = 'jaar' then begin
        try
          y := strtoint(copy(s,6,4));
        except
          fout := -3;
        end;
      end;
      if copy(s,1,5) = 'maand' then begin
        try
          m := strtoint(copy(s,7,2));
        except
          fout := -4;
        end;
      end;
      if copy(s,1,3) = 'dag' then begin
        try
          d := strtoint(copy(s,5,3));
        except
          fout := -5;
        end;
      end;
    end;
    closefile(t);
    if (d>0) and (m>0) and (y>0) then begin
      Ingangsdatum := EncodeDate(y,m,d);
    end;    
  end else begin
    fout := -1;
  end;
end;

procedure TRentix.CheckNieuweRenteUpdatesV2(FinixID: Widestring; MaatschappijID: integer; rentepad, patchpad: string);
var
  fnaam :string;
  Updatefile:string;
  DTgroep, NewDate : TDateTime;
  sourcenaam, targetnaam : pchar;
  fout, vNew, vHuidig : integer; 
begin
  vHuidig := GetSheetVersieEnDatum(FinixID, MaatschappijID, false, Dtgroep, fout); 
  AddToLog('','maatschappij : ' + inttostr(MaatschappijID) + ' vHuidig' + inttostr(vHuidig) + ' datum ' + datetostr(dtgroep));
  if fout<0 then exit;

  vNew := GetSheetVersieEnDatum(FinixID, MaatschappijID, True, NewDate, fout); 
  AddToLog('','maatschappij : ' + inttostr(MaatschappijID) + ' vNew' + inttostr(vNew) + ' datum ' + datetostr(Newdate));
  if fout<0 then exit;
    
  UpdateFile := datapath + patchpad + 'ERW_' + inttostr(MaatschappijID) + '_update.ini';
  if FileExists(Updatefile) then begin
    if FileExists(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID)+ '.xml') then begin

      if Newdate < now then begin
        AddToLog('','----------------------------------------------------------------------------');
        AddToLog('','Actuele rente update gevonden voor maatschappij : ' + inttostr(MaatschappijID));
        fnaam:= datapath + rentepad + 'backup\' + 'ERW_' + inttostr(MaatschappijID)+ '.xml';

        try
          if not deleteFile(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID) + '_update.bak') then begin
            AddToLog('','Oude backup updatefile kan niet worden delete.');
          end;
        except
          AddToLog('','Oude backup updatefile kan niet worden delete.');
        end;

        //backup huidige rentefile (Verplaats file naar sub-dir backup)
        fnaam:= datapath + rentepad + 'ERW_' + inttostr(MaatschappijID)+ '.xml';
        if FileExists(fnaam) then begin
          sourcenaam := pchar(fnaam);
          targetnaam := pchar(datapath + rentepad + 'backup\ERW_' + inttostr(MaatschappijID)+ '.xml');
          if CopyFile(sourcenaam , targetnaam, false) then begin
            if deletefile(sourcenaam) then begin
              addtolog('',' Delete van oude file gelukt');
            end else begin
              addtolog('','WARNING!!! Delete van ' + sourcenaam + ' mislukt. Kopieren naar ' + targetnaam + ' wel gelukt.');
            end;
          end else begin
            AddToLog('','WARNING!!! Huidige rentefile "' + fnaam+ '" kan niet gekopieerd worden naar directory backup.');
          end;
        end;

        //verplaatst nieuw rente file naar rente directory
        sourcenaam := pchar(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID)+ '.xml');
        if FileExists(sourcenaam) then begin
          targetnaam := pchar(fnaam);
          if copyFile(sourcenaam, targetnaam, false) then begin
            AddToLog('','Nieuwe rentefile succesvol verplaatst naar rente-dir.');
            if not DeleteFile(sourcenaam) then begin
              addtolog('','WARNING!!! Delete van ' + sourcenaam + ' mislukt.');
            end;
            sourcenaam := pchar(datapath + patchpad + 'ERW_' + inttostr(MaatschappijID)+ 'teller.ini');
            targetnaam := pchar(datapath + rentepad + 'ERW_' + inttostr(MaatschappijID)+ 'teller.ini');
            if copyFile(sourcenaam, targetnaam, false) then begin
              AddToLog('','Nieuwe renteteller file succesvol verplaatst naar rente-dir.');
            end;
            //hernoem de updatefile om te voorkomen dat er weer een update getriggered wordt
            if not RenameFile(UpdateFile, ChangeFileExt(UpdateFile, '.bak')) then begin
              addtolog('','Rename van ' + Updatefile + ' naar .bak mislukt');
            end;
          end else begin
            AddToLog('','WARNING!!! Nieuwe rentefile kon niet worden gekopieerd.');
          end;
        end; //if FileExists(sourcenaam) then begin

        AddToLog('','----------------------------------------------------------------------------');
      end else begin
        AddToLog('','Update-ini gevonden voor maatschappij ' + inttostr(MaatschappijID)+ ' maar ingangsdatum is pas ' + FormatDateTime('dd-mm-yyyy',dtgroep) +'.');
      end; //if DTgroep > now then begin
    end else begin
      AddToLog('','----------------------------------------------------------------------------');
      AddToLog('','WARNING!!! Update-ini gevonden maar geen nieuwe rentefile. maatschappij ' + inttostr(MaatschappijID));
      AddToLog('','----------------------------------------------------------------------------');
    end;
  end; //if FileExists(Updatefile) then begin
end;

function TRentix.GetRenteBestandV6(FinixID: Widestring; MaatschappijID: Integer; var fout: integer; NieuweRentesOphalen: boolean): TSOAPAttachment;
var
  fnaam:string;
  pad, newpad : string;
begin
  pad := rentepath;
  newpad := rentenieuwpath;
  if IsTestLicentie(FinixID) then begin
    pad :=  TESTrentepath;
    newpad := TESTrentenieuwpath;
  end;

  //doe nieuwe rentes check
  if (NOT NieuweRentesOphalen) then CheckNieuweRenteUpdatesV2(FinixID, MaatschappijID, pad, newpad);

  fout := 0;
  if ControleerRentixID(FinixID, fout) or Checkfinixlicentie(FinixID) then begin
    fout := 0;


    if NieuweRentesOphalen then
      fnaam:= datapath + newpad + 'ERW_' + inttostr(MaatschappijID) + '.xml'
    else
      fnaam:= datapath + pad + 'ERW_' + inttostr(MaatschappijID) + '.xml';

    if FileExists(fnaam) then begin
      AddToLog(FinixID, 'Aanroep getRenteBestand voor maatschappijID:' + InttoStr(MaatschappijID));
      Result := TSoapAttachment.Create;
      Result.SetSourceFile(fnaam);
      fout := 0;
    end
    else
    begin
      if (NOT NieuweRentesOphalen) then
      begin
        Result := nil;
        fout := -3;
        AddToLog(FinixID , 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
        AddToLog('', 'Aanroep getRenteBestand mislukt. Bestand "' +fnaam + '" bestaat niet.');
      end
      else
      begin
        Result := nil;
        fout := 0;
      end;
    end;
  end else begin
    result := nil;
    if fout = -1 then AddToLog(FinixID, 'Aanroep getRenteBestand mislukt. Dagelijkse update is al geweest.');
    if fout = -2 then AddToLog('', 'Aanroep getRenteBestand mislukt. RentixID : "' +FinixID + '" bestaat niet.');
  end;
end;

initialization
  { Invokable classes must be registered }
  InvRegistry.RegisterInvokableClass(TRentix);

end.

unit Opties;

interface

{$warn SYMBOL_PLATFORM	off}

type
  TinternetMode = (imContinue, imInbel, imGeen);
  TOpties = class
    private
      _naam : string;
      _CSVpad : string;
      _XMLpad : string;
      _Temppad : string;
    procedure setCSVpad(const Value: string);
    procedure setXMLpad(const Value: string);
    procedure setTemppad(const Value: string);
    function getTempPad: string;
    public
      DefaultDatapad : boolean;
      Databasenaam : string;
      BBRenteDatabasenaam : string;
      ClientDatabasenaam : string;
      LicentieNummer : string;
      FTPhost:string;
      FTPdir:string;
      FTPaccount:string;
      FTPpassword:string;
      FTPport:word;
      EurofaceServer:string;
      InternetMode:TinternetMode;
      AutoAfsluitClient : boolean;

      property CSVpad : string read _CSVpad write setCSVpad;
      property XMLpad : string read _XMLpad write setXMLpad;
      property Temppad : string read GetTemppad write setTemppad;
      function CodeerPassword(value:string; Codeer:boolean):string;
      Function ReadfromIni:boolean;
      Function WriteToIni:boolean;
      constructor Create;
  end; //class



var
  LaatsteUpdate : TdateTime = 0;


implementation

uses
  SysUtils, Classes, inifiles, Dialogs, DatabaseConstanten, Windows,
  RentixTools, Registry, bbsetup, RentixLicentieConst, u_Utility,
  u_SysFolders, EfsDialogs;

{ TOpties }

{$IFDEF IS_RENTIXCLIENT}
{$define BLA}
Const
  ininaam = 'Rentix.ini';
{$endif}

{$ifdef IS_RENTIXSERVER}
{$define BLA}
Const
  ininaam = 'RentixServer.ini';
{$endif}

{$ifndef BLA}
Const
  ininaam = '';
{$endif}

const
  Regpad = '\Software\euroface\rentix';

function TOpties.CodeerPassword(value: string; Codeer: boolean): string;
begin
  if Codeer then begin
    result := Enigma( value, codeer, RentixPassword);
  end else begin
    result := Enigma( value, codeer, RentixPassword);
  end;
end;

constructor TOpties.Create;
begin
  _naam := IncludeTrailingBackslash(ExtractFilePath(paramstr(0))) + ininaam;
  ReadfromIni;
end;

function TOpties.ReadfromIni: boolean;
var
  r:TRegistry;
  ini : TIniFile;

  function ReadStr(aNaam:string; def : string):string;
  var s:string;
  begin
    s := r.ReadString(aNaam);
    if s='' then result := def else result := s;
  end;

begin
  result := true;
  loadSetup;
  DefaultDatapad := True;
  LaatsteUpdate := now;
  BBRenteDatabasenaam := BBsetupInfo.databasepad + BBrentesDBnaam;
  ClientDatabasenaam := BBsetupInfo.databasepad + ClientDBnaam;
  InternetMode := imContinue;
  EurofaceServer := 'ws.euroface.nl';
  Temppad := GettempDir;
  if FileExists(_naam) then begin
    ini := TIniFile.Create(_naam);
    Temppad := ini.ReadString('rentix','temppad',GetTempDir);
    AutoAfsluitClient := ini.ReadBool('rentix', 'autoafsluit', false);
    EurofaceServer := ini.ReadString('rentix', 'Server', 'ws.euroface.nl');
    DefaultDatapad := ini.ReadBool('rentix', 'DefaultDatabase', True);

    if not DefaultDatapad then begin
      BBRenteDatabasenaam := ini.ReadString('rentix', 'RentesMDB', BBsetupInfo.databasepad + BBrentesDBnaam);
      ClientDatabasenaam := ini.ReadString('rentix', 'RentixMDB', BBsetupInfo.databasepad + ClientDBnaam);
      if not FileExists(BBRenteDatabasenaam) then begin
        efsShowMessage(BBRenteDatabasenaam + ' niet gevonden.');
      end;
      if not FileExists(ClientDatabasenaam) then begin
        efsShowMessage(ClientDatabasenaam + ' niet gevonden.');
      end;
    end;
    ini.Free;
  end else begin
    //client
    BBRenteDatabasenaam := BBsetupInfo.databasepad + BBrentesDBnaam;
    ClientDatabasenaam := BBsetupInfo.databasepad + ClientDBnaam;
    LicentieNummer := '';
    AutoAfsluitClient :=true;
    InternetMode := imContinue;
    //algemeen

    r := TRegistry.Create;
    r.RootKey := HKEY_CURRENT_USER;
    if not(r.OpenKey(Regpad, false)) then begin
      WriteToIni;
      if not (r.OpenKey(Regpad, false)) then exit;
    end;
    CSVpad := ReadStr('CSV',CSVpad);
    XMLpad := ReadStr('XML',XMLpad);
    databasenaam :=ReadStr('datalokatie', databasenaam);

    try
      DefaultDatapad := R.ReadBool('DefaultDatapad');
    except
      DefaultDatapad := True;
    end;

    if not DefaultDatapad then begin
      BBRenteDatabasenaam := ReadStr('Clientbbdata', BBRenteDatabasenaam);
      ClientDatabasenaam := ReadStr('Clientdata', ClientDatabasenaam);
    end;
    Temppad := ReadStr('tempdir',temppad);

    LicentieNummer := ReadStr('Licentie',LicentieNummer );
    InternetMode := TInternetmode( StrToInt(Readstr('InternetMode', IntToStr(integer(InternetMode)) )));
    try
      AutoAfsluitClient := r.ReadBool('AutoAfsluit');
    except
      AutoAfsluitClient := false;
    end;

    FTPhost := ReadStr('FTPHost',FTPhost);
    FTPdir  := ReadStr('FTPDir',FTPdir);
    FTPaccount := ReadStr('FTPAccount',FTPaccount );
    FTPpassword := CodeerPassword(ReadStr('FTPPassword',FTPpassword ), false);
    FTPport := StrToIntDef(ReadStr('FTPPort',inttostr(FTPport)),FTPport);

    FreeAndNil(r);
  end;

  if (Temppad='') or (Temppad='\') or (length(Temppad)<=4) then
    Temppad := TSysFolders.TempFolder;

  WriteToIni;
end;

function TOpties.getTempPad: string;
begin
  result := _Temppad;
  if not DirectoryExists(result) then
    result := GetTempDir;
end;

procedure SaveLaatsteUpdate;
var
  ini : TIniFile;
begin
  try
    ini := TIniFile.Create(IncludeTrailingBackslash(TUtility.AppRoot) + ininaam);
    ini.WriteDateTime('rentix', 'LastDatum', date );
    ini.free;
  except
  end;
end;

procedure TOpties.setCSVpad(const Value: string);
begin
  _CSVpad := IncludeTrailingBackslash(Value);
end;

procedure TOpties.setTemppad(const Value: string);
begin
  _Temppad := IncludeTrailingBackslash(Value);
end;

procedure TOpties.setXMLpad(const Value: string);
begin
  _XMLpad := IncludeTrailingBackslash(Value);
end;

function TOpties.WriteToIni: boolean;
var
  ini : TIniFile;
begin
  result := true;
  try
    ini := TIniFile.Create(_naam);
    ini.WriteString('rentix', 'temppad', Temppad );
    ini.WriteBool  ('rentix', 'autoafsluit', AutoAfsluitClient );
    ini.WriteString('rentix', 'Server', EurofaceServer);
    ini.WriteBool('rentix', 'DefaultDatabase', DefaultDatapad );
    if not DefaultDatapad then begin
      ini.WriteString('rentix', 'RentesMDB', BBRenteDatabasenaam );
      ini.WriteString('rentix', 'RentixMDB', ClientDatabasenaam  );
    end;
    ini.Free;

{  try
    r:= TRegistry.Create;
    r.RootKey := HKEY_CURRENT_USER;
    if r.OpenKey(Regpad, true) then begin
      r.WriteString('CSV',CSVpad);
      r.WriteString('XML',XMLpad);
      r.WriteString('datalokatie',Databasenaam );
      r.WriteString('EurofaceServer',EurofaceServer );
      r.WriteString('FTPHost',FTPhost);
      r.WriteString('FTPDir',FTPdir);
      r.WriteString('FTPAccount',FTPaccount);
      r.WriteString('FTPPassword',CodeerPassword(FTPpassword,true));
      r.WriteString('FTPPort',IntToStr(FTPport));
      r.writeBool('DefaultDatapad', DefaultDatapad);
      if DefaultDatapad then begin
        r.writestring('Clientbbdata', '');
        r.writestring('Clientdata', '');
      end else begin
        r.writestring('Clientbbdata', BBRenteDatabasenaam);
        r.writestring('Clientdata', ClientDatabasenaam);
      end;
      r.writestring('tempdir', Temppad );
      r.WriteString('Licentie',LicentieNummer );
      r.WriteString('InternetMode',IntToStr(integer(InternetMode)));
      r.WriteBool ('AutoAfsluit',AutoAfsluitClient);
      FreeAndNil(r);
    end;
}
  except
    efsShowMessage ('Ini-file kon niet worden aangemaakt.'#13#10 + _naam);
    result := false;
  end;
end;

end.

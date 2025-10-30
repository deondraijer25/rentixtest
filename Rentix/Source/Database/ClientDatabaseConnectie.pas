unit ClientDatabaseConnectie;

interface

uses
  DatabaseConnectie, Classes, ADODB_TLB, BlackBoxEnums, Rio, SOAPHTTPClient,RentixIntf;

type
  TClientControllerDB = class
  private
//    Procedure LeesLeningLijst;
  public
//    LeningLijst : TStringList;  //Lijst met TLeningData objecten
//    Procedure UpdateLeningUpdateDatum(leningGuid:string; aDatum:TDateTime);
//    procedure UpdateMaatschappijUpdateDatum(MaatschappijID:integer; aDatum:integer);
//    Function GetMaatschappijUpdateDatum(MaatschappijID:integer) : integer;
    Procedure UpdateOverallUpdateDatum;
    procedure UpdateRentixID;
    Function CheckLicentieEnUpdateDatum(var error:string) : boolean;
    //class function create(aDatabasenaam: String; OpenExclusive: boolean=false; const aPrefix: string=''): TControllerDB; virtual;
    //class function  Create(aDatabasenaam:string; OpenExclusive:boolean=false; const aPrefix:string=''): TClientControllerDB;
    Destructor Destroy; override;
  end;

  TLeningData = class
    LeningGUID : string;
    MaatschappijNaam:String;
    MaatschappijID:integer;
    Omschrijving : string;
    Datum : TDatetime;
    Actief : boolean;
  end;

implementation

uses
  Sysutils, ClientVariabelen, ClientRunMode, FormLicentieActivatie,
  controls, Dialogs, FinixLicentieCheck, ModuleLijstEnum,
  DatabaseConstanten, ProxySupport,SOAPHTTPTrans, OPConvert
  {$IF COMPILERVERSION>=23}, Soap.OpConvertOptions{$IFEND};

function TClientControllerDB.CheckLicentieEnUpdateDatum(var error: string): boolean;
var
  rs : TAdoRecordset;
  fout:boolean;
  Lastupdate:TDateTime;
  hypmaatschapDB : TControllerDB;
  prefix,newprefix : string;
  HTTPRIO: THTTPRIO;
begin
  result := true;
  try
    try
      rs := GlobalClientDB.OpenQuery('Select rentixdatum from rentixdatum');
    except
      on e:exception do begin
        error := 'Database is mogelijk corrupt. Programma wordt afgesloten. Systeemmelding : ' + e.Message;
        result := false;
        exit;
      end;
    end;
//    RentixID := ReadDBValue(varstring, rs, 'RentixID', false, fout);
    FinixID := 'EFS-WILCO-A'; //FinixLicentieT.instance.LicentieNummer;
    LastUpdate := ReadDBValue(varDate, rs, 'RentixDatum', false, fout);
  finally
    GlobalClientDB.CloseQuery(rs);
  end;
  //if ((FinixID = '') or (NOT FinixLicentieT.instance.LicentieValid)) then
  //begin
  //  Error := 'De licentie voor Finix is niet valide, waardoor Rentix niet kan functioneren.';
  //  result := false;
 //   exit;
  //end;

  prefix := uppercase(copy(FinixID,0,3));

  //NIA-ADP-KMB licenties moeten worden omgezet naar STK-licenties
  if not GlobalOpties.DefaultDatapad then begin
    hypmaatschapDB := TControllerDB.Create(GlobalOpties.BBRenteDatabasenaam,false);
  end else begin
    hypmaatschapDB := TControllerDB.Create(DatabasePad + MainDatabasenaam,false);
  end;
  rs := hypmaatschapDB.OpenQuery('select * from LicChg where van=' + quotedstr(prefix));
  if not rs.EOF then begin
    fout := false;
    newprefix := ReadDBValue(varString,rs,'naar', true, fout);
    if (not fout) and (newprefix <> '')  then begin
      HTTPRIO := THTTPRIO.Create(nil);
      try
        StelProxyIn(HTTPRIO);

        HTTPRIO.URL := 'http://' + GlobalOpties.EurofaceServer + '/scripts/Rentixservice.exe/soap/IRentix';
        HTTPRIO.HTTPWebNode.Agent := 'Borland SOAP 1.2';
        HTTPRIO.HTTPWebNode.UseUTF8InHeader := False;
        HTTPRIO.HTTPWebNode.InvokeOptions := [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI];
        HTTPRIO.Converter.Options := [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML];
        (HTTPRIO as iRentix).RenameLicentie(FinixID, newprefix);
      except
        fout := True;
      end;
      if not fout then begin
        FinixID := newprefix[1] + FinixID[2] + newprefix[2]+FinixID[4]+newprefix[3] + FinixID[6] + copy(FinixID,7,length(FinixID));
//MZW        UpdateRentixID;
      end;
    end;
  end;
  hypmaatschapDB.CloseQuery(rs);
  hypmaatschapDB.Free;

  if (Lastupdate >= date()) and (not (runmode in [rmBeheer, rmAdmin,rmAdminAuto]))  then begin
    Error := '';
    result := false;
    exit;
  end;
end;

(*class function TClientControllerDB.Create(aDatabasenaam:string; OpenExclusive:boolean=false; const aPrefix:string=''): TClientControllerDB;
begin
  result := inherited create(aDatabasenaam);
  //CheckWritable(true);
//  LeesLeningLijst;
end;*)

destructor TClientControllerDB.Destroy;
begin
//  LeningLijst.free;
  inherited;
end;

procedure TClientControllerDB.UpdateOverallUpdateDatum;
var
  s:string;
begin
  s := floattostr(now);
  s := StringReplace(s, ',', '.',[rfReplaceAll ]);
  s := StringReplace(s, '.', '.',[rfReplaceAll ]);
  //floats altijd met punt als decimalseperator
  
  s := 'UPDATE version SET version.UpdateDatum = ' + s;
  try
    GlobalClientDB.QueryExecute(s);
  except
    Melding('fout in updaten version.updatedatum');
  end;
end;

procedure TClientControllerDB.UpdateRentixID;
//var
//  s:string;
//  dateint:integer;
begin
  //zet de rentixID in de datebase en zet de UpdateDatum naar gisteren
//  dateint := round(date) -1;
//  s := 'UPDATE version SET version.RentixID = ' + quotedstr(RentixID) +
//       ',version.UpdateDatum = ' + IntToStr(dateint);
//  QueryExecute(s);


//  LeesLeningLijst;  //even de leninglijst opnieuw inlezen..
end;

end.

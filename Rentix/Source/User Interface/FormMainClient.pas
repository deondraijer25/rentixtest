unit FormMainClient;
{
===================================================================================================
07-08-2007 Jelte: Een ontbrekende 'NOT' toegevoegd, tbv het openen van de rentes database
  (hypmaatschappijdb.mdb) op de juiste locatie.
===================================================================================================
}
interface

{
 run parameters:

 /auto       automatische mode
 /adminauto  automatische mode zonder dag-restrictie
 /beheer     beheer mode
 /admin      admin mode
 /silent     silent mode
}


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, InvokeRegistry, Rio, SOAPHTTPClient ,RentixIntf,
  DatabaseConnectie, CheckLst, FrameLabelPicture, ComCtrls, Gauges, registry,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus, cxButtons,
  cxClasses, cxStyles, cxControls, cxContainer, cxEdit, cxProgressBar,
  fspTaskbarMgr, dxSkinsCore, dxSkinMoneyTwins, cxCheckBox, cxLabel, cxGroupBox,
  dxGDIPlusClasses;

type
  TRentixClass = class
    Versienummer : integer;
    MaatschappijID : integer;
    Ingangsdatum : TdateTime;
  end;

  TfrmMainformClient = class(TForm)
    HTTPRIO1: THTTPRIO;
    TimerAutoStart: TTimer;
    cxLookAndFeelController1: TcxLookAndFeelController;
    cxStyleRepository1: TcxStyleRepository;

    pnlBottom: TcxGroupBox;
    Panel1: TcxGroupBox;
    Label1: TcxLabel;
    Label4: TcxLabel;
    btnOpties: TcxButton;
    Button1: TcxButton;
    Button2: TcxButton;
    pnlTop: TcxGroupBox;
    Label3: TcxLabel;
    cxGroupBox1: TcxGroupBox;
    FramInit: TFrame1;
    framStap1: TFrame1;
    framStap2: TFrame1;
    framStap3: TFrame1;
    FramStap4: TFrame1;
    FramStap5: TFrame1;
    FramStap6: TFrame1;
    FramStap7: TFrame1;
    FramStap8: TFrame1;
    framStap9: TFrame1;
    FramStap10: TFrame1;
    FramStap11: TFrame1;
    Gauge1: TcxProgressBar;
    btnSluiten: TcxButton;
    cbAutoAfsluit: TcxCheckBox;
    lblMaatschappij: TcxLabel;
    lblLicentie: TcxLabel;
    procedure btnSluitenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOptiesClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerAutoStartTimer(Sender: TObject);
    procedure cbAutoAfsluitClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    _Warnings, TotaalWarnings : integer;
    TooMuchWarnings : boolean;
    _UpdateLijst : TStringList;
    _FilenaamLijst : TStringList;
    _Meldingen : TStringList;
    Errors, TotaalErrors:integer;
    UitZicht : boolean;
    RentixWeb : IRentix;
    nieuwerentesophalen:boolean;
    function CallGetUpdateLijst :boolean;
    function DownloadRentebestanden:boolean;
    function VerwerkenXML:boolean;
    function VerwerkXML(filenaam:string; MaatschappijID:integer; Ingangsdatum : tDateTime) : boolean;
    procedure SetWarnings(const Value: integer);
    function CheckLicentieEnUpdateDatum : boolean;
    function CheckInternet : boolean;
    Procedure ExplainError(WebserviceFout:integer);
    procedure GetMaatschappijen;
    procedure CheckWriteRights;
    function UpdatePatches : boolean;
    function UpdateDatabasePatches : boolean;
    function ExecuteDatabasePatch(filenaam:string;patchnummer:integer) : boolean;
    function GetMaatschappijUpdateDatum(MaatschappijID: integer): TdateTime;
    procedure UpdateMaatschappijRenteSheetVersie(MaatschappijID:integer; aVersie : integer; Toekomst : boolean);
//    procedure UpdateMaatschappijUpdateDatum(MaatschappijID:integer;
//      aDatum: TdateTime);
    procedure SaveLaatsteUpdate;
    function RenteWijzigingActueel(filenaam:string;var aDatum:Tdatetime):boolean;
    function GetMaatschappijRenteSheetVersie(MaatschappijID: integer;
      Toekomst: boolean): integer;
  public
    { Public declarations }
    NieuweRentesGevonden:Boolean;
    ShutDownNow : boolean;
    _left : integer;
    Maatschappijen : TStringlist;
    MaatschappijenID : TStringList;

    hypmaatschapDB : TControllerDB;
    LeningLijst :TstringList;
    LaatsteUpdateDatum : TDateTime;

    property Warnings:integer read _Warnings write SetWarnings;
    procedure RunAuto;
    constructor Create(aOwner : Tcomponent); override;
    Destructor Destroy; override;
  end;

var
  frmMainformClient: TfrmMainformClient;


procedure Cleanup(finished : boolean);
function RentixLocked: boolean;
procedure LockRentix;

implementation

uses
  FormOpties, ClientRunMode, XMLimport, Opties, strUtils, inifiles,
  RVP, RenteUpdate, ClientDatabaseConnectie, ClientVariabelen,
  RentixTools, InternetWrap, formDialogRenteUpdate, dateutils,
  Math, formMeldingen, mmsystem, FinixLicentieCheck, ModuleLijstEnum,
  RentixXMLconstanten, ProxySupport, FileVersion, DatabaseConstanten,
  u_Utility, EfsDialogs;

{$R *.dfm}


var
  Meldingen : TstringList;

function Locktime : integer;
var
  f:textfile;
  fn, s:string;
  t : extended;
begin
  //berekend hoeveel minuten de lockfile al bestaat
  fn := TUtility.AppRoot + 'rentix.lck';
  if FileExists(fn) then begin
    AssignFile(f, fn);
    reset(f);
    Readln(f,s);
    closefile(f);
    s := StringReplace(s, '.', DecimalSeparator,[]);
    s:=StringReplace(s, ',', DecimalSeparator,[]);
    t := StrToFloatDef(s, 0);
    if t=0 then begin
      //uitlezen tijd gaat mis-> ga ervanuit dat het een oude lockfile is
      result := 10000;
    end else begin
      t := (now - t) / 0.0007;   ///0.0007 is ongeveer 1 minuut
      result := trunc(t);
    end;
  end else begin
    //file bestaat niet dus niet gelocked.
    result := 10000;
  end;
end;

procedure Cleanup(finished : boolean);
var
  fn : string;
begin
  //ruim het rentix.nu bestandje op. Deze file wordt door Webix neergezet om een rentix-sessie te starten
  fn := TUtility.AppRoot + 'rentix.nu';
  if FileExists(fn) then begin
    FileSetAttr(fn, 0);
    deletefile(fn);
  end;
  fn := TUtility.AppRoot + 'rentix.lck';
  if FileExists(fn) then begin
    if finished or (Locktime > 10) then begin
      //ruim de lockfile op als Rentix klaar is, of als de lockfile ouder is dan 10 minuten
      FileSetAttr(fn, 0);
      deletefile(fn);
    end;
  end;
end;

function RentixLocked: boolean;
var
  fn : string;
begin
  result := false;        //WICA
  exit;

  fn := TUtility.AppRoot + 'rentix.lck';
  if FileExists(fn) then begin
    //Rentix is gelocked als de lockfile jonger is dan 10 minuten
    result := (Locktime <=10);
    if (FinixLicentieT.instance.LicentieValid) then begin
      if (FinixLicentieT.instance.HasModule(ModuleDebug)) then begin
        result := false;
      end;
    end;
  end else begin
    //file bestaat niet dus niet gelocked.
    result := False;
  end;
end;

procedure LockRentix;
var
  fn:string;
  f:textfile;
  s:string;
begin
  //Maak een lock-file met daarin een timestamp  (decimalseperator altijd een punt)
  fn := TUtility.AppRoot + 'rentix.lck';
  AssignFile(f,fn);
  rewrite(f);
  s := FloatToStr(now);
  s := StringReplace(s,',', '.',[] );
  writeln(f, s);
  closefile(f);
end;


function TfrmMainformClient.GetMaatschappijUpdateDatum(MaatschappijID: integer): TdateTime;
var
  rs : TAdoRecordset;
  s : string;
begin
  s := 'SELECT DatumRentes FROM Lening WHERE maatschappijGUID = ' + inttostr(MaatschappijID);
  try
    rs := hypmaatschapDB.OpenQuery(s);
    if not rs.EOF then begin
      if VarIsNull(rs.Fields.Item[0].Value) then begin
        result := 0;
      end else begin
        try
          result := rs.Fields.Item[0].Value;
        except
          result := 0;
        end;
      end;
    end else begin
      result := 0;
    end;
    hypmaatschapDB.CloseQuery(rs);
  except
    result := 0;
  end;
end;

function TfrmMainformClient.GetMaatschappijRenteSheetVersie(MaatschappijID: integer; Toekomst : boolean): integer;
var
  rs : TAdoRecordset;
  s : string;
begin
  if toekomst then begin
    s := 'SELECT RenteSheetToekomstVersie FROM maatschappij WHERE [GUID] = ' + inttostr(MaatschappijID);
  end else begin
    s := 'SELECT RentesheetVersie FROM maatschappij WHERE [GUID] = ' + inttostr(MaatschappijID);
  end;
  try
    rs := hypmaatschapDB.OpenQuery(s);
    if not rs.EOF then begin
      if VarIsNull(rs.Fields.Item[0].Value) then begin
        result := 0;
      end else begin
        try
          result := rs.Fields.Item[0].Value;
        except
          result := 0;
        end;
      end;
    end else begin
      result := 0;
    end;
    hypmaatschapDB.CloseQuery(rs);
  except
    result := 0;
  end;
end;

procedure TfrmMainformClient.UpdateMaatschappijRenteSheetVersie(MaatschappijID:integer; aVersie : integer; Toekomst : boolean);
var
  s:string;
begin
  if toekomst then begin
    s := 'UPDATE maatschappij SET RentesheetToekomstVersie=' + inttostr(aVersie)+' WHERE [GUID] = ' + inttostr(MaatschappijID);
  end else begin
    s := 'UPDATE maatschappij SET RenteSheetVersie=' + inttostr(aVersie)+' WHERE [GUID] = ' + inttostr(MaatschappijID);
  end;
  try
    hypmaatschapDB.QueryExecute(s);
  except
  end;
end;

{procedure TfrmMainformClient.UpdateMaatschappijUpdateDatum(MaatschappijID:integer;
  aDatum: TdateTime);
var
  s:string;
begin
  s := 'UPDATE Lening SET Lening.DatumRentes = ' + FloatToStr(aDatum) + ' ';
  s := s + 'WHERE maatschappijGUID = ' + inttostr(MaatschappijID);
  try
    hypmaatschapDB.QueryExecute(s);
  except
  end;
end;
}

procedure TfrmMainformClient.btnSluitenClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMainformClient.FormCreate(Sender: TObject);
var
  v:FileVersionInfoRetrieverT;
begin
  v := FileVersionInfoRetrieverT.create(GetModuleName(HInstance));
  //TaskbarProgress.ProgressState := fstpsNormal;
  Caption := '(c) Euroface Financial Services  - Rentix ' + format('%d.%d.%d', [v.fileVersion[0], v.fileVersion[1], v.fileVersion[2]]);
  v.free;
  Label1.Caption := '(c) 2003-' + inttostr(yearof(now)) + ' Euroface Financial Services';
  Meldingen := TstringList.Create;
  Maatschappijen := TStringList.Create;
  GetMaatschappijen;
  ShutDownNow := false;

  if Runmode <> rmBeheer then begin
    CheckWriteRights;
  end;

  if ShutDownNow then begin
      TimerAutoStart.Enabled := true;
      Button1.Visible := false;
      btnSluiten.Visible := false;
      btnOpties .Visible := false;
      WindowState := wsMinimized;
      exit;
  end;

  HTTPRIO1.URL := 'http://' + GlobalOpties.EurofaceServer + '/scripts/Rentixservice.exe/soap/IRentix';

  StelProxyIn(HTTPRIO1);

  RentixWeb := (HTTPRIO1 as IRentix);
  cbAutoAfsluit.Visible := false;
  if Trunc(LaatsteUpdateDatum) = date then begin
    if runmode in [rmAuto] then begin
      ShutDownNow := true;
      WindowState := wsMinimized;
      TimerAutoStart.Enabled := true;
    end;
  end else begin
    if runmode in [rmAuto] then begin
      frmDialogRenteUpdate := TfrmDialogRenteUpdate.Create(self);
      if frmDialogRenteUpdate.ShowModal = mrcancel then begin
        ShutDownNow := true;
        WindowState := wsMinimized;
        TimerAutoStart.Enabled := true;
      end;
      frmDialogRenteUpdate.Free;
    end;
  end;
  if not ShutDownNow then begin
    if UitZicht then begin
      SetBounds(_left, top,width,Height);
    end;
    if Runmode in [rmbeheer, rmAdmin] then begin
      btnOpties.Visible := true;
    end else begin
      btnOpties.Visible := false;
    end;

    if Runmode in [rmAuto, rmAdminAuto] then begin
      Button1.Visible := false;
      btnSluiten.Visible := false;
      BorderIcons := [];
      TimerAutoStart.Enabled := true;
      cbAutoAfsluit.Visible := true;
      cbAutoAfsluit.Checked := GlobalOpties.AutoAfsluitClient;
    end;
  end;
end;

procedure TfrmMainformClient.btnOptiesClick(Sender: TObject);
begin
  FrmOpties := TFrmOpties.create(self);
  FrmOpties.hide;
  FrmOpties.ShowModal;
end;

procedure TfrmMainformClient.RunAuto;
begin
  Button1Click(self);
  if NieuweRentesGevonden then begin
    FormStyle := fsStayOnTop;
    Application.ProcessMessages;
    SetFocus;
//    PlaySound(PChar('SYSTEMASTERISK'), 0, SND_ASYNC);
    Melding('Nieuwe Rentes zijn ontvangen.', false);
    if not StilleMode then begin
      efsShowMessage('Rentix heeft nieuwe rentes ontvangen.'+#13+
        'Als FINIX actief is, zullen de gewijzigde rentes automatisch te zien zijn.');
    end;
  end;
end;

function TfrmMainformClient.VerwerkXML(filenaam: string; MaatschappijID: integer; Ingangsdatum : tDateTime) : boolean;
var
  xmldata : TXMLimport;
  prod : string;
  rvpLijst : TList;
  rvpObj : TRVP;
  i,j : integer;
  error:string;
  oke : integer;
  mnaam : string;
  Omsch ,s: string;
  Update : boolean;
  LastUpdateDatum : TdateTime;
  index:integer;
  waarschuwingen : integer;
  tekstLabel : string;
  totaalaantal : integer;
  RenteAnders : boolean;
  Logged : boolean;
  RentesheetDatum, toekomstdatum : TDateTime; 
  rs : TAdoRecordset;
  fout:boolean;
begin
  Logged :=false;
  tekstLabel := lblMaatschappij.Caption;
  result := True;
  xmldata := TXMLimport.Create;
  if xmldata.ImportFile(filenaam, MaatschappijID ) then begin
      totaalaantal := 0;
      for i:= 0 to xmldata.Leningen.Count -1 do begin
        totaalaantal := totaalaantal + TList(xmldata.Leningen.Objects[i]).Count
      end;

      //TaskbarProgress.ProgressValueMax := totaalaantal;
      //TaskbarProgress.ProgressValue := 0;
      //TaskbarProgress.Active := true;

      Gauge1.Position := 0;
      Gauge1.Properties.Min := 0;
      Gauge1.Properties.Max := totaalaantal;

      RenteAnders := false;
      RentesheetDatum := 0;
      for i:= 0 to xmldata.Leningen.Count -1 do begin
        Prod := xmldata.Leningen.Strings[i];
        rvpLijst := TList(xmldata.Leningen.Objects[i]);

        index := LeningLijst.indexof(lowercase(prod));
        if index>=0 then begin
          if TLeningData( LeningLijst.objects[index]).Actief then begin
            mnaam := TLeningData( LeningLijst.objects[index]).MaatschappijNaam;
            omsch := TLeningData( LeningLijst.objects[index]).Omschrijving;
            LastUpdateDatum := ingangsDatum;

            lblMaatschappij.Caption := tekstlabel + mnaam;
            lblMaatschappij.Refresh;

            Update:=True;
            if rvpLijst.Count >0 then begin
              rvpObj := TRVP(rvpLijst.items[0]);
              //niet meer controleren op datum. De controle werkt nu op Versienummer en die controle is al geweest
              //altijd de update uitvoeren dus!
//              if (LastUpdateDatum < rvpObj.Datum) or (runmode in [rmAdmin,rmAdminAuto]) then begin
                if rvpObj.Datum > date() then begin
                  _meldingen.Add('--> Rente update ontvangen voor "' + Omsch + '" van de maatschappij "' + mnaam +'".');
                  _meldingen.Add('    Deze rentewijziging geldt vanaf: ' + FormatDateTime('dddd, dd-mm-yyyy', rvpObj.Datum) + ' en zal vanaf die datum geactiveerd worden.');
                  //reset de datum van het rentebestand in Rentix anders
                  //wordt hij de volgende keer niet meegenomen.
                  //UpdateMaatschappijUpdateDatum (MaatschappijID, 29221 );  //1-1-1980
                  if nieuwerentesophalen then Update:=true else Update := false;
                  result := true;
                end;
                if rvpObj.Datum > RentesheetDatum then RentesheetDatum := rvpObj.Datum;
                if rvpObj.Datum = date() then begin
                  result := true;
                end;
                if rvpObj.Datum > date() then begin
                end;
//              end else begin
//                update := false;
//                _Meldingen.Add('Geen nieuwe rente update ontvangen voor "' + Omsch + '" van de maatschappij "' + mnaam +'"' );
//              end;
            end;
          end else begin
            update := false;
          end;
        end else begin
          Update:= false;
        end;
        if update then begin
          rvpobj := nil;
          UpdateRenteTeksten(MaatschappijID, xmlData.HeeftVerlengingsrente,  xmlData.RenteTeksten);
          for j:= 0 to rvpLijst.Count -1 do begin
            rvpObj := TRVP(rvpLijst.items[j]);
            waarschuwingen := 0;
            oke := UpdateRentes(prod, rvpobj.GUID ,rvpobj.Rentevorm, rvpObj.RenteBedenktijdtype, rvpObj.Looptijd, FinixID,   rvpobj.Rentelijst, waarschuwingen, error, rvpobj.Datum);
            Warnings := Warnings + waarschuwingen;
            TotaalWarnings := TotaalWarnings + waarschuwingen;
            if oke >= 1 then begin
              RenteAnders := true;
{              try
                GlobalClientDB.UpdateLeningUpdateDatum(prod, rvpobj.Datum);
              except
                on e:exception do begin
                  Warnings := Warnings +1;
                  result := false;
                  ShowMessage('Update informatie kon niet worden weggeschreven in de Rentix-database. Systeemmelding: ' + e.Message);
                end;
              end;  }
            end else begin
              if error>'' then begin
                _Meldingen.Add(error);
              end;
            end;
            Gauge1.Position := Gauge1.Position +1;
            //TaskbarProgress.ProgressValue := TaskbarProgress.ProgressValue+1;

          end; //for j
          
          if RentesheetDatum >0 then begin
            s := floattostr(RentesheetDatum);
            s := StringReplace(s, ',', '.',[rfReplaceAll ]);
            s := StringReplace(s, '.', '.',[rfReplaceAll ]);

            fout:= false;
            toekomstdatum := -1;
            try
              rs := GlobalClientDB.OpenQuery('select datumtoekomstrentesheet from lening WHERE ([GUID]=' + quotedstr(prod) + ')') ;
              if not rs.EOF then begin
                toekomstdatum := ReadDBValue(varDate, rs, 'datumtoekomstrentesheet', false, fout );
              end;
              GlobalClientDB.CloseQuery(rs);
            except
              on e:exception do begin
                _Meldingen.Add( 'Database-query (uitlezen datumtoekomstrentesheet) kon niet worden uitgevoerd. error: ' + e.Message);
              end;
            end;

            try
              if toekomstdatum <= date then begin
                GlobalClientDB.QueryExecute('update lening set datumrentesheet=' + inttostr(trunc(toekomstdatum)) + ' WHERE ([GUID]=' + quotedstr(prod) + ')');             
              end;
            except
              on e:exception do begin
                _Meldingen.Add( 'Database-query (beschrijven datumrentesheet) kon niet worden uitgevoerd. error: ' + e.Message);
              end;
            end;

            try
              if RentesheetDatum <= date then begin
                GlobalClientDB.QueryExecute('update lening set datumrentesheet=' + inttostr(trunc(RentesheetDatum)) + ' WHERE ([GUID]=' + quotedstr(prod) + ')');             
              end;
            except
              on e:exception do begin
                _Meldingen.Add( 'Database-query (beschrijven datumrentesheet) kon niet worden uitgevoerd. error: ' + e.Message);
              end;
            end;

            try
              GlobalClientDB.QueryExecute('update lening set datumtoekomstrentesheet=' + s + ' WHERE [GUID]=' + quotedstr(prod)); 
            except
              on e:exception do begin
                _Meldingen.Add( 'Database-query (beschrijven datumtoekomstrentesheet) kon niet worden uitgevoerd. error: ' + e.Message);
              end;
            end;              
          end;


          if RenteAnders then begin

            framStap10.Label1.Caption := 'Een of meer rentetarieven zijn aangepast ! Bekijk de details om te zien welke.';
            if not logged then begin
              melding('Nieuwe rentetarieven ontvangen voor ' + mnaam ,false);
              logged:=true;
            end;
            framStap10.Status := 3;
            NieuweRentesGevonden := true;
            _Meldingen.Add('--> ' + mnaam + ' heeft nieuwe rentes voor ' + Omsch + '.');
            if assigned(rvpObj) then begin
              if rvpObj.Datum = date() then begin
                _meldingen.Add('    Deze rentewijziging geldt vanaf vandaag !');
              end;
              if rvpObj.Datum < date() then begin
                _meldingen.Add('    Deze rentewijziging is al geldig vanaf ' + FormatDateTime('dddd, dd-mm-yyyy', rvpObj.Datum) +'.' );
              end;
            end;
          end;
          RenteAnders := false;
        end;
      end; //for i\
  end else begin
    Warnings := Warnings + 1;
    TotaalWarnings := TotaalWarnings + 1;
    result := false;
    melding('fout in verwerking van ' + filenaam + #13#10 + xmldata.LastResult);
  end;

  //TaskbarProgress.Active := False;
end;

function TfrmMainformClient.CallGetUpdateLijst : boolean;
var
  s:string;
  Lijst : string;
  i:integer;
  fout:integer;
begin
  result := true;
  Warnings := 0;
  Errors := 0;


  // ---------------------------------------------------------------------------
  // 2012-03-30 JS:
  fout := 0;
  // Voorkomt dat Rentix zo nu en dan kapt na stap 5..
  // Het blijkt n.l. dat een niet-geinitializeerde variabele foutieve random waarden
  // aanneemt en met een giga-hoge errorcode terugkomt. Verderop wordt
  // "RentixWeb.GetUpdateLijst" aangeroepen, waar fout terugkomt zoals het
  // in is gegaan.
  //
  //
  // !! Why doesn't nobody care about this?!?
  // !! (JS: vermoedelijk omdat 'zij' de telefoon niet hoeven te beantwoorden)
  //
  // ---------------------------------------------------------------------------

  _UpdateLijst := TStringList.Create;
  _FilenaamLijst := TStringList.Create;
  lijst:='';

  try
    Lijst := RentixWeb.GetUpdateLijst(FinixID, fout);
  except
    Melding('Webservice van Euroface is onbereikbaar.'#13 +
                'Dit is mogelijk een tijdelijk of eenmalig probleem.'#13 +
                'Probeer het, na opnieuw opstarten van Rentix, nogmaals.');
    Errors := errors +1;
    result :=false;
    exit;
  end;

  if fout=0 then begin
    while lijst<>'' do begin
      i := pos(';' , lijst);
      if i=0 then begin
        lijst := '';
      end else begin
        s := copy(lijst,1,i-1);
        if FinixLicentieT.instance.HasModule(LicentieModuleT(strtointdef(s,0))) then begin
          _UpdateLijst.Add(s);
        end;
        delete(lijst,1,i);
      end;
    end;
  end else begin
    ExplainError(fout);
    result := false;
  end;
end;

procedure TfrmMainformClient.Button1Click(Sender: TObject);

    function rlic(s:string) : string;
      var
        i:integer;
    begin
      result :='';
      for i:= 1 to length(s) do begin
        if odd(i) then begin
          result := result + s[i];
        end;
      end;
    end;
begin
  CheckWriteRights;
  if ShutDownNow then begin
    close;
    exit;
  end;
  framinit.Status := 2;
  framStap9.Status := 0;
  Button2.Visible := false;
  NieuweRentesGevonden := false;
  try
    GlobalClientDB := TControllerDB.Create(GlobalOpties.clientDatabasenaam );
    GlobalClientDBExtension :=  TClientControllerDB.Create();
    GlobalClientDB.CheckWritable(true);
  except
    framinit.Status := -1;
    melding(GlobalOpties.clientDatabasenaam +' kan niet gevonden of geopend worden.');
    exit;
  end;
  try
    GlobalRenteDbase := TControllerDB.Create(GlobalOpties.BBRenteDatabasenaam);
    GlobalRenteDbase.CheckWritable(true);
    GlobalRenteDbase.GetVersion;
  except
    framinit.Status := -1;
    melding('De rentedatabase van Finix "'+ GlobalOpties.BBRenteDatabasenaam +'" kan niet gevonden of geopend worden.'#13 +
                'Controleer de lokatie-instelling en of de database beschrijfbaar is.');
    exit;
  end;
  TotaalWarnings := 0;
  TotaalErrors := 0;
  TooMuchWarnings := false;  

  try
    _Meldingen.Add('Er wordt gebruik gemaakt van de website ' + uppercase(GlobalOpties.EurofaceServer) +'.');
    framinit.Status := 1;
    framStap1.Status := 2;
    if CheckLicentieEnUpdateDatum then
    begin
      lblLicentie.Caption := 'Licentie: '+ uppercase(FinixID);
      lblLicentie.Refresh;
      framStap1.Status := 1;
      framStap2.Status := 2;

      activateNieuweRentes;

      if CheckInternet then begin

        if Runmode in [rmAdmin,rmAdminAuto] then begin
          try
            RentixWeb.ResetClientUpdateDatum(FinixID, '23$zxW8#');
          except
            framStap2.Status := -1;
            raise Exception.Create('Er kon geen contact worden gemaakt met internet.'#13 +
                'Waarschijnlijk is er geen internetverbinding beschikbaar.'#13 +
                'Om dit te controleren, kun u naar uw favoriete site surfen met uw internetbrowser (bv Internet Explorer), '#13 +
                'Als dit gelukt is, probeert u dan opnieuw Rentix te starten.'#13);
          end;
        end;
        framStap2.Status := 1;

        framStap3.Status := 2;
        if UpdatePatches then begin
          framStap3.Status := 1;
        end else begin
          framStap3.Status := -1;
          inc(Errors);
        end;

        if UpdateDatabasePatches then begin
          framStap4.Status := 1;
        end else begin
          framStap4.Status := -1;
        end;

        framStap5.Status := 2;
        if CallGetUpdateLijst then begin
          framStap5.Status := 1;
          framStap6.Status := 2;
          if _UpdateLijst.count>0 then begin
            if DownloadRentebestanden then begin
              framStap6.Status := 1;
              framStap7.Status := 2;
              if VerwerkenXML then
              begin
                if Warnings + Errors =0 then
                begin
                  framStap7.Status := 1;
                end else begin
                  framStap7.Status := -1;
                end;
                warnings := 0;
                TooMuchWarnings := false;                  
                errors := 0;
                activateNieuweRentes;

                if CallGetUpdateLijst then
                begin
                  framStap8.Status := 2;
                  framStap9.Status := 0;

                  nieuwerentesophalen := true;
                  if DownloadRentebestanden then
                    framStap8.Status := 1;
                    framStap9.Status := 2;
                    if VerwerkenXML then activateNieuweRentes;
                    if Warnings + Errors =0 then
                    begin
                      framStap9.Status := 1;
                    end else begin
                      framStap9.Status := -1;
                    end;
                end;

                RentixWeb.UpdateAccessDatum(FinixID);
              end else begin
                framStap7.Status := -1;
              end;
            end else begin
              framStap6.Status := -1;
            end;
          end else begin
            _Meldingen.Add('Er zijn geen nieuwe rentebestanden ontvangen.');
            framStap5.Status := 1;
            framStap6.Status := 1;
            framStap7.Status := 1;
          end;
        end else begin
          framStap5.Status := -1;
        end;
      end else begin
        framStap2.Status := -1;
      end;
    end else
    begin
      if errors=0 then
      begin
        activateNieuweRentes;
        framStap1.Status := 1;
      end else begin
        framStap1.Status := -1;
      end;
    end;
  except
    on e:exception do begin
      inc(Errors);
      Melding('Foutmelding! '#13#13 + e.Message + #13'Update niet succesvol !');
      btnSluiten.Visible := true;
      cbAutoAfsluit.Checked := false;
    end;
  end;
  try
    if Assigned(GlobalRenteDbase) then begin
      GlobalRenteDbase.Free;
    end;
  except
  end;
  try
    if assigned(GlobalClientDB) then begin
      GlobalClientDB.Free;
    end;
  except
  end;
  Gauge1.Position := Gauge1.Properties.Max;
  //TaskbarProgress.ProgressValue := TaskbarProgress.ProgressValueMax;
  //TaskbarProgress.Active:=false;
  _Meldingen.Add('');
  _Meldingen.Add('Waarschuwingen: ' + inttostr(Totaalwarnings) + ', fouten : ' + inttostr(totaalerrors));
  if totaalerrors=0 then begin
    if totaalWarnings =0 then begin
      framStap11.Label1.Caption := 'Update succesvol !';
      framStap11.Status := 1;
    end else begin
      framStap11.Label1.Caption := 'Update gedeeltelijk succesvol. Controleer de details om de ernst te achterhalen.';
      framStap11.Status := -1;
    end;
  end else begin
    framStap11.Label1.Caption := 'Update niet succesvol ! Controleer de details om de ernst te achterhalen.';
    framStap11.Status := -1;
  end;
  if UitZicht then begin
    SetBounds(_left, top,width,Height);
    Application.ProcessMessages;
  end;
  Cleanup(True);
  Button2.Visible := True;
end;

function TfrmMainformClient.VerwerkenXML:boolean;
var
  i:integer;
  UpdateDatum: boolean;
  VersieObj: TRentixClass;

  teller : Integer;
  fout : integer;
begin
  updateDatum := True;
  try
    if not assigned(GlobalClientDB) then begin
      inc(Errors);
      Melding('FOUT - De database "HybMaatschappijDB.mdb" kan niet geopend worden.'#13 +
              '       Controleer de lokatie-instelling en of de database beschrijfbaar is.');
      UpdateDatum:=false;
      result :=false;
    end;
    teller := 0;
    fout := 0;

    //TaskbarProgress.ProgressState := fstpsNormal;
    //TaskbarProgress.ProgressValueMax := _FilenaamLijst.Count;
    //TaskbarProgress.ProgressValue := 0;

    for i := 0 to _FilenaamLijst.Count -1 do
    begin
      //TaskbarProgress.ProgressValue := i;
      lblMaatschappij.Caption := 'Bezig met ' + inttostr(i+1) + ' van ' + inttostr(_FilenaamLijst.Count) + ' : ';
      if _FilenaamLijst.Strings[i] <> '' then begin
        VersieObj := TRentixClass(_FilenaamLijst.Objects[i]);
        if VerwerkXML(_FilenaamLijst.Strings[i], VersieObj.MaatschappijID, VersieObj.Ingangsdatum  ) then begin
          teller := teller +1;
          UpdateMaatschappijRenteSheetVersie( VersieObj.MaatschappijID, VersieObj.Versienummer, nieuwerentesophalen);
        end else begin
          fout := fout + 1;
        end;
      end;
      Application.ProcessMessages;
    end;
    //TaskbarProgress.ProgressValue := _FilenaamLijst.Count;
    //TaskbarProgress.ProgressState := fstpsPaused;

    if nieuwerentesophalen then
    begin
      lblMaatschappij.Caption := inttostr(teller) + ' maatschappijen aangekondigde rentes up to date gemaakt. Bij ' + inttostr(fout) + ' is dit mislukt.';
      lblMaatschappij.Refresh;
      melding(inttostr(teller) + ' maatschappijen aangekondigde rentes up to date gemaakt. Bij ' + inttostr(fout) + ' is dit mislukt.', false);
    end
    else
    begin
      lblMaatschappij.Caption := inttostr(teller) + ' maatschappijen actuele rentes up to date gemaakt. Bij ' + inttostr(fout) + ' is dit mislukt.';
      lblMaatschappij.Refresh;
      melding(inttostr(teller) + ' maatschappijen actuele rentes up to date gemaakt. Bij ' + inttostr(fout) + ' is dit mislukt.', false);
    end;

    if (teller = 0) and (fout=0) then begin
      _Meldingen.Add('Van geen enkele maatschappij zijn nieuwe rentes ontvangen.');
      result := true;
    end else begin
      if fout>0 then begin
        Result := false;
      end else begin
        result := true;
      end;
    end;
  finally
    try
      if UpdateDatum then begin
        SaveLaatsteUpdate;
        GlobalClientDBExtension.UpdateOverallUpdateDatum;
      end;

    except
    end;
  end;
end;

constructor TfrmMainformClient.Create(aOwner: Tcomponent);
begin
  inherited;

  nieuwerentesophalen := false;
  _Meldingen := TStringList.Create;
  Maatschappijen := TStringList.Create;
  MaatschappijenID := TStringList.Create;
  framStap10.Label1.Caption := '';
  framStap10.Status := 0;
  framStap11.Label1.Caption := '';
  framStap11.Status := 0;

  if Runmode = rmAuto then begin
    //dit is nodig om het scherm uit het zicht te brengen voor het zichtbaar wordt.
    SetBounds(20000,top,width,height);
    UitZicht := true;
  end;
  ShutDownNow := false;
  Randomize;
end;

destructor TfrmMainformClient.Destroy;
begin
  Cleanup(true);
  hypmaatschapDB.Free;
  _FilenaamLijst.Free;
  _UpdateLijst.free;
  LeningLijst.free;
  inherited;
end;

procedure TfrmMainformClient.SetWarnings(const Value: integer);
const
  limiet=30;
begin
  _Warnings := value;
  if (not TooMuchWarnings) and (Warnings>limiet) then begin
    TooMuchWarnings:= true;
    inc(errors);
    inc(TotaalErrors);
    _Meldingen.Add('FOUT: aantal waarschuwingen > ' + inttostr(limiet));
  end;
end;

function TfrmMainformClient.CheckLicentieEnUpdateDatum : boolean;
var
  error : string;
begin
  result := true;
  if assigned( GlobalClientDB ) then begin
    if not GlobalClientDBExtension.CheckLicentieEnUpdateDatum(error) then begin
      if error ='' then begin
      Melding('Rentegegevens zijn vandaag al up to date gebracht.');
        _Meldingen.Add('Rentegegevens zijn vandaag al up to date gebracht.');
        SaveLaatsteUpdate;
      end else begin
        inc(Errors,1);
        _Meldingen.Add('Rentix licentie gegevens zijn niet correct.');
        _Meldingen.Add('Neem contact op uw leverancier voor meer informatie over Rentix.');
        Melding(error);
      end;
      result := false;
    end;
  end else begin
    result := false;
  end;
end;

function TfrmMainformClient.CheckInternet: boolean;
var
  www : TNetWrap;
  wwwOke,stop : boolean;
  sc: Tcursor;
begin
  sc := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if GlobalOpties.InternetMode = imGeen then begin
      result := false;
      exit;
    end;
    result := false;
    www := TNetWrap.Create;
    if GlobalOpties.InternetMode = imInbel then begin
      if not www.InternetIsActive then begin
        if MessageDlg('Er zal nu contact worden gelegd met internet. Doorgaan?', mtConfirmation, [mbYes,mbNo],0 ) = mrNo then begin
          Result := false;
          exit;
        end;
      end;
    end;
    wwwOke:=false;
    stop := false;
    while (not wwwOke) and (not stop) do begin
      wwwOke := True;
      if not wwwOke then begin
        if StilleMode then begin
          Melding('Er kon geen contact worden gemaakt met internet.');
          wwwOke := false;
          result := false;
          stop := true;
        end else begin
          If MessageDlg(
            'Er kon geen contact worden gemaakt met internet.'#13 +
            'Waarschijnlijk is er geen internetverbinding beschikbaar.'#13 +
            'Om dit te controleren, kun u naar uw favoriete site surfen met uw internetbrowser (bv InternetExplorer), '#13 +
            'Als dit gelukt is, probeert u dan opnieuw.'#13#13+
            'Nu opnieuw proberen ?', mtInformation, [mbYes, mbNo], 0)= mrNo
          then begin
            wwwOke := false;
            result := false;
            stop := true;
          end;
        end;
      end else begin
        result := true;
        wwwOke := true;
        stop := true;
      end;
    end;
  finally
    Screen.Cursor := sc;
  end;
end;

procedure TfrmMainformClient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RentixWeb := nil;
end;

procedure TfrmMainformClient.TimerAutoStartTimer(Sender: TObject);
var
  i:integer;
begin
  _left := left;
  TimerAutoStart.Enabled := false;
  if ShutDownNow then begin
    btnSluiten.Click;
    exit;
  end;

  melding('Rentix start', false);
  RunAuto;
  AddToLog('Rente update klaar. Fouten : ' + inttostr(TotaalErrors) + ' Waarschuwingen:  ' + inttostr(TotaalWarnings));
  if (TotaalErrors + TotaalWarnings = 0)  and (cbAutoAfsluit.Checked) then begin
    framStap11.Label1.Caption := 'Update succesvol. Dit programma zal automatisch worden afgesloten in 3 seconden.';
    framStap11.status:= 1;
    for i:= 59 downto 0 do begin
      Application.ProcessMessages;
      sleep(50);
      if (i mod 20)=0 then begin
        framStap11.Label1.Caption := 'Update succesvol. Dit programma zal automatisch worden afgesloten in ' + inttostr(i div 20) + ' seconden.';
      end;
      if not cbAutoAfsluit.Checked then begin
        framStap11.Label1.Caption := 'Update succesvol. Het automatisch afsluiten is uitgezet door de gebruiker.';
        break;
      end;
    end;
    if cbAutoAfsluit.Checked then begin
      close;
    end else begin
      btnSluiten.Visible := true;
    end;
  end else begin
    btnSluiten.Visible := true;
  end;
  SaveLaatsteUpdate;
  if StilleMode then close;
end;

function TfrmMainformClient.DownloadRentebestanden: boolean;
var
  i:integer;
  SoapAttachment: TSoapAttachment;
  MaatschappijID:string;
  Pogingen : integer;
  opnieuw : boolean;
  s,maa:string;
  fout:integer;
  aDatum, MyDate, ServerDate : TdateTime;
  index : integer;
  versieObj : TRentixClass;
  ClientVersie, serverVersie : integer;
begin
  SoapAttachment := nil;
  result := True;

  i := 0;
  repeat
    MaatschappijID := _UpdateLijst.Strings[i];
    index := MaatschappijenID.indexof(MaatschappijID);
    if index< 0 then begin
      _UpdateLijst.Delete(i);
      _Meldingen.Add('Maatschappij ' + MaatschappijID +' bestaat niet in de HypMaatschappijDB. Dit rentebestand wordt overgeslagen.');
    end else begin
      inc(i);
    end;
  until i = _UpdateLijst.Count;

  Gauge1.Properties.Min := 0;
  Gauge1.Properties.Max := _UpdateLijst.Count;

  //TaskbarProgress.ProgressValueMax := _UpdateLijst.Count;
  //TaskbarProgress.ProgressValue := 0;
 // TaskbarProgress.Active:=true;

  lblmaatschappij.Caption := '';

  for i := 0 to _UpdateLijst.Count -1 do begin

    Application.ProcessMessages;
    MaatschappijID := _UpdateLijst.Strings[i];
    index := MaatschappijenID.indexof(MaatschappijID);
    if index>= 0 then begin
      maa := Maatschappijen.Strings[index];
      s := '';
      clientVersie := GetMaatschappijRenteSheetVersie(strtointdef(MaatschappijID,0), nieuwerentesophalen);
      ServerVersie := RentixWeb.GetSheetVersieEnDatum(FinixID, strtointdef(MaatschappijID,0), nieuwerentesophalen, ServerDate, fout );
      if clientversie < Serverversie then begin // als de sheet op de server nieuwer is, downloaden
        versieObj := TRentixClass.create;
        versieObj.Versienummer := ServerVersie;
        versieObj.MaatschappijID := strtointdef(MaatschappijID, 0);
        versieObj.Ingangsdatum := ServerDate;
        try
          Pogingen := 1;
          opnieuw := true;
          while opnieuw do begin
            opnieuw := false;
            try
              Refresh;
              SoapAttachment:= TSoapAttachment.Create ;
              SoapAttachment := RentixWeb.GetRenteBestandv6(FinixID, strtointdef(MaatschappijID,0), fout, nieuwerentesophalen);   // ophalen rentesheet
              if Assigned(SoapAttachment) then begin
                s := GlobalOpties.Temppad  + 'ERW_' + MaatschappijID + '.xml';
                try
                  SoapAttachment.SaveToFile( s );
                  _Meldingen.Add('>>> Nieuw rentebestand van maatschappij ' + Maa +' ontvangen.');
                  lblmaatschappij.Caption := 'Nieuw rentebestand van maatschappij ' + Maa +' ontvangen...';
                except
                  Melding('Het ontvangen rentebestand kon niet worden gesaved naar : '#13 +s+#13'Dit rentebestand zal worden overgeslagen.');
                  _Meldingen.Add('Rentebestand van maatschappij ' + Maa +' overgeslagen vanwege een fout.');
                end;
              end else begin
                if fout<> 0 then begin
                  ExplainError(fout);
                  if fout=-3 then begin
                    _Meldingen.Add('Maatschappij = ' + Maa);
                  end;
                end else begin
                  _Meldingen.Add('Maatschappij ' + Maa +' heeft geen nieuw rentebestand.');
                  if nieuwerentesophalen then begin
                    //Indien "toekomst-mode"
                    //als de versie van de client lager is dan de versie op de server, dan is er iets mis. Maak de client-versie gelijk aan de server-versie
                    UpdateMaatschappijRenteSheetVersie(strtointdef(MaatschappijID,0), serverVersie, True);
                  end;
                end;
              end;
            except
              opnieuw := true;
              Pogingen := Pogingen +1;
              if Pogingen > 5 then begin
                Melding('Webservice van Euroface is onbereikbaar.');
                result :=false;
                opnieuw := false;
                inc(Errors);
              end else begin
                Sleep(2000);
              end;
            end;
          end;
        finally
          if s > '' then begin
            _FilenaamLijst.AddObject(s, versieObj);
          end;
          if assigned(SoapAttachment) then begin
            try
              SoapAttachment.Free;
            except
            end;
          end;
        end;
      end;
    end;

    //TaskbarProgress.ProgressValue := TaskbarProgress.ProgressValue+1;
    Gauge1.Position := i+1;
    Gauge1.Refresh;
  end; //for i

  //TaskbarProgress.Active:=false;
end;

procedure TfrmMainformClient.cbAutoAfsluitClick(Sender: TObject);
begin
  if cbAutoAfsluit.Checked = not GlobalOpties.AutoAfsluitClient then begin
    GlobalOpties.AutoAfsluitClient := cbAutoAfsluit.Checked;
    GlobalOpties.WriteToIni;
  end;
end;

procedure TfrmMainformClient.ExplainError(WebserviceFout: integer);
var
  s:string;
//  newId :string;
//  i:integer;
//  rlic : string;
begin
  s := '';
  case WebserviceFout of
    -1: begin
          s := 'De rente-update service geeft aan dat er, buiten dit programma om, vandaag al contact is ';
          s := s + 'geweest met de service met behulp van uw licentiecode.';
          s := s + 'Dit kan betekenen dat iemand buiten u of uw organisatie contact maakt van uw licentiecode.';
          s := s + 'Per licentiecode kan maar eenmaal per dag contact gemaakt worden.';
          s := s + 'Neem contact op uw leverancier als dit vaker gebeurt.';
          Errors := Errors +1;
          TotaalErrors := TotaalErrors + 1;
        end;
    -2: begin
          _Meldingen.Add('FOUT');
          _Meldingen.Add('De Finix-licentie is niet valide.');
          Errors := Errors +1;
          TotaalErrors := TotaalErrors + 1;
        end;
    -3: begin
          s := s + 'Rente update bestand van maatschappij niet correct ontvangen.';
          Warnings := Warnings +1;
          TotaalWarnings := TotaalWarnings + 1;
        end;
  end;
  if s<> '' then melding(s);
end;


procedure TfrmMainformClient.Button2Click(Sender: TObject);
begin
  frmMeldingen := TfrmMeldingen.Create(self);
  frmMeldingen.Memo1.Text := _Meldingen.GetText;
  frmMeldingen.ShowModal;
end;

procedure TfrmMainformClient.SaveLaatsteUpdate;
var
  s:string;
begin
  try
    hypmaatschapDB.QueryExecute('update Rentixdatum set rentixdatum='+ inttostr(trunc(now)));
    s := floattostr(now);
    s := StringReplace(s, ',', '.', [rfReplaceAll ]);
    hypmaatschapDB.QueryExecute('update Rentixdatum set fullrentixdatum='+ s);
  except
  end;
end;


procedure TfrmMainformClient.getMaatschappijen;
var
  rs:TAdoRecordset;
  obj : TLeningData;
  fout : boolean;
  idx : integer;
begin
  try
    GlobalClientDB := TControllerDB.Create(GlobalOpties.ClientDatabasenaam );
    GlobalClientDBExtension :=  TClientControllerDB.Create();
  except
    melding(GlobalOpties.ClientDatabasenaam +' kan niet gevonden of geopend worden.'#13 +
            'Controleer de lokatie-instelling en of de database beschrijfbaar is.');
  end;

  if not GlobalOpties.DefaultDatapad then begin
    hypmaatschapDB := TControllerDB.Create(GlobalOpties.BBRenteDatabasenaam,false);
  end else begin
    hypmaatschapDB := TControllerDB.Create(DatabasePad + MainDatabasenaam,false);
  end;
  
  rs := hypmaatschapDB.OpenQuery('Select naam, GUID from maatschappij order by GUID');
  while not rs.EOF do begin
    Maatschappijen.Add(rs.Fields.Item[0].value);
    MaatschappijenID.Add(rs.Fields.Item[1].Value);
    rs.MoveNext;
  end;
  hypmaatschapDB.CloseQuery(rs);

  LeningLijst := TStringList.Create;
  rs := hypmaatschapDB.OpenQuery('Select * from lening');
  while not rs.EOf do begin
    obj := TLeningData.Create;
    obj.LeningGUID := lowercase(ReadDBValue(varstring, rs, 'GUID', true, fout));
    obj.MaatschappijID := ReadDBValue(varInteger, rs, 'MaatschappijGUID', true, fout);
    idx := MaatschappijenID.indexof(inttostr(obj.maatschappijID));
    if idx>=0 then begin
      obj.MaatschappijNaam := Maatschappijen.Strings[idx];
    end else begin
      obj.MaatschappijNaam := 'Maatschappij X ';
    end;
    obj.Omschrijving := ReadDBValue(varstring, rs, 'Naam', false, fout);
    obj.Datum := ReadDBValue(varDate, rs, 'DatumRentes', false, fout);
    obj.Actief := true; // FinixLicentieT.instance.HasModule(LicentieModuleT(obj.MaatschappijID));
    if not fout then begin
      LeningLijst.AddObject(trim(obj.LeningGUID), obj);
    end;
    rs.MoveNext;
  end;
  hypmaatschapDB.CloseQuery(rs);

  rs := hypmaatschapDB.OpenQuery('Select * from rentixDatum');
  LaatsteUpdateDatum := ReadDBValue(varDate, rs, 'FullRentixDatum', false, fout);
  hypmaatschapDB.CloseQuery(rs);
end;

function TfrmMainformClient.UpdatePatches: boolean;
var
  ini : string;
  fout : integer;
  klaar : boolean;
  patchteller : integer;
  aantal:integer;
  aantalTonen:integer;
  MeldingTonen : boolean;
  MaatID : integer;
  Verwerkt : boolean;
  patchnaam : string;
  LaatstSuccesvollePatch,OriginalPatchnummer : integer;
  sql : string;
  rs : TAdoRecordset;
begin
  _Meldingen.Add('Controleren op nieuwe of gewijzigde rentetarieven.');
  klaar := false;
  result := True;
  aantal := 0;
  aantalTonen := 0;
  MeldingTonen :=true;
  try

    sql := 'select * from Rentepatch';
    rs := GlobalRenteDbase.OpenQuery(sql);
    klaar := false;
    OriginalPatchnummer := ReadDBValue(varInteger, rs, 'versie' , true, klaar);
    GlobalRenteDbase.CloseQuery(rs);

    LaatstSuccesvollePatch := OriginalPatchnummer;
    patchteller := OriginalPatchnummer + 1;
    try
      while not klaar do begin
        verwerkt := false;
        ini := RentixWeb.GetMetaUpdate(FinixID, patchteller , fout);
        klaar := (ini='');
        if not Klaar then begin
          inc(aantal);
          _Meldingen.Add('Rentetarief ' + inttostr(patchteller ) +' ontvangen.');
          try
            verwerkt := VerwerktRentePatch(ini, patchteller, MaatID, patchnaam);
          except
            on e:exception do begin
              _Meldingen.Add(e.Message);
              klaar := true;
              result := false;
            end;
          end;
          MeldingTonen := True;
          if FinixLicentieT.instance.HasModule(MaatschappijIDToModule(maatid)) then begin
            MeldingTonen := true;
          end else begin
            MeldingTonen := false;
          end;
          if MeldingTonen then inc(aantalTonen);
          if not verwerkt then begin
            klaar := true;
            result := false;
            if MeldingTonen then begin
              _Meldingen.Add('Rentetarief ' + IntToStr(patchteller) + ' kan niet worden verwerkt. Eventuele verdere rentetarieven wijzigingen worden niet uitgevoerd.');
            end;
          end else begin
            if MeldingTonen then begin
              _Meldingen.Add('Rentetarief ' + IntToStr(patchteller) + ' verwerkt. ' + patchnaam);
            end;
            LaatstSuccesvollePatch := Patchteller;
            patchteller := patchteller + 1;
            result := true;
          end;
        end;
      end;
      try
        if OriginalPatchnummer <> LaatstSuccesvollePatch then begin
          melding('Rentepatches verwerkt. Versie nummer is nu ' + inttostr(LaatstSuccesvollePatch), false);
        end;
        GlobalRenteDbase.QueryExecute('update Rentepatch set [Rentepatch].[versie] = ' + inttostr(LaatstSuccesvollePatch) + ', [Rentepatch].[versiestring] = ' + quotedstr(floattostr(LaatstSuccesvollePatch/100)));
      except
        if MeldingTonen then begin
          _Meldingen.Add('Versie van '+GlobalOpties.BBRenteDatabasenaam+' kan niet worden verhoogd.');
          melding('Versie van '+GlobalOpties.BBRenteDatabasenaam+' kan niet worden verhoogd.', false);
        end;
        result := false;
        inc(_Warnings);
        inc(TotaalWarnings);
      end;
    except
      Melding('Webservice van Euroface is onbereikbaar.'#13 +
              'Dit is mogelijk een tijdelijk of eenmalig probleem.'#13 +
              'Probeer het, na opnieuw opstarten van Rentix, nogmaals.');
      Errors := errors +1;
      result := false;
      exit;
    end;
  finally
    if result then begin
      if aantal =0 then begin
        _Meldingen.Add('Er zijn geen nieuwe/gewijzigde rentetarieven.');
        melding('Er zijn geen nieuwe/gewijzigde rentetarieven (patches).', false);
        result := true;
      end else begin
        if aantalTonen>0 then begin
          _Meldingen.Add(inttostr(aantalTonen) + ' nieuwe/gewijzigde rentetarieven succesvol verwerkt.');
          if aantal > aantalTonen then begin
            _Meldingen.Add(inttostr(aantal - aantalTonen) + ' van de gevonden wijzigingen zijn niet bedoeld voor de ingeregelde maatschappijen.');
          end;
        end else begin
          _Meldingen.Add('Geen van de gevonden wijzigingen zijn bedoeld voor de ingeregelde maatschappijen.');
        end;
        result := true;
      end;
    end else begin
      if MeldingTonen then begin
        _Meldingen.Add('Fouten tijdens het up to date maken van nieuwe/gewijzigde rentetarieven.');
      end;
      result :=false;
    end;
  end;
end;

function TfrmMainformClient.UpdateDatabasePatches: boolean;
var
  OudeVersie, NieuweVersie : integer;
  inhoud, regel, fnm : string;
  db : TControllerDB;
  rs :TAdoRecordset;
  Fout : integer;
  doorgaan : boolean;
  p,p1 : integer;
  f:TextFile;
begin
  OudeVersie := 0;
  result :=false;
  db := nil;
  try
    if not GlobalOpties.DefaultDatapad then begin
      DB := TControllerDB.Create(GlobalOpties.BBRenteDatabasenaam,false);
    end else begin
      DB := TControllerDB.Create(DatabasePad + 'hypmaatschappijDB.mdb');
    end;
    
    db.CheckWritable(true);
    if assigned(db) then begin
      rs := db.OpenQuery('select * from patches');
      if assigned(rs) then begin
        OudeVersie := rs.Fields[0].Value;
        db.CloseQuery(rs);
      end;

      NieuweVersie := OudeVersie;
      Doorgaan := true;
      while Doorgaan do begin
        inhoud := RentixWeb.GetDatabasePatch(FinixID, NieuweVersie , fout );
        if (inhoud<>'') and (fout=0) then begin
          fnm := GlobalOpties.Temppad  + 'patch_' + inttostr(NieuweVersie) + '.ini';
          assignfile(f, fnm);
          try
            rewrite(f);
          except
            _Meldingen.Add('Tijdelijke file kon niet worden neergezet: ' + fnm +'. Het updaten van database patches is geannuleerd.');
            melding('Tijdelijke file kon niet worden neergezet: ' + fnm +'. Het updaten van database patches is geannuleerd.', false);

            inc(errors);
            exit;
          end;

          p1 :=1;
          p := posex(#10,inhoud, p1);
          while p>0 do begin
            regel := copy(inhoud, p1, p-p1);
            writeln(f, regel);
            p1 := p + 1;
            p := posex(#10,inhoud, p1);
          end;
          closefile(f);
          if ExecuteDatabasePatch(fnm, NieuweVersie) then begin
            Deletefile(fnm);
            inc(nieuweVersie);
          end else begin
            _Meldingen.Add('Database patchnummer ' + inttostr(NieuweVersie) +' kon niet worden uitgevoerd. Verdere uitvoering van het updaten van database patches is geannuleerd.');
            melding('Database patchnummer ' + inttostr(NieuweVersie) +' kon niet worden uitgevoerd. Verdere uitvoering van het updaten van database patches is geannuleerd.', false);
            inc(errors);
            exit;
          end;
        end else begin
          doorgaan := false;
          result :=true;
        end;
      end; //while doorgaan

      try
        if OudeVersie = NieuweVersie then begin
          _Meldingen.Add('Er zijn geen nieuwe database patches om te installeren.');
        end else begin
          //update patchnummer in de database, alleen als er fout is geweest.
          db.QueryExecute('update patches set [patchnummer]=' + inttostr(NieuweVersie));
        end;
      except
        //jammer dan
      end;

    end else begin
      _Meldingen.Add('HypmaatschappijDB kon niet worden gelezen. Database patches kunnen niet uitgevoerd worden.');
       melding('HypmaatschappijDB kon niet worden gelezen. Database patches kunnen niet uitgevoerd worden.', false);
      inc(errors);
      exit;
    end;
  finally
    if assigned(DB) then DB.Free;
  end;
end;

function TfrmMainformClient.ExecuteDatabasePatch(filenaam:string; patchnummer:integer): boolean;
var
  ini : TIniFile;
  inim : TSTringList;
  aantal : integer;
  databasenaam:string;
  i:integer;
  qry : widestring;
  tekst:string;
  db : TControllerDB;
  ignore : integer;

  idx:integer;
begin
  aantal := 0;
  result := True;

  inim := TSTringList.create;
  ini := TIniFile.Create(filenaam);
  try
    inim.LoadFromFile(filenaam);
    try
      databasenaam := ini.ReadString('info', 'DB', '');
      aantal := ini.ReadInteger('info', 'aantal', 0);
    except
      _Meldingen.Add('Database patch ' + filenaam + ' kan niet geopend of gelezen worden.');
      inc(errors);
    end;

    if Not GlobalOpties.DefaultDatapad then begin
      if uppercase(trim(databasenaam)) = 'RENTES.MDB' then databasenaam := GlobalOpties.BBRenteDatabasenaam;
      if uppercase(trim(databasenaam)) = 'RENTES' then databasenaam := GlobalOpties.BBRenteDatabasenaam;
    end else begin
      if uppercase(trim(databasenaam)) = 'RENTES.MDB' then databasenaam := DatabasePad + 'hypmaatschappijDB.mdb';
      if uppercase(trim(databasenaam)) = 'RENTES' then databasenaam := DatabasePad + 'hypmaatschappijDB';
    end;

    try
      db := TControllerDB.Create(databasenaam);
      db.CheckWritable(true);
      _Meldingen.Add('Uitvoeren database patch ' + inttostr(patchnummer));
      for i := 1 to aantal do begin
  //      qry := ini.ReadString('query' + inttostr(i), 'qry','');
        tekst := ini.ReadString('query' + inttostr(i), 'tekst','');
        ignore := ini.ReadInteger('query' + inttostr(i),'skiperror',1);

        idx := inim.IndexOf('[query' + inttostr(i) + ']');
        repeat
          idx := idx + 1;
          qry := inim.Strings[idx];
        until uppercase(copy(qry,1,4)) = 'QRY=';
        qry := copy(qry,5,length(qry));

        if qry<>'' then begin
          try
            //SQLserver wil een enkele quote als stringdelimiter
            qry := StringReplace(qry,'"',#39,[rfReplaceAll]);
            db.QueryExecute(qry);
            _Meldingen.Add ('> query ' + inttostr(i) + ' uitgevoerd. ' + tekst);
            Result := true;
          except
            if ignore<>0 then begin
              result :=false;
              inc(errors);
            end;
          end;
        end else begin
          _Meldingen.Add('Database patch niet correct. Query ' + inttostr(i) + ' bestaat niet.');
        end;
      end;
    except
      _Meldingen.Add('Database ' + DatabasePad + databasenaam + ' kan niet geopend worden.');
      inc(errors);
      result := false;
    end;
  finally
    try
      inim.free;
      ini.free;
    except
    end;
  end;
end;

function TfrmMainformClient.RenteWijzigingActueel(filenaam:string; var aDatum: Tdatetime): boolean;
var
  f:textfile;
  s:string;
  i:integer;
  gevonden : boolean;
  y,m,d:word;
begin
  try
    assignfile(f,filenaam);
    reset(f);
    gevonden := false;
    while (not eof(f)) and (not gevonden) do begin
      readln(f,s);
      i := pos('<' + PropDatum+ '>',s);
      if i>0 then begin
        delete(s,1,7);
        y := strtoint(copy(s,1,4));
        m := strtoint(copy(s,5,2));
        d := strtoint(copy(s,7,2));
        aDatum := EncodeDate(y,m,d);
        gevonden := true;
      end;
    end;
    Closefile(f);
    result := gevonden;
    if NOT nieuwerentesophalen then result := result and (aDatum <= (trunc(now)+0.999));
  except
    result := true;
  end;
end;

procedure TfrmMainformClient.CheckWriteRights;
var
  NoRight : boolean;
  f:textfile;
  soort : integer;
begin
  NoRight := False;
  soort := 0;

  if not DirectoryExists(GlobalOpties.Temppad) then begin
    if not ForceDirectories(GlobalOpties.Temppad) then begin
      NoRight := True;
      soort := 1;
    end else begin
      try
        AssignFile(f,IncludeTrailingPathDelimiter(GlobalOpties.Temppad) + 'text.txt');
        rewrite(f);
        writeln(f);
        flush(f);
        closefile(f);
        if not DeleteFile(IncludeTrailingPathDelimiter(GlobalOpties.Temppad) + 'text.txt') then begin
          NoRight := True;
          soort := 2;
        end;
      except
        NoRight := True;
        soort := 3;
      end;
    end;
  end;
  if NoRight then begin
    case soort of
      1: begin
          efsShowMessage('De directory "' + GlobalOpties.Temppad + '" bestaat niet.'#13'De standaard directory voor tijdelijke files wordt nu gebruikt ' + (GettempDir) + ').');
          GlobalOpties.Temppad := GettempDir;
          GlobalOpties.WriteToIni;
         end;
      2: efsShowMessage('Er zijn geen "delete"-rechten in de directory "' + GlobalOpties.Temppad + '".'#13'Dit kan een probleem zijn bij het uitvoeren van Rentix. Neem contact op met uw systeembeheerder.');
      3: begin
           efsShowMessage('Er zijn geen schrijf-rechten in de directory "' + GlobalOpties.Temppad + '".'#13'Neem contact op met uw systeembeheerder.'#13'De standaard directory voor tijdelijke files wordt nu gebruikt ' + (GettempDir) + ').');
           GlobalOpties.Temppad := GettempDir;
           GlobalOpties.WriteToIni;
         end;
    end;
  end;
end;


end.

unit FormCSVverwerking;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WizardForm, ComCtrls, StdCtrls, Buttons, ExtCtrls, CheckLst, RenteBasis,
  OleCtrls, SHDocVw;

type
  TfrmCSVverwerking = class(TFrmWizard)
    CheckListBox1: TCheckListBox;
    Panel2: TPanel;
    btnRefreshCSV: TButton;
    Memo1: TMemo;
    btnAlles: TButton;
    btnNiets: TButton;
    MemAanvul: TMemo;
    GroupBox1: TGroupBox;
    Panel3: TPanel;
    ProgressBar1: TProgressBar;
    MemXMLversturen: TMemo;
    Panel4: TPanel;
    btnStartUpload: TButton;
    BtnKillUpload: TButton;
    memAuto: TMemo;
    Panel5: TPanel;
    Panel6: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnRefreshCSVClick(Sender: TObject);
    procedure btnNietsClick(Sender: TObject);
    procedure btnAllesClick(Sender: TObject);
    procedure BtnKillUploadClick(Sender: TObject);
    procedure btnStartUploadClick(Sender: TObject);
    procedure btnFinishClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    TermSignal : Integer;
    LijstCSV : TStringList;
    FilesGelezen : boolean;
    RenteBasisTable:TRenteBasisLijst;
    XMLobjecten : TStringlist;
    Uploaded : Boolean;
    procedure LeesFilesIn;
    procedure PaginaInlezen;
    Function CSVInlezen : integer;
    Function RentesEnXMLAanmaken : integer;
    procedure XMLsFilesAanmaken;
    Procedure XMLsUploaden;
    procedure MemoAdd(mem:Tmemo; s:string);
    function MaakXMLfilenaam(aNaam:string): string;
  public
    { Public declarations }
    Procedure OnPageShow(NewTabSheet:TTabSheet); override;
    procedure RunAuto;

    constructor Create(aOwner:TComponent); override;
    Destructor Destroy; override;
  end;

var
  frmCSVverwerking: TfrmCSVverwerking;

implementation

uses
  Opties, CSV, RVP, RenteXMLmaak, InternetWrap, PlafondBasis,
  ServerVariabelen, StrUtils;

{$R *.dfm}

{ TfrmCSVverwerking }

procedure TfrmCSVverwerking.OnPageShow(NewTabSheet: TTabSheet);
begin
  inherited;
  panel1.Caption := '';
  case NewTabSheet.PageIndex of
    0 : PaginaInlezen;
    1 : CSVInlezen;
    2 : RentesEnXMLAanmaken;
    3 : XMLsUploaden;
  end;
end;

procedure TfrmCSVverwerking.PaginaInlezen;
begin
  Panel1.Caption := 'Lijst met CSV-bestanden in de directory: ' + GlobalOpties.CSVpad;
end;

procedure TfrmCSVverwerking.btnNietsClick(Sender: TObject);
var
  i:integer;
begin
  for i:= 0 to CheckListBox1.Items.Count -1 do CheckListBox1.Checked[i] := false;
end;

procedure TfrmCSVverwerking.btnRefreshCSVClick(Sender: TObject);
begin
  inherited;
  LeesFilesIn;
end;

procedure TfrmCSVverwerking.btnAllesClick(Sender: TObject);
var
  i:integer;
begin
  for i:= 0 to CheckListBox1.Items.Count -1 do CheckListBox1.Checked[i] := True;
end;

procedure TfrmCSVverwerking.FormCreate(Sender: TObject);
begin
  inherited;
  LeesFilesIn;
end;

procedure TfrmCSVverwerking.LeesFilesIn;
var
  s:TSearchRec;
  i:integer;
begin
  CheckListBox1.Clear;
  i:=0;
  if FindFirst( GlobalOpties.CSVpad + '*.csv', faAnyFile	- faSysFile -faVolumeID -faDirectory , s ) = 0 then begin
    repeat
      CheckListBox1.Items.Add(s.Name);
      CheckListBox1.Checked[i] := true;
      inc(i);
    until FindNext(s)>0;
  end;
  FilesGelezen := true;
end;

Function TfrmCSVverwerking.CSVInlezen : integer;
var
  i:integer;
  obj : TCSVobject;
  teller:integer;
begin
  Result := 0;
  Panel1.Caption := 'Inlezen van de geselecteerde CSV-bestanden...';
  //alleen opnieuw inlezen als 'volgende' is gedrukt
  if HuidigePagina < TabSheet2.PageIndex then begin
    Memo1.clear;
    LijstCSV.Clear;
    teller := 0;
    for i := 0 to CheckListBox1.Items.Count -1 do begin
      if CheckListBox1.Checked[i] then begin
        MemoAdd(memo1, CheckListBox1.Items[i] + ' inlezen...');
        Obj := TCSVobject.Create;
        try
          obj.LeesBestandIn(GlobalOpties.CSVpad + CheckListBox1.Items[i] );
          MemoAdd(memo1,'Ok');
          inc(teller);
        except
          on e:exception do begin
            MemoAdd(memo1,'FOUT ! ' + e.Message );
            Result := 1;
          end;
        end;
        LijstCSV.AddObject(CheckListBox1.Items[i], obj);
      end;
    end;
    MemoAdd(memo1,'');
    MemoAdd(memo1,'Aantal files ingelezen: ' + inttostr(teller));
  end;
  memo1.SelStart := 0;
  memo1.SelLength := 1;
end;


constructor TfrmCSVverwerking.Create(aOwner: TComponent);
begin
  inherited;
  Uploaded := false;
  FilesGelezen := false;
  LijstCSV := TStringList.create;
  RenteBasisTable := TRenteBasisLijst.Create ;
  try
    RenteBasisTable.ReadFromDatabase;
  except
    ShowMessage('Rentebasis gegevens konden niet worden gelezen.');
  end;
end;

destructor TfrmCSVverwerking.Destroy;
begin
  LijstCSV.Free;
  inherited;
end;

Function TfrmCSVverwerking.RentesEnXMLAanmaken : integer;
var
  i,j,k,l:integer;
  csvObject : TCSVobject;
  regel : TCSVregel;
  productGUID : string;
  LRB : TLeningRenteBasis;
  obj : TRenteBasis;
  NieuweRente : double;
  NieuwPlafond : double;
  XML : TRenteXMLmaak;
  melding : string;
begin
  Result := 0;
  panel1.Caption := 'Aanmaken van alle rentes per maatschappij';
  MemAanvul.Clear;

  XMLobjecten := TStringlist.Create;
  for i:= 0 to LijstCSV.Count -1 do begin
    csvObject := TCSVobject(lijstCSV.Objects[i]);

    XML := TRenteXMLmaak.Create;
    xml.AddStartMaatschappijID(csvObject.MaatschappijID);
    MemoAdd(MemAanvul, 'Aanvullen van de rentes voor maatschappijID ' + inttostr(csvObject.MaatschappijID));

    for j := 0 to csvObject.ProductLijst.Count-1 do begin

      productGUID := csvObject.ProductLijst.Strings[j];
      XML.AddStartProduct(productGUID );

      MemoAdd(MemAanvul,#9'producttype : ' + productGUID);
      MemoAdd(MemAanvul,#9#9'aantal RVP : ' + inttostr(TSTringList(csvobject.productlijst.objects[j]).count));
      for l := 0 to TSTringList(csvobject.productlijst.objects[j]).count-1 do begin

        regel := TCSVregel(TSTringList(csvobject.productlijst.objects[j]).objects[l]);
        if regel.IsOverbruggingRente then begin
          {$IFDEF VERSIE2}
          XML.AddStartRVP(regel.GetRVPcode, regel.GetLooptijd, regel.GetDatum);
          XML.AddStartRente(regel.GetRente, false , 0,0);
          XML.AddEndRente;
          XML.AddEndRVP;
          {$ENDIF}
        end else begin //if regel.IsOverbruggingRente then begin

          XML.AddStartRVP(regel.GetRVPcode, regel.GetLooptijd, regel.GetDatum);

          LRB := RenteBasisTable.GetLeningRentes(csvObject.MaatschappijID, productGUID);
          if assigned(LRB) then begin
            for k := 0 to LRB.RenteBasisLijst.Count -1 do begin
              obj := TRenteBasis(lrb.RenteBasisLijst.Objects[k]);
              if obj.NHG then begin
                nieuwerente := Lrb.BepaalRente(regel.GetRenteNHG , 0 , true);
                if regel.HeeftPlafondRente then begin
                  nieuwPlafond := NieuweRente + PlafondBasisLijst.GetPlafondFactor(csvObject.MaatschappijID, productGUID, regel.GetLooptijd , True);
                  XML.AddStartRente(nieuwerente, True, 0,0, NieuwPlafond );
                end else begin
                  NieuwPlafond :=0;
                  XML.AddStartRente(nieuwerente, True, 0,0 );
                end;
              end else begin
                nieuwerente := Lrb.BepaalRente(regel.GetRente, obj.MinToEW , false);
                if regel.HeeftPlafondRente then begin
                  nieuwPlafond := NieuweRente + PlafondBasisLijst.GetPlafondFactor(csvObject.MaatschappijID, productGUID, regel.GetLooptijd , False);
                  XML.AddStartRente(nieuwerente, False, obj.MinToEW , obj.MaxToEW, NieuwPlafond );
                end else begin
                  NieuwPlafond :=0;
                  XML.AddStartRente(nieuwerente, False, obj.MinToEW , obj.MaxToEW);
                end;
              end; //if NHG

              xml.AddEndRente;

            end; // for k (executiewaardes per RVP)
          end; // if LRB  (zijn er rentes?)

          xml.AddEndRVP;
        end; //  if else regel.IsOverbruggingRente then begin

      end; // for l  (rvp's per product

      XML.AddEndProduct;

    end; //for ProductLijst  (producten per maatschappij)

    XML.AddEndMaatschappijID;

    XMLobjecten.AddObject(csvObject.naam, XML);
  end; //for lijstCSV  (maatschappijen)
  MemAanvul.SelStart :=0;
  MemAanvul.SelLength :=1;

  try
    MemoAdd(MemAanvul,'');
    XMLsFilesAanmaken;
    MemoAdd(MemAanvul,'');
    MemoAdd(MemAanvul,'XML-bestanden correct weggeschreven naar directory: "' + GlobalOpties.XMLpad + '"' );
  except
    on e:exception do begin
      MemoAdd(MemAanvul,'Fout in wegschrijven van XML-bestanden.');
      MemoAdd(MemAanvul,e.Message);
      MemoAdd(MemAanvul,'');
      Result := 1;
    end;
  end;
end;

procedure TfrmCSVverwerking.XMLsFilesAanmaken;
var
  i,j:integer;
  filenaam : string;
  f:textfile;
  mID:string;

begin
  for i := 0 to XMLobjecten.Count - 1 do begin
    //naam van de XML- bestanden zijn 'ERW_<mID>.xml'
    //dus bv ERW_91.xml voor maatschappij 91
    //Naamgeving is belangrijk! niet zomaar veranderen dus.

    
    filenaam := MaakXMLfilenaam(XMLobjecten.Strings[i]);
    try
      assignfile(f, filenaam);
      filemode := fmOpenReadWrite;
      Rewrite(f);
      write(f, TRenteXMLmaak(XMLobjecten.Objects[i]).gettext);
      CloseFile(f);
      MemoAdd(MemAanvul, filenaam + ' succesvol weggeschreven.');
    except
      on e:exception do begin
        raise exception.Create('FOUT! Wegschrijven van "' + filenaam +'" mislukt. ' + e.Message);
      end;
    end;
  end;
end;

Procedure TfrmCSVverwerking.XMLsUploaden;
begin
  Uploaded := False;
  MemXMLversturen.clear;
  MemoAdd(MemXMLversturen ,'Druk "Start upload" om te uploaden.');
  BtnKillUpload.Enabled := false;
end;

procedure TfrmCSVverwerking.BtnKillUploadClick(Sender: TObject);
begin
  if MessageDlg('Wilt u de upload echt stoppen?', mtConfirmation, mbYesNoCancel,0 ) = mrYes then begin
    TermSignal := 1;
  end;
end;

procedure TfrmCSVverwerking.btnStartUploadClick(Sender: TObject);
var
  i:integer;
  web:TNetWrap;
  TermSig:Pinteger;
  kortnaam, filenaam : string;
  ok:boolean;
  tijd : TDateTime;
begin
  MemXMLversturen.clear;
  MemoAdd(MemXMLversturen ,'Connectie maken met internet');
  tijd := now();
  web := TNetWrap.Create;
  MemoAdd(MemXMLversturen ,'Internetconnectie gelegd. (' + trim(format('%8.2f',[ (now() - tijd)*24*3600]) + ' sec)')  );
  MemoAdd(MemXMLversturen ,'Inloggen op FTP-server....');
  tijd := now();
  web.SetFTPinfo(GlobalOpties.FTPhost, GlobalOpties.FTPaccount, GlobalOpties.FTPpassword ,GlobalOpties.FTPport);
  web.LogOnFTPsite;
  MemoAdd(MemXMLversturen ,'Connected to FTP-server. (' + trim(format('%8.2f',[ (now() - tijd)*24*3600]) + ' sec)')  );

  //Verander ftp directory indien nodig
  if GlobalOpties.FTPdir >'' then begin
    MemXMLversturen.lines.add('Veranderen van directory op FTP-server naar "' + GlobalOpties.FTPdir +  '"');
    tijd := now();
    ok := web.FTPChangeCurrentDirectory(GlobalOpties.FTPdir);
    if not ok then begin
      MemoAdd(MemXMLversturen ,'Fout bij changedir');
      exit;
    end;
    MemoAdd(MemXMLversturen ,'FTP-server directory veranderd. (' + trim(format('%8.2f',[ (now() - tijd)*24*3600]) + ' sec)')  );
  end;

  TermSignal :=0;
  Termsig := @TermSignal;
  BtnKillUpload.Enabled := true;
  
  for i := 0 to XMLobjecten.Count -1 do begin
    Filenaam := MaakXMLfilenaam(XMLobjecten.Strings[i]);
    kortnaam := ExtractFileName(filenaam);
    if FileExists(filenaam) then begin
      GroupBox1.Caption := 'Uploaden ' + kortnaam;
      Filenaam := GlobalOpties.XMLpad + kortnaam;
      MemoAdd(MemXMLversturen ,'Bezig met uploaden "'+ kortnaam +'"');
      tijd := now();
      web.FTPuploadFile(filenaam, GlobalOpties.FTPdir, ExtractFileName(filenaam), TermSig, ProgressBar1);
      MemoAdd(MemXMLversturen ,kortnaam + ' succesvol geupload. (' + trim(format('%8.2f',[ (now() - tijd)*24*3600]) + ' sec)')  );
    end;
    if (TermSignal=1) then break;
  end;
  MemoAdd(MemXMLversturen ,'Uitloggen FTP-server');
  tijd := now();
  web.LogOffFTPsite;
  BtnKillUpload.Enabled := false;
  MemoAdd(MemXMLversturen ,'Disconnected. (' + trim(format('%8.2f',[ (now() - tijd)*24*3600]) + ' sec)')  );
  if TermSignal =0 then begin
    MemoAdd(MemXMLversturen ,'KLAAR !');
    Uploaded := true;
  end;
  web.Free;
end;

procedure TfrmCSVverwerking.btnFinishClick(Sender: TObject);
begin
  if not Uploaded then begin
    ShowMessage('Voltooien kan alleen als de totale upload gelukt is.');
  end else begin
    Close;
  end;
end;

procedure TfrmCSVverwerking.RunAuto;
var
  i:integer;
begin
  try
    Show;
    PageControl1.Enabled := false;
    PageControl1.Visible := false;
    panel1.Visible := false;
    pnlButtons.Visible := false;

    for i:= 0 to PageControl1.PageCount -1 do begin
      PageControl1.Pages[i].Visible := false;
    end;
    memAuto.Visible := true;
    memAuto.Clear;
    Application.ProcessMessages;
    if CSVInlezen <> 0 then exit;
    if RentesEnXMLAanmaken <> 0 then exit;
    XMLsUploaden;
    btnStartUpload.Click;
  finally
    if Uploaded then begin
      ShowMessage('Klaar');
    end else begin
      ShowMessage('Niet succesvol.');
    end;
    Panel5.Visible := true;
  end;
end;

procedure TfrmCSVverwerking.Button1Click(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmCSVverwerking.MemoAdd(mem: Tmemo; s: string);
begin
  mem.Lines.add(s);
  memAuto.Lines.add(s);
end;

function TfrmCSVverwerking.MaakXMLfilenaam(aNaam:string): string;
var
  j:integer;
  Mid : string;
begin
  result := aNaam;
  j := pos('_',result ) + 1;
  mID := copy(result , j , posex('_', result, j)-j);
  result := GlobalOpties.XMLpad + 'ERW_' + mID + '.xml';
end;

end.

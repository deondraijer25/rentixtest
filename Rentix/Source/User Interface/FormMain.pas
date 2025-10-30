unit FormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, jpeg, SOAPHTTPClient, InvokeRegistry, Rio;

type
  TFrmMain = class(TForm)
    MainMenu1: TMainMenu;
    Bestand1: TMenuItem;
    Opties1: TMenuItem;
    Open1: TMenuItem;
    CSVFormaat1: TMenuItem;
    XMLformaat1: TMenuItem;
    N1: TMenuItem;
    Sluiten1: TMenuItem;
    Rapporten1: TMenuItem;
    Rentepermaatschappij1: TMenuItem;
    Communicatie1: TMenuItem;
    Upload1: TMenuItem;
    Downloadlog1: TMenuItem;
    N2: TMenuItem;
    Uploadnieuwelicentie1: TMenuItem;
    Verwerken1: TMenuItem;
    gevondenCSV1: TMenuItem;
    Automatischverwerken1: TMenuItem;
    menu999: TMenuItem;
    HTTPRIO1: THTTPRIO;
    procedure Opties1Click(Sender: TObject);
    procedure Downloadlog1Click(Sender: TObject);
    procedure Upload1Click(Sender: TObject);
    procedure CSVFormaat1Click(Sender: TObject);
    procedure gevondenCSV1Click(Sender: TObject);
    procedure Sluiten1Click(Sender: TObject);
    procedure XMLformaat1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Automatischverwerken1Click(Sender: TObject);
    procedure Uploadnieuwelicentie1Click(Sender: TObject);
    procedure Rentepermaatschappij1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure menu999Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var                      
  FrmMain: TFrmMain;

implementation

uses FormOpties, InternetWrap, Opties, FormFileUpload, FormCSVverwerking,
  formShowCSV, formShowXML, DatabaseConnectie,
  FormRapportRentePerMaatschappij, ServerVariabelen, FormLicentieMaken,
  FormLogBekijken, WebserviceInterface;

{$R *.dfm}

procedure TFrmMain.Opties1Click(Sender: TObject);
begin
  FrmOpties := TFrmOpties.create(Self);
  FrmOpties.Hide;
  FrmOpties.ShowModal;
end;                

procedure TFrmMain.Downloadlog1Click(Sender: TObject);
begin
  frmLogBekijken := TfrmLogBekijken.Create(self);
  frmLogBekijken.Show;
end;

procedure TFrmMain.Upload1Click(Sender: TObject);
var
  frm:TfrmDialogVoortgang;
begin
  frm := TfrmDialogVoortgang.Create(self);
  frm.show;
end;

procedure TFrmMain.CSVFormaat1Click(Sender: TObject);
begin
  frmShowCSV := TfrmShowCSV.Create(self);
  frmShowCSV.Show;
end;

procedure TFrmMain.gevondenCSV1Click(Sender: TObject);
begin
  frmCSVverwerking := TfrmCSVverwerking.Create(self);
  frmCSVverwerking.Hide;
  frmCSVverwerking.ShowModal;
end;

procedure TFrmMain.Sluiten1Click(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.XMLformaat1Click(Sender: TObject);
begin
  frmShowXML := TfrmShowXML.Create(self);
  frmShowXML.show;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  GlobalDbase := TControllerDB.Create(GlobalOpties.Databasenaam) ;
end;

procedure TFrmMain.Automatischverwerken1Click(Sender: TObject);
begin
  frmCSVverwerking := TfrmCSVverwerking.Create(self);
  frmCSVverwerking.RunAuto;
end;

procedure TFrmMain.Uploadnieuwelicentie1Click(Sender: TObject);
begin
  frmLicentieMaken := TfrmLicentieMaken.create(self);
  frmLicentieMaken.Show;
end;

procedure TFrmMain.Rentepermaatschappij1Click(Sender: TObject);
begin
  frmRapportRentePerMaatschappij := tfrmRapportRentePerMaatschappij.create(self);
  frmRapportRentePerMaatschappij.Show;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if assigned(GlobalDbase) then begin
    GlobalDbase.free;
  end;
end;

procedure TFrmMain.menu999Click(Sender: TObject);
var
  lic : string;
begin
  lic := InputBox('Reset Rentix Licentie','geef licentie:' , '' );
  if lic<>'' then begin
    HTTPRIO1.URL := 'http://' + GlobalOpties.EurofaceServer + '/scripts/RentixService.exe/soap/IRentix';
    if (HTTPRIO1 as Irentix).ResetLicentie(Lic, '23$zxW8#') then begin
      ShowMessage('Oke');
    end else begin
      ShowMessage('Niet oke');
    end;
  end;
end;

end.

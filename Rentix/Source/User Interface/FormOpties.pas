unit FormOpties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, cxGroupBox, cxButtons,
  cxTextEdit, dxSkinsCore, dxSkinMoneyTwins, dxSkinscxPCPainter, cxLabel, cxPC,
  cxPCdxBarPopupMenu;

type
  TFrmOpties = class(TForm)
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    OpenDialog3: TOpenDialog;
    Panel1: TcxGroupBox;
    btnSave: TcxButton;
    btnAnnuleren: TcxButton;
    cxGroupBox1: TcxGroupBox;
    PageControl1: TcxPageControl;
    tsLocaties: TcxTabSheet;
    GroupBox1: TcxGroupBox;
    edtDatabase: TcxTextEdit;
    btnBrowseDatabase: TcxButton;
    GroupBox2: TcxGroupBox;
    edtCSVbestanden: TcxTextEdit;
    edtXMLbestanden: TcxTextEdit;
    btnBrowseXML: TcxButton;
    btnBrowseCSV: TcxButton;
    Label1: TcxLabel;
    Label2: TcxLabel;
    tsWebserver: TcxTabSheet;
    edtFTPhost: TcxTextEdit;
    edtFTPAccountnaam: TcxTextEdit;
    edtFTPpassword: TcxTextEdit;
    edtFTPdirectory: TcxTextEdit;
    edtFTPport: TcxTextEdit;
    btnFTPtest: TcxButton;
    btnDefault: TcxButton;
    Label3: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    Label8: TcxLabel;
    tsClient: TcxTabSheet;
    GroupBox4: TcxGroupBox;
    btnBrowseTemppad: TcxButton;
    btnTemppadDefault: TcxButton;
    edtTemppad: TcxTextEdit;
    TabSheet1: TcxTabSheet;
    GroupBox7: TcxGroupBox;
    edtEurofaceServer: TcxTextEdit;
    Label9: TcxLabel;
    GroupBox5: TcxGroupBox;
    edtClientDatabase: TcxTextEdit;
    btnBrowseClientdatabase: TcxButton;
    GroupBox3: TcxGroupBox;
    edtRenteDB: TcxTextEdit;
    btnBrowseRenteDB: TcxButton;
    Label10: TcxLabel;
    Label11: TcxLabel;
    procedure btnBrowseCSVClick(Sender: TObject);
    procedure btnBrowseXMLClick(Sender: TObject);
    procedure edtXMLbestandenExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnFTPtestClick(Sender: TObject);
    procedure btnSluitenClick(Sender: TObject);
    procedure btnBrowseDatabaseClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure btnBrowseRenteDBClick(Sender: TObject);
    procedure btnBrowseTemppadClick(Sender: TObject);
    procedure btnTemppadDefaultClick(Sender: TObject);
    procedure btnBrowseClientdatabaseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmOpties: TFrmOpties;

implementation

{$R *.dfm}
uses
  {$ifdef IS_RENTIXClient}ClientVariabelen, {$endif}
  {$ifdef IS_RENTIXSERVER}ServerVariabelen, {$endif}
  filectrl, Opties, InternetWrap, RentixTools, EfsDialogs;

procedure TFrmOpties.btnBrowseCSVClick(Sender: TObject);
var
  dir : string;
begin
  dir := edtCSVbestanden.text;
  SelectDirectory('Selecteer een directory', '', Dir);
  if dir>'' then begin
    edtCSVbestanden.text := dir;
  end;
end;

procedure TFrmOpties.btnBrowseXMLClick(Sender: TObject);
var
  dir : string;
begin
  dir := edtXMLbestanden.text;
  SelectDirectory('Selecteer een directory', '', Dir);
  if dir>'' then begin
    edtXMLbestanden.text := dir;
  end;
end;

procedure TFrmOpties.edtXMLbestandenExit(Sender: TObject);
begin
  if not DirectoryExists(edtXMLbestanden.text) then begin
    efsShowMessage('Dit is geen geldige directory.');
    edtXMLbestanden.SetFocus;
  end;
end;

procedure TFrmOpties.FormCreate(Sender: TObject);
begin
  {$IFDEF IS_RENTIXCLIENT}
  tsLocaties.PageIndex := 2;
  tsLocaties.TabVisible := False;
  tsClient.Visible := true;
  tsClient.TabVisible := true;
  tsClient.PageIndex := 0;
  tsWebserver.TabVisible := false;
  {$ELSE}
  tsClient.Visible := false;
  tsClient.TabVisible := False;
  tsClient.PageIndex := 2;
  tsLocaties.Visible := true;
  tsLocaties.PageIndex := 0;
  tslocaties.TabVisible := true;
  tsWebserver.TabVisible := true;
  {$ENDIF}

  PageControl1.ActivePageIndex :=0;
  edtCSVbestanden.Text := GlobalOpties.CSVpad;
  edtXMLbestanden.Text := GlobalOpties.XMLpad;
  edtDatabase.Text := GlobalOpties.Databasenaam;
  edtEurofaceServer.Text := GlobalOpties.EurofaceServer; 
  
  edtFTPhost.text := GlobalOpties.FTPhost;
  edtFTPdirectory.text := GlobalOpties.FTPdir;
  edtFTPAccountnaam.text := GlobalOpties.FTPaccount;
  edtFTPpassword.text := GlobalOpties.FTPpassword;

  edtRenteDB.Text := GlobalOpties.BBRenteDatabasenaam;
  edtTemppad.Text := GlobalOpties.Temppad;
  edtClientDatabase.text := GlobalOpties.ClientDatabasenaam;
end;

procedure TFrmOpties.btnSaveClick(Sender: TObject);
begin
  if tsClient.Visible then
    if not DirectoryExists(edtTemppad.Text) then
    begin
      PageControl1.ActivePage := tsClient;
      edtTemppad.SelectAll;
      edtTemppad.SetFocus;

      efsShowMessage('Dit is geen geldige directory.');
      Abort;
    end;

  GlobalOpties.CSVpad := edtCSVbestanden.text;
  GlobalOpties.XMLpad := edtXMLbestanden.text;
  GlobalOpties.Databasenaam := edtDatabase.text;
  GlobalOpties.EurofaceServer := edtEurofaceServer.Text;

  GlobalOpties.FTPhost := edtFTPhost.text;
  GlobalOpties.FTPdir := edtFTPdirectory.text;
  GlobalOpties.FTPaccount := edtFTPAccountnaam.text;
  GlobalOpties.FTPpassword := edtFTPpassword .text;
  GlobalOpties.FTPport := StrToIntDef(edtFTPport.text, 21);

  GlobalOpties.BBRenteDatabasenaam := edtRenteDB.text;
  GlobalOpties.Temppad := edtTemppad.Text;
  GlobalOpties.ClientDatabasenaam := edtClientDatabase.Text;
  GlobalOpties.InternetMode := imContinue;
  if GlobalOpties.InternetMode = imGeen then begin
    efsShowMessage('Zonder toegang op internet is Rentix volledig onbruikbaar.');
  end;

  GlobalOpties.WriteToIni;

  ModalResult := mrOk;
end;

procedure TFrmOpties.btnFTPtestClick(Sender: TObject);
var
  www : TNetWrap;
  ok:boolean;
begin
  www := TNetWrap.Create;
  www.SetFTPinfo(edtFTPhost.text, edtFTPAccountnaam.text, edtFTPpassword.text, strToIntdef(edtFTPport.text, 21) );
  if www.LogOnFTPsite(true) then begin
    ok := false;
    if GlobalOpties.FTPdir >'' then begin
      ok := www.FTPChangeCurrentDirectory(GlobalOpties.FTPdir);
    end;    
    if ok then begin
      efsShowMessage('Connectie is gelukt.');
    end else begin
      efsShowMessage('Connectie is gelukt maar de opgegeven directory "' + GlobalOpties.FTPdir + '" is fout.');
    end;
  end else begin
    efsShowMessage('Connectie mislukt.'#13#10+ www.LastResult);
  end;
  www.LogOffFTPsite;

  FreeAndNil(www);
end;

procedure TFrmOpties.btnSluitenClick(Sender: TObject);
begin
  btnSaveClick(sender);
end;

procedure TFrmOpties.btnBrowseDatabaseClick(Sender: TObject);
var
  dir : string;
begin
  dir := ExtractFilePath(edtDatabase.Text);
  OpenDialog1.InitialDir := dir;
  if OpenDialog1.Execute then begin
    edtDatabase.Text := OpenDialog1.FileName;
  end;
end;

procedure TFrmOpties.btnDefaultClick(Sender: TObject);
begin
  edtFTPport.Text := '21';
end;

procedure TFrmOpties.btnBrowseRenteDBClick(Sender: TObject);
var
  dir : string;
begin
  dir := ExtractFilePath(edtRenteDB.Text);
  OpenDialog2.InitialDir := dir;
  if OpenDialog2.Execute then begin
    edtRenteDB.Text := OpenDialog2.FileName;
  end;
end;

procedure TFrmOpties.btnBrowseTemppadClick(Sender: TObject);
var
  dir : string;
begin
  dir := edtTemppad.text;
  SelectDirectory('Selecteer een directory', '', Dir);
  if dir>'' then begin
    edtTemppad.text := dir;
  end;

end;

procedure TFrmOpties.btnTemppadDefaultClick(Sender: TObject);
begin
  edtTemppad.Text := GetTempDir;
end;

procedure TFrmOpties.btnBrowseClientdatabaseClick(Sender: TObject);
var
  dir:string;
begin
  dir := ExtractFilePath(edtClientDatabase.Text);
  OpenDialog3.InitialDir := dir;
  if OpenDialog3.Execute then begin
    edtClientDatabase.text := OpenDialog3.FileName;
  end;
end;

end.

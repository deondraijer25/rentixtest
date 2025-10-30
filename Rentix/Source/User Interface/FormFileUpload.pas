unit FormFileUpload;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, InvokeRegistry, Rio,
  SOAPHTTPClient;

type
  TfrmDialogVoortgang = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Button1: TButton;
    Panel4: TPanel;
    Panel5: TPanel;
    Label2: TLabel;
    edtUploadBestand: TEdit;
    btnBrowse: TButton;
    OpenDialog1: TOpenDialog;
    btnStart: TButton;
    Label3: TLabel;
    HTTPRIO1: THTTPRIO;
    procedure Button1Click(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Terminated : integer;
    UploadGestart:Boolean;

    constructor Create(aOwner:TComponent); override;
  end;

implementation

uses Opties, InternetWrap, ServerVariabelen, WebserviceInterface;

{$R *.dfm}

procedure TfrmDialogVoortgang.Button1Click(Sender: TObject);
begin
  if UploadGestart then begin
    if MessageDlg('Wilt u het uploaden echt stoppen?', mtConfirmation, [mbYes,mbNo],0 ) = mrYes then begin
      Terminated := 1;
      UploadGestart := false;
    end;
  end else begin
    Close;
  end;
end;

constructor TfrmDialogVoortgang.Create(aOwner: TComponent);
begin
  inherited;
  HTTPRIO1.URL := 'http://' + GlobalOpties.EurofaceServer + '/scripts/RentixService.exe/soap/IRentix';  
  Caption := 'Uploaden van willekeurige (XML-) bestanden naar de FTP-server.';
  Button1.Caption := '&Sluiten';
  Terminated := 0;
  UploadGestart := false;
  Label3.Caption := 'Uploaddirectory : ' + GlobalOpties.EurofaceServer + '/scripts/rentes_update'; 
end;

procedure TfrmDialogVoortgang.btnBrowseClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := GlobalOpties.XMLpad;
  if OpenDialog1.Execute then begin
    edtUploadBestand.Text := OpenDialog1.FileName;
  end;
end;

procedure TfrmDialogVoortgang.btnStartClick(Sender: TObject);
var
  bestand : TSOAPAttachment;
  fout : integer;
  filenaam : string;
  mid:integer;
begin
  btnStart.Enabled := false;
  btnBrowse.Enabled := false;
  filenaam := edtUploadBestand.Text;
  if FileExists(filenaam ) then begin
    try
      mid := strtoint(copy(extractfilename(filenaam),5,2));
    except
      ShowMessage('MaatschappijID onbekend');
      exit;
    end;    
    
    bestand := TSOAPAttachment.Create;
    bestand.SetSourceFile(filenaam);
    fout := (HTTPRIO1 as Irentix).PutRenteUpdateBestand(mid, bestand, now+1, '23$zxW8#','Euroface', true );
    case fout of
      0 : ShowMessage('Upload succesvol.');
      -1: ShowMessage('Er is al een update bestand aanwezig van deze maatschappij');
      -2 : ShowMessage('Password verkeerd');
      -3 : ShowMessage('Bestand kon niet worden gesaved op de site.');
    end;
  end;
  Button1.Caption := '&Sluiten';
  btnBrowse.Enabled := True;
  btnStart.Enabled := true;
end;

end.

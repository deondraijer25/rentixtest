unit FormLicentieMaken;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, InvokeRegistry, SOAPHTTPClient, StdCtrls, Rio;

type
  TfrmLicentieMaken = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    edtnaam: TEdit;
    label4: TLabel;
    edtLicentie: TEdit;
    btnCancel: TButton;
    Label2: TLabel;
    Label3: TLabel;
    HTTPRIO1: THTTPRIO;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLicentieMaken: TfrmLicentieMaken;

implementation

uses WebserviceInterface, Opties, ServerVariabelen, RentixLicentieConst;

{$R *.dfm}

procedure TfrmLicentieMaken.Button1Click(Sender: TObject);
var
  fout:integer;
begin
  try
    if (HTTPRIO1 as Irentix).AddLicentie(edtnaam.Text , edtLicentie.text, RentixPassword,fout) then begin
      ShowMessage('De licentie is geplaatst en klaar om te worden geactiveerd door de klant.');
    end else begin
      case fout of
        -1:ShowMessage('Deze licentie bestaat al!.');
        -2:ShowMessage('Iets ging mis...');
      end;
    end;
  except
    on e:Exception do begin
      Beep;
      ShowMessage('FOUT! Er is iets erg misgegaan. Probeer opnieuw.'#13+ e.message);
    end;
  end;
end;

procedure TfrmLicentieMaken.FormCreate(Sender: TObject);
begin
  HTTPRIO1.URL := 'http://' + GlobalOpties.EurofaceServer + '/scripts/RentixService.exe/soap/IRentix';
end;

procedure TfrmLicentieMaken.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TfrmLicentieMaken.btnCancelClick(Sender: TObject);
begin
  Close;
end;

end.

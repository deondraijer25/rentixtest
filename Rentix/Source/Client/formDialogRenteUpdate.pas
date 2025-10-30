unit formDialogRenteUpdate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Menus, cxButtons, cxControls, cxContainer, cxEdit,
  cxGroupBox, dxSkinsCore, dxSkinDarkRoom, cxLabel;

type
  TfrmDialogRenteUpdate = class(TForm)
    Timer1: TTimer;
    cxGroupBox1: TcxGroupBox;
    Label1: TcxLabel;
    Label2: TcxLabel;
    lblAutoContinue: TcxLabel;
    Panel1: TcxGroupBox;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    wait : integer;
  public
    { Public declarations }
  end;

var
  frmDialogRenteUpdate: TfrmDialogRenteUpdate;

implementation

{$R *.dfm}

procedure TfrmDialogRenteUpdate.FormCreate(Sender: TObject);
begin
  wait := -1;
  Timer1Timer(nil);
end;

procedure TfrmDialogRenteUpdate.Timer1Timer(Sender: TObject);
const
  maxtijd=5;
begin
  Timer1.Enabled := false;
  inc(Wait);
  lblAutoContinue.Caption := format('Indien update onwenselijk, druk Annuleer binnen %d seconden.', [maxtijd-wait]);
  if wait = maxtijd then begin
    btnOk.Click;
  end else begin
    Timer1.Enabled := true;
  end;  
end;

procedure TfrmDialogRenteUpdate.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Timer1.Enabled := false;
end;

end.

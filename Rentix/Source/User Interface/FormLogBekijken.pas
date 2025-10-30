unit FormLogBekijken;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, InternetWrap, ComCtrls;

type
  TfrmLogBekijken = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Panel2: TPanel;
    Panel3: TPanel;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    naam : string;
    www : TNetwrap;
    Terminated : integer;
    DownloadGestart:boolean;
    procedure ReadLog;
  end;

const
  LogNaam = 'RentixLog.txt';   //Case sensative!

var
  frmLogBekijken: TfrmLogBekijken;

implementation

uses Opties, ServerVariabelen;


{$R *.dfm}

const
  rentixLogDir = '/scripts/licentie';

procedure TfrmLogBekijken.FormCreate(Sender: TObject);
begin
  naam := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + lognaam;
  Readlog;
  www := TNetWrap.Create;
  Label1.Caption := 'De log,' + lognaam + ', wordt gedownload van ' + rentixLogDir + 
                    #13'en gesaved als "' +naam+'"';
end;


procedure TfrmLogBekijken.ReadLog;
var
  f:textfile;
  s:string;
begin
  memo1.Clear;
  assignfile(f, naam);
  try
    reset(f);
    memo1.Visible := false;
    while not eof(f) do begin
      readln(f,s);
      Memo1.Lines.add(s);
    end;
    Closefile(f);
    memo1.Visible := true;
  except
    memo1.Lines.Add(naam + ' bestaat niet of is onleesbaar');
  end;
  memo1.SelStart := 0;
  Memo1.SelLength :=0;  
end;

procedure TfrmLogBekijken.Button1Click(Sender: TObject);
var
  Termsig : Pinteger;
  s:string;
begin
  if DownloadGestart then begin
    Terminated := 1;
  end else begin
    DownloadGestart := true;
    Terminated :=0;
    Termsig := @Terminated;
    s := Button1.Caption;
    Button1.Caption := 'Cancel';

    Memo1.Lines.Add('working');
    Application.ProcessMessages;
    www.SetFTPinfo(GlobalOpties.FTPhost, GlobalOpties.FTPaccount, GlobalOpties.FTPpassword);
    if www.LogOnFTPsite then begin
      if www.FTPdownloadFile(rentixLogDir, lognaam, naam, termsig, ProgressBar1) then begin
        ReadLog;
      end else begin
        Memo1.Lines.Add('Downloaden mislukt.');
      end;
    end else begin
      Memo1.Lines.Add('Inloggen mislukt.');
    end;

    Button1.Caption := s;
    DownloadGestart := false;
  end;
end;

procedure TfrmLogBekijken.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TfrmLogBekijken.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  action:= cafree;
end;

procedure TfrmLogBekijken.Button3Click(Sender: TObject);
begin
  ReadLog;
end;

end.

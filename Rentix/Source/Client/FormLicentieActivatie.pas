unit FormLicentieActivatie;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, InternetWrap, RentixIntf,
  InvokeRegistry, Rio, SOAPHTTPClient, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinDarkRoom,
  cxTextEdit, cxLabel, cxGroupBox, Vcl.Menus, cxButtons;

type
  TfrmLicentieActivering = class(TForm)
    HTTPRIO1: THTTPRIO;
    Panel1: TcxGroupBox;
    Panel3: TcxGroupBox;
    Label3: TcxLabel;
    Panel4: TcxGroupBox;
    Label2: TcxLabel;
    Label1: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    edtLicentie: TcxTextEdit;
    btnRegistreer: TcxButton;
    btnAnnuleer: TcxButton;
    procedure btnRegistreerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    newRentixID:string;
  end;

implementation

uses RentixTools, ClientVariabelen, Opties, ProxySupport, u_Utility;

{$R *.dfm}


procedure TfrmLicentieActivering.btnRegistreerClick(Sender: TObject);
var
  id:string;
  fout:boolean;
  www : TNetWrap;
  stop, wwwOke:boolean;
  sc : Tcursor;
begin
  ModalResult := mrNone;
  sc := Screen.Cursor;
  Screen.Cursor := crHourGlass; 
  try
    if GlobalOpties.InternetMode = imGeen then begin
      exit;
    end;
    www := TNetWrap.Create;
    if GlobalOpties.InternetMode = imInbel then begin
      if not www.InternetIsActive then begin
        if MessageDlg('Er zal nu contact worden gelegd met internet. Doorgaan?', mtConfirmation, [mbYes,mbNo],0 ) = mrNo then begin
          exit;
        end;
      end;
    end;
    wwwOke:=false;
    stop := false;
    while (not wwwOke) and (not stop) do begin
      wwwOke := True;
      if not wwwOke then begin
        If MessageDlg(
          'Er kon geen contact worden gemaakt met internet.'#13 +
          'Waarschijnlijk is er geen internetverbinding beschikbaar.'#13 +
          'Om dit te controleren, kun u naar uw favoriete site surfen met uw internetbrowser (bv InternetExplorer), '#13 +
          'Als dit gelukt is, probeert u dan opnieuw.'#13#13+
          'Nu opnieuw proberen ?', mtInformation, [mbYes, mbNo], 0)= mrNo
        then begin
          wwwOke := false;
          stop := true;
        end;
      end else begin
        wwwOke := true;
        stop := true;
      end;  
    end;

    if wwwOke then begin
      fout := false;
      try
        ID:= GetWindowsID;
        if ID='' then begin
          ID := 'Foutje in de bepaling'; //zomaar een id
        end;
        ID := (HTTPRIO1 as IRentix).GetRentixID(edtLicentie.text, ID);
        if ID='' then begin
          fout := true;
        end else begin
          newRentixID := ID;
          ShowMessage('Licentie geactiveerd.'#13#13'Bedankt dat u gekozen heeft voor de software van Euroface!');
          ModalResult := mrOK;
        end;
      except
        fout := true;
      end;
      If fout then begin
        Beep;
        ShowMessage('De activatie is mislukt.'#13#13'De meest waarschijnlijke oorzaken:'#13#10 +
        '* Uw internet connectie is niet actief'#13#10 +
        '    - controleer uw internetconnectie door bijvoorbeeld naar een website te surfen.'#13#13 +
        '* De ingegeven licentiecode klopt niet'#13#10 +
        '    - controleer de ingetoetste licentiecode met de code die aan u verstrekt is.'#13#10 +
        '      De licentiecode is niet hoofdlettergevoelig.'#13#13 +
        '* Het gegeven licentienummer is al eens geactiveerd.'#13#10 +
        '    - Neem contact op met Euroface voor meer informatie.');
      end;
    end else begin
      ShowMessage('Zonder internet kan de activering niet plaatsvinden.');
    end;
  finally
    Screen.Cursor := sc;
  end;
  
end;

procedure TfrmLicentieActivering.FormCreate(Sender: TObject);
var
  s:string;
  f : textfile;
begin
  HTTPRIO1.URL := 'http://' + GlobalOpties.EurofaceServer + '/scripts/Rentixservice.exe/soap/IRentix';
  StelProxyIn(HTTPRIO1);
  
  s := IncludeTrailingPathDelimiter(TUtility.AppRoot) + 'AddonInfo.txt';
  if FileExists(s) then begin
    assignfile(f, s);
    reset(f);
    readln(f,s);
    closefile(f);
    Label5.Caption  := s;
  end;  
end;

end.

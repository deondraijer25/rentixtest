unit WizardForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls;

var
  GlobalBackColor : integer = clBtnFace;

type
  TFrmWizard = class(TForm)
    pnlButtons: TPanel;
    btnNext: TBitBtn;
    btnPrev: TBitBtn;
    btnCancel: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnFinish: TBitBtn;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
  private
    { Private declarations }
    iHuidigePagina:integer;
    CurrentTabSheet:TTabSheet;
    ThePageControl : TPageControl;

    AantalPaginas:integer;
    Procedure ShowNextPage;
    Procedure ShowPrevPage;
    procedure setHuidigePagina(const Value: integer);
  public
    { Public declarations }
    PagesVisible:array of boolean;
    Cancelled:Boolean;
    ValidateOnEnter : boolean;
    Procedure OnPageShow(NewTabSheet:TTabSheet); Virtual;
    function CanChangePage( TheTabSheet:TTabSheet):boolean ; virtual;
    property HuidigePagina:integer read iHuidigePagina write setHuidigePagina;
    procedure ShowPage(Page:integer);
  end;


implementation

{$R *.dfm}

procedure TFrmWizard.FormCreate(Sender: TObject);
var
  i:integer;
  j:integer;
begin
  Cancelled := false;
  AantalPaginas := 0;
  CurrentTabSheet := TabSheet1;
  For i:=0 to ControlCount-1 do begin
    if Controls[i] is TPageControl then begin
      ThePageControl := TPageControl(controls[i]);
      AantalPaginas := ThePageControl.PageCount;
      setLength(PagesVisible,AantalPaginas);
      for j := 0 to ThePageControl.PageCount-1 do begin
        //Zet de parent van de tabsheets naar het form ipv het pagecontrol.
        ThePageControl.Pages[j].Parent := self;
        //en maak alle tabsheets invisible
        ThePageControl.Pages[j].Visible := false;
        PagesVisible[j] := ThePageControl.Pages[j].TabVisible;
      end;
      break;
    end;
  end;
  Color := GlobalBackColor;
  ThePageControl.Visible := false;
  TabSheet1.Visible := true;
  ValidateOnEnter := false;
  HuidigePagina:=0;
  ValidateOnEnter := true;
  OnPageShow(TabSheet1);
end;


procedure TFrmWizard.btnCancelClick(Sender: TObject);
begin
  Cancelled := True;
  Close;
end;

procedure TFrmWizard.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i:integer;
begin

  if canclose then begin
    //Zet de parent van de tabsheets weer terug naar het PageControl anders crashed het programma.
    For i:=0 to ThePageControl.PageCount-1 do begin
      ThePageControl.Pages[i].Parent :=ThePageControl;
    end;
  end;
end;

procedure TFrmWizard.btnPrevClick(Sender: TObject);
begin
  ShowPrevPage;
end;

procedure TFrmWizard.ShowNextPage;
begin
  HuidigePagina := HuidigePagina +1;
end;

procedure TFrmWizard.ShowPrevPage;
begin
  HuidigePagina := HuidigePagina -1;
end;

procedure TFrmWizard.ShowPage(Page: integer);
var
  i:integer;
  CurPageIndex:integer;
  gevonden:boolean;
  NewTabSheet:TTabSheet;
begin
  //Deze moet wordt aangeroepen VOORDAT huidigePagina veranderd is.
  //Page is de pagina die zichtbaar moet gaan worden.
  //HuidgePagina is de pagina die op dit moment zichtbaar is.
  For i:=0 to ControlCount-1 do begin
    if Controls[i] is TTabSheet then begin
      if TTabsheet(Controls[i]).Visible then begin
        CurrentTabSheet := TTabsheet(Controls[i]);
        break;
      end;
    end;
  end;
  CurrentTabSheet.Visible := false;
  CurPageIndex := CurrentTabSheet.PageIndex;

  NewTabSheet := nil;

  gevonden:=false;
  i:=0;
  while (not gevonden) and (i<controlcount) and (i>=0) do begin
    if Controls[i] is TTabSheet then begin
      if TTabsheet(Controls[i]).PageIndex = Page then begin
        if PagesVisible[Page] then begin
          Gevonden:=true;
          NewTabSheet := TTabsheet(Controls[i]);
        end else begin
          i:=0;
          if Page< CurPageIndex then begin
            Page:= page -1;
            //we gaan naar een previous pagina
          end else begin
            //we gaan naar een next pagina
            Page:= page +1;
          end;
        end;
      end;
    end;
    i:=i+1;
  end;

  if Assigned(NewTabSheet) then begin
    CurrentTabSheet := NewTabSheet;
  end;

  btnNext.Enabled := true;
  btnFinish.Enabled := false;
  btnPrev.Enabled := true;
  if CurrentTabSheet.PageIndex = AantalPaginas-1 then begin
    btnFinish.Enabled := true;
    btnNext.Enabled := false;
  end;
  if CurrentTabSheet.PageIndex = 0 then begin
    btnprev.Enabled := false;
  end;

  CurrentTabSheet.Visible := true;
end;

procedure TFrmWizard.setHuidigePagina(const Value: integer);
begin
  if ValidateOnEnter and CanChangePage(CurrentTabSheet) then begin
    ShowPage(Value);
    OnPageShow(CurrentTabSheet);
    iHuidigePagina := CurrentTabSheet.PageIndex;
  end;
end;

procedure TFrmWizard.btnNextClick(Sender: TObject);
begin
  ShowNextPage;
end;

procedure TFrmWizard.OnPageShow(NewTabSheet:TTabSheet);
begin
  //doe iets
end;

function TFrmWizard.CanChangePage(TheTabSheet: TTabSheet): boolean;
begin
  Result :=true;
end;

end.

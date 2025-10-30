unit FormRapportRentePerMaatschappij;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls;

type
  TfrmRapportRentePerMaatschappij = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Panel2: TPanel;
    Panel3: TPanel;
    Button1: TButton;
    Panel4: TPanel;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRapportRentePerMaatschappij: TfrmRapportRentePerMaatschappij;

implementation

uses Opties, StrUtils, RVP, XMLimport, BlackBoxEnums, ServerVariabelen;

{$R *.dfm}

type
  TStringObject = Class
    tekst : string;
    Constructor Create(s:string);
  end;

constructor TStringObject.Create(s: string);
begin
  Tekst := s;
end;

procedure TfrmRapportRentePerMaatschappij.FormCreate(Sender: TObject);
var
  s:TSearchRec;
  id:string;
  i:integer;
begin
  if FindFirst(GlobalOpties.XMLpad + '*.xml', $20, s) = 0 then begin
    repeat
      i := pos('_',s.Name ) + 1;
      id := copy(s.Name , i , posex('.', s.name, i)-i);
      ComboBox1.Items.AddObject(ID, TStringObject.Create(GlobalOpties.XMLpad + s.name));
    until FindNext(s)<>0;
  end;
end;

procedure TfrmRapportRentePerMaatschappij.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfrmRapportRentePerMaatschappij.ComboBox1Change(Sender: TObject);
var
  filenaam : string;
  Obj : TXMLimport;
  rvplijst : TList;
  rvpobj:TRVP;
  RenteObj:TRente;
  teller, i,j,k:integer;
  prod : String;
begin
  if ComboBox1.ItemIndex >-1 then begin
    for i:= 0 to StringGrid1.RowCount -1 do
      for j:= 0 to StringGrid1.ColCount -1 do StringGrid1.Cells[j,i] := '';

    Filenaam := TStringObject(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).tekst;
    Obj := TXMLimport.Create;
    teller := 1;
    if obj.ImportFile(filenaam, strtoint(ComboBox1.Text)) then begin
      StringGrid1.Cells[0,0] := 'Product';
      StringGrid1.Cells[1,0] := 'RVPcode';
      StringGrid1.Cells[2,0] := 'looptijd';
      StringGrid1.Cells[3,0] := 'Rente';
      StringGrid1.Cells[4,0] := 'MinEW';
      StringGrid1.Cells[5,0] := 'MaxEW';
      StringGrid1.Cells[6,0] := 'NHG';
      StringGrid1.Cells[7,0] := 'Plafond';
      for i:= 0 to obj.Leningen.Count -1 do begin
        prod := obj.Leningen.Strings[i];
        rvplijst :=TList(obj.Leningen.Objects[i]);
        for j := 0 to rvplijst.Count -1 do begin
          rvpobj := TRVP(rvplijst.Items[j]);
          for K := 0 to rvpobj.Rentelijst.count-1 do begin
            RenteObj := Trente(rvpobj.Rentelijst.Items [K]);
            StringGrid1.Cells [0,teller] := Prod;
            StringGrid1.Cells [1,teller] := rvpobj.Code;
            StringGrid1.Cells [2,teller] := inttostr(rvpobj.Looptijd);
            StringGrid1.Cells [3,teller] := FloatToStr(RenteObj.Rente);
            if RenteObj.NHG then begin
              StringGrid1.Cells [6,teller] := 'Ja';
            end else begin
              StringGrid1.Cells [4,teller] := FloatToStr(RenteObj.MinEW );
              StringGrid1.Cells [5,teller] := FloatToStr(RenteObj.MaxEW );
            end;
            if rvpobj.Rentevorm = rvpsPlafond then begin
              StringGrid1.Cells [7,teller] := FloatToStr(RenteObj.Plafond );
            end;

            inc(teller);
            If teller> StringGrid1.RowCount then StringGrid1.RowCount := StringGrid1.RowCount +20;
          end; //k
        end; //j
      end; //i
    end else begin
      ShowMessage(obj.LastResult);
    end;
  end;
end;

{ TStringObject }


procedure TfrmRapportRentePerMaatschappij.Button1Click(Sender: TObject);
begin
  Close;
end;

end.

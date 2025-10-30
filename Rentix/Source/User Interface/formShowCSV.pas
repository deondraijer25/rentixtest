unit formShowCSV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls, ExtCtrls, StdCtrls, ImgList, CSV;

type
  TfrmShowCSV = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Panel3: TPanel;
    StringGrid1: TStringGrid;
    Panel4: TPanel;
    Label1: TLabel;
    edtDir: TEdit;
    btnBrowseDir: TButton;
    Panel5: TPanel;
    ListView1: TListView;
    ImageList: TImageList;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseDirClick(Sender: TObject);
    procedure edtDirExit(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure VulTree;
  public
    CSV : Tcsvobject ;
    { Public declarations }
  end;

var
  frmShowCSV: TfrmShowCSV;

implementation

uses Opties, filectrl, ServerVariabelen;

{$R *.dfm}

procedure TfrmShowCSV.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmShowCSV.FormCreate(Sender: TObject);
begin
  edtDir.Text := GlobalOpties.CSVpad;
  VulTree;
end;

procedure TfrmShowCSV.btnBrowseDirClick(Sender: TObject);
var
  dir:string;
begin
  dir := edtDir.text;
  SelectDirectory('Selecteer een directory', '', Dir);
  if dir > '' then begin
    edtdir.text := dir;
    Vultree;
  end;
end;

procedure TfrmShowCSV.VulTree;
var
  s:TSearchRec;
  node : TListItem;
begin
  ListView1.Clear;
  if FindFirst(edtDir.Text + '\*.csv', faAnyFile	- faSysFile -faVolumeID -faDirectory , s ) =0 then begin
    Listview1.AddItem(s.Name, nil);

    while FindNext(s) = 0 do begin
      Listview1.AddItem(s.Name, nil);
    end;
  end;

end;

procedure TfrmShowCSV.edtDirExit(Sender: TObject);
begin
  VulTree;
end;

procedure TfrmShowCSV.ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
var
  i,j:integer;
begin
  if change = ctState then begin
    CSV := TCSVobject.Create;
    CSV.LeesBestandIn(IncludeTrailingBackslash (edtDir.Text) + Item.Caption);
    StringGrid1.ColCount := csv.AantalKolommen+1;
    StringGrid1.RowCount := csv.Lijnen.Count;
    panel5.Caption := ' MaatschappijID = ' +inttostr(csv.MaatschappijID);

    for j:= 0 to StringGrid1.RowCount-1  do begin
      StringGrid1.Cells[0,j] := inttostr(j+1);
      for i:= 1 to csv.AantalKolommen do begin
        StringGrid1.Cells[i,j] := csv.GetKolom(csv.Lijnen[j],i);
      end;
    end;
  end;
end;

procedure TfrmShowCSV.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

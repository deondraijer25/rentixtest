unit formShowXML;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ImgList, OleCtrls, SHDocVw;

type
  TfrmShowXML = class(TForm)
    Panel2: TPanel;
    ListView1: TListView;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    Panel4: TPanel;
    edtDir: TEdit;
    btnBrowseDir: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    memText: TMemo;
    ImageList: TImageList;
    WebBrowser1: TWebBrowser;
    procedure Button1Click(Sender: TObject);
    procedure btnBrowseDirClick(Sender: TObject);
    procedure edtDirExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    closed : boolean;
  public
    { Public declarations }
    procedure VulTree;
  end;

var
  frmShowXML: TfrmShowXML;

implementation

{$R *.dfm}

uses
  FileCtrl, Opties, ServerVariabelen;

procedure TfrmShowXML.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmShowXML.btnBrowseDirClick(Sender: TObject);
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

procedure TfrmShowXML.VulTree;
var
  s:TSearchRec;
  node : TListItem;
begin
  ListView1.Clear;
  if FindFirst(edtDir.Text + '\*.xml', faAnyFile	- faSysFile -faVolumeID -faDirectory , s ) =0 then begin
    Listview1.AddItem(s.Name, nil);

    while FindNext(s) = 0 do begin
      Listview1.AddItem(s.Name, nil);
    end;
  end;
end;

procedure TfrmShowXML.edtDirExit(Sender: TObject);
begin
  VulTree;
end;

procedure TfrmShowXML.FormCreate(Sender: TObject);
begin
  edtDir.Text := GlobalOpties.xmlpad;
  VulTree;
  closed := false;
end;

procedure TfrmShowXML.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  s,r : string;
  f : textfile;
  naam:string;
  i:integer;
begin
  if Change = ctState then begin
    memText.Clear;
    naam := IncludeTrailingBackslash (edtDir.Text) + Item.Caption;
    if FileExists(naam) then begin
      try
        assignfile(f, naam);
        FileMode := fmOpenRead ;
        reset(f);
        while not eof(f) do begin
          readln(f,s);
          memText.Lines.add(s);
        end;
        closefile(f);
        memText.SelStart := 1;
        memtext.SelLength := 1;
      except
        on e:exception do begin
          memText.clear;
          memtext.lines.add('File kon niet worden ingelezen.');
          memtext.lines.add(e.Message);
        end;
      end;
      try
        if not closed then begin
          WebBrowser1.Navigate(naam);
        end;
      except
       end;
    end;
  end;
end;

procedure TfrmShowXML.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmShowXML.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  closed :=true;
end;

end.

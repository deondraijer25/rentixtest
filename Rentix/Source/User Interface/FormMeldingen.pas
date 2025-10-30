unit FormMeldingen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Menus, cxButtons, cxTextEdit,
  cxMemo, dxSkinsCore, dxSkinDarkRoom, cxGroupBox;

type
  TfrmMeldingen = class(TForm)
    Memo1: TcxMemo;
    Panel1: TcxGroupBox;
    Button1: TcxButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMeldingen: TfrmMeldingen;

implementation

{$R *.dfm}

end.

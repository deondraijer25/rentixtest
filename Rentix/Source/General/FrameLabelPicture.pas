unit FrameLabelPicture;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  ExtCtrls, StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinMoneyTwins,
  cxLabel, cxGroupBox, dxGDIPlusClasses;


type
  TFrame1 = class(TFrame)
    cxGroupBox1: TcxGroupBox;
    Label1: TcxLabel;
    Image5: TImage;
    Image4: TImage;
    Image3: TImage;
    Image1: TImage;
    Image2: TImage;
  private
    { Private declarations }
    _Status : Integer;
    procedure SetStatus(const Value: integer);
    procedure SetText(const Value: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published    
    property Status : integer read _Status write SetStatus;
    property Text : string write SetText;
  end;

implementation

{$R *.dfm}

{ TFrame1 }

constructor TFrame1.Create(AOwner: TComponent);
begin
  inherited;
  Status := 0;
end;

procedure TFrame1.SetStatus(const Value: integer);
begin
  image1.Visible := (Value = 1);    // groene vink
  image2.Visible := (Value = -1);   // rode x
  image3.Visible := (Value = 0);    //leeg
  image4.Visible := (Value = 2);    //bliksem
  image5.Visible := (Value = 3);    //sirene
  Refresh; 
end;

procedure TFrame1.SetText(const Value: string);
begin
  Label1.Caption := Value;
end;

end.

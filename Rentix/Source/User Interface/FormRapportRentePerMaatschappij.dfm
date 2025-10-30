object frmRapportRentePerMaatschappij: TfrmRapportRentePerMaatschappij
  Left = 390
  Top = 339
  Width = 774
  Height = 415
  Caption = 'Rentes per maatschappij'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poMainFormCenter
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 766
    Height = 77
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 20
      Top = 28
      Width = 88
      Height = 13
      Caption = 'Kies maatschappij:'
    end
    object ComboBox1: TComboBox
      Left = 124
      Top = 24
      Width = 213
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboBox1Change
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 340
    Width = 766
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Panel3: TPanel
      Left = 668
      Top = 1
      Width = 97
      Height = 39
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = '&Sluiten'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 77
    Width = 766
    Height = 263
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object StringGrid1: TStringGrid
      Left = 0
      Top = 0
      Width = 766
      Height = 263
      Align = alClient
      ColCount = 8
      DefaultRowHeight = 18
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 0
    end
  end
end

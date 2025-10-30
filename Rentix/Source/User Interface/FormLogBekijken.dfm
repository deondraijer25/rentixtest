object frmLogBekijken: TfrmLogBekijken
  Left = 377
  Top = 150
  Width = 870
  Height = 640
  Caption = 'Bekijken Webservice log'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 862
    Height = 37
    Align = alTop
    BorderWidth = 3
    TabOrder = 0
    object Label1: TLabel
      Left = 4
      Top = 4
      Width = 854
      Height = 29
      Align = alClient
      Caption = 'Label1'
      WordWrap = True
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 37
    Width = 862
    Height = 528
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 0
    Top = 565
    Width = 862
    Height = 41
    Align = alBottom
    TabOrder = 2
    object Panel3: TPanel
      Left = 764
      Top = 1
      Width = 97
      Height = 39
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button2: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Sluiten'
        TabOrder = 0
        OnClick = Button2Click
      end
    end
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Downloaden'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 96
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Refresh'
      TabOrder = 2
      OnClick = Button3Click
    end
    object ProgressBar1: TProgressBar
      Left = 208
      Top = 12
      Width = 245
      Height = 17
      TabOrder = 3
    end
  end
end

object frmMeldingen: TfrmMeldingen
  Left = 255
  Top = 148
  Caption = 'Meldingen'
  ClientHeight = 602
  ClientWidth = 854
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TcxMemo
    Left = 0
    Top = 0
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ParentFont = False
    Properties.ReadOnly = True
    Properties.ScrollBars = ssVertical
    Style.BorderStyle = ebsNone
    Style.Edges = []
    TabOrder = 0
    Height = 567
    Width = 854
  end
  object Panel1: TcxGroupBox
    Left = 0
    Top = 567
    Align = alBottom
    UseDockManager = True
    PanelStyle.Active = True
    ParentColor = False
    Style.Color = clBtnFace
    TabOrder = 1
    DesignSize = (
      854
      35)
    Height = 35
    Width = 854
    object Button1: TcxButton
      Left = 776
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Sluiten'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
  end
end

object FrmWizard: TFrmWizard
  Left = 365
  Top = 116
  BorderStyle = bsDialog
  Caption = 'FrmWizard'
  ClientHeight = 430
  ClientWidth = 603
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object pnlButtons: TPanel
    Left = 0
    Top = 393
    Width = 603
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      603
      37)
    object btnNext: TBitBtn
      Left = 434
      Top = 0
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Volgende'
      Default = True
      TabOrder = 0
      OnClick = btnNextClick
    end
    object btnPrev: TBitBtn
      Left = 354
      Top = 0
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Vorige'
      Enabled = False
      TabOrder = 1
      OnClick = btnPrevClick
    end
    object btnCancel: TBitBtn
      Left = 274
      Top = 0
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Annuleren'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object btnFinish: TBitBtn
      Left = 514
      Top = 0
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Voltooien'
      Default = True
      Enabled = False
      TabOrder = 3
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 29
    Width = 603
    Height = 364
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
    end
    object TabSheet3: TTabSheet
      Caption = 'TabSheet3'
      ImageIndex = 2
    end
    object TabSheet4: TTabSheet
      Caption = 'TabSheet4'
      ImageIndex = 3
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 603
    Height = 29
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 2
  end
end

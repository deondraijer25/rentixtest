object frmDialogRenteUpdate: TfrmDialogRenteUpdate
  Left = 373
  Top = 426
  BorderStyle = bsDialog
  Caption = 'Uitvoeren rente update'
  ClientHeight = 169
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 0
    Align = alClient
    PanelStyle.Active = True
    PanelStyle.BorderWidth = 1
    Style.BorderStyle = ebsNone
    Style.Edges = []
    TabOrder = 1
    Height = 128
    Width = 400
    object Label1: TcxLabel
      AlignWithMargins = True
      Left = 4
      Top = 30
      Margins.Top = 12
      Margins.Bottom = 0
      Align = alClient
      AutoSize = False
      Caption = 
        'Rentix zal nu via internet zoeken of er nieuwe rentes opgehaald ' +
        'moeten worden, even geduld a.u.b.'
      Properties.WordWrap = True
      Transparent = True
      Height = 77
      Width = 392
    end
    object Label2: TcxLabel
      Left = 1
      Top = 1
      Margins.Bottom = 0
      Align = alTop
      AutoSize = False
      Caption = 'RENTIX'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = 15
      Style.Font.Name = 'Tahoma'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 17
      Width = 398
      AnchorX = 200
    end
    object lblAutoContinue: TcxLabel
      AlignWithMargins = True
      Left = 4
      Top = 110
      Margins.Bottom = 0
      Align = alBottom
      Caption = 'Annuleer indien wenselijk in %d seconden.'
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Transparent = True
      AnchorX = 200
    end
  end
  object Panel1: TcxGroupBox
    Left = 0
    Top = 128
    Align = alBottom
    UseDockManager = True
    PanelStyle.Active = True
    ParentColor = False
    Style.BorderStyle = ebsNone
    Style.Color = clBtnFace
    Style.Edges = [bTop]
    TabOrder = 0
    Height = 41
    Width = 400
    object btnOk: TcxButton
      Left = 121
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TcxButton
      Left = 204
      Top = 9
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Annuleer'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 356
    Top = 142
  end
end

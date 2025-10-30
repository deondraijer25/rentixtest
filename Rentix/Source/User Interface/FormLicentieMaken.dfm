object frmLicentieMaken: TfrmLicentieMaken
  Left = 453
  Top = 139
  Width = 506
  Height = 197
  Caption = 'Toevoegen Licentie op webservice'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefaultPosOnly
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 48
    Width = 37
    Height = 13
    Caption = 'Naam : '
  end
  object label4: TLabel
    Left = 32
    Top = 76
    Width = 70
    Height = 13
    Caption = 'Licentiecode : '
  end
  object Label2: TLabel
    Left = 4
    Top = 4
    Width = 453
    Height = 16
    Caption = 'Geef de naam en licentiecode die op internet gezet moet worden. '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 300
    Top = 24
    Width = 159
    Height = 13
    Caption = '(Beide zijn hoofdletter ongevoelig)'
  end
  object Button1: TButton
    Left = 108
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Verzenden'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
  object edtnaam: TEdit
    Left = 108
    Top = 44
    Width = 301
    Height = 21
    TabOrder = 0
  end
  object edtLicentie: TEdit
    Left = 108
    Top = 72
    Width = 301
    Height = 21
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 336
    Top = 112
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Annuleren'
    ModalResult = 2
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object HTTPRIO1: THTTPRIO
    HTTPWebNode.Agent = 'Borland SOAP 1.2'
    HTTPWebNode.UseUTF8InHeader = False
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 228
    Top = 120
  end
end

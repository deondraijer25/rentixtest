object frmLicentieActivering: TfrmLicentieActivering
  Left = 275
  Top = 283
  BorderStyle = bsDialog
  Caption = 'Activeren RENTIX licentie'
  ClientHeight = 212
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TcxGroupBox
    Left = 0
    Top = 181
    Align = alBottom
    UseDockManager = True
    PanelStyle.Active = True
    ParentColor = False
    Style.BorderStyle = ebsNone
    Style.Color = clBtnFace
    TabOrder = 1
    DesignSize = (
      433
      31)
    Height = 31
    Width = 433
    object btnRegistreer: TcxButton
      Left = 270
      Top = 3
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Registreer'
      Default = True
      TabOrder = 0
      OnClick = btnRegistreerClick
    end
    object btnAnnuleer: TcxButton
      Left = 354
      Top = 3
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Annuleer'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Panel3: TcxGroupBox
    Left = 0
    Top = 107
    Align = alClient
    UseDockManager = True
    PanelStyle.Active = True
    ParentColor = False
    Style.BorderStyle = ebsNone
    Style.Color = clBtnFace
    TabOrder = 0
    Height = 74
    Width = 433
    object Label3: TcxLabel
      Left = 19
      Top = 19
      Margins.Bottom = 0
      Caption = 'Geef uw licentiecode: '
      Transparent = True
    end
    object edtLicentie: TcxTextEdit
      Left = 135
      Top = 16
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -15
      Style.Font.Name = 'MS Sans Serif'
      Style.Font.Style = [fsBold]
      Style.IsFontAssigned = True
      TabOrder = 0
      TextHint = 'XXX - YYYYYYYYY - Z'
      Width = 279
    end
  end
  object Panel4: TcxGroupBox
    Left = 0
    Top = 0
    Align = alTop
    UseDockManager = True
    PanelStyle.Active = True
    ParentColor = False
    Style.BorderStyle = ebsNone
    Style.Color = clBtnFace
    TabOrder = 2
    Height = 107
    Width = 433
    object Label2: TcxLabel
      Left = 2
      Top = 19
      Margins.Bottom = 0
      Align = alTop
      Caption = 
        'Hiervoor is dus een internetconnectie nodig. Deze zal, indien no' +
        'dig, worden opgebouwd.'
      Transparent = True
    end
    object Label1: TcxLabel
      Left = 2
      Top = 36
      Margins.Bottom = 0
      Align = alTop
      Caption = 
        'Voor het gebruik van Rentix moeten de licentie geactiveerd worde' +
        'n via internet.'
      Transparent = True
    end
    object Label4: TcxLabel
      Left = 2
      Top = 2
      Margins.Bottom = 0
      Align = alTop
      Caption = 
        'Er zijn geen geactiveerde licentie gegevens gevonden voor het ge' +
        'bruik van Rentix.'
      ParentFont = False
      Transparent = True
    end
    object Label5: TcxLabel
      Left = 2
      Top = 53
      Margins.Bottom = 0
      Align = alClient
      AutoSize = False
      Caption = 
        'Elke licentiecode kan maar eenmaal gebruikt worden. Wilt u Renti' +
        'x op meer computers laten draaien, neem dan contact op met Eurof' +
        'ace, tel: 079-3460080 of kijk op onze website http://www.eurofac' +
        'e.nl'
      Properties.WordWrap = True
      Transparent = True
      Height = 52
      Width = 429
    end
  end
  object HTTPRIO1: THTTPRIO
    WSDLLocation = 'http://62.234.62.116/scripts/RentixWebservice.dll/wsdl/IRentix'
    Service = 'IRentixservice'
    Port = 'IRentixPort'
    HTTPWebNode.Agent = 'Borland SOAP 1.2'
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    HTTPWebNode.WebNodeOptions = []
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 484
    Top = 111
  end
end

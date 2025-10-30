object frmDialogVoortgang: TfrmDialogVoortgang
  Left = 496
  Top = 306
  BorderStyle = bsDialog
  ClientHeight = 97
  ClientWidth = 619
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 56
    Width = 619
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Panel3: TPanel
      Left = 437
      Top = 0
      Width = 182
      Height = 41
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 96
        Top = 8
        Width = 75
        Height = 25
        Caption = '&Annuleer'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 619
    Height = 56
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Panel5: TPanel
      Left = 0
      Top = 0
      Width = 619
      Height = 81
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label2: TLabel
        Left = 20
        Top = 34
        Width = 104
        Height = 13
        Caption = 'Te uploaden bestand '
      end
      object Label3: TLabel
        Left = 22
        Top = 0
        Width = 50
        Height = 19
        Caption = 'Server'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object edtUploadBestand: TEdit
        Left = 132
        Top = 30
        Width = 365
        Height = 21
        TabOrder = 0
      end
      object btnBrowse: TButton
        Left = 496
        Top = 30
        Width = 25
        Height = 21
        Caption = '...'
        TabOrder = 1
        OnClick = btnBrowseClick
      end
      object btnStart: TButton
        Left = 533
        Top = 28
        Width = 75
        Height = 25
        Caption = '&Start'
        TabOrder = 2
        OnClick = btnStartClick
      end
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.xml'
    Filter = 'Rente-bestanden (*.xml)|ERW_*.xml|Alle bestanden (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Selecteer een bestand om te uploaden.'
    Left = 570
    Top = 4
  end
  object HTTPRIO1: THTTPRIO
    HTTPWebNode.Agent = 'Borland SOAP 1.2'
    HTTPWebNode.UseUTF8InHeader = False
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 562
    Top = 60
  end
end

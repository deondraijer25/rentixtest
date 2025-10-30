object FrmMain: TFrmMain
  Left = 237
  Top = 340
  Width = 853
  Height = 586
  Caption = 'Rentix - Server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 164
    Top = 188
    object Bestand1: TMenuItem
      Caption = '&Bestand'
      object Open1: TMenuItem
        Caption = '&Open'
        object CSVFormaat1: TMenuItem
          Caption = 'CSV-Formaat'
          OnClick = CSVFormaat1Click
        end
        object XMLformaat1: TMenuItem
          Caption = 'XML-formaat'
          OnClick = XMLformaat1Click
        end
      end
      object Opties1: TMenuItem
        Caption = '&Opties'
        OnClick = Opties1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Sluiten1: TMenuItem
        Caption = '&Sluiten'
        OnClick = Sluiten1Click
      end
    end
    object Verwerken1: TMenuItem
      Caption = '&CSV-bestanden'
      object gevondenCSV1: TMenuItem
        Caption = 'Handmatig verwerken'
        OnClick = gevondenCSV1Click
      end
      object Automatischverwerken1: TMenuItem
        Caption = 'Automatisch verwerken'
        OnClick = Automatischverwerken1Click
      end
    end
    object Rapporten1: TMenuItem
      Caption = '&Rapporten'
      object Rentepermaatschappij1: TMenuItem
        Caption = 'Rente per maatschappij'
        OnClick = Rentepermaatschappij1Click
      end
    end
    object Communicatie1: TMenuItem
      Caption = '&Utilities'
      object Upload1: TMenuItem
        Caption = '&Upload XML'
        OnClick = Upload1Click
      end
      object Uploadnieuwelicentie1: TMenuItem
        Caption = '&Upload nieuwe licentie'
        OnClick = Uploadnieuwelicentie1Click
      end
      object menu999: TMenuItem
        Caption = 'Reset Rentix Licentie'
        OnClick = menu999Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Downloadlog1: TMenuItem
        Caption = '&Download log'
        OnClick = Downloadlog1Click
      end
    end
  end
  object HTTPRIO1: THTTPRIO
    HTTPWebNode.Agent = 'Borland SOAP 1.2'
    HTTPWebNode.UseUTF8InHeader = False
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 302
    Top = 100
  end
end

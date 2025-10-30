object FrmOpties: TFrmOpties
  Left = 1760
  Top = 392
  BorderStyle = bsDialog
  Caption = 'Rentix - Opties'
  ClientHeight = 362
  ClientWidth = 467
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TcxGroupBox
    Left = 0
    Top = 324
    Align = alBottom
    UseDockManager = True
    PanelStyle.Active = True
    ParentBackground = False
    ParentColor = False
    Style.BorderStyle = ebsNone
    Style.Color = clBtnFace
    Style.Edges = []
    TabOrder = 0
    DesignSize = (
      467
      38)
    Height = 38
    Width = 467
    object btnSave: TcxButton
      Left = 308
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Save'
      Default = True
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnAnnuleren: TcxButton
      Left = 389
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Annuleren'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object cxGroupBox1: TcxGroupBox
    Left = 0
    Top = 0
    Align = alClient
    PanelStyle.Active = True
    Style.BorderStyle = ebsNone
    TabOrder = 1
    Height = 324
    Width = 467
    object PageControl1: TcxPageControl
      Left = 2
      Top = 2
      Width = 463
      Height = 320
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = tsLocaties
      ClientRectBottom = 318
      ClientRectLeft = 2
      ClientRectRight = 461
      ClientRectTop = 25
      object tsLocaties: TcxTabSheet
        Caption = 'Locaties'
        object GroupBox1: TcxGroupBox
          Left = 8
          Top = 8
          Caption = ' Database '
          TabOrder = 0
          Height = 61
          Width = 441
          object edtDatabase: TcxTextEdit
            Left = 16
            Top = 24
            TabOrder = 0
            Width = 385
          end
          object btnBrowseDatabase: TcxButton
            Left = 400
            Top = 24
            Width = 25
            Height = 21
            Caption = '...'
            TabOrder = 1
            OnClick = btnBrowseDatabaseClick
          end
        end
        object GroupBox2: TcxGroupBox
          Left = 8
          Top = 84
          Caption = 'Directories'
          TabOrder = 1
          Height = 109
          Width = 441
          object edtCSVbestanden: TcxTextEdit
            Left = 112
            Top = 28
            TabOrder = 0
            Width = 289
          end
          object edtXMLbestanden: TcxTextEdit
            Left = 112
            Top = 64
            TabOrder = 1
            OnExit = edtXMLbestandenExit
            Width = 289
          end
          object btnBrowseXML: TcxButton
            Left = 400
            Top = 64
            Width = 25
            Height = 21
            Caption = '...'
            TabOrder = 2
            OnClick = btnBrowseXMLClick
          end
          object btnBrowseCSV: TcxButton
            Left = 400
            Top = 28
            Width = 25
            Height = 21
            Caption = '...'
            TabOrder = 3
            OnClick = btnBrowseCSVClick
          end
          object Label1: TcxLabel
            Left = 16
            Top = 32
            Margins.Bottom = 0
            Caption = 'CSV-bestanden '
            Transparent = True
          end
          object Label2: TcxLabel
            Left = 16
            Top = 64
            Margins.Bottom = 0
            Caption = 'XML-bestanden'
            Transparent = True
          end
        end
      end
      object tsWebserver: TcxTabSheet
        Caption = 'Internet Connectie'
        ImageIndex = 1
        object edtFTPhost: TcxTextEdit
          Left = 112
          Top = 16
          TabOrder = 0
          Width = 281
        end
        object edtFTPAccountnaam: TcxTextEdit
          Left = 112
          Top = 80
          TabOrder = 2
          Width = 145
        end
        object edtFTPpassword: TcxTextEdit
          Left = 112
          Top = 112
          TabOrder = 3
          Width = 145
        end
        object edtFTPdirectory: TcxTextEdit
          Left = 112
          Top = 48
          TabOrder = 1
          Text = 'scripts/xml'
          Width = 281
        end
        object edtFTPport: TcxTextEdit
          Left = 112
          Top = 148
          TabOrder = 5
          Text = '21'
          Width = 37
        end
        object btnFTPtest: TcxButton
          Left = 112
          Top = 188
          Width = 75
          Height = 25
          Caption = '&Test'
          TabOrder = 4
          OnClick = btnFTPtestClick
        end
        object btnDefault: TcxButton
          Left = 168
          Top = 148
          Width = 75
          Height = 25
          Caption = 'Default'
          TabOrder = 6
          OnClick = btnDefaultClick
        end
        object Label3: TcxLabel
          Left = 8
          Top = 20
          Margins.Bottom = 0
          Caption = 'FTP adres'
          Transparent = True
        end
        object Label4: TcxLabel
          Left = 8
          Top = 84
          Margins.Bottom = 0
          Caption = 'Accountnaam'
          Transparent = True
        end
        object Label5: TcxLabel
          Left = 8
          Top = 116
          Margins.Bottom = 0
          Caption = 'Password'
          Transparent = True
        end
        object Label6: TcxLabel
          Left = 8
          Top = 52
          Margins.Bottom = 0
          Caption = 'Default directory'
          Transparent = True
        end
        object Label7: TcxLabel
          Left = 8
          Top = 152
          Margins.Bottom = 0
          Caption = 'FTP port'
          Transparent = True
        end
        object Label8: TcxLabel
          Left = 292
          Top = 72
          Margins.Bottom = 0
          Caption = 
            'Gebruik bij een unix-server altijd een '#39'/'#39' als padscheiding. Voo' +
            'r- en achteraan komen meestal geen '#39'/'#39
          Transparent = True
        end
      end
      object tsClient: TcxTabSheet
        Caption = 'Client'
        ImageIndex = 2
        object GroupBox4: TcxGroupBox
          Left = 6
          Top = 10
          Caption = 'Tijdelijke bestanden'
          TabOrder = 0
          Height = 95
          Width = 441
          object btnBrowseTemppad: TcxButton
            Left = 400
            Top = 24
            Width = 25
            Height = 25
            Caption = '...'
            TabOrder = 1
            OnClick = btnBrowseTemppadClick
          end
          object btnTemppadDefault: TcxButton
            Left = 342
            Top = 54
            Width = 81
            Height = 27
            Caption = 'default'
            TabOrder = 2
            OnClick = btnTemppadDefaultClick
          end
          object edtTemppad: TcxTextEdit
            Left = 16
            Top = 28
            TabOrder = 0
            Width = 385
          end
        end
      end
      object TabSheet1: TcxTabSheet
        Caption = 'Systeem'
        ImageIndex = 3
        object GroupBox7: TcxGroupBox
          Left = 2
          Top = 36
          Caption = 'Euroface Server'
          TabOrder = 0
          Height = 53
          Width = 441
          object edtEurofaceServer: TcxTextEdit
            Left = 112
            Top = 18
            TabOrder = 0
            Width = 293
          end
          object Label9: TcxLabel
            Left = 16
            Top = 20
            Margins.Bottom = 0
            Caption = 'URL of IP :'
            Transparent = True
          end
        end
        object GroupBox5: TcxGroupBox
          Left = 2
          Top = 96
          Caption = 'Rentix database'
          TabOrder = 1
          Height = 61
          Width = 441
          object edtClientDatabase: TcxTextEdit
            Left = 16
            Top = 24
            TabOrder = 0
            Width = 385
          end
          object btnBrowseClientdatabase: TcxButton
            Left = 400
            Top = 20
            Width = 25
            Height = 25
            Caption = '...'
            TabOrder = 1
            OnClick = btnBrowseClientdatabaseClick
          end
        end
        object GroupBox3: TcxGroupBox
          Left = 4
          Top = 162
          Caption = 'Rente database van Finix'
          TabOrder = 2
          Height = 61
          Width = 441
          object edtRenteDB: TcxTextEdit
            Left = 16
            Top = 24
            TabOrder = 0
            Width = 385
          end
          object btnBrowseRenteDB: TcxButton
            Left = 400
            Top = 20
            Width = 25
            Height = 25
            Caption = '...'
            TabOrder = 1
            OnClick = btnBrowseRenteDBClick
          end
        end
        object Label10: TcxLabel
          Left = 6
          Top = 256
          Margins.Bottom = 0
          Caption = 
            'Verander niets aan deze instellingen als u niet weet wat u doet.' +
            '..'
          ParentFont = False
          Transparent = True
        end
        object Label11: TcxLabel
          Left = 6
          Top = 276
          Margins.Bottom = 0
          Caption = 
            'Rentix moet opnieuw worden opgestart voordat systeemwijzigingen ' +
            'worden doorgevoerd.'
          Transparent = True
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    FileName = 'RentixServer.mdb'
    Filter = 'Access-databases (*.mdb)|*.mdb'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofPathMustExist, ofFileMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Title = 'Selecteer de RentixServer database (RentixServer.mdb)'
    Left = 256
    Top = 40
  end
  object OpenDialog2: TOpenDialog
    FileName = 'Rentes.mdb'
    Filter = 'Access-databases (*.mdb)|*.mdb'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofPathMustExist, ofFileMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Title = 'Selecteer de RentixServer database (RentixServer.mdb)'
    Left = 312
    Top = 88
  end
  object OpenDialog3: TOpenDialog
    FileName = 'Rentix.mdb'
    Filter = 'Access-databases (*.mdb)|*.mdb'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofPathMustExist, ofFileMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Title = 'Selecteer de Rentix database (Rentix.mdb)'
    Left = 328
    Top = 24
  end
end

inherited frmCSVverwerking: TfrmCSVverwerking
  Left = 418
  Top = 522
  Caption = 'Verwerking van een Comma-Seperated files'
  OldCreateOrder = True
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 16
  object memAuto: TMemo [0]
    Left = 0
    Top = 29
    Width = 603
    Height = 331
    Align = alClient
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
    Visible = False
  end
  inherited pnlButtons: TPanel
    inherited btnFinish: TBitBtn
      OnClick = btnFinishClick
    end
  end
  inherited PageControl1: TPageControl
    Height = 331
    ActivePage = TabSheet4
    inherited TabSheet1: TTabSheet
      BorderWidth = 5
      Caption = 'Selecteren csv'
      object CheckListBox1: TCheckListBox
        Left = 0
        Top = 0
        Width = 585
        Height = 259
        Align = alClient
        ItemHeight = 16
        TabOrder = 0
      end
      object Panel2: TPanel
        Left = 0
        Top = 259
        Width = 585
        Height = 31
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object btnRefreshCSV: TButton
          Left = 4
          Top = 4
          Width = 75
          Height = 25
          Caption = '&Refresh'
          TabOrder = 0
          OnClick = btnRefreshCSVClick
        end
        object btnAlles: TButton
          Left = 176
          Top = 4
          Width = 75
          Height = 25
          Caption = '&Alles'
          TabOrder = 1
          OnClick = btnAllesClick
        end
        object btnNiets: TButton
          Left = 88
          Top = 4
          Width = 81
          Height = 25
          Caption = '&Niets'
          TabOrder = 2
          OnClick = btnNietsClick
        end
      end
    end
    inherited TabSheet2: TTabSheet
      BorderWidth = 5
      Caption = 'inlezen csv'
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 585
        Height = 290
        Align = alClient
        Color = clBtnFace
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    inherited TabSheet3: TTabSheet
      Caption = 'Aanvullen rentes + XML'
      object MemAanvul: TMemo
        Left = 0
        Top = 0
        Width = 595
        Height = 300
        Align = alClient
        Color = clBtnFace
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    inherited TabSheet4: TTabSheet
      BorderWidth = 5
      Caption = 'Versturen XMLs'
      object GroupBox1: TGroupBox
        Left = 0
        Top = 235
        Width = 585
        Height = 55
        Align = alBottom
        Caption = 'Voortgang'
        TabOrder = 0
        object Panel3: TPanel
          Left = 2
          Top = 18
          Width = 581
          Height = 35
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 5
          TabOrder = 0
          object ProgressBar1: TProgressBar
            Left = 5
            Top = 5
            Width = 571
            Height = 25
            Align = alClient
            TabOrder = 0
          end
        end
      end
      object MemXMLversturen: TMemo
        Left = 0
        Top = 41
        Width = 585
        Height = 194
        Align = alClient
        Color = clBtnFace
        TabOrder = 1
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 585
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object btnStartUpload: TButton
          Left = 20
          Top = 8
          Width = 89
          Height = 25
          Caption = '&Start upload'
          TabOrder = 0
          OnClick = btnStartUploadClick
        end
        object BtnKillUpload: TButton
          Left = 120
          Top = 8
          Width = 89
          Height = 25
          Caption = '&Cancel upload'
          TabOrder = 1
          OnClick = BtnKillUploadClick
        end
      end
    end
  end
  inherited Panel1: TPanel
    Alignment = taLeftJustify
    BorderWidth = 3
  end
  object Panel5: TPanel
    Left = 0
    Top = 360
    Width = 603
    Height = 33
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 4
    Visible = False
    object Panel6: TPanel
      Left = 508
      Top = 0
      Width = 95
      Height = 33
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button1: TButton
        Left = 4
        Top = 4
        Width = 75
        Height = 25
        Caption = '&Sluiten'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
  end
end

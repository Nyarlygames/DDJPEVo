object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Editeur de piste de Dance Dance JP Evolution'
  ClientHeight = 633
  ClientWidth = 698
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 182
    Top = 541
    Width = 92
    Height = 13
    Caption = 'Temps en  seconde'
  end
  object Elements: TListBox
    Left = 24
    Top = 167
    Width = 649
    Height = 362
    ItemHeight = 13
    TabOrder = 0
    OnClick = ElementsClick
  end
  object Supprimer: TButton
    Left = 598
    Top = 560
    Width = 75
    Height = 25
    Caption = 'Supprimer'
    TabOrder = 1
    OnClick = SupprimerClick
  end
  object Ajouter: TButton
    Left = 296
    Top = 558
    Width = 106
    Height = 25
    Caption = 'Ajouter une fl'#232'che'
    TabOrder = 2
    OnClick = AjouterClick
  end
  object Temps: TEdit
    Left = 182
    Top = 560
    Width = 69
    Height = 21
    BiDiMode = bdRightToLeft
    ParentBiDiMode = False
    TabOrder = 3
    Text = '0,0'
  end
  object Fleches: TComboBox
    Left = 24
    Top = 560
    Width = 121
    Height = 21
    DropDownCount = 4
    ItemHeight = 13
    TabOrder = 4
    Text = 'Type de fl'#232'che'
  end
  object Play: TButton
    Left = 24
    Top = 41
    Width = 97
    Height = 25
    Caption = 'Play/Pause'
    TabOrder = 5
    OnClick = PlayClick
  end
  object Progress: TTrackBar
    Left = 24
    Top = 72
    Width = 185
    Height = 45
    TabOrder = 6
  end
  object Son: TTrackBar
    Left = 229
    Top = 69
    Width = 69
    Height = 45
    TabOrder = 7
    OnChange = SonChange
  end
  object Time: TEdit
    Left = 214
    Top = 123
    Width = 69
    Height = 21
    ReadOnly = True
    TabOrder = 8
    Text = 'Duree'
  end
  object Track: TEdit
    Left = 24
    Top = 123
    Width = 80
    Height = 21
    TabOrder = 9
    Text = '00:00:00'
  end
  object GetTo: TButton
    Left = 110
    Top = 123
    Width = 59
    Height = 25
    Caption = 'Aller '#224'...'
    TabOrder = 10
    OnClick = GetToClick
  end
  object OpenDialog: TOpenDialog
    Left = 360
    Top = 40
  end
  object Timer: TTimer
    Interval = 100
    OnTimer = TimerTimer
    Left = 392
    Top = 40
  end
  object MainMenu1: TMainMenu
    object Fichierjp1: TMenuItem
      Caption = 'Fichier'
      object Nouveau: TMenuItem
        Caption = 'Nouveau'
        OnClick = NouveauClick
      end
      object Ouvrir1: TMenuItem
        Caption = 'Ouvrir'
        OnClick = Ouvrir1Click
      end
      object Enregistrer1: TMenuItem
        Caption = 'Enregistrer'
        OnClick = Enregistrer1Click
      end
      object Sauvegarder1: TMenuItem
        Caption = 'Enregister sous...'
        OnClick = Sauvegarder1Click
      end
    end
    object Au1: TMenuItem
      Caption = 'Audio'
      object FermerMusique1: TMenuItem
        Caption = 'Fermer Musique'
      end
      object ChercherMusique1: TMenuItem
        Caption = 'Ouvrir Musique'
        OnClick = ChercherMusique1Click
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 32
  end
  object OpenDialog1: TOpenDialog
    Left = 64
  end
end

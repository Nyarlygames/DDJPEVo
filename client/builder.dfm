object Build: TBuild
  Left = 0
  Top = 0
  Caption = 'Editeur de piste de Dance Dance JP Evolution'
  ClientHeight = 789
  ClientWidth = 556
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Elements: TListBox
    Left = 24
    Top = 253
    Width = 513
    Height = 489
    ItemHeight = 13
    TabOrder = 0
    OnClick = ElementsClick
  end
  object Supprimer: TButton
    Left = 24
    Top = 756
    Width = 75
    Height = 25
    Caption = 'Supprimer'
    TabOrder = 1
    OnClick = SupprimerClick
  end
  object Ajouter: TButton
    Left = 462
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Ajouter'
    TabOrder = 2
    OnClick = AjouterClick
  end
  object Temps: TEdit
    Left = 160
    Top = 130
    Width = 113
    Height = 21
    TabOrder = 3
    Text = 'Temps'
  end
  object Fleches: TComboBox
    Left = 24
    Top = 130
    Width = 121
    Height = 21
    DropDownCount = 4
    ItemHeight = 13
    TabOrder = 4
    Text = 'Type de fl'#232'che'
  end
  object Nom: TEdit
    Left = 24
    Top = 184
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'Nom de la piste'
  end
  object Save: TButton
    Left = 160
    Top = 182
    Width = 113
    Height = 25
    Caption = 'Sauver'
    TabOrder = 6
    OnClick = SaveClick
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 488
    Top = 24
  end
end

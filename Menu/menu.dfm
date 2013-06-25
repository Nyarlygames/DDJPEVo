object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Menu Dance Dance JP Evolution v1.0'
  ClientHeight = 768
  ClientWidth = 1024
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
  object Button1: TButton
    Left = 192
    Top = 608
    Width = 121
    Height = 20
    Caption = 'Moteur de jeu'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 688
    Top = 608
    Width = 121
    Height = 20
    Caption = 'Client'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 192
    Top = 680
    Width = 121
    Height = 20
    Caption = 'Gameplay'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 440
    Top = 608
    Width = 121
    Height = 20
    Caption = 'Site web'
    TabOrder = 3
    OnClick = Button5Click
  end
  object Button4: TButton
    Left = 440
    Top = 679
    Width = 121
    Height = 20
    Caption = 'IA'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button6: TButton
    Left = 688
    Top = 679
    Width = 121
    Height = 20
    Caption = 'Editeur de maps'
    TabOrder = 5
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 688
    Top = 634
    Width = 121
    Height = 20
    Caption = 'Serveur'
    TabOrder = 6
    OnClick = Button7Click
  end
end

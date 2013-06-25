object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Menu Dance Dance JP Evolution v1.0'
  ClientHeight = 833
  ClientWidth = 424
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
    Left = 224
    Top = 120
    Width = 121
    Height = 41
    Caption = 'Moteur de jeu'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 224
    Top = 248
    Width = 121
    Height = 41
    Caption = 'R'#233'seau'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 224
    Top = 376
    Width = 121
    Height = 41
    Caption = 'Gameplay'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 224
    Top = 512
    Width = 121
    Height = 41
    Caption = 'IA'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 224
    Top = 640
    Width = 121
    Height = 41
    Caption = 'Site web'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 224
    Top = 768
    Width = 121
    Height = 41
    Caption = 'Moteur Son'
    TabOrder = 5
    OnClick = Button6Click
  end
end

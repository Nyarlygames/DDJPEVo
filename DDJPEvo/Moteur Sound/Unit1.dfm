object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 67
  ClientWidth = 396
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 40
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Play/Pause'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 144
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Quitter'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 336
    Top = 8
    Width = 52
    Height = 21
    TabOrder = 2
  end
  object Button3: TButton
    Left = 336
    Top = 34
    Width = 52
    Height = 25
    Caption = 'OK !'
    TabOrder = 3
    OnClick = Button3Click
  end
end

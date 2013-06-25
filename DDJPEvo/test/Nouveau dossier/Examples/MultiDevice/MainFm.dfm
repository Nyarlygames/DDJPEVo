object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'ColorEffect and ParticleSprite Demo'
  ClientHeight = 450
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 280
    Top = 391
    Width = 193
    Height = 22
    AutoSize = False
    Caption = 'ColorEffect and ParticleSprite Demo'
    WordWrap = True
  end
  object Panel1: TPanel
    Left = 4
    Top = 8
    Width = 357
    Height = 377
    Caption = 'Panel1'
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 366
    Top = 8
    Width = 357
    Height = 377
    Caption = 'Panel2'
    TabOrder = 1
  end
  object Button1: TButton
    Left = 136
    Top = 411
    Width = 75
    Height = 25
    Caption = 'FullScreen'
    TabOrder = 2
    OnClick = Button1Click
    OnKeyDown = Button1KeyDown
  end
  object Button2: TButton
    Left = 512
    Top = 411
    Width = 75
    Height = 25
    Caption = 'FullScreen'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 320
    Top = 411
    Width = 75
    Height = 25
    Caption = '<-Convert->'
    TabOrder = 4
    OnClick = Button3Click
  end
end

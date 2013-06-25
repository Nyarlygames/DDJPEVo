object MainFrm: TMainFrm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'MainFrm'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 615
    Top = 232
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 679
    Top = 344
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 679
    Top = 395
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'Edit2'
  end
  object Edit3: TEdit
    Left = 679
    Top = 440
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'Edit3'
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = FormCreate
    Left = 696
    Top = 56
  end
end

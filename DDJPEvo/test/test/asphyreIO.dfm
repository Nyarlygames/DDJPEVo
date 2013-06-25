object MainFrm: TMainFrm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'MainFrm'
  ClientHeight = 1024
  ClientWidth = 1280
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
    Left = 800
    Top = 24
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 800
    Top = 136
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = FormCreate
    Left = 696
    Top = 56
  end
end

object MainFrm: TMainFrm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Serveur'
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
    Left = 511
    Top = 72
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 559
    Top = 191
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
  object Serveur: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServeurClientConnect
    Left = 656
    Top = 56
  end
end

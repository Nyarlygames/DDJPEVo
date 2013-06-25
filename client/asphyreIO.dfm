object MainFrm: TMainFrm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Client'
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
    Left = 334
    Top = 8
    Width = 194
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 358
    Top = 103
    Width = 113
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 557
    Top = 103
    Width = 75
    Height = 25
    Caption = 'Connecter'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 557
    Top = 134
    Width = 75
    Height = 25
    Caption = 'D'#233'connecter'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = FormCreate
    Left = 688
    Top = 56
  end
  object Client: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnRead = ClientRead
    Left = 648
    Top = 56
  end
end

object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Tchat Dance Dance Jp Evo'
  ClientHeight = 527
  ClientWidth = 844
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Host: TLabel
    Left = 144
    Top = 12
    Width = 28
    Height = 17
    Caption = 'Host'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Connect: TButton
    Left = 295
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connecter'
    TabOrder = 0
    OnClick = ConnectClick
  end
  object Deconnect: TButton
    Left = 376
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Deconnecter'
    TabOrder = 1
    OnClick = DeconnectClick
  end
  object Port: TEdit
    Left = 8
    Top = 10
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '666'
  end
  object Envoie: TButton
    Left = 744
    Top = 496
    Width = 92
    Height = 25
    Caption = 'Envoyer'
    TabOrder = 3
    OnClick = EnvoieClick
  end
  object Affichage: TRichEdit
    Left = 8
    Top = 37
    Width = 828
    Height = 453
    Lines.Strings = (
      'Affichage')
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object Ecriture: TEdit
    Left = 8
    Top = 498
    Width = 721
    Height = 21
    TabOrder = 5
    Text = 'Tapez votre texte ici'
  end
  object Serveur: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServeurClientConnect
    OnClientDisconnect = ServeurClientDisconnect
    OnClientRead = ServeurClientRead
    Left = 816
  end
end

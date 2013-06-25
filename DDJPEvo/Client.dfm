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
  object Connect: TButton
    Left = 262
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connecter'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = ConnectClick
  end
  object Deconnect: TButton
    Left = 343
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
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = EnvoieClick
  end
  object Host: TEdit
    Left = 135
    Top = 10
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'Hostname'
  end
  object Ecriture: TEdit
    Left = 8
    Top = 498
    Width = 721
    Height = 21
    TabOrder = 5
    Text = 'Tapez votre texte ici'
  end
  object Affichage: TRichEdit
    Left = 8
    Top = 37
    Width = 828
    Height = 455
    Lines.Strings = (
      'Affichage')
    TabOrder = 6
  end
  object ClientChat: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnecting = ClientChatConnecting
    OnConnect = ClientChatConnect
    OnDisconnect = ClientChatDisconnect
    OnRead = ClientChatRead
    OnError = ClientChatError
    Left = 808
  end
end

unit jcj;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,asphyreIO,test,AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, ExtCtrls, StdCtrls;

type
  TForm2 = class(TForm)
    Timer1: TTimer;
    Edit1: TEdit;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
    procedure ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject; var Config: TScreenConfig);
    procedure RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;
  J1 : TMainFrm;

implementation

{$R *.dfm}

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math;

procedure TForm2.FormCreate(Sender: TObject);
begin
Timer1.Enabled := true;
        //Initialisation de DirectX
  if (not Devices.Initialize(ConfigureDevice, Self)) then
  begin
    //L'initalisation a échoué
    MessageDlg('Asphyre n''a pas pu s''initialiser!', mtError, [mbOk], 0);
    Close();
    Exit;
  end;

  //Initialisation de AsphyreInput
  AsphyreInput.Initialize;
  AsphyreInput.WindowHandle := Handle;
  //Initialisation des interfaces
  AsphyreInput.Keyboard.Initialize;
  AsphyreInput.Mouse.Initialize;
  DefDevice.Render(RenderCallback, self, $FF0000FF);
end;

procedure TForm2.ConfigureDevice(Sender: TAsphyreDevice; Tag: TObject; var Config: TScreenConfig);
begin
  //Paramétrage de l'affichage
  Config.Width   := ClientWidth;
  Config.Height  := ClientHeight;
  Config.Windowed:= True;

  Config.WindowHandle:= Self.Handle;
  Config.HardwareTL  := true;
end;

procedure TForm2.RenderCallback(Sender: TAsphyreDevice; Tag: TObject);
begin
  J1.FormCreate(Form2);
end;


end.

unit mainfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,bas,gauche,droite,haut,test,AsphyreEvents, AsphyreTimer,DirectInput;

type


  TForm1 = class(TForm)
  private
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  Frm : TMainFrm;
 sender: TComponent;

implementation

{$R *.dfm}




initialization

 Frm := TMainFrm.Create(Form1);
 Frm.FormCreate(Form1);
  finalization
  Frm.Free;
end.

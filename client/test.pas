unit test;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls;

const
MAX_FLECHES= 1999;

  type

  t_fleche = record
    time : integer;
    dir : integer;
    ord : Extended;
    sender: TAsphyreDevice;
    nombre : integer;
    tag: TObject;
    img : TAsphyreCustomImage;
  end;

    t_vec = array [0..MAX_FLECHES] of t_fleche;

  TTYpes = class(TForm)

  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math;

{$R *.dfm}


end.

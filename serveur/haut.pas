unit haut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,test;

type

  THautFrm = class(TForm)
  procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }


  public
    { Déclarations publiques }
    procedure RenderCallback(rec : t_fleche);
  end;

var
  HautFrm: THautFrm;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math,asphyreIO;

{$R *.dfm}

  procedure THautFrm.FormDestroy(Sender: TObject);
begin
  //Finalisation de DirectX
  Devices.Finalize;
end;

procedure THautFrm.RenderCallback(rec : t_fleche);
var
haut : TAsphyreCustomImage;
begin
  ImageGroups.ParseLink('Ressources.xml');
  with rec.sender.Canvas do
  begin
      //haut
    haut := rec.img;
    UseImage(haut, TexFull4);
    TexMap(pBounds4(350, rec.ord, haut.Texture[0].Size.X, haut.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
end;                                                         
end;



end.

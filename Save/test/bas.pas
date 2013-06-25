unit bas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,test;

type

  TBasFrm = class(TForm)
  procedure FormDestroy(Sender: TObject; i : integer;rec : t_fleche);
  private
    { Déclarations privées }


  public
    { Déclarations publiques }
    procedure RenderCallback(rec : t_fleche);
  end;

var
  BasFrm: TBasFrm;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math,asphyreIO;

{$R *.dfm}


procedure TBasFrm.FormDestroy(Sender: TObject;i : integer;rec : t_fleche);
begin
  //Finalisation de DirectX

end;


procedure TBasFrm.RenderCallback(rec : t_fleche);
var
bas : TAsphyreCustomImage;
begin
  ImageGroups.ParseLink('Ressources.xml');
  with rec.sender.Canvas do
  begin
      //bas
    bas := rec.img;
    UseImage(bas, TexFull4);
    TexMap(pBounds4(650, rec.ord, bas.Texture[0].Size.X, bas.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
end;
end;



end.

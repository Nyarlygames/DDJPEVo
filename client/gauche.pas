unit gauche;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,test;

type

  TGaucheFrm = class(TForm)
  procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }


  public
    { Déclarations publiques }
    procedure RenderCallback(rec : t_fleche);
  end;

var
  GaucheFrm: TGaucheFrm;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math,asphyreIO;

{$R *.dfm}

  procedure TGaucheFrm.FormDestroy(Sender: TObject);
begin
  //Finalisation de DirectX
  Devices.Finalize;
end;

procedure TGaucheFrm.RenderCallback(rec : t_fleche);
var
gauche : TAsphyreCustomImage;
begin
  ImageGroups.ParseLink('Ressources.xml');
  with rec.sender.Canvas do
  begin
      //gauche
    gauche := rec.img;
    UseImage(gauche, TexFull4);
    TexMap(pBounds4(50, rec.ord, gauche.Texture[0].Size.X, gauche.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
end;                                                         
end;



end.

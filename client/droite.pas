unit droite;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls,test;

type
  
  TDroitfrm = class(TForm)
  procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }


  public
    { Déclarations publiques }
    procedure RenderCallback(rec : t_fleche);
  end;

var
  Droitfrm: TDroitfrm;

implementation

uses
  AsphyreEvents, AsphyreTimer, AsphyreSystemFonts, MediaImages, MediaFonts,
  AsphyreEffects, Vectors2, DirectInput, Math,asphyreIO;

{$R *.dfm}

procedure TDroitFrm.FormDestroy(Sender: TObject);
begin
  //Finalisation de DirectX
  Devices.Finalize;
end;

procedure TDroitfrm.RenderCallback(rec : t_fleche);
var
droite : TAsphyreCustomImage;
begin
  ImageGroups.ParseLink('Ressources.xml');
  with rec.sender.Canvas do
  begin
      //droite
    droite := rec.img;
    UseImage(droite, TexFull4);
    TexMap(pBounds4(950, rec.ord, droite.Texture[0].Size.X, droite.Texture[0].Size.Y),
      cColor4($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF), fxuMultiBlend);
end;                                                         
end;



end.

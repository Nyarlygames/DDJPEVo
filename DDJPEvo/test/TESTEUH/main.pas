unit mainfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AsphyreDevices, AsphyreImages, AsphyreTypes, AsphyreJoystick, AsphyreMouse,
  AsphyreKeyboard, AsphyreInputs, StdCtrls;

type
 TJoyInfos = record
    Axis: integer;
    Buttons: integer;
    POVs: integer;
  end;

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  Form1: TForm1;
  Frm : TMainFrm;
  Joy : TObject;

implementation

{$R *.dfm}



end.

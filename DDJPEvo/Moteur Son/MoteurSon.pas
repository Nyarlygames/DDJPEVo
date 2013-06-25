unit MoteurSon;

interface

uses
  SysUtils, fmod, fmodtypes, AsphyreDevices, AsphyreImages, AsphyreTypes,
  AsphyreKeyboard, AsphyreInputs, AsphyreJoystick, AsphyreMouse, DirectInput;

var
  starcraft : PFSOUNDSTREAM ;

implementation

begin

//initialisation de FMOD ( nb Hz / nb canaux dispos / flags? mais osef )
FSOUND_Init(44100, 32, 0);

//on charge la musique ( nom fichier / osef ^^ / debut de la ziq / jusqu'ou )
starcraft := FSOUND_Stream_Open('starcraft.mp3',0,0,0) ;

//on joue la musique ( FMOD choisi un canal, musique en question )
FSOUND_Stream_play( FSOUND_FREE, starcraft ) ;

//changer le volume ( sur tous les canaux / entre 0 et 255 ou 256 )
FSOUND_SetVolume(FSOUND_ALL, 255);

//initialisation clavier
  //Initialisation de AsphyreInput
  AsphyreInput.Initialize;
  //Initialisation des interfaces
  AsphyreInput.Keyboard.Initialize;


//mettre la chanson en pause =====> ne marche pas encore ^^
if AsphyreInput.Keyboard.Update then
  with AsphyreInput.Keyboard do
    if Key[DIK_ESCAPE] then
      if (FMUSIC_GetPaused(starcraft)) then     // Si la chanson est en pause
        FMUSIC_SetPaused(starcraft, false) // On enlève la pause
      else                              // Sinon, elle est en cours de lecture
        FMUSIC_SetPaused(starcraft, true);// On met en pause






end.

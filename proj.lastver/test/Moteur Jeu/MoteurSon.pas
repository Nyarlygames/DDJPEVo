unit MoteurSon;

interface

uses
  SysUtils, fmod, fmodtypes, AsphyreDevices, AsphyreImages, AsphyreTypes,
  AsphyreKeyboard, AsphyreInputs, DirectInput;

var
  music : PFSOUNDSTREAM ;

implementation

begin

//initialisation de FMOD ( nb Hz / nb canaux dispos / flags? mais osef )
FSOUND_Init(44100, 32, 0);

//on charge la musique ( nom fichier / osef ^^ / debut de la ziq / jusqu'ou )
music := FSOUND_Stream_Open('z3_fontaine.mid',0,0,0) ;

//on joue la musique ( FMOD choisi un canal, musique en question )
FSOUND_Stream_play( FSOUND_FREE, music ) ;

//changer le volume ( sur tous les canaux / entre 0 et 255 ou 256 )
FSOUND_SetVolume(FSOUND_ALL, 255);

//Boucle de musique
FMUSIC_SetLooping(music, true) ;




//liberer la memoire une fois que c'est fini
//FSOUND_CLOSE() ;
   




end.

unit MoteurSon;

interface

uses
  SysUtils, fmod, fmodtypes, AsphyreDevices, AsphyreImages, AsphyreTypes,
  AsphyreKeyboard, AsphyreInputs, DirectInput;

var
  music : PFSoundSample ;

implementation

begin

//initialisation de FMOD ( nb Hz / nb canaux dispos / flags? mais osef )
FSOUND_Init(44100, 42, 0);

//on charge la musique ( nom fichier / osef ^^ / debut de la ziq / jusqu'ou )
music := Fmusic_loadsong('z3_fontaine.mid') ;


Fmusic_setlooping(music,true);

//on joue la musique ( FMOD choisi un canal, musique en question )
FMUSIC_playsong( music ) ;

Fmusic_setpaused(music,true);

//changer le volume ( sur tous les canaux / entre 0 et 255 ou 256 )
Fmusic_Setmastervolume(music, 255);






//liberer la memoire une fois que c'est fini
//FSOUND_CLOSE() ;
   




end.

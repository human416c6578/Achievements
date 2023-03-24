#include < amxmodx >
#include < sockets >
#include < achievement_api >


enum _:eAchievement{
	 eName[32],
	 eDesc[64],
	 eMaxVal,
	 eXP,
	 eCredits
}

new g_achievements[27][eAchievement] = {
	{"Lucky Shot",		  "Omoara Teroristul",				1,	  50, 100},
	{"Terrorist Killer",	"Omoara Teroristul 10 ori",		 10,	 100, 300},
	{"Anti-Terro",		  "Omoara Teroristul de 50 ori",	  50,	 500, 3000},
	{"The Pacifier",		"Omoara Teroristul de 100 ori",	 100,	1000, 8000},

	{"Bomber",			  "Omoara Teroristul cu o grenada",   1,	  150, 500},

	{"Trickster",		   "Joaca ca terorist",				1,	  25, 50},
	{"The Terrorist",	   "Joaca ca terorist de 10 ori",	  10,	 75, 100},
	{"Trap-Man",			"Joaca ca terorist de 50 ori",	  50,	 200, 500},
	{"GameMaster",		  "Joaca ca terorist de 100 ori",	 100,	500, 1500},

	{"Beginner's Luck",	 "Castiga un duel",				  1,	 125, 350},
	{"Executioner",		 "Castiga 10 dueluri",			   10,	350, 1500},
	{"Can't Touch This",	"Castiga 50 de dueluri",			50,	750, 3500},
	{"Wild West Conquerer", "Castiga 100 de dueluri",		   100,   1500, 10000},

	{"Beginner Runner",	 "Termina o harta",				  1,	 25, 100},
	{"Intermediate Runner", "Termina harta de 10 ori",		  10,	75, 250},
	{"Advanced Runner",	 "Termina harta de 50 ori",		  50,	250, 1000},
	{"Pro Runner",		  "Termina harta de 100 ori",		 100,   500, 5000},
	{"Insane Runner",	   "Termina harta de 200 ori",		 200,   1000, 10000},
	{"God-Like Runner",	 "Termina harta de 300 ori",		 300,   1500, 15000},

	{"Debutee",			 "Sparge recordul hartii",		   1,	 150, 500},
	{"Regular",			 "Sparge recordul hartii de 5 ori",  5,	 500, 1000},
	{"Old-Timer",		   "Sparge recordul hartii de 10 ori", 10,	1000, 5000},
	{"The First of Many",   "Sparge recordul hartii de 25 ori", 25,	2000, 10000},

	{"Fresh Start",		 "Joaca o ora pe server",			60,	 125, 350},
	{"Passionate",		  "Joaca 10 ore pe server",		   600,	350, 1500},
	{"Addicted",			"Joaca 50 ore pe server",		   3000,   750, 3500},
	{"No Lifer",			"Joaca 100 ore pe server",		  6000,   1500, 10000}
}

public plugin_init( )
{
	register_plugin( "Achievement API: MOTD Info", "0.0.1", "Xellath" );

	register_clcmd( "say /achievements", "ShowMotd" );
	register_clcmd( "say /achi", "ShowMotd" );
	register_clcmd( "say /misiuni", "ShowMenu" );
}

public ShowMotd(id){
	new website[1024], title[64], Name[64];
	new ObjectiveData;
	new AchievementsCompleted;
	new AchievementKey[64];
	get_user_name(id, Name, charsmax(Name));
	format(website, charsmax(website), "http://www.cs-gfx.eu/drinfo/ach/ach.php?");
	for( new AchievementIndex = 0; AchievementIndex < GetMaxAchievements( ); AchievementIndex++ )
	{
		GetAchievementKey( AchievementIndex, AchievementKey );
		ObjectiveData = GetAchievementData( Name, AchievementKey );
		format(website, charsmax(website), "%sa[]=%d&", website, ObjectiveData);
		if(ObjectiveData >= GetAchievementMaxValue( AchievementIndex ))
			AchievementsCompleted++;
	}
	format(website, charsmax(website), "%scomp=%d", website, AchievementsCompleted);
	format(title, charsmax(title), "Achievements");
	show_web_motd(id, website, title);
}

stock show_web_motd(id, website[], desc[]){
	new motd[1024];
	formatex(motd, sizeof(motd) - 1, "<html><head><meta http-equiv=^"Refresh^" content=^"0;url=%s^"></head><body><p><center>LOADING...</center></p></body></html>", website);
	show_motd(id, motd, desc);
}

public ShowMenu(id){

	new Title[64], Name[64], AchData[27], bool:AchCompleted[27];
	new AchievementsCompleted;
	new AchievementKey[64];
	get_user_name(id, Name, charsmax(Name));


	for( new AchievementIndex = 0; AchievementIndex < GetMaxAchievements( ); AchievementIndex++ )
	{
		GetAchievementKey( AchievementIndex, AchievementKey );
		AchData[AchievementIndex] = GetAchievementData( Name, AchievementKey );
		if(AchData[AchievementIndex] >= GetAchievementMaxValue( AchievementIndex )){
			AchCompleted[AchievementIndex] = true;
			AchievementsCompleted++;
		}
	}

	format(Title, charsmax(Title), "\rAchievements \w- \y%d/\r%d Completed\w", AchievementsCompleted, 27);

	new menu = menu_create(Title, "menu_handler");

	new Item[128];
	for( new i; i<27;i++ ){
		if(AchCompleted[i])
			format(Item, charsmax(Item), "\g%s - \rCompleted", g_achievements[i][eName]);
		else
			format(Item, charsmax(Item), "\w%s \y%d \wXP \y%d \w Credits - %d/\r%d", g_achievements[i][eName], g_achievements[i][eXP], g_achievements[i][eCredits], AchData[i], GetAchievementMaxValue(i));

		menu_additem(menu, Item);
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);

}

public menu_handler(id, menu, item){
	if(!item) return PLUGIN_HANDLED;

	menu_destroy(menu);

	client_print(id, print_chat, g_achievements[item][eDesc]);

	return PLUGIN_HANDLED;
}

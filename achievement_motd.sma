#include < amxmodx >
#include < sockets >
#include < achievement_api >


public plugin_init( )
{
	register_plugin( "Achievement API: MOTD Info", "0.0.1", "Xellath" );

	register_clcmd( "say /achievements", "ShowMotd" );
	register_clcmd( "say /achi", "ShowMotd" );
	register_clcmd( "say /misiuni", "ShowMotd" );
}

public ShowMotd(id){
	new website[1024], title[64], Name[64];
	new ObjectiveData;
	new AchievementsCompleted;
	new AchievementKey[64];
	get_user_name(id, Name, charsmax(Name));
	format(website, charsmax(website), "https://www.smite.ro/drinfo/ach/ach.php?");
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
#include <amxmodx>
#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <achievement_api>
#include <credits>
#include <crxranks>

#define TIME_NUM 4

new const InfoTime[TIME_NUM][ AchievementDataStruct ] = {
	{
		"Fresh Start", 
		"Joaca o ora pe server", 
		"progress_time1", 
		60 
	},
	{
		"Passionate", 
		"Joaca 10 ore pe server", 
		"progress_time10", 
		600 
	},
	{
		"Addicted", 
		"Joaca 50 ore pe server", 
		"progress_time50", 
		3000 
	},
	{
		"No Lifer", 
		"Joaca 100 ore pe server", 
		"progress_time100", 
		6000 
	}
};




new const InfoRewardsTime[TIME_NUM][] = {
	{
		125, //XP
		350 //Credits
	},
	{
		350, 
		1500 
	},
	{
		750, 
		3500 
	},
	{
		1500,
		10000
	}
}


// pointer to achievement
new g_pTime[TIME_NUM];

// our objective counter
new Time[ MAX_PLAYERS + 1 ][TIME_NUM];

new bool:Time_Loaded[MAX_PLAYERS + 1];

public plugin_init( )
{
	register_plugin( "Achievement API: Ore", "0.1", "MrShark45" );

	for(new i;i<TIME_NUM;i++){
		g_pTime[i] = RegisterAchievement( 
			InfoTime[i][ eName ], 
			InfoTime[i][ eDescription ], 
			InfoTime[i][ eKey ], 
			InfoTime[i][ eMaxValue ] 
		);
	}


}

public plugin_cfg(){
	//entity to show player current time
	new eTimer = create_entity("info_target");
	entity_set_string(eTimer, EV_SZ_classname, "info_timecount");
	register_think("info_timecount", "TimeCount");
	entity_set_float(eTimer, EV_FL_nextthink, get_gametime() + 60.0);
}

public client_putinserver( Client )
{
	set_task( 5.0, "TaskDelayConnect", Client );
}

public TaskDelayConnect( Client )
{
	new szName[64];

	get_user_name( Client, szName, charsmax( szName ) );

	for(new i;i<TIME_NUM;i++){
		Time[Client][i] = GetAchievementData( szName, InfoTime[i][ eKey ]  );
	}
	
	Time_Loaded[Client] = true;
}

public client_disconnected( Client )
{
	for(new i;i<TIME_NUM;i++)
		Time[ Client ][i] = 0;

	Time_Loaded[Client] = false;
}

public TimeCount(ent){
	new iPlayers[MAX_PLAYERS], iNum, Client, szName[64];
	get_players(iPlayers, iNum, "ch");
	for(new i;i<iNum;i++){
		Client = iPlayers[i];
		
		if(!Time_Loaded[Client]) continue;

		get_user_name(Client, szName, charsmax(szName));
		for(new i;i<TIME_NUM;i++){
			// check if client already completed achievement
			if( GetClientAchievementStatus( g_pTime[i], Time[ Client ][i] ) == _In_Progress )
			{
				Time[Client][i]++;
	
				// save objective data to clients steamid
				SetAchievementData( szName, InfoTime[i][ eKey ], Time[ Client ][i]);

				if( GetClientAchievementStatus( g_pTime[i], Time[ Client ][i] ) == _Unlocked )
				{
					ClientAchievementCompleted( Client, g_pTime[i]);
				}
			}
		}
	}

	entity_set_float(ent, EV_FL_nextthink, get_gametime() + 60);
}

public Forward_ClientEarnedAchievement( const AchiPointer, const Client )
{
	for(new i;i<TIME_NUM;i++){
		if(AchiPointer == g_pTime[i]){
			GiveReward(Client, InfoRewardsTime[i][0], InfoRewardsTime[i][1]);
		}
	}
}

public GiveReward(id, xp, credits){
	crxranks_give_user_xp(id, xp);
	set_user_credits(id, get_user_credits(id) + credits);
}
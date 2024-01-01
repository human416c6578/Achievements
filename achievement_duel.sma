#include <amxmodx>
#include <cstrike>
#include <achievement_api>
#include <credits>
#include <crxranks>

forward player_won_duel(id);

#define DUEL_NUM 4

new const InfoDuel[DUEL_NUM][ AchievementDataStruct ] = {
	{
		"Beginner's Luck",
		"Castiga un duel",
		"progress_duel1", 
		1 
	},
	{
		"Executioner", 
		"Castiga 10 dueluri", 
		"progress_duel10", 
		10 
	},
	{
		"Can't Touch This", 
		"Castiga 50 de dueluri", 
		"progress_duel50", 
		50 
	},
	{
		"Wild West Conquerer", 
		"Castiga 100 de dueluri", 
		"progress_duel100",
		100 
	},
};




new const InfoRewardsDuel[DUEL_NUM][] = {
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
new g_pDuel[DUEL_NUM];

// our objective counter
new Duel[ MAX_PLAYERS + 1 ][DUEL_NUM];

public plugin_init( )
{
	register_plugin( "Achievement API: Timer", "0.1", "MrShark45" );

	for(new i;i<DUEL_NUM;i++){
		g_pDuel[i] = RegisterAchievement( 
			InfoDuel[i][ eName ], 
			InfoDuel[i][ eDescription ], 
			InfoDuel[i][ eKey ],
			InfoDuel[i][ eMaxValue ] 
		);
	}
}


public client_putinserver( Client )
{
	set_task( 5.0, "TaskDelayConnect", Client );
}

public TaskDelayConnect( Client )
{
	new szName[64];

	get_user_name( Client, szName, charsmax( szName ) );

	for(new i;i<DUEL_NUM;i++){
		Duel[Client][i] = GetAchievementData( szName, InfoDuel[i][ eKey ]  );
	}
	
}

public client_disconnected( Client )
{
	for(new i;i<DUEL_NUM;i++)
		Duel[ Client ][i] = 0;
}

public player_won_duel( Client ){
    new szName[64];
    get_user_name(Client, szName, charsmax(szName));
    for(new i;i<DUEL_NUM;i++){
	    // check if client already completed achievement
	    if( GetClientAchievementStatus( g_pDuel[i], Duel[ Client ][i] ) == _In_Progress )
	    {
	    	Duel[Client][i]++;

	    	// save objective data to clients steamid
	    	SetAchievementData( szName, InfoDuel[i][ eKey ], Duel[ Client ][i]);

	    	if( GetClientAchievementStatus( g_pDuel[i], Duel[ Client ][i] ) == _Unlocked )
	    	{
	    		ClientAchievementCompleted( Client, g_pDuel[i] );
	    	}
	    }
	}
}

public Forward_ClientEarnedAchievement( const AchiPointer, const Client )
{
	for(new i;i<DUEL_NUM;i++){
		if(AchiPointer == g_pDuel[i]){
			GiveReward(Client, InfoRewardsDuel[i][0], InfoRewardsDuel[i][1]);
		}
	}
}

public GiveReward(id, xp, credits){
	crxranks_give_user_xp(id, xp);
	set_user_credits(id, get_user_credits(id) + credits);
}
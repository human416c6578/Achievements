#include < amxmodx >
#include < timer >
#include < achievement_api >
#include < credits >
#include < crxranks >

#define FINISH_NUM 6
#define RECORD_NUM 4

new const InfoFinish[FINISH_NUM][ AchievementDataStruct ] = {
	{
		"Beginner Runner", 
		"Termina harta o data", 
		"progress_finish1", 
		1 
	},
	{
		"Intermediate Runner",
		"Termina harta de 10 ori", 
		"progress_finish10",
		10 
	},
	{
		"Advanced Runner", 
		"Termina harta de 50 de ori",
		"progress_finish50",
		50 
	},
	{
		"Pro Runner", 
		"Termina harta de 100 de ori",
		"progress_finish100", 
		100 
	
	},
	{
		"Insane Runner", 
		"Termina harta de 200 de ori",
		"progress_finish200",
		200 
	
	},
	{
		"God-Like Runner", 
		"Termina harta de 300 de ori", 
		"progress_finish300", 
		300
	
	}
};

new const InfoRecord[RECORD_NUM][ AchievementDataStruct ] = {
	{
		"Debutee",
		"Sparge recordul hartii",
		"progress_record1", 
		1 
	
	},
	{
		"Regular", 
		"Sparge recordul hartii de 5 ori", 
		"progress_record5",
		5 
	
	},
	{
		"Old-Timer", 
		"Sparge recordul hartii de 10 ori", 
		"progress_record10", 
		10
	},
	{
		"The First Of Many", 
		"Sparge recordul hartii de 25 ori", 
		"progress_record25", 
		25
	}
};

new const InfoRewardsFinish[FINISH_NUM][] = {
	{
		25, 
		100 
	},
	{
		75, 
		250 
	},
	{
		250, 
		1000 
	},
	{
		500, 
		5000 
	},
	{
		1000,
		10000
	},
	{
		1500,
		15000
	}
}

new const InfoRewardsRecord[RECORD_NUM][] = {
	{
		150, 
		500 
	},
	{
		500, 
		1000 
	},
	{
		1000,
		5000 
	},
	{
		2000,
		10000
	}
}

// pointer to achievement
new g_pFinish[FINISH_NUM];
new g_pRecord[RECORD_NUM];

// our objective counter
new Finished[ MAX_PLAYERS + 1 ][FINISH_NUM];
new Record[ MAX_PLAYERS + 1 ][RECORD_NUM];

public plugin_init( )
{
	register_plugin( "Achievement API: Timer", "0.1", "MrShark45" );
	

	for(new i;i<FINISH_NUM;i++){
		g_pFinish[i] = RegisterAchievement( 
			InfoFinish[i][ eName ],
			InfoFinish[i][ eDescription ],
			InfoFinish[i][ eKey ], 
			InfoFinish[i][ eMaxValue ] 
		);
	}

	for(new i;i<RECORD_NUM;i++){
		g_pRecord[i] = RegisterAchievement( 
			InfoRecord[i][ eName ],
			InfoRecord[i][ eDescription ],
			InfoRecord[i][ eKey ], 
			InfoRecord[i][ eMaxValue ] 
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

	for(new i;i<FINISH_NUM;i++){
		Finished[Client][i] = GetAchievementData( szName, InfoFinish[i][ eKey ]  );
	}

	for(new i;i<RECORD_NUM;i++){
		Record[Client][i] = GetAchievementData( szName, InfoRecord[i][ eKey ]  );
	}
	
}

public client_disconnected( Client )
{
	for(new i;i<FINISH_NUM;i++)
		Finished[ Client ][i] = 0;
	for(new i;i<RECORD_NUM;i++)
		Record[ Client ][i] = 0;
}

public timer_player_finished(Client){
	new szName[64];
	// get username
	get_user_name( Client, szName, charsmax( szName ) );
	
	for(new i;i<FINISH_NUM;i++){
		// check if client already completed achievement
		if( GetClientAchievementStatus( g_pFinish[i], Finished[ Client ][i] ) == _In_Progress )
		{
			Finished[Client][i]++;
	
			// save objective data to clients steamid
			SetAchievementData( szName, InfoFinish[i][ eKey ], Finished[ Client ][i]);

			if( GetClientAchievementStatus( g_pFinish[i], Finished[ Client ][i] ) == _Unlocked )
			{
                ClientAchievementCompleted( Client, g_pFinish[i] );
			}
		}
	}
	
}

public timer_player_record(Client){
	new szName[64];
	// get username
	get_user_name( Client, szName, charsmax( szName ) );
	
	for(new i;i<RECORD_NUM;i++){
		// check if client already completed achievement
		if( GetClientAchievementStatus( g_pRecord[i], Record[ Client ][i] ) == _In_Progress )
		{
			Record[Client][i]++;
	
			// save objective data to clients steamid
			SetAchievementData( szName, InfoRecord[i][ eKey ], Record[ Client ][i]);

			if( GetClientAchievementStatus( g_pRecord[i], Record[ Client ][i] ) == _Unlocked )
			{
                ClientAchievementCompleted( Client, g_pRecord[i] );
			}
		}
	}
}

public Forward_ClientEarnedAchievement( const AchiPointer, const Client )
{
	for(new i;i<FINISH_NUM;i++){
		if(AchiPointer == g_pFinish[i]){
			GiveReward(Client, InfoRewardsFinish[i][0], InfoRewardsFinish[i][1]);
		}
	}

	for(new i;i<RECORD_NUM;i++){
		if(AchiPointer == g_pRecord[i]){
			GiveReward(Client, InfoRewardsRecord[i][0], InfoRewardsRecord[i][1]);
		}
	}
}

public GiveReward(id, xp, credits){
	crxranks_give_user_xp(id, xp);
	set_user_credits(id, get_user_credits(id) + credits);
}
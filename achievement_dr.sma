#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <achievement_api>
#include <credits>
#include <crxranks>

#define m_bitsDamageType 76

#define DMG_GRENADE (1<<24)

#define KILLT_NUM 4
#define PLAYT_NUM 4

new const InfoKillT[KILLT_NUM][ AchievementDataStruct ] = {
	{
		"Lucky Shot",
		"Omoara teroristul",
		"progress_killt1",
		1
	},
	{
		"Terrorist Killer",
		"Omoara teroristul de 10 ori",
		"progress_killt10",
		10
	},
	{
		"Anti-Terro",
		"Omoara teroristul de 50 ori", 
		"progress_killt50",
		50
	},
	{
		"The Pacifier",
		"Omoara teroristul de 100 ori",
		"progress_killt100",
		100
	},
};

new const InfoNade[ AchievementDataStruct ] = {
	"Bomber",
	"Omoara teroristul cu o grenada",
	"progress_nade",
	1 
};

new const InfoPlayT[PLAYT_NUM][ AchievementDataStruct ] = {
	{
		"Trickster",
		"Joaca ca terorist",
		"progress_playt1", 
		1 
	},
	{
		"The Terrorist", 
		"Joaca ca terorist de 10 ori", 
		"progress_playt10", 
		10 
	},
	{
		"Trap-Man",
		"Joaca ca terorist de 50 ori",
		"progress_playt50", 
		50 
	},
	{
		"GameMaster", 
		"Joaca ca terorist de 100 ori", 
		"progress_playt100", 
		100
	},
};




new const InfoRewardsKillT[KILLT_NUM][] = {
	{
		50, //XP
		100 //Credits
	},
	{
		100,
		300 
	},
	{
		500, 
		3000 
	},
	{
		1000,
		8000 
	}
}

new const InfoRewardsPlayT[PLAYT_NUM][] = {
	{
		25, //XP
		50 //Credits
	},
	{
		75,
		100
	},
	{
		200,
		500 
	},
	{
		500, 
		1500 
	}
}

new const InfoRewardsNade[] = {
	150, //XP
	500 //Credits
}

// pointer to achievement
new g_pKillT[KILLT_NUM];
new g_pPlayT[PLAYT_NUM];
new g_pNade;

// our objective counter
new Kills[ MAX_PLAYERS + 1 ][KILLT_NUM];
new Plays[ MAX_PLAYERS + 1 ][PLAYT_NUM];
new Nade[ MAX_PLAYERS + 1 ];

public plugin_init( )
{
	register_plugin( "Achievement API: DR", "0.1", "MrShark45" );

	RegisterHam(Ham_Killed, "player", "player_killed");
	RegisterHam(Ham_Spawn, "player", "player_spawn");
	

	for(new i;i<KILLT_NUM;i++){
		g_pKillT[i] = RegisterAchievement( 
			InfoKillT[i][ eName ], 
			InfoKillT[i][ eDescription ], 
			InfoKillT[i][ eKey ],
			InfoKillT[i][ eMaxValue ] 
		);
	}

	g_pNade = RegisterAchievement( 
			InfoNade[ eName ], 
			InfoNade[ eDescription ], 
			InfoNade[ eKey ], 
			InfoNade[ eMaxValue ] 
	);

	for(new i;i<PLAYT_NUM;i++){
		g_pPlayT[i] = RegisterAchievement( 
			InfoPlayT[i][ eName ], 
			InfoPlayT[i][ eDescription ], 
			InfoPlayT[i][ eKey ], 
			InfoPlayT[i][ eMaxValue ] 
		);
	}

	

}

public client_putinserver( Client )
{
	TaskDelayConnect(Client);
}

public TaskDelayConnect( Client )
{
	new szName[64];

	get_user_name( Client, szName, charsmax( szName ) );

	for(new i;i<KILLT_NUM;i++){
		Kills[Client][i] = GetAchievementData( szName, InfoKillT[i][ eKey ]  );
	}

	for(new i;i<PLAYT_NUM;i++){
		Plays[Client][i] = GetAchievementData( szName, InfoPlayT[i][ eKey ]  );
	}

	Nade[Client] = GetAchievementData( szName, InfoNade[ eKey ]  );
	
}

public client_disconnected( Client )
{
	for(new i;i<KILLT_NUM;i++)
		Kills[ Client ][i] = 0;
	for(new i;i<PLAYT_NUM;i++)
		Plays[ Client ][i] = 0;

	Nade[Client] = 0;
}

public player_spawn( Client )
{
	if(!is_user_connected(Client)) return HAM_IGNORED;
		
	if(cs_get_user_team(Client) != CS_TEAM_T) return HAM_IGNORED;

	new szName[64];
	get_user_name( Client, szName, charsmax( szName ) );

	for(new i;i<PLAYT_NUM;i++){
		// check if client already completed achievement
		if( GetClientAchievementStatus( g_pPlayT[i], Plays[ Client ][i] ) == _In_Progress )
		{
			Plays[Client][i]++;
	
			// save objective data to clients steamid
			SetAchievementData( szName, InfoPlayT[i][ eKey ], Plays[ Client ][i]);

			if( GetClientAchievementStatus( g_pPlayT[i], Plays[ Client ][i] ) == _Unlocked )
			{
				ClientAchievementCompleted( Client, g_pPlayT[i] );
			}
		}
	}
	return HAM_IGNORED;
}

public player_killed( Victim, Attacker )
{
	if(!is_user_connected(Attacker)) return HAM_IGNORED;
		
	if(cs_get_user_team(Victim) != CS_TEAM_T) return HAM_IGNORED;

	new szName[64];
	get_user_name( Attacker, szName, charsmax( szName ) );

	for(new i;i<KILLT_NUM;i++){
		// check if client already completed achievement
		if( GetClientAchievementStatus( g_pKillT[i], Kills[ Attacker ][i] ) == _In_Progress )
		{
			Kills[Attacker][i]++;
	
			// save objective data to clients steamid
			SetAchievementData( szName, InfoKillT[i][ eKey ], Kills[ Attacker ][i]);

			if( GetClientAchievementStatus( g_pKillT[i], Kills[ Attacker ][i] ) == _Unlocked )
			{
				ClientAchievementCompleted( Attacker, g_pKillT[i] );
			}
		}
	}

	if ( get_pdata_int( Attacker , m_bitsDamageType ) & DMG_GRENADE )
	{
		if( GetClientAchievementStatus( g_pNade, Nade[ Attacker ] ) == _In_Progress )
		{
			Nade[Attacker]++;
	
			// save objective data to clients steamid
			SetAchievementData( szName, InfoNade[ eKey ], Nade[ Attacker ]);

			if( GetClientAchievementStatus( g_pNade, Nade[ Attacker ] ) == _Unlocked )
			{
				ClientAchievementCompleted( Attacker, g_pNade );
			}
		}
	}   
	return HAM_IGNORED;

}


public Forward_ClientEarnedAchievement( const AchiPointer, const Client )
{
	for(new i;i<KILLT_NUM;i++){
		if(AchiPointer == g_pKillT[i]){
			GiveReward(Client, InfoRewardsKillT[i][0], InfoRewardsKillT[i][1]);
		}
	}

	for(new i;i<PLAYT_NUM;i++){
		if(AchiPointer == g_pPlayT[i]){
			GiveReward(Client, InfoRewardsPlayT[i][0], InfoRewardsPlayT[i][1]);
		}
	}

	if(AchiPointer == g_pNade){
		GiveReward(Client, InfoRewardsNade[0], InfoRewardsNade[1]);
	}
}

public GiveReward(id, xp, credits){
	crxranks_give_user_xp(id, xp);
	set_user_credits(id, get_user_credits(id) + credits);
}
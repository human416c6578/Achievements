#include <amxmodx>
#include <hamsandwich>
#include <nvault>
#include <cromchat>

#define DebugMode

enum eStatus
{
	_In_Progress = 0,
	_Unlocked
};

enum eAchievementsStruct
{
	eName[ 64 ],
	eDescription[ 256 ],
	eKey[ 64 ],
	eMaxValue
};

new Array:g_aAchievement;

new g_iVault;

new g_fwClientAchievement;

new g_iCompleted[MAX_PLAYERS];

public plugin_init( )
{
	register_plugin( "Achievement API: Core", "0.1", "MrShark45" );

	register_clcmd("achievements_debug", "PrintAchievements", ADMIN_IMMUNITY);

	g_iVault = nvault_open("Achievements");
	
	g_fwClientAchievement = CreateMultiForward( "Forward_ClientEarnedAchievement", ET_IGNORE, FP_CELL, FP_CELL );
	
	g_aAchievement = ArrayCreate( eAchievementsStruct );

	CC_SetPrefix("&x04[MISIUNI]");
}

public plugin_end( )
{
	ArrayDestroy( g_aAchievement );

	nvault_close( g_iVault );
}

public plugin_natives( )
{
	register_library( "achievement_api" );
	
	register_native( "RegisterAchievement", "_RegisterAchievement" );
	
	register_native( "ClientAchievementCompleted", "_ClientAchievementCompleted" );
	
	register_native( "GetClientAchievementStatus", "_GetClientAchievementStatus" );
	
	register_native( "GetClientAchievementsCompleted", "_GetClientAchievementsCompleted" );
	register_native( "GetMaxAchievements", "_GetMaxAchievements" );
	
	register_native( "GetAchievementKey", "_GetAchievementKey" );
	register_native( "GetAchievementMaxValue", "_GetAchievementMaxValue" );

	register_native( "SetAchievementData", "_SetAchievementData" );
	register_native( "GetAchievementData", "_GetAchievementData" );
}

public _RegisterAchievement( Plugin, Params )
{
	new AchievementData[ eAchievementsStruct ];
	get_string( 1, AchievementData[ eName ], charsmax( AchievementData[ eName ] ) );
	get_string( 2, AchievementData[ eDescription ], charsmax( AchievementData[ eDescription ] ) );
	get_string( 3, AchievementData[ eKey ], charsmax( AchievementData[ eKey ] ) );
	AchievementData[ eMaxValue ] = get_param(4);

	ArrayPushArray( g_aAchievement, AchievementData);

	return (ArraySize(g_aAchievement) - 1);
}

public _ClientAchievementCompleted( Plugin, Params )
{
	new Client = get_param(1);
	new AchievementPointer = get_param(2);

	new AchievementData[eAchievementsStruct];
	ArrayGetArray( g_aAchievement, AchievementPointer, AchievementData );
	
	new szName[64];
	get_user_name( Client, szName, charsmax( szName ) );
	
	CC_SendMessage(0, "&x01Jucatorul &x04%s &x01a completat Achievementul &x07[%s]&x01!", 
	szName, AchievementData[ eName ]);
	
	new iReturn;
	ExecuteForward( g_fwClientAchievement, iReturn, AchievementPointer, Client );
	
}

public eStatus:_GetClientAchievementStatus( Plugin, Params )
{
	new AchievementPointer = get_param( 1 );

	new AchievementData[ eAchievementsStruct ];
	ArrayGetArray( g_aAchievement, AchievementPointer, AchievementData );
	
	if( get_param( 2 ) >= AchievementData[ eMaxValue ] )
	{
		return _Unlocked;
	}
	
	return _In_Progress;
}

public _GetClientAchievementsCompleted( Plugin, Params )
{
	return g_iCompleted[get_param(1)];
}

public _GetMaxAchievements( Plugin, Params )
{
	return ArraySize( g_aAchievement );
}

public _GetAchievementKey( Plugin, Params )
{
	new AchievementPointer = get_param( 1 );
	new AchievementData[ eAchievementsStruct ];
	ArrayGetArray( g_aAchievement, AchievementPointer, AchievementData );
	
	set_string( 2, AchievementData[ eKey ], charsmax( AchievementData[ eKey ] ) );
}

public _GetAchievementMaxValue( Plugin, Params )
{
	new AchievementPointer = get_param( 1 );
	new AchievementData[ eAchievementsStruct ];
	ArrayGetArray( g_aAchievement, AchievementPointer, AchievementData );
	
	return AchievementData[ eMaxValue ];
}

public _SetAchievementData( Plugin, Params )
{
	new szKey[64], szAchKey[64], iValue;
	
	get_string( 1, szKey, charsmax( szKey ) );
	get_string( 2, szAchKey, charsmax( szAchKey ) );
	
	iValue = get_param(3);

	SetAchievementData(szAchKey, szKey, iValue);
}

public _GetAchievementData( Plugin, Params )
{
	new szKey[ 64 ], szAchKey[ 64 ];
	
	get_string( 1, szKey, charsmax( szKey ) );
	get_string( 2, szAchKey, charsmax( szAchKey ) );

	return GetAchievementData(szAchKey, szKey);
}

public client_connect( Client )
{
	g_iCompleted[ Client ] = 0;
	GetClientAchievements( Client );
}

public client_disconnected( Client )
{
	g_iCompleted[ Client ] = 0;
}

public GetAchievementData( szAchKey[], szKey[] ){
	new timestamp;
	new szValue[12], szVaultKey[64], iValue = 0;

	format(szVaultKey, charsmax(szVaultKey), "%s%s", szAchKey, szKey);
	if(nvault_lookup(g_iVault, szVaultKey, szValue, charsmax(szValue), timestamp)){
		iValue = str_to_num(szValue);
	}
	return iValue;
}

public SetAchievementData( szAchKey[], szKey[], iValue ){
	new szValue[12], szVaultKey[64];

	format(szValue, charsmax(szValue), "%d", iValue);
	format(szVaultKey, charsmax(szVaultKey), "%s%s", szAchKey, szKey)

	nvault_set(g_iVault, szVaultKey, szValue);
}

public GetClientAchievements( Client )
{
	new szName[64], szVaultKey[64], szValue[12];
	new AchievementData[eAchievementsStruct];

	get_user_name(Client, szName, charsmax(szName));

	for(new i;i<ArraySize(g_aAchievement);i++){
		ArrayGetArray(g_aAchievement, i, AchievementData);
		format(szVaultKey, charsmax(szVaultKey), "%s%s", AchievementData[eName], szName);
		nvault_get(g_iVault, szVaultKey, szValue, charsmax(szValue));
		if(str_to_num(szValue) >= AchievementData[eMaxValue])
			g_iCompleted[ Client ]++;
	}
}

public PrintAchievements( Client ){
	new AchievementData[eAchievementsStruct], Line[256];
	for(new i;i<ArraySize(g_aAchievement);i++){
		ArrayGetArray(g_aAchievement, i, AchievementData);
		format(Line, charsmax(Line), "[^"%s^", ^"%s^", %d, ^"XP^", ^"Credits^"],", AchievementData[eName], AchievementData[eDescription], AchievementData[eMaxValue]);
		client_print(Client, print_console, Line);
	}
}
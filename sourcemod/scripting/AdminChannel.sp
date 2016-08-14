#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.1"

char gS_Prefix[32];
bool gB_IsInChannel[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[CS:GO] AdminChannel",
	author = "nhnkl159",
	description = "none",
	version = PLUGIN_VERSION,
	url = "https://github.com/nhnkl159/AdminChannel"
};

public void OnPluginStart()
{
	FormatEx(gS_Prefix, 32, "%s\x05[AdminChannel]\x01 ", (GetEngineVersion() == Engine_CSGO)? " ":"");

	RegAdminCmd("sm_adminchannel", Command_AdminChannel, ADMFLAG_CHAT);
	RegAdminCmd("sm_ac", Command_AdminChannel, ADMFLAG_CHAT);

	CreateConVar("sm_adminchannel_version", PLUGIN_VERSION, "Plugin version.", FCVAR_DONTRECORD);
}

public void OnMapStart()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		gB_IsInChannel[i] = false;
	}
}

public Action Command_AdminChannel(int client, int args)
{
	if(client == 0)
	{
		return Plugin_Handled;
	}

	return ShowMenu(client);
}

public Action ShowMenu(int client)
{
	if(!IsClientInGame(client))
	{
		return Plugin_Handled;
	}

	char ChannelFormat[32];
	FormatEx(ChannelFormat, 32, "Admin channel: [%s]", (gB_IsInChannel[client])? "X":"");

	Menu menu = new Menu(AdminMenuHandler);
	menu.SetTitle("Admin channel status:");
	menu.AddItem("", ChannelFormat);
	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int AdminMenuHandler(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		gB_IsInChannel[client] = !gB_IsInChannel[client];
		SetClientVoice(client, gB_IsInChannel[client]);

		if(gB_IsInChannel[client])
		{
			PrintToChat(client, "%sYou have \x07entered\x01 the admin voice channel, you can now hear who is in the admins channel.", gS_Prefix);
		}

		else
		{
			PrintToChat(client, "%sYou have \x07quit\x01 the admin voice channel, you can now hear non-admins.", gS_Prefix);
		}

		ShowMenu(client);
	}

	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public void SetClientVoice(int client, bool adminchannel)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			ListenOverride override = ((adminchannel && gB_IsInChannel[i]) || (!adminchannel && !gB_IsInChannel[i]))? Listen_Yes:Listen_No;

			SetListenOverride(i, client, override);
			SetListenOverride(client, i, override);
		}
	}
}

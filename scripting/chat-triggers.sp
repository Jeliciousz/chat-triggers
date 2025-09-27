#include <sourcemod>
#include <tf2>
#include <morecolors>

#pragma semicolon 1


public Plugin myinfo =
{
	name = "Chat Triggers",
	author = "Jeliciousz",
	description = "Automatically respond to players when they say a specific trigger.",
	version = "0.1.0",
	url = "https://github.com/Jeliciousz/chat-triggers"
};


enum struct ChatTrigger
{
    char trigger[64];
    char response[2048];
}


ArrayList g_alTriggers;
ConVar g_cvFilename;


public void OnPluginStart()
{
    g_cvFilename = CreateConVar("sm_chat_triggers_filename", "chat_triggers.txt", "File containing the chat triggers.");
    g_cvFilename.AddChangeHook(CVChanged_Filename);

    g_alTriggers = new ArrayList(sizeof(ChatTrigger));

    RegServerCmd("sm_chat_triggers_reload", Command_ReloadTriggers, "Reload the chat triggers file.");

    AutoExecConfig(true, "chat-triggers");
}


public void OnConfigsExecuted()
{
    ParseTriggers();
}


public void CVChanged_Filename(ConVar convar, const char[] oldValue, const char[] newValue)
{
    ParseTriggers();
}


public Action Command_ReloadTriggers(int args)
{
    ParseTriggers();
    return Plugin_Handled;
}


void ParseTriggers()
{
    g_alTriggers.Clear();

    char filename[64], filepath[PLATFORM_MAX_PATH];
    g_cvFilename.GetString(filename, sizeof(filename));
    BuildPath(Path_SM, filepath, sizeof(filepath), "configs/%s", filename);

    KeyValues chat_triggers = new KeyValues("ChatTriggers");
    chat_triggers.SetEscapeSequences(true);
    chat_triggers.ImportFromFile(filepath);
    chat_triggers.GotoFirstSubKey();

    ChatTrigger trigger;
    do {
        chat_triggers.GetString("trigger", trigger.trigger, sizeof(ChatTrigger::trigger));
        chat_triggers.GetString("response", trigger.response, sizeof(ChatTrigger::response));
        
        g_alTriggers.PushArray(trigger);
    } while (chat_triggers.GotoNextKey());
    
    delete chat_triggers;
}


public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (!client || IsFakeClient(client))
    {
        return Plugin_Continue;
    }

    for (int i = 0; i < g_alTriggers.Length; i++)
    {
        ChatTrigger trigger;
        g_alTriggers.GetArray(i, trigger);

        char prefix_trigger[65];

        Format(prefix_trigger, sizeof(prefix_trigger), "/%s", trigger.trigger);
        ReplaceString(prefix_trigger, sizeof(prefix_trigger), " ", "_");

        if (StrEqual(sArgs, prefix_trigger, false))
        {
            MC_PrintToChat(client, trigger.response);
            return Plugin_Handled;
        }
    }

    return Plugin_Continue;
}


public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
    if (!client || IsFakeClient(client))
    {
        return;
    }

    for (int i = 0; i < g_alTriggers.Length; i++)
    {
        ChatTrigger trigger;
        g_alTriggers.GetArray(i, trigger);

        char prefix_trigger[64];

        Format(prefix_trigger, sizeof(prefix_trigger), "!%s", trigger.trigger);
        ReplaceString(prefix_trigger, sizeof(prefix_trigger), " ", "_");

        if (StrEqual(sArgs, trigger.trigger, false) || StrEqual(sArgs, prefix_trigger, false))
        {
            MC_PrintToChatAll(trigger.response);
            return;
        }
    }
}

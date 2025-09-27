# Chat Triggers

A SourceMod plugin for configuring automatic chat responses in your server.

`sm_chat_triggers_filename` (def: "chat_triggers.txt")

The name of the file that contains your chat triggers. (Located in addons/sourcemod/configs/)

`sm_chat_triggers_reload`
Command to reload the chat triggers file.

The chat_triggers.txt file looks like this:

```
ChatTriggers
{
    Trigger1
    {
        "trigger"       "trigger1"
        "response"      "This is a chat trigger."
    }
    Trigger2
    {
        "trigger"       "trigger2"
        "response"      "This is another trigger, I can have {red}c{orange}o{yellow}l{green}o{blue}r{purple}s{default}!"
    }
    ThisCanBeLiterallyAnything
    {
        "trigger"       "funny number"
        "response"      "{green}420"
    }
}
```

`"trigger"` is the phrase that the plugin is looking for in a chat message.

It'll match on just the exact phrase, the phrase prefixed with '!', and, if the phrase is prefixed with '/', it won't send the player's chat message to the rest of the server and only they will see the response.

If there are any spaces in `"trigger"`'s value, they'll have to be replaced with underscores '_' to be triggered with a prefix like '!' or '/'.

`"response"` is what the plugin will respond with, sending the response to the whole server, or just the player that triggered it, if they used the '/' prefix.

This plugin uses morecolors to allow colored responses.

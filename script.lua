--- Creating module
local function new(type, parent)
    if type then
        if parent then
            return Instance.new(type, parent)
        else
            return Instance.new(type)
        end
    end
end





local MODULES = {}
local OLD_REQUIRE = require

local function require(ModuleScript: ModuleScript)
    local ModuleState = MODULES[ModuleScript]


    if ModuleState then
        if not ModuleState.Required then
            ModuleState.Required = true
            ModuleState.Value = ModuleState.Closure()
        end

        return ModuleState.Value
    end


    return OLD_REQUIRE(ModuleScript)
end







local RobloxDevKit = new('Folder', game:GetService('CoreGui'))
RobloxDevKit.Name = 'RobloxDevKit'


local RobloxGameFolder = new('ModuleScript', RobloxDevKit)
RobloxGameFolder.Name = 'Game-Source'




local ChatManager = new('ModuleScript', RobloxGameFolder)
ChatManager.Name = 'ChatManager'

local ChatWindowModule = new('ModuleScript', ChatManager)
ChatWindowModule.Name = 'ChatWindowManager'


local ChatVersionManager = new('ModuleScript', ChatManager)
ChatVersionManager.Name = 'Chat-Version'


local OldChatManager = new('ModuleScript', ChatVersionManager)
OldChatManager.Name = 'Legacy-Chat-Service'

local TextChatManager = new('ModuleScript', ChatVersionManager)
TextChatManager.Name = 'TextChatService-Chat-Service'



MODULES[TextChatManager] = {
    ['Closure'] = function()
        local script = TextChatManager
        local TextChatService = game:GetService('TextChatService')


        --- THANK U SO MUCH TO THE VAPE DEV / 7GrandDad FOR SHOWING ME HOW TO DO THIS, CODE IN:
        --- https://github.com/7GrandDadPGN/VapeV4ForRoblox/blob/main/Universal.lua#L373



        local ChatInputBar = TextChatService:WaitForChild('ChatInputBarConfiguration')





        local module = {}


        module.SendPlayerMessage = function(message: string)
            ChatInputBar:WaitForChild('TargetTextChannel'):SendAsync(message)
        end


        module.SendWhisperToPlayer = function(PlayerUserId: number, message: string)
            local oldChannel = ChatInputBar:WaitForChild('TargetTextChannel')
            local newChannel = cloneref(game:GetService('RobloxReplicatedStorage')).ExperienceChat:WaitForChild('WhisperChat'):InvokeServer(PlayerUserId)

            if newChannel then
                newChannel:SendAsync(message)
            end

            ChatInputBar.TargetTextChannel = oldChannel
        end


        module.SendChatMessage = function(message)
            local RBXGeneral = TextChatService:WaitForChild('TextChannels'):WaitForChild('RBXGeneral')


            if RBXGeneral then
                RBXGeneral:DisplaySystemMessage(message)
            end
        end





        return module
    end
}



MODULES[OldChatManager] = {
    ['Closure'] = function()
        local script = OldChatManager
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local TextChatService = game:GetService('TextChatService')
        local StarterGui = game:GetService('StarterGui')
        local Players = game:GetService('Players')


        local DefaultChatSystemChatEvents = ReplicatedStorage:WaitForChild('DefaultChatSystemChatEvents')






        local module = {}


        module.SendPlayerMessage = function(message)
            local SayMessageRequest = DefaultChatSystemChatEvents:WaitForChild('SayMessageRequest')

            SayMessageRequest:FireServer(message)
        end


        module.SendWhisperToPlayer = function(PlayerUserId: number, message: string)
            local SayMessageRequest = DefaultChatSystemChatEvents:WaitForChild('SayMessageRequest')
            local Player = Players:GetPlayerByUserId(PlayerUserId)


            local args = {
                [1] = message,
                [2] = 'To '..Player.Name
            }


            SayMessageRequest:FireServer(unpack(args))
        end

        

        module.SendChatMessage = function(message, Color, Font, TextSize)
            local Text = message or 'nil'


            local args = {
                [1] = {
                    Text = Text,
                    Color = '#'..Color3.new(1, 1, 1):ToHex(),
                    Font = Font.Name or Enum.Font.Arial.Name,
                    TextSize = TextSize or 18
                }
            }


            StarterGui:SetCore('ChatMakeSystemMessage', unpack(args))
        end



    
        return module
    end
}




local CommandsUsedAlready = {}


MODULES[ChatManager] = {
    ['Closure'] = function()
        local script = ChatManager
        local TextChatService = game:GetService('TextChatService')

        local LegacyChatService = require(script['Chat-Version']['Legacy-Chat-Service'])
        local TextChatService_Module = require(script['Chat-Version']['TextChatService-Chat-Service'])
        local Players = game:GetService('Players')



        local module = {}



        module.SendChatMessage = function(message)
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                TextChatService_Module.SendChatMessage(message)
            elseif TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
                LegacyChatService.SendChatMessage(message)
            end
        end


        module.SendPlayerMessage = function(message)
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                TextChatService_Module.SendPlayerMessage(message)
            elseif TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
                LegacyChatService.SendPlayerMessage(message)
            end
        end


        module.SendWhisperToPlayer = function(PlayerUserId: number, message: string)
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                TextChatService_Module.SendWhisperToPlayer(PlayerUserId, message)
            elseif TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
                LegacyChatService.SendWhisperToPlayer(PlayerUserId, message)
            end
        end



        module.AddCommand = function(Name, Callback)
            local Name = Name or ''
            local Callback = Callback or function() print('Hello World') end



            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local Command = new('TextChatCommand', TextChatService:WaitForChild('TextChatCommands'))


                Command.Name = Name
                Command.PrimaryAlias = Name
                Command.Triggered:Connect(Callback)
            elseif TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
                Players.LocalPlayer.Chatted:Connect(function(a, b)
                    local Command = a:split(' ')


                    if not table.find(CommandsUsedAlready, Name) then
                        CommandsUsedAlready[Name] = Callback
                    end


                    if table.find(CommandsUsedAlready, Command[1]) then
                        CommandsUsedAlready[Command[1]]()
                    end
                end)
            end
        end



        return module
    end
}



local RobloxScriptPrimissions_Folder = new('Folder', RobloxGameFolder)
RobloxScriptPrimissions_Folder.Name = 'Roblox-Primissions-Folder'



local RobloxPrimissionsModule = new('ModuleScript', RobloxScriptPrimissions_Folder)
RobloxPrimissionsModule.Name = 'Roblox-Primissions-Storage'


MODULES[RobloxPrimissionsModule] = {
    ['Closure'] = function()
        local script = RobloxPrimissionsModule
        local UserInputService = game:GetService('UserInputService')
        local StarterGui = game:GetService('StarterGui')



        local module = {}



        module.ToggleDevConsole = function(open: boolean)
            StarterGui:SetCore('DevConsoleVisible', ((type(open) == 'boolean') or (not StarterGui:GetCore('DevConsoleVisible'))))
        end


        module.SendNotification = function(Title, Text, Icon, Duration, Callback, Button1, Button2)
            StarterGui:SetCore('SendNotification', {
                Title = (Title or 'nil'),
                Text = (Text or 'nil'),
                Icon = (Icon),
                Duration = (Duration),
                Callback = (Callback),
                Button1 = (Button1),
                Button2 = (Button2)
            })
        end


        return module
    end
}



local MainScripts_Folder = new('Folder', RobloxGameFolder)
MainScripts_Folder.Name = 'Main-Scripts-Folder'



local ChatCommandsHandler = new('LocalScript', MainScripts_Folder)
ChatCommandsHandler.Name = 'Commands-Handler'


local function Spawn_ChatCommandsHandler()
    local script = ChatCommandsHandler
    local RobloxScriptPrimissions_Module = require(script.Parent['Roblox-Primissions-Folder']['Roblox-Primissions-Storage'])
    local ChatManager = require(script.Parent['ChatManager'])
end


spawn(Spawn_ChatCommandsHandler)









-- loadstring(game:HttpGet('https://raw.githubusercontent.com/SubnauticaLaserMain/RobloxDevKit-Executor-Version/main/script.lua', true))()

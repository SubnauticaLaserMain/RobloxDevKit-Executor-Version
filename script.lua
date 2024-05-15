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

        local DefaultChatSystemChatEvents = ReplicatedStorage:WaitForChild('DefaultChatSystemChatEvents')






        local module = {}


        module.SendPlayerMessage = function(message)
            local SayMessageRequest = DefaultChatSystemChatEvents:WaitForChild('SayMessageRequest')

            SayMessageRequest:FireServer(message)
        end



        






        return module
    end
}

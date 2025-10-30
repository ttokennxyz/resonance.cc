getgenv().VisualsTabCreated = false
getgenv().window = nil

loadstring(game:HttpGet('https://luauth.com/api/scripts/project_d550e6e6dbd2afed/loader', true))(); -- main script, sets UILoaded to true and yields until VisualsTabCreated is true

repeat task.wait() until getgenv().window ~= nil

loadstring(game:HttpGet('https://raw.githubusercontent.com/ttokennxyz/resonance.cc/refs/heads/main/visuals.lua'))(); -- ESP script, sets VisualsTabCreated to true

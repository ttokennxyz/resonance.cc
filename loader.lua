getgenv().VisualsTabCreated = false

task.spawn(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ttokennxyz/resonance.cc/refs/heads/main/visuals.lua'))(); -- ESP script, sets VisualsTabCreated to true
end)

loadstring(game:HttpGet('https://luauth.com/api/scripts/project_2a59ad1fda8ef46e/loader', true))(); -- main script, sets UILoaded to true and yields until VisualsTabCreated is true

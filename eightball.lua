--[[
    GameSense 8BALL
    - This allows you to get answers to questions.
]]

local tab, container = 'LUA', 'B'

local answers = {
    'Yes - definitely.',
    'It is decidedly so.',
    'Without a doubt.',
    'Reply hazy, try again.',
    'Ask again later.',
    'Better not tell you now.',
    'My sources say no.',
    'Outlook not so good.',
    'Very doubtful.'
}

local _ = ui.new_label(tab, container, 'GameSense 8BALL')
local _ = ui.new_label(tab, container, 'Question')
local question = ui.new_textbox(tab, container, 'Question')

local button = ui.new_button(tab, container, 'Shake Eight Ball', function()
    local response = answers[math.random(1, 9)]

    if string.len(ui.get(question)) > 3 then
        print(string.format('Question: %s, Answer: %s', ui.get(question), response))
    else
        print('You must ask the ball a question for a response.')
    end
end)

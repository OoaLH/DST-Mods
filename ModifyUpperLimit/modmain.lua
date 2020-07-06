local require = GLOBAL.require
require 'constants'
require 'tuning'
local change_all = GetModConfigData('CHANGE ALL')
local characters = {"WILSON", "WILLOW", "WENDY", "WOLFGANG", "WICKERBOTTOM", "WES", "WAXWELL", "WOODIE", "WATHGRITHR", "WEBBER", "WINONA", "WORTOX", "WORMWOOD", "WARLY", "WURT", "WALTER"}
local character_status = {}
for i = 1, #characters do
    character_status[i] = GetModConfigData(characters[i])
end
local calories_per_day = 150
TUNING.HEALING_TINY = 30
TUNING.HEALING_SMALL = 40
TUNING.HEALING_MEDSMALL = 50
TUNING.HEALING_MED = 60
TUNING.HEALING_MEDLARGE = 70
TUNING.HEALING_LARGE = 80
TUNING.HEALING_HUGE = 90
TUNING.SANITY_SUPERTINY = 40
TUNING.SANITY_TINY = 50
TUNING.SANITY_SMALL = 60
TUNING.SANITY_MED = 70
TUNING.SANITY_MEDLARGE = 80
TUNING.SANITY_LARGE = 90
TUNING.SANITY_HUGE = 100
TUNING.SANITY_BECOME_SANE_THRESH = 35/400
TUNING.SANITY_BECOME_INSANE_THRESH = 30/400
TUNING.SANITY_BECOME_ENLIGHTENED_THRESH = 170/400
TUNING.SANITY_LOSE_ENLIGHTENMENT_THRESH = 165/400
TUNING.CALORIES_TINY = calories_per_day/8 -- berries
TUNING.CALORIES_SMALL = calories_per_day/6 -- veggies
TUNING.CALORIES_MEDSMALL = calories_per_day/4
TUNING.CALORIES_MED = calories_per_day/3 -- meat
TUNING.CALORIES_LARGE = calories_per_day/2 -- cooked meat
TUNING.CALORIES_HUGE = calories_per_day -- crockpot foods?
TUNING.CALORIES_SUPERHUGE = calories_per_day*2 -- crockpot foods?
--TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WEBBER = {"spidereggsack", "monstermeat", "monstermeat", "torch"}
if change_all==false then 
    for i = 1, #characters do
        table.insert( TUNING['GAMEMODE_STARTING_ITEMS']['DEFAULT'][characters[i]], "torch" )
        table.insert( TUNING['GAMEMODE_STARTING_ITEMS']['DEFAULT'][characters[i]], "earmuffshat" )
        if character_status[i]~=false then
            TUNING[characters[i]..'_HEALTH'] = character_status[i]
            TUNING[characters[i]..'_SANITY'] = character_status[i]
            TUNING[characters[i]..'_HUNGER'] = character_status[i]
        end
    end
else
    for i = 1, #characters do
        table.insert( TUNING['GAMEMODE_STARTING_ITEMS']['DEFAULT'][characters[i]], "torch" )
        table.insert( TUNING['GAMEMODE_STARTING_ITEMS']['DEFAULT'][characters[i]], "earmuffshat" )
        TUNING[characters[i]..'_HEALTH'] = change_all
        TUNING[characters[i]..'_SANITY'] = change_all
        TUNING[characters[i]..'_HUNGER'] = change_all
    end
end

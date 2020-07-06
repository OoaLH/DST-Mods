local require = GLOBAL.require
require 'constants'
require 'tuning'
local change_all = GetModConfigData('CHANGE ALL')
local charactors = {"WILSON", "WILLOW", "WENDY", "WOLFGANG", "WICKERBOTTOM", "WES", "WAXWELL", "WOODIE", "WATHGRITHR", "WEBBER", "WINONA", "WORTOX", "WORMWOOD", "WARLY", "WURT", "WALTER"}
local charactor_status = {}
for i = 1, #charactors do
    charactor_status[i] = GetModConfigData(charactors[i])
end
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
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WEBBER = {"spidereggsack", "monstermeat", "monstermeat", "torch"}
if change_all==false then 
    for i = 1, #charactors do
        if charactor_status[i]~=false then
            TUNING[charactors[i]..'_HEALTH'] = charactor_status[i]
            TUNING[charactors[i]..'_SANITY'] = charactor_status[i]
            TUNING[charactors[i]..'_HUNGER'] = charactor_status[i]
        end
    end
else
    for i = 1, #charactors do
        TUNING[charactors[i]..'_HEALTH'] = change_all
        TUNING[charactors[i]..'_SANITY'] = change_all
        TUNING[charactors[i]..'_HUNGER'] = change_all
    end
end

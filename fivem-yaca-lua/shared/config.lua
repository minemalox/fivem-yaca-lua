Settings = {
    -- Voice range in meters
    VoiceRanges = {
        [1] = 1,
        [2] = 3,
        [3] = 8,
        [4] = 15,
        [5] = 20,
        [6] = 25,
        [7] = 30,
        [8] = 40,
    },

    -- Max range for phone speaker in meters
    MaxPhoneSpeekerRange = 5,

    --[[ 
        * default are 2 meters
        * if the value is set to -1, the player voice range is taken
        * if the value is >= 0, you can set the max muffling range before it gets completely cut off
    ]]
    mufflingRange = 2,

    unmuteDelay = 400,
}

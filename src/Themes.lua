local Types = require(script.Parent.Types)

return table.freeze({
    Obsidian = {
        schemeColor = Color3.fromRGB(74, 99, 135),
        background = Color3.fromRGB(36, 37, 43),
        header = Color3.fromRGB(28, 29, 34),
        textColor = Color3.fromRGB(255,255,255),
        elementColor = Color3.fromRGB(32, 32, 38)
    },

    Dark = {
        schemeColor = Color3.fromRGB(64, 64, 64),
        background = Color3.fromRGB(0, 0, 0),
        header = Color3.fromRGB(0, 0, 0),
        textColor = Color3.fromRGB(255,255,255),
        elementColor = Color3.fromRGB(20, 20, 20)
    },

    Light = {
        schemeColor = Color3.fromRGB(150, 150, 150),
        background = Color3.fromRGB(255,255,255),
        header = Color3.fromRGB(200, 200, 200),
        textColor = Color3.fromRGB(0,0,0),
        elementColor = Color3.fromRGB(224, 224, 224)
    },

    Blood = {
        schemeColor = Color3.fromRGB(227, 27, 27),
        background = Color3.fromRGB(10, 10, 10),
        header = Color3.fromRGB(5, 5, 5),
        textColor = Color3.fromRGB(255,255,255),
        elementColor = Color3.fromRGB(20, 20, 20)
    },

    Grape = {
        schemeColor = Color3.fromRGB(166, 71, 214),
        background = Color3.fromRGB(64, 50, 71),
        header = Color3.fromRGB(36, 28, 41),
        textColor = Color3.fromRGB(255,255,255),
        elementColor = Color3.fromRGB(74, 58, 84)
    },

    Ocean = {
        schemeColor = Color3.fromRGB(86, 76, 251),
        background = Color3.fromRGB(26, 32, 58),
        header = Color3.fromRGB(38, 45, 71),
        textColor = Color3.fromRGB(200, 200, 200),
        elementColor = Color3.fromRGB(38, 45, 71)
    },

    Midnight = {
        schemeColor = Color3.fromRGB(26, 189, 158),
        background = Color3.fromRGB(44, 62, 82),
        header = Color3.fromRGB(57, 81, 105),
        textColor = Color3.fromRGB(255, 255, 255),
        elementColor = Color3.fromRGB(52, 74, 95)
    },

    Sentinel = {
        schemeColor = Color3.fromRGB(230, 35, 69),
        background = Color3.fromRGB(32, 32, 32),
        header = Color3.fromRGB(24, 24, 24),
        textColor = Color3.fromRGB(119, 209, 138),
        elementColor = Color3.fromRGB(24, 24, 24)
    },

    Synapse = {
        schemeColor = Color3.fromRGB(46, 48, 43),
        background = Color3.fromRGB(13, 15, 12),
        header = Color3.fromRGB(36, 38, 35),
        textColor = Color3.fromRGB(152, 99, 53),
        elementColor = Color3.fromRGB(24, 24, 24)
    },

    Serpent = {
        schemeColor = Color3.fromRGB(0, 166, 58),
        background = Color3.fromRGB(31, 41, 43),
        header = Color3.fromRGB(22, 29, 31),
        textColor = Color3.fromRGB(255,255,255),
        elementColor = Color3.fromRGB(22, 29, 31)
    },
}) :: { [string]: Types.Theme }

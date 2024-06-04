rule = {
    matches = {
        {
            { "device.bus-path", "equals", "platform-hdmi0-sound" },
        },
    },
    apply_properties = {
        ["device.description"] = "HDMI",
        ["node.description"] = "HDMI",
    },
}

table.insert(alsa_monitor.rules,rule)

rule = {
    matches = {
        {
            { "alsa.card_name", "equals", "rockchip-hdmi0" },
        },
    },
    apply_properties = {
        ["priority.driver"] = "1500",
        ["priority.session"] = "1500",
    },
}

table.insert(alsa_monitor.rules,rule)

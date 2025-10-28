rule = {
    matches = {
        {
            { "device.bus-path", "equals", "platform-sound-micarray" },
        },
    },
    apply_properties = {
        ["device.description"] = "DMIC",
        ["node.description"] = "DMIC",
    },
}

table.insert(alsa_monitor.rules,rule)

rule = {
    matches = {
        {
            { "alsa.card_name", "equals", "rockchip,sound-micarray" },
        },
    },
    apply_properties = {
        ["priority.driver"] = "2500",
        ["priority.session"] = "2500",
    },
}

table.insert(alsa_monitor.rules,rule)

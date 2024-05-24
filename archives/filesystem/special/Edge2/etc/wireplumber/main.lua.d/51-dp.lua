rule = {
    matches = {
        {
            { "device.bus-path", "equals", "platform-dp0-sound" },
        },
    },
    apply_properties = {
        ["device.description"] = "DP",
        ["node.description"] = "DP",
    },
}

table.insert(alsa_monitor.rules,rule)

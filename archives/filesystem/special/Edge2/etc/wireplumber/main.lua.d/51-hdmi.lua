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

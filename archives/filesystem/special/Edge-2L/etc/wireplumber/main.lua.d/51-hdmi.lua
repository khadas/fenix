rule = {
    matches = {
        {
            { "device.bus-path", "equals", "platform-hdmi-sound" },
        },
    },
    apply_properties = {
        ["device.description"] = "HDMI",
        ["node.description"] = "HDMI",
    },
}

table.insert(alsa_monitor.rules,rule)

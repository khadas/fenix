rule = {
    matches = {
        {
            { "device.bus-path", "equals", "platform-es8316-sound" },
        },
    },
    apply_properties = {
        ["device.description"] = "ES8316 Codec",
        ["node.description"] = "ES8316 Codec",
    },
}

table.insert(alsa_monitor.rules,rule)

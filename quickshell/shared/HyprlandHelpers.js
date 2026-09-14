.pragma library

function appLabel(appId) {
    var names = {
        "com.mitchellh.ghostty": "Ghostty",
        "chromium": "Chromium",
    }
    return names[appId] ?? appId
}

function networkIcon(networkType, signal) {
    if (networkType === "ethernet") return "󰈀"
    if (networkType !== "wifi") return "󰤭"
    var level = Number(signal ?? 0)
    if (level <= 0) return "󰢿"
    if (level >= 50) return "󰢾"
    if (level >= 25) return "󰢽"
    return "󰢼"
}

function workspaceFor(workspaces, id) {
    for (var workspace of workspaces) {
        if (workspace.id === id) return workspace
    }
    return null
}

function workspaceOccupied(workspaces, id) {
    var workspace = workspaceFor(workspaces, id)
    return workspace !== null && (workspace.toplevels?.values?.length ?? 0) > 0
}

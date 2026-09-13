import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

// Auto-brightness switch for the imac-patcher `autobright` module. The icon is
// bright while wluma (the user service that follows the light sensor) runs, and
// dimmed while it doesn't; a click enables or disables the service, so the
// choice survives a reboot. What wluma learned is kept either way.
BarWidget {
  id: root
  moduleName: "imac.autobright"

  property bool autoOn: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() { if (!stateProc.running) stateProc.running = true }
  function toggle() {
    if (toggleProc.running) return
    root.autoOn = !root.autoOn   // show the new state at once; refresh() confirms it
    toggleProc.command = ["systemctl", "--user", root.autoOn ? "enable" : "disable", "--now", "wluma.service"]
    toggleProc.running = true
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰃡"
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    dimmed: !root.autoOn
    useActiveColor: false
    onPressed: root.toggle()
    tooltipText: root.autoOn ? "Auto-brightness on: follows the room's light (click to turn off)"
                         : "Auto-brightness off (click to turn on)"
  }

  Process {
    id: stateProc
    command: ["systemctl", "--user", "is-active", "--quiet", "wluma.service"]
    onExited: (exitCode, exitStatus) => root.autoOn = exitCode === 0
  }

  Process {
    id: toggleProc
    onExited: root.refresh()
  }

  // The service can also change from the patcher or a terminal; a slow poll
  // keeps the icon honest without doing anything costly.
  Timer {
    interval: 15000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}

import QtQuick
import Quickshell
import Quickshell.Io

// Controller for the Command Code agents-panel record. The panel only ever
// reads the JSON record this writes; this item exists so it regenerates on a
// timer without a system-wide `omarchy agent usage-update` run.
Item {
  id: controller

  property var manifest: null
  property var shell: null

  // Resolved from this file's own location: "ui/main.qml" -> plugin root.
  readonly property string pluginDir: {
    var url = Qt.resolvedUrl("..")
    return String(url).replace(/^file:\/\//, "").replace(/\/$/, "")
  }

  readonly property string collectorPath: pluginDir + "/bin/commandcode-collect"
  readonly property int refreshMs: 300000
  property bool running: false

  Timer {
    interval: controller.refreshMs
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: controller.collect()
  }

  function collect() {
    if (controller.running) return
    controller.running = true
    proc.command = ["/usr/bin/env", "python3", controller.collectorPath, "--write"]
    proc.running = true
  }

  Process {
    id: proc
    stdout: StdioCollector { }
    stderr: StdioCollector { id: stderr }
    onExited: function(code) {
      controller.running = false
      var message = stderr.text.trim()
      if (code !== 0 || message)
        console.warn("commandcode", code !== 0 ? "exit " + code : message)
    }
  }
}

import QtQuick 2.0
import QtQuick.Controls 1.2

Rectangle {
    id: gameOfLifeRoot

    property alias running: stepTimer.running
    property int columnCount: 100
    property int rowCount: 100
    property var cells: [[]]
    property var cellsNext: [[]]
    property var trace: [[]]

    width: 100
    height: 62

    function reset() {
        for(var i = 0; i < rowCount; i++) {
            cells[i] = []
            cellsNext[i] = []
            trace[i] = []
            for(var j = 0; j < columnCount; j++) {
                cells[i][j] = 0
                cellsNext[i][j] = 0
                trace[i][j] = 255
            }
        }
    }

    function step() {
        for(var i = 0; i < rowCount; i++) {
            for(var j = 0; j < columnCount; j++) {
                var liveNeighbors = 0
                for(var di = -1; di < 2; di++) {
                    var ni = i + di
                    if(ni < 0) {
                        ni = 1
                    }
                    if(ni > rowCount - 1) {
                        ni = rowCount - 2
                    }
                    for(var dj = -1; dj < 2; dj++) {
                        var nj = j + dj
                        if(nj < 0) {
                            nj = 1
                        }
                        if(nj > columnCount - 1) {
                            nj = columnCount - 2
                        }
                        if(di == 0 && dj == 0) {
                            continue
                        }
                        liveNeighbors += cells[ni][nj]
                    }
                }
                if(cells[i][j] === 1) {
                    if(liveNeighbors < 2) {
                        cellsNext[i][j] = 0
                    } else if(liveNeighbors == 2 || liveNeighbors == 3) {
                        cellsNext[i][j] = 1
                    } else {
                        cellsNext[i][j] = 0
                    }
                } else {
                    if(liveNeighbors === 3) {
                        cellsNext[i][j] = 1
                    } else {
                        cellsNext[i][j] = 0
                    }
                }
                if(cells[i][j] === 1) {
                    trace[i][j] = 150
                } else {
                    trace[i][j] = Math.min(255, trace[i][j] + 1)
                }
            }
        }

        var tmp = cells
        cells = cellsNext
        cellsNext = tmp
        canvas.requestPaint()
    }

    Component.onCompleted: {
        reset()
        canvas.requestPaint()
    }

    onWidthChanged: {
        console.log(gameOfLifeRoot.width / columnCount)
    }

    Canvas {
        id: canvas

        width: columnCount
        height: rowCount

        anchors.centerIn: parent

        transformOrigin: Item.Center

        smooth: false
        antialiasing: false

        scale: Math.min(1.0 * gameOfLifeRoot.width / columnCount, 1.0 * gameOfLifeRoot.height / rowCount)

        onScaleChanged: {
            console.log("Scale: " + scale)
        }

        onPaint: {
            var ctx = canvas.getContext("2d")
            ctx.save();
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            var imageData = ctx.createImageData(rowCount, columnCount)

            var data = imageData.data

            for(var i = 0; i < rowCount; i++) {
                for(var j = 0; j < columnCount; j++) {
                    var index = i*columnCount*4 + j*4

                    var value = 255
                    if(cells[i][j] === 1) {
                        value = 0
                    } else {
                        value = trace[i][j]
                    }

                    data[index + 0] = value
                    data[index + 1] = value
                    data[index + 2] = value
                    data[index + 3] = 255
                }
            }
            ctx.drawImage(imageData, 0, 0)

            ctx.restore();
        }
    }

    MouseArea {
        anchors.fill: parent

        function toggleSite(mouse) {
            var pos = mapToItem(canvas, mouse.x, mouse.y)
            var i = parseInt(pos.y)
            var j = parseInt(pos.x)
            if(i > 0 && j > 0 && i < rowCount - 1 && j < columnCount - 1) {
                cells[i][j] = 1
                canvas.requestPaint()
            }
        }

        onPressed: {
            toggleSite(mouse)
        }

        onPositionChanged: {
            toggleSite(mouse)
        }
    }

    Button {
        text: running ? "Pause" : "Play"
        onClicked: running = !running
    }

    Timer {
        id: stepTimer
        repeat: true
        running: false
        interval: 100
        onTriggered: {
            step()
        }
    }
}


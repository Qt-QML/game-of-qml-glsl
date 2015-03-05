import QtQuick 2.0

Rectangle {
    width: 100
    height: 62

    Rectangle {
        id: rect
        anchors.fill: parent
        color: "black"
    }

    ShaderEffectSource {
        id: effectSource
        width: 100
        height: 100
        sourceItem: rect
        recursive: true
    }

    ShaderEffect {
        id: effect
        property real time: 0
        property vector2d resolution: Qt.vector2d(width, height)
        property vector2d mouse: Qt.vector2d(50, 50)
        property var backbuffer: effectSource

        anchors.fill: parent

        width: 100
        height: 100
        fragmentShader: "
            // adapted from http://glsl.herokuapp.com/e#207.3
            uniform float time;
            uniform vec2 mouse;
            uniform vec2 resolution;
            uniform sampler2D backbuffer;

            vec4 live = vec4(0.5,1.0,0.7,1.);
            vec4 dead = vec4(0.,0.,0.,1.);
            vec4 blue = vec4(0.,0.,1.,1.);

            void main( void ) {
                vec2 position = ( gl_FragCoord.xy / resolution.xy );
                vec2 mousePosition = (mouse.xy / resolution.xy);
                mousePosition.y = 1.0 - mousePosition.y;
                vec2 pixel = 1./resolution;

                if (length(position-mousePosition) < 0.02) {
                    float rnd1 = mod(fract(sin(dot(position + time * 0.001, vec2(14.9898,78.233))) * 43758.5453), 1.0);
                    if (rnd1 > 0.5) {
                        gl_FragColor = live;
                    } else {
                        gl_FragColor = blue;
                    }
                } else {
                    float sum = 0.;
                    sum += texture2D(backbuffer, position + pixel * vec2(-1., -1.)).g;
                    sum += texture2D(backbuffer, position + pixel * vec2(-1., 0.)).g;
                    sum += texture2D(backbuffer, position + pixel * vec2(-1., 1.)).g;
                    sum += texture2D(backbuffer, position + pixel * vec2(1., -1.)).g;
                    sum += texture2D(backbuffer, position + pixel * vec2(1., 0.)).g;
                    sum += texture2D(backbuffer, position + pixel * vec2(1., 1.)).g;
                    sum += texture2D(backbuffer, position + pixel * vec2(0., -1.)).g;
                    sum += texture2D(backbuffer, position + pixel * vec2(0., 1.)).g;
                    vec4 me = texture2D(backbuffer, position);

                    if (me.g <= 0.1) {
                        if ((sum >= 2.9) && (sum <= 3.1)) {
                            gl_FragColor = live;
                        } else if (me.b > 0.004) {
                            gl_FragColor = vec4(0., 0., max(me.b - 0.004, 0.25), 1.);
                        } else {
                            gl_FragColor = dead;
                        }
                    } else {
                        if ((sum >= 1.9) && (sum <= 3.1)) {
                            gl_FragColor = live;
                        } else {
                            gl_FragColor = blue;
                        }
                    }
                }
            }
        "
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: {
            effect.mouse.x = mouse.x
            effect.mouse.y = mouse.y
        }
    }

    Timer {
        id: stepTimer
        running: true
        repeat: true
        interval: 100
        onTriggered: {
            effectSource.update()
            effect.update()
            effect.time += 1
            effectSource.sourceItem = effect
        }
    }
}


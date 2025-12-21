import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 960
    height: 640
    minimumWidth: 800
    minimumHeight: 600
    color: theme.backgroundColor
    title: "StudyMoney Desktop"

    property var categories: ["Еда", "Транспорт", "Учеба", "Развлечения", "Одежда", "Здоровье", "Жилье", "Другое"]
    property var catColors: ["#f87171", "#fb923c", "#facc15", "#4ade80", "#60a5fa", "#a78bfa", "#e879f9", "#94a3b8"]

    QtObject {
        id: theme
        property bool isDark: true
        property color backgroundColor: "#0f172a" 
        property color sidebarColor:    "#020617" 
        property color cardColor:       "#1e293b" 
        property color hoverColor:      "#334155" 
        property color accentColor:     "#3b82f6" 
        property color textColor:       "#f8fafc"
        property color subTextColor:    "#94a3b8"
        property color borderColor:     "#334155"
        property color incomeColor:     "#10b981"
        property color expenseColor:    "#ef4444"
    }

    component VectorIcon: Canvas {
        property string name
        property color color: "white"
        width: 24; height: 24
        antialiasing: true
        onNameChanged: requestPaint()
        onColorChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d"); ctx.reset();
            ctx.strokeStyle = color; ctx.fillStyle = color; ctx.lineWidth = 2; ctx.lineCap = "round"; ctx.lineJoin = "round";
            if (name === "dashboard") {
                ctx.strokeRect(3, 3, 8, 8); ctx.strokeRect(13, 3, 8, 8); ctx.strokeRect(3, 13, 8, 8); ctx.strokeRect(13, 13, 8, 8);
                if (color == theme.accentColor) ctx.fillRect(3, 3, 8, 8);
            } else if (name === "list") {
                ctx.strokeRect(4, 3, 16, 18); ctx.beginPath(); ctx.moveTo(8, 8); ctx.lineTo(16, 8); ctx.moveTo(8, 12); ctx.lineTo(16, 12); ctx.moveTo(8, 16); ctx.lineTo(13, 16); ctx.stroke();
            } else if (name === "wallet") {
                ctx.beginPath(); ctx.rect(2, 6, 20, 12); ctx.stroke(); ctx.beginPath(); ctx.arc(12, 12, 3, 0, Math.PI*2); ctx.stroke(); ctx.beginPath(); ctx.arc(5, 12, 1, 0, Math.PI*2); ctx.fill(); ctx.beginPath(); ctx.arc(19, 12, 1, 0, Math.PI*2); ctx.fill();
            } else if (name === "chart") {
                ctx.beginPath(); ctx.moveTo(2, 20); ctx.lineTo(22, 20); ctx.moveTo(6, 20); ctx.lineTo(6, 12); ctx.moveTo(12, 20); ctx.lineTo(12, 6); ctx.moveTo(18, 20); ctx.lineTo(18, 14); ctx.stroke();
            } else if (name === "target") {
                ctx.beginPath(); ctx.arc(12, 12, 8, 0, Math.PI*2); ctx.stroke(); ctx.beginPath(); ctx.arc(12, 12, 4, 0, Math.PI*2); ctx.stroke(); ctx.beginPath(); ctx.arc(12, 12, 1, 0, Math.PI*2); ctx.fill();
            } else if (name === "idea") {
                ctx.beginPath(); ctx.arc(12, 9, 5, Math.PI, 0); ctx.stroke(); ctx.beginPath(); ctx.moveTo(7, 9); ctx.lineTo(10, 15); ctx.lineTo(14, 15); ctx.lineTo(17, 9); ctx.stroke(); ctx.fillRect(10, 15, 4, 3);
            } else if (name === "exit") {
                ctx.beginPath(); ctx.moveTo(10, 5); ctx.lineTo(19, 5); ctx.lineTo(19, 19); ctx.lineTo(10, 19); ctx.stroke(); ctx.beginPath(); ctx.moveTo(10, 12); ctx.lineTo(2, 12); ctx.stroke(); ctx.beginPath(); ctx.moveTo(6, 9); ctx.lineTo(2, 12); ctx.lineTo(6, 15); ctx.stroke();
            } else if (name === "arrow_up") {
                ctx.beginPath(); ctx.moveTo(12, 17); ctx.lineTo(12, 7); ctx.stroke(); ctx.beginPath(); ctx.moveTo(7, 12); ctx.lineTo(12, 7); ctx.lineTo(17, 12); ctx.stroke();
            } else if (name === "arrow_down") {
                ctx.beginPath(); ctx.moveTo(12, 7); ctx.lineTo(12, 17); ctx.stroke(); ctx.beginPath(); ctx.moveTo(7, 12); ctx.lineTo(12, 17); ctx.lineTo(17, 12); ctx.stroke();
            } else if (name === "briefcase") {
                ctx.strokeRect(4, 7, 16, 12); ctx.beginPath(); ctx.moveTo(9, 7); ctx.lineTo(9, 4); ctx.lineTo(15, 4); ctx.lineTo(15, 7); ctx.stroke();
            }
        }
    }

    component SidebarButton: Rectangle {
        property string text; property string iconName; property bool isActive: false; signal clicked()
        Layout.fillWidth: true; Layout.preferredHeight: 46; color: isActive ? "#1e293b" : "transparent"; radius: 8
        Rectangle { width: 4; height: 24; radius: 2; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; color: theme.accentColor; visible: parent.isActive }
        RowLayout { anchors.fill: parent; anchors.leftMargin: 20; spacing: 15; VectorIcon { name: iconName; color: isActive ? theme.accentColor : theme.subTextColor } Text { text: parent.parent.text; color: isActive ? "white" : theme.subTextColor; font.pixelSize: 14; font.bold: isActive; Layout.fillWidth: true } }
        MouseArea { anchors.fill: parent; onClicked: parent.clicked(); hoverEnabled: true; onEntered: parent.color = isActive ? "#1e293b" : "#0f2035"; onExited: parent.color = isActive ? "#1e293b" : "transparent" }
    }

    component DesktopTextField: TextField {
        id: dtf; Layout.fillWidth: true; Layout.preferredHeight: 38; font.pixelSize: 14; color: theme.textColor; placeholderTextColor: theme.subTextColor; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
        background: Rectangle { color: theme.backgroundColor; border.color: dtf.activeFocus ? theme.accentColor : theme.borderColor; border.width: 1; radius: 6 }
    }

    component PrimaryButton: Button {
        id: btn; Layout.preferredHeight: 38; Layout.preferredWidth: 140
        contentItem: Text { text: btn.text; font.pixelSize: 14; font.bold: true; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { color: btn.down ? Qt.darker(theme.accentColor, 1.2) : theme.accentColor; radius: 6 }
    }

    component StatCard: Rectangle {
        property string title; property string value; property string iconName; property color iconColor; property color iconBg: "transparent"
        Layout.fillWidth: true; Layout.preferredHeight: 100; color: theme.cardColor; radius: 12; border.color: theme.borderColor; border.width: 1
        RowLayout { anchors.fill: parent; anchors.margins: 20; spacing: 15; Rectangle { Layout.preferredWidth: 48; Layout.preferredHeight: 48; radius: 12; color: iconBg; VectorIcon { anchors.centerIn: parent; name: iconName; color: iconColor } } ColumnLayout { spacing: 4; Text { text: title; color: theme.subTextColor; font.pixelSize: 13; font.weight: Font.Medium } Text { text: value; color: "white"; font.pixelSize: 22; font.bold: true } } }
    }

    Item {
        id: loginScreen; anchors.fill: parent; visible: !mainWindow.authorized; z: 1000
        Rectangle { anchors.fill: parent; color: theme.backgroundColor }
        Rectangle {
            width: 380; height: 450; anchors.centerIn: parent; color: theme.cardColor; radius: 16; border.color: theme.borderColor; border.width: 1
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 40; spacing: 20
                Text { text: "StudyMoney"; font.pixelSize: 28; font.bold: true; color: "white"; Layout.alignment: Qt.AlignHCenter }
                Text { text: registerForm.visible ? "Создание аккаунта" : "Вход в систему"; color: theme.subTextColor; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
                ColumnLayout {
                    visible: !registerForm.visible; Layout.fillWidth: true; spacing: 15
                    ColumnLayout { spacing: 6; Layout.fillWidth: true; Text { text: "Логин"; color: theme.subTextColor; font.pixelSize: 12 } DesktopTextField { id: loginField; placeholderText: "Введите логин" } }
                    ColumnLayout { spacing: 6; Layout.fillWidth: true; Text { text: "Пароль"; color: theme.subTextColor; font.pixelSize: 12 } DesktopTextField { id: passField; placeholderText: "Введите пароль"; echoMode: TextInput.Password; onAccepted: mainWindow.login(loginField.text, passField.text) } }
                    Item { Layout.preferredHeight: 5 }
                    PrimaryButton { Layout.fillWidth: true; text: mainWindow.loading ? "Загрузка..." : "Войти"; onClicked: mainWindow.login(loginField.text, passField.text) }
                    Text { text: "Нет аккаунта? Регистрация"; color: theme.accentColor; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: registerForm.visible = true } }
                }
                ColumnLayout {
                    id: registerForm; visible: false; Layout.fillWidth: true; spacing: 15
                    DesktopTextField { id: rLogin; placeholderText: "Логин" } DesktopTextField { id: rEmail; placeholderText: "Email" } DesktopTextField { id: rPass; placeholderText: "Пароль"; echoMode: TextInput.Password }
                    PrimaryButton { Layout.fillWidth: true; text: "Создать аккаунт"; onClicked: mainWindow.registerUser(rLogin.text, rPass.text, rEmail.text) }
                    Text { text: "Вернуться ко входу"; color: theme.subTextColor; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: registerForm.visible = false } }
                }
                Text { text: mainWindow.authError; color: theme.expenseColor; visible: text.length > 0; Layout.alignment: Qt.AlignHCenter }
            }
        }
    }

    RowLayout {
        anchors.fill: parent; visible: mainWindow.authorized; spacing: 0
        Rectangle {
            Layout.preferredWidth: 240; Layout.fillHeight: true; color: theme.sidebarColor; border.color: theme.borderColor; border.width: 1
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 8
                Text { text: "StudyMoney"; font.pixelSize: 22; font.bold: true; color: "white"; Layout.bottomMargin: 20 }
                SidebarButton { text: "Дашборд"; iconName: "dashboard"; isActive: stack.currentIndex === 0; onClicked: { stack.currentIndex = 0; mainWindow.refreshData() } }
                SidebarButton { text: "Все расходы"; iconName: "list"; isActive: stack.currentIndex === 1; onClicked: { stack.currentIndex = 1; mainWindow.refreshData() } }
                SidebarButton { text: "Доходы"; iconName: "wallet"; isActive: stack.currentIndex === 2; onClicked: { stack.currentIndex = 2; mainWindow.refreshData() } }
                SidebarButton { text: "Аналитика"; iconName: "chart"; isActive: stack.currentIndex === 3; onClicked: { stack.currentIndex = 3; mainWindow.refreshData() } }
                SidebarButton { text: "Цели"; iconName: "target"; isActive: stack.currentIndex === 4; onClicked: { stack.currentIndex = 4; mainWindow.refreshData() } }
                SidebarButton { text: "Рекомендации"; iconName: "idea"; isActive: stack.currentIndex === 5; onClicked: { stack.currentIndex = 5; } }
                Item { Layout.fillHeight: true }
                Rectangle { Layout.fillWidth: true; height: 1; color: theme.borderColor }
                SidebarButton { text: "Выйти"; iconName: "exit"; onClicked: mainWindow.logout() }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; color: theme.backgroundColor
            StackLayout {
                id: stack; anchors.fill: parent; anchors.margins: 24; currentIndex: 0
                ColumnLayout {
                    spacing: 20
                    Text { text: "Обзор финансов"; font.pixelSize: 28; font.bold: true; color: "white" }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 15
                        StatCard { title: "Баланс"; value: mainWindow.remainingAmount.toFixed(2) + " Br"; iconName: "briefcase"; iconColor: "#60a5fa" }
                        StatCard { title: "Доход"; value: "+" + mainWindow.budget.toFixed(2); iconName: "arrow_up"; iconColor: theme.incomeColor; iconBg: "#3310b981" }
                        StatCard { title: "Расход"; value: "−" + mainWindow.spent.toFixed(2); iconName: "arrow_down"; iconColor: theme.expenseColor; iconBg: "#33ef4444" }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: theme.cardColor; border.color: theme.borderColor; border.width: 1
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 20; spacing: 15
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Последние операции"; color: "white"; font.bold: true; font.pixelSize: 18; Layout.fillWidth: true }
                                PrimaryButton { text: "+ Расход"; Layout.preferredWidth: 120; background: Rectangle{color:theme.expenseColor; radius:6} onClicked: expenseDialog.open() }
                                PrimaryButton { text: "+ Доход"; Layout.preferredWidth: 120; background: Rectangle{color:theme.incomeColor; radius:6} onClicked: incomeDialog.open() }
                            }
                            Rectangle { Layout.fillWidth: true; height: 1; color: theme.borderColor }
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 30; color: theme.backgroundColor
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20
                                    Text { text: "Дата"; color: theme.subTextColor; font.bold: true; Layout.preferredWidth: 80; font.pixelSize: 12 }
                                    Text { text: "Категория / Источник"; color: theme.subTextColor; font.bold: true; Layout.fillWidth: true; font.pixelSize: 12 }
                                    Text { text: "Сумма"; color: theme.subTextColor; font.bold: true; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight; font.pixelSize: 12 }
                                }
                            }
                            ListView {
                                Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: mainWindow.lastExpenses
                                delegate: Rectangle {
                                    width: parent.width; height: 40; color: index % 2 === 0 ? "transparent" : "#08ffffff"
                                    RowLayout {
                                        anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20
                                        Text { text: modelData.date; color: theme.textColor; font.pixelSize: 13; Layout.preferredWidth: 80 }
                                        Text { text: modelData.category; color: theme.textColor; font.pixelSize: 13; Layout.fillWidth: true }
                                        Text { text: (modelData.type === 1 ? "+" : "−") + modelData.amount.toFixed(2); color: modelData.type === 1 ? theme.incomeColor : theme.expenseColor; font.bold: true; font.pixelSize: 13; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
                                    }
                                }
                            }
                        }
                    }
                }
                ColumnLayout {
                    Text { text: "Все расходы"; font.pixelSize: 24; font.bold: true; color: "white" }
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                        ListView {
                            anchors.fill: parent; anchors.margins: 10; clip: true; model: mainWindow.weeklyExpenses; spacing: 2
                            delegate: Rectangle {
                                width: parent.width; height: 40; color: index % 2 === 0 ? "transparent" : "#08ffffff"
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 15; anchors.rightMargin: 15
                                    Text { text: modelData.date; color: theme.subTextColor; Layout.preferredWidth: 100 }
                                    Text { text: modelData.category; color: "white"; font.pixelSize: 14; Layout.fillWidth: true }
                                    Text { text: "-" + modelData.amount.toFixed(2) + " Br"; color: theme.expenseColor; font.bold: true; font.pixelSize: 14 }
                                }
                            }
                        }
                    }
                }
                ColumnLayout {
                    Text { text: "История доходов"; font.pixelSize: 24; font.bold: true; color: "white" }
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                        ListView {
                            anchors.fill: parent; anchors.margins: 10; clip: true; model: mainWindow.incomeHistoryModel; spacing: 2
                            delegate: Rectangle {
                                width: parent.width; height: 40; color: index % 2 === 0 ? "transparent" : "#08ffffff"
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 15; anchors.rightMargin: 15
                                    Text { text: modelData.date; color: theme.subTextColor; Layout.preferredWidth: 100 }
                                    Text { text: modelData.source; color: "white"; font.pixelSize: 14; Layout.fillWidth: true }
                                    Text { text: "+" + modelData.amount.toFixed(2) + " Br"; color: theme.incomeColor; font.bold: true; font.pixelSize: 14 }
                                }
                            }
                        }
                    }
                }
                ColumnLayout {
                    spacing: 20; Text { text: "Аналитика расходов"; font.pixelSize: 24; font.bold: true; color: "white" }
                    RowLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true; spacing: 20
                        Rectangle {
                            Layout.fillHeight: true; Layout.preferredWidth: 350; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                            ColumnLayout {
                                anchors.centerIn: parent
                                Canvas {
                                    width: 220; height: 220; antialiasing: true; property var dataModel: mainWindow.analyticsData; onDataModelChanged: requestPaint()
                                    onPaint: { var ctx = getContext("2d"); ctx.reset(); var cx = width/2; var cy = height/2; var r = 80; var startAngle = -Math.PI/2; ctx.lineWidth = 30; if (dataModel && dataModel.length > 0) { for (var i = 0; i < dataModel.length; i++) { var sweep = dataModel[i].percent * 2 * Math.PI; ctx.beginPath(); ctx.arc(cx, cy, r, startAngle, startAngle + sweep, false); ctx.strokeStyle = catColors[i % catColors.length]; ctx.stroke(); startAngle += sweep; } } else { ctx.beginPath(); ctx.arc(cx, cy, r, 0, 2*Math.PI); ctx.strokeStyle = theme.borderColor; ctx.stroke(); } }
                                }
                                Text { text: "По категориям"; color: theme.subTextColor; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true; Layout.fillWidth: true; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                            Canvas {
                                id: barChart; anchors.fill: parent; anchors.margins: 40; antialiasing: true; property var dataModel: mainWindow.analyticsData; onDataModelChanged: requestPaint()
                                onPaint: { var ctx = getContext("2d"); ctx.reset(); var w = width; var h = height; ctx.beginPath(); ctx.strokeStyle = theme.subTextColor; ctx.lineWidth = 2; ctx.moveTo(0, 0); ctx.lineTo(0, h); ctx.lineTo(w, h); ctx.stroke(); if (!dataModel || dataModel.length === 0) return; var maxVal = 0; for(var i=0; i<dataModel.length; i++) if(dataModel[i].amount > maxVal) maxVal = dataModel[i].amount; if(maxVal === 0) maxVal = 1; var barWidth = (w / dataModel.length) * 0.5; var gap = (w / dataModel.length) * 0.5; var x = gap/2; for(var i=0; i<dataModel.length; i++) { var barH = (dataModel[i].amount / maxVal) * (h - 30); ctx.fillStyle = catColors[i % catColors.length]; ctx.fillRect(x, h - barH, barWidth, barH); ctx.fillStyle = theme.subTextColor; ctx.font = "bold 11px sans-serif"; ctx.fillText(dataModel[i].category.substring(0,3), x, h+15); x += barWidth + gap; } }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 100; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                        ListView {
                            anchors.fill: parent; anchors.margins: 15; clip: true; model: mainWindow.analyticsData; orientation: ListView.Horizontal; spacing: 20
                            delegate: RowLayout { Rectangle { width: 12; height: 12; radius: 6; color: catColors[index % catColors.length] } Column { Text { text: modelData.category; color: theme.textColor; font.bold: true; font.pixelSize: 13 } Text { text: modelData.amount.toFixed(2) + " Br (" + (modelData.percent*100).toFixed(1) + "%)"; color: theme.subTextColor; font.pixelSize: 11 } } }
                        }
                    }
                }
                ColumnLayout {
                    RowLayout { Text { text: "Цели"; font.pixelSize: 24; font.bold: true; color: "white"; Layout.fillWidth: true } PrimaryButton { text: "+ Цель"; onClicked: addGoalDialog.open() } }
                    GridView {
                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true; cellWidth: 260; cellHeight: 160; model: mainWindow.goalsModel
                        delegate: Rectangle {
                            width: 240; height: 140; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                            MouseArea { anchors.fill: parent; onClicked: { goalsViewActiveId = modelData.id; topUpGoalDialog.open() } }
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 15
                                Text { text: modelData.name; color: "white"; font.bold: true; font.pixelSize: 18 }
                                Item { Layout.fillHeight: true }
                                RowLayout { Layout.fillWidth: true; Text { text: (modelData.progress * 100).toFixed(0) + "%"; color: theme.accentColor; font.bold: true; font.pixelSize: 16 } Item { Layout.fillWidth: true } Text { text: modelData.current + " / " + modelData.target + " Br"; color: theme.subTextColor; font.pixelSize: 12 } }
                                Rectangle { Layout.fillWidth: true; height: 8; radius: 4; color: theme.backgroundColor; Rectangle { width: parent.width * modelData.progress; height: 8; radius: 4; color: theme.accentColor } }
                                Item { Layout.preferredHeight: 5 }
                                PrimaryButton { Layout.fillWidth: true; Layout.preferredHeight: 30; text: "Пополнить"; background: Rectangle { color: "transparent"; border.color: theme.accentColor; radius: 6 } contentItem: Text { text: "Пополнить"; color: theme.accentColor; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12 } onClicked: { goalsViewActiveId = modelData.id; topUpGoalDialog.open() } }
                            }
                        }
                    }
                }
                ColumnLayout {
                    spacing: 20; Text { text: "Умный помощник"; font.pixelSize: 24; font.bold: true; color: "white" }
                    PrimaryButton { text: mainWindow.loading ? "Анализ..." : "Сформировать отчёт"; Layout.preferredWidth: 200; onClicked: mainWindow.generateAnalyticsReport() }
                    RowLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true; spacing: 20
                        Rectangle {
                            Layout.fillHeight: true; Layout.preferredWidth: 350; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                            visible: mainWindow.recommendationChart.length > 0
                            ColumnLayout {
                                anchors.centerIn: parent
                                Text { text: "Траты за 30 дней"; color: theme.subTextColor; font.bold: true; Layout.alignment: Qt.AlignHCenter; Layout.bottomMargin: 10 }
                                Canvas {
                                    width: 200; height: 200; antialiasing: true; property var dataModel: mainWindow.recommendationChart; onDataModelChanged: requestPaint()
                                    onPaint: { var ctx = getContext("2d"); ctx.reset(); var cx = width/2; var cy = height/2; var r = 80; var startAngle = -Math.PI/2; ctx.lineWidth = 20; if (dataModel && dataModel.length > 0) { for (var i = 0; i < dataModel.length; i++) { var sweep = dataModel[i].percent * 2 * Math.PI; ctx.beginPath(); ctx.arc(cx, cy, r, startAngle, startAngle + sweep, false); ctx.strokeStyle = catColors[i % catColors.length]; ctx.stroke(); startAngle += sweep; } } }
                                }
                                ListView {
                                    Layout.preferredWidth: 200; Layout.preferredHeight: 120; clip: true; model: mainWindow.recommendationChart
                                    delegate: RowLayout { width: 200; Rectangle { width: 10; height: 10; radius: 5; color: catColors[index % catColors.length] } Text { text: modelData.category; color: "white"; font.pixelSize: 11; Layout.fillWidth: true } Text { text: (modelData.percent*100).toFixed(0) + "%"; color: theme.subTextColor; font.pixelSize: 11 } }
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: theme.cardColor; border.color: theme.borderColor
                            ListView {
                                anchors.fill: parent; anchors.margins: 20; spacing: 10; clip: true; model: mainWindow.recommendationText
                                delegate: Rectangle { width: parent.width; height: msgText.implicitHeight + 30; color: theme.backgroundColor; radius: 8; border.color: theme.borderColor; RowLayout { anchors.fill: parent; anchors.margins: 15; Text { id: msgText; text: modelData; color: theme.textColor; font.pixelSize: 14; wrapMode: Text.WordWrap; textFormat: Text.RichText; Layout.fillWidth: true } } }
                            }
                            Text { anchors.centerIn: parent; visible: mainWindow.recommendationText.length === 0; text: "Нажмите 'Сформировать отчёт',\nчтобы получить рекомендации."; color: theme.subTextColor; horizontalAlignment: Text.AlignHCenter }
                        }
                    }
                }
            }
        }
    }

    property int goalsViewActiveId: -1

    Dialog { id: expenseDialog; anchors.centerIn: parent; width: 400; modal: true; background: Rectangle { color: theme.cardColor; radius: 12; border.color: theme.borderColor; border.width: 1 } Overlay.modal: Rectangle { color: "#aa000000" } property string selectedCategory: ""; contentItem: ColumnLayout { spacing: 20; Text { text: "Добавить расход"; color: "white"; font.bold: true; font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter } DesktopTextField { id: exSum; placeholderText: "Сумма (Br)"; validator: RegularExpressionValidator { regularExpression: /^[0-9]+([.,][0-9]{1,2})?$/ } } Text { text: "Категория"; color: theme.subTextColor; font.pixelSize: 12 } GridLayout { columns: 2; Layout.fillWidth: true; columnSpacing: 10; rowSpacing: 10; Repeater { model: window.categories; delegate: Rectangle { Layout.fillWidth: true; height: 40; radius: 6; color: expenseDialog.selectedCategory === modelData ? theme.expenseColor : theme.backgroundColor; border.color: theme.borderColor; border.width: 1; Text { anchors.centerIn: parent; text: modelData; color: "white"; font.pixelSize: 14 } MouseArea { anchors.fill: parent; onClicked: expenseDialog.selectedCategory = modelData } } } } RowLayout { Layout.fillWidth: true; spacing: 10; PrimaryButton { text: "Отмена"; background: Rectangle{color:"transparent"; border.color:theme.subTextColor; radius:6} onClicked: expenseDialog.close() } PrimaryButton { text: "Добавить"; background: Rectangle{color:theme.expenseColor; radius:6} onClicked: { var clean = exSum.text.replace(",", "."); var amt = parseFloat(clean)||0; if(amt>0 && expenseDialog.selectedCategory!==""){ mainWindow.addExpense(amt, expenseDialog.selectedCategory); expenseDialog.close(); exSum.text="" } } } } } }
    Dialog { id: incomeDialog; anchors.centerIn: parent; width: 400; modal: true; background: Rectangle { color: theme.cardColor; radius: 12; border.color: theme.borderColor; border.width: 1 } Overlay.modal: Rectangle { color: "#aa000000" } contentItem: ColumnLayout { spacing: 20; Text { text: "Добавить доход"; color: "white"; font.bold: true; font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter } DesktopTextField { id: inSum; placeholderText: "Сумма (Br)"; validator: RegularExpressionValidator { regularExpression: /^[0-9]+([.,][0-9]{1,2})?$/ } } DesktopTextField { id: inSrc; placeholderText: "Источник" } RowLayout { Layout.fillWidth: true; spacing: 10; PrimaryButton { text: "Отмена"; background: Rectangle{color:"transparent"; border.color:theme.subTextColor; radius:6} onClicked: incomeDialog.close() } PrimaryButton { text: "Сохранить"; background: Rectangle{color:theme.incomeColor; radius:6} onClicked: { var clean = inSum.text.replace(",", "."); var amt = parseFloat(clean)||0; mainWindow.addIncome(amt, inSrc.text); incomeDialog.close(); inSum.text=""; inSrc.text="" } } } } }
    Dialog { id: addGoalDialog; anchors.centerIn: parent; width: 400; modal: true; background: Rectangle { color: theme.cardColor; radius: 12; border.color: theme.borderColor; border.width: 1 } Overlay.modal: Rectangle { color: "#aa000000" } contentItem: ColumnLayout { spacing: 20; Text { text: "Новая цель"; color: "white"; font.bold: true; font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter } DesktopTextField { id: glName; placeholderText: "Название цели" } DesktopTextField { id: glTarget; placeholderText: "Сумма"; validator: RegularExpressionValidator { regularExpression: /^[0-9]+([.,][0-9]{1,2})?$/ } } RowLayout { Layout.fillWidth: true; spacing: 10; PrimaryButton { text: "Отмена"; background: Rectangle{color:"transparent"; border.color:theme.subTextColor; radius:6} onClicked: addGoalDialog.close() } PrimaryButton { text: "Создать"; onClicked: { var clean = glTarget.text.replace(",", "."); var amt = parseFloat(clean)||0; mainWindow.createGoal(glName.text, amt); addGoalDialog.close(); glName.text=""; glTarget.text="" } } } } }
    Dialog { id: topUpGoalDialog; anchors.centerIn: parent; width: 400; modal: true; background: Rectangle { color: theme.cardColor; radius: 12; border.color: theme.borderColor; border.width: 1 } Overlay.modal: Rectangle { color: "#aa000000" } contentItem: ColumnLayout { spacing: 20; Text { text: "Пополнить"; color: "white"; font.bold: true; font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter } DesktopTextField { id: glTopUpSum; placeholderText: "Сумма"; validator: RegularExpressionValidator { regularExpression: /^[0-9]+([.,][0-9]{1,2})?$/ } } RowLayout { Layout.fillWidth: true; spacing: 10; PrimaryButton { text: "Отмена"; background: Rectangle{color:"transparent"; border.color:theme.subTextColor; radius:6} onClicked: topUpGoalDialog.close() } PrimaryButton { text: "ОК"; background: Rectangle{color:theme.incomeColor; radius:6} onClicked: { var clean = glTopUpSum.text.replace(",", "."); var amt = parseFloat(clean)||0; mainWindow.topUpGoal(goalsViewActiveId, amt); topUpGoalDialog.close(); glTopUpSum.text="" } } } } }
}

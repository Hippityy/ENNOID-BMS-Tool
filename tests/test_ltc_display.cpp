#include "pages/pagertdata.h"

#include <QApplication>
#include <QCheckBox>
#include <QLabel>
#include <QTabWidget>
#include <cassert>
#include <cmath>

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    BMSInterface bms;
    PageRtData page;
    page.setDieBieMS(&bms);
    auto toggle = page.findChild<QCheckBox *>("ltcTempCorrectionBox");
    auto status = page.findChild<QLabel *>("ltcTempStatusLabel");
    auto graph = page.findChild<QCustomPlot *>("auxBarGraph");
    assert(toggle && status && graph && !toggle->isChecked());
    auto bars = dynamic_cast<QCPBars *>(graph->plottable(0));
    assert(bars);

    int commandsSent = 0;
    QObject::connect(bms.commands(), &Commands::dataToSend,
                     [&commandsSent](QByteArray &) { ++commandsSent; });
    QVector<double> raw = {25.0, 100.0, -10.0, 15.10};
    assert(QMetaObject::invokeMethod(&page, "auxReceived", Qt::DirectConnection,
                                    Q_ARG(int, raw.size()), Q_ARG(QVector<double>, raw)));
    assert(bars->data()->at(0)->value == 25.0);
    toggle->setChecked(true);
    assert(std::fabs(bars->data()->at(0)->value - 61.6666667) < 0.001);
    assert(std::isnan(bars->data()->at(1)->value));
    assert(std::isnan(bars->data()->at(2)->value));
    assert(status->text().contains("2 invalid"));
    toggle->setChecked(false);
    assert(bars->data()->at(0)->value == 25.0);
    assert(bars->data()->at(1)->value == 100.0);
    assert(commandsSent == 0);  // Toggling never writes configuration/commands.

    toggle->setChecked(true);
    page.findChild<QTabWidget *>("tabWidget")->setCurrentWidget(
        page.findChild<QWidget *>("auxBarGraphTab"));
    page.resize(1400, 850);
    page.show();
    app.processEvents();
    if (argc > 1) {
        assert(page.grab().save(QString::fromLocal8Bit(argv[1])));
    }
    // Changing the source clears cached temperatures instead of converting
    // readings from a previous connection/device.
    page.setDieBieMS(nullptr);
    assert(bars->data()->isEmpty());
    return 0;
}

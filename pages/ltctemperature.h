#ifndef LTCTEMPERATURE_H
#define LTCTEMPERATURE_H

#include <cmath>

namespace LtcTemperature {

// Display-only conversion from mur-embedded/docs/thermistor-temperature-reference.md,
// Table 5 (2026-10-16). Assumes BMS R25/Rtop = 100 kohm, beta = 4250 K,
// Vref = 3.000 V. Invalid readings are not clamped or extrapolated.
inline bool corrected(double reportedC, double &actualC)
{
    if (!std::isfinite(reportedC) || reportedC < -50.0 || reportedC == 100.0) {
        return false;
    }
    const double resistance = 100000.0 * std::exp(
        4250.0 * (1.0 / (reportedC + 273.15) - 1.0 / 298.15));
    // Match the reference implementation's recovered-voltage precision (1 uV).
    const double voltageMv = std::round(
        3000000.0 * resistance / (resistance + 100000.0)) / 1000.0;
    static const double tableMv[] = {
        2440, 2420, 2400, 2380, 2350, 2320, 2270, 2230, 2170,
        2110, 2050, 1990, 1920, 1860, 1800, 1740, 1680,
        1630, 1590, 1550, 1510, 1480, 1450, 1430, 1400,
        1380, 1370, 1350, 1340, 1330, 1320, 1310, 1300
    };
    const unsigned count = sizeof(tableMv) / sizeof(tableMv[0]);
    if (!std::isfinite(voltageMv) || voltageMv > tableMv[0] ||
        voltageMv < tableMv[count - 1]) {
        return false;
    }
    for (unsigned i = 1; i < count; ++i) {
        if (voltageMv >= tableMv[i]) {
            actualC = -40.0 + (i - 1) * 5.0 +
                      (voltageMv - tableMv[i - 1]) /
                      (tableMv[i] - tableMv[i - 1]) * 5.0;
            return true;
        }
    }
    return false;
}

} // namespace LtcTemperature

#endif

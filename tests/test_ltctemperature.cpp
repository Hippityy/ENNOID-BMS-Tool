#include "pages/ltctemperature.h"

#include <cassert>
#include <limits>

static double reportedAtVoltage(double mv)
{
    const double resistance = 100000.0 * mv / (3000.0 - mv);
    return 1.0 / (std::log(resistance / 100000.0) / 4250.0 + 1.0 / 298.15) - 273.15;
}

int main()
{
    double actual = 0;
    assert(LtcTemperature::corrected(25.0, actual));
    assert(std::fabs(actual - 61.6666667) < 0.0001);
    assert(LtcTemperature::corrected(reportedAtVoltage(1830), actual));
    assert(std::fabs(actual - 27.5) < 0.0001);

    // Independently recover each supplied table knot, including both limits.
    const double knots[] = {
        2440, 2420, 2400, 2380, 2350, 2320, 2270, 2230, 2170,
        2110, 2050, 1990, 1920, 1860, 1800, 1740, 1680,
        1630, 1590, 1550, 1510, 1480, 1450, 1430, 1400,
        1380, 1370, 1350, 1340, 1330, 1320, 1310, 1300
    };
    for (unsigned i = 0; i < sizeof(knots) / sizeof(knots[0]); ++i) {
        assert(LtcTemperature::corrected(reportedAtVoltage(knots[i]), actual));
        assert(std::fabs(actual - (-40.0 + 5.0 * i)) < 0.0001);
    }
    assert(!LtcTemperature::corrected(reportedAtVoltage(2450), actual));
    assert(!LtcTemperature::corrected(reportedAtVoltage(1290), actual));
    assert(!LtcTemperature::corrected(100.0, actual));
    assert(!LtcTemperature::corrected(-50.01, actual));
    assert(!LtcTemperature::corrected(std::numeric_limits<double>::quiet_NaN(), actual));
    assert(!LtcTemperature::corrected(std::numeric_limits<double>::infinity(), actual));
}

# ENNOID-BMS Tool (based on DieBieMS-Tool)

The ENNOID-BMS tool can be used to configure the ENNOID-BMS, update the firmware.

![alt text](images/IMAGE01.png)

![alt text](images/IMAGE02.png)

Latest compiled version can be found in the release tab:
[ENNOID-BMS Tool](https://github.com/EnnoidMe/ENNOID-BMS-Tool/releases)

# Other parts of this project:

[ENNOID-BMS Hardware](https://github.com/EnnoidMe/ENNOID-BMS)

[ENNOID-BMS Bootloader](https://github.com/EnnoidMe/DieBieMS-Bootloader) Same as DieBieMS bootloader Can be flashed with the ENNOID-BMS Tool in the firmware tab or with an STlink-V2.

[ENNOID-BMS Firmware](https://github.com/EnnoidMe/ENNOID-BMS-Firmware/tree/ENNOID) Can be flashed with the ENNOID-BMS Tool in the firmware tab.  

The compiled build .bin and hex files can be found in the MDK-ARM folder [Firmware files](https://github.com/EnnoidMe/ENNOID-BMS-Firmware/tree/ENNOID/MDK-ARM/ENNOID-BMS)

# Building on macOS

1. Install Qt 5 via Homebrew:
   ```bash
   brew install qt@5
   ```
2. Run the build script:
   ```bash
   ./build_macos.sh
   ```
   This will compile the application and bundle `ENNOID-BMS-Tool.app` and `ENNOID-BMS-Tool.dmg`.

### Running on Another Mac
If macOS blocks opening the app on an un-notarized Mac, run:
```bash
xattr -cr /Applications/ENNOID-BMS-Tool.app
```

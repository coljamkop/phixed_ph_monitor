# phixedphmonitor

pHixed pH Monitor

## Dependencies
- flutter
- balena-cli
- balena account

## Getting Started

- Open balenaCloud
- Navigate to the Devices page
- Click Add device
- Choose the device type
- Select the development edition
- (Optional) Setup the network connection if using WiFi
- Download balenaOS

- Write the balenaOS image to an SD card
- Plug it into the device
- Turn the device on
- Navigate to the Devices page on balenaCloud
- Locate your device
- Navigate to your device's page
- Click the dropdown near the Reboot Restart buttons
- Select Enable local Mode
- Take note of your devices UUID

- Checkout this project
- Run `flutter build bundle`
- Run `balena push {Device UUID}.local`
- The image should be pushed to your device and it should show the UI


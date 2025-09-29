# 📱 WA Status Saver

A modern, feature-rich Flutter application for saving and viewing WhatsApp status updates (stories) on your device. Built with clean architecture and Material Design 3, this app provides a seamless experience for managing your favorite WhatsApp statuses.

## ✨ Features

### 🔍 **Smart Status Detection**
- Automatically detects WhatsApp and WhatsApp Business status files
- Supports both regular WhatsApp and WhatsApp Business
- Real-time status discovery with duplicate detection
- Categorizes content into Images and Videos tabs

### 📥 **Easy Status Saving**
- One-tap saving to your device's Downloads folder
- Organized file naming with timestamps
- Preserves original quality and metadata
- Bulk operations support

### 🖼️ **Gallery Viewer**
- Beautiful grid layout with staggered view
- Full-screen status viewer with zoom support
- Video playback with controls
- Smooth animations and transitions
- Share functionality built-in

### 🔐 **Permission Management**
- Smart permission handling for storage access
- Clear permission request dialogs
- Fallback options for different Android versions
- External storage management support

### 🎨 **Modern UI/UX**
- Material Design 3 implementation
- Light and Dark theme support
- Responsive design for all screen sizes
- Intuitive navigation with smooth transitions

### 🛠️ **Developer Tools**
- Built-in debug screen for troubleshooting
- Permission status monitoring
- Directory exploration tools
- File system diagnostics

## 📸 Screenshots

*Screenshots will be added soon*

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (Android 6.0+)

### Building from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/ChawerKamanga/just_wa_status_saver
   cd just_wa_status_saver
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate launcher icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Required Permissions

The app requires the following permissions to function properly:

- **READ_EXTERNAL_STORAGE** - To access WhatsApp status files
- **WRITE_EXTERNAL_STORAGE** - To save status files to Downloads
- **MANAGE_EXTERNAL_STORAGE** (Android 11+) - For broader file system access
- **INTERNET** - For future features and updates

## 🎯 Usage

1. **Grant Permissions**: On first launch, grant the required storage permissions
2. **Browse Statuses**: Navigate between Images and Videos tabs to view available statuses
3. **Save Statuses**: Tap the save icon on any status to download it to your device
4. **View Full Screen**: Tap on any status to view it in full screen with zoom capabilities
5. **Share**: Use the share button to send statuses to other apps
6. **Debug**: Access the debug screen from settings for troubleshooting

## 🏗️ Technical Details

### Built With
- **Flutter 3.8.1** - UI framework
- **Dart** - Programming language
- **Provider** - State management
- **GoRouter** - Navigation and routing
- **Material Design 3** - Design system

### Key Dependencies
```yaml
dependencies:
  flutter_staggered_grid_view: ^0.7.0  # Grid layouts
  permission_handler: ^11.3.1          # Permission management
  path_provider: ^2.1.4                # File system paths
  external_path: ^2.2.0                # External storage access
  video_player: ^2.8.6                 # Video playback
  cached_network_image: ^3.3.1         # Image caching
  share_plus: ^12.0.0                  # Share functionality
  provider: ^6.1.2                     # State management
  go_router: ^14.2.7                   # Navigation
```

### Project Structure
```
lib/
├── core/
│   ├── constants/          # App constants and themes
│   ├── navigation/         # Routing configuration
│   └── services/           # Core business services
├── data/
│   └── models/            # Data models
├── features/
│   ├── feed/              # Status viewing functionality
│   ├── saved/             # Saved statuses management
│   └── settings/          # App settings
├── shared/
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point
```

## 🔧 Configuration

### Android Manifest
The app is configured with necessary permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

### App Icon
Custom app icon is configured using `flutter_launcher_icons` package with:
- Adaptive icon support
- Background color: `#57C56D` (WhatsApp green)
- Icon source: `assets/images/logo.png`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This app is designed to save WhatsApp statuses that are already accessible on your device. It respects WhatsApp's terms of service and only accesses files that are stored in publicly accessible directories. Please use responsibly and respect others' privacy.

## 🐛 Troubleshooting

### Common Issues

1. **No statuses found**:
   - Ensure WhatsApp is installed and you've viewed some statuses
   - Grant all required permissions
   - Use the debug screen to check directory access

2. **Permission denied**:
   - Go to Settings > Apps > WA Status Saver > Permissions
   - Enable all storage permissions
   - On Android 11+, enable "All files access"

3. **Files not saving**:
   - Check available storage space
   - Verify Downloads folder permissions
   - Try using the debug screen's test download feature

## 📞 Support

If you encounter any issues or have questions, please:
1. Check the troubleshooting section above
2. Use the built-in debug screen for diagnostics
3. Open an issue on GitHub with detailed information

---

**Made with ❤️ using Flutter**

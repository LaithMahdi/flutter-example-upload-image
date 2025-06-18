# Image Upload Flutter App

A modern Flutter application for uploading images to an API using Dio, image picker, and dotenv for configuration management.

## Features

- 📸 **Multiple Image Selection** - Pick multiple images from gallery
- 📷 **Camera Capture** - Take photos directly from camera
- 🖼️ **Image Preview** - Preview selected images before upload
- 🔄 **Smart Upload Logic** - Automatically tries different field names for maximum API compatibility
- 🌐 **Environment Configuration** - Use .env files for API configuration
- 💫 **Modern UI** - Clean Material 3 design with loading states
- ⚡ **Error Handling** - Comprehensive error handling with user-friendly messages
- 🔍 **Detailed Logging** - Extensive logging for debugging API issues

## Screenshots

The app provides a clean, intuitive interface for image upload operations with real-time feedback and status updates.

## Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android/iOS device or emulator for testing

## Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd upload_image
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Update the `.env` file with your API base URL:

   ```env
   # Replace this with your actual API server base URL
   BASE_URL=https://your-api-server.com/api
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Dependencies

### Production Dependencies

- **flutter**: Flutter SDK
- **cupertino_icons**: iOS style icons
- **dio**: HTTP client for API requests
- **image_picker**: Image selection from gallery/camera
- **flutter_dotenv**: Environment variable management

### Development Dependencies

- **flutter_test**: Testing framework
- **flutter_lints**: Dart linting rules

## API Integration

### Endpoint Configuration

The app uploads images to the following endpoint:

- **URL**: `{BASE_URL}/upload/no-token`
- **Method**: POST
- **Content-Type**: `multipart/form-data`
- **Field Names**: The app automatically tries multiple field names:
  - `images` (primary)
  - `image`
  - `file`
  - `files`
  - `upload`
  - `photo`

### Request Format

```http
POST /upload/no-token
Content-Type: multipart/form-data

Form Data:
- images: [image files]
```

### Expected Response

```json
{
  "message": "Files uploaded successfully",
  "data": [
    {
      "url": "https://upload.example.com/path/to/image.jpg",
      "originalSize": 5365,
      "uploadedSize": 5000,
      "compressionRatio": 0.92,
      "format": "image/jpeg"
    }
  ],
  "totalUploaded": 1
}
```

## Project Structure

```
lib/
├── main.dart                           # App entry point and main UI
├── services/
│   └── image_upload_service.dart       # API service for image uploads
├── .env                                # Environment configuration
└── pubspec.yaml                        # Project dependencies
```

## Configuration

### Environment Variables

Create or update the `.env` file in the project root:

```env
# API Configuration
BASE_URL=https://api.mariage.com.tn

# Optional: Add other configuration as needed
# API_KEY=your_api_key_here
# TIMEOUT=30000
```

### API Service Configuration

The `ImageUploadService` class handles:

- **Environment Loading**: Reads BASE_URL from .env
- **Dio Configuration**: HTTP client setup with timeouts
- **Smart Field Detection**: Tries multiple field names automatically
- **Error Handling**: Comprehensive error catching and logging
- **MIME Type Detection**: Automatic content type detection

## Usage

### Basic Upload Flow

1. **Select Images**: Tap "Gallery" to choose from photos or "Camera" to take a new photo
2. **Preview**: Selected images appear in a horizontal scrollable list
3. **Upload**: Tap "Upload Images" to send files to the API
4. **Feedback**: Real-time status updates show upload progress and results

### Code Example

```dart
// Initialize the service
final ImageUploadService uploadService = ImageUploadService();

// Upload images
try {
  final response = await uploadService.uploadImages(selectedImages);
  if (response != null && response.statusCode == 200) {
    print('Upload successful!');
  }
} catch (e) {
  print('Upload failed: $e');
}
```

## Error Handling

The app handles various error scenarios:

- **Network Issues**: Connection timeouts, no internet
- **API Errors**: Invalid field names, server errors
- **File Issues**: Invalid file types, large files
- **Permission Issues**: Camera/gallery access denied

Error messages are user-friendly and color-coded:

- 🟢 **Green**: Success messages
- 🔴 **Red**: Error messages
- 🔵 **Blue**: Info messages

## Debugging

### Enable Verbose Logging

The app includes extensive logging for debugging API issues:

```bash
flutter run --verbose
```

### Common Issues

1. **"Unexpected field" Error**

   - The API doesn't recognize the field name
   - Check API documentation for correct field names
   - The app automatically tries multiple field names

2. **Network Timeout**

   - Check internet connection
   - Verify BASE_URL in .env file
   - Increase timeout in ImageUploadService

3. **Permission Denied**
   - Grant camera/gallery permissions in device settings
   - Restart the app after granting permissions

## Development

### Adding New Features

1. **New Field Names**: Add to the `fieldNames` list in `ImageUploadService`
2. **Custom Headers**: Modify the Dio configuration in the constructor
3. **File Validation**: Add validation logic before upload
4. **Progress Tracking**: Implement upload progress callbacks

### Testing

```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Deployment

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:

1. Check the [Issues](../../issues) section
2. Review the debugging section above
3. Create a new issue with detailed logs and error messages

## Changelog

### v1.0.0

- Initial release
- Multi-image selection and upload
- Camera integration
- Environment configuration
- Smart field name detection
- Modern Material 3 UI
- Comprehensive error handling

---

**Built with ❤️ using Flutter**

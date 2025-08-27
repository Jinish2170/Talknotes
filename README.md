# TalkNotes 🎤📝

TalkNotes is an AI-powered voice notes application backend that transforms audio recordings into intelligent, well-formatted notes using advanced AI technology. Upload your voice recordings and get transcribed text, AI-generated summaries, and professionally styled notes.

## Features ✨

- 🎙️ **Audio Upload & Processing**: Upload audio files with support for multiple formats
- 🔤 **Speech-to-Text**: Automatic transcription using Google Cloud Speech API
- 🤖 **AI-Powered Content Generation**: Transform transcriptions into well-formatted notes using Google Gemini AI
- 📚 **Multiple Note Styles**: Support for different note formatting styles (meeting notes, journal entries, etc.)
- 💾 **Cloud Storage**: Secure audio file storage using Cloudinary
- 👤 **User Management**: User registration, authentication, and profile management
- 🔧 **Admin Panel**: Administrative controls for user and note style management
- 📊 **CRUD Operations**: Complete note management with create, read, update, delete functionality

## Technology Stack 🛠️

- **Backend**: Node.js, Express.js
- **Database**: MongoDB with Mongoose ODM
- **AI Services**: 
  - Google Gemini AI for content generation
  - Google Cloud Speech-to-Text API for transcription
- **File Storage**: Cloudinary for audio file management
- **Authentication**: JWT tokens with bcrypt for password hashing
- **Additional**: CORS, Morgan logging, File upload handling

## Prerequisites 📋

Before running this application, make sure you have:

- Node.js (v14 or higher)
- MongoDB database
- Google Cloud Console account with Speech API enabled
- Google Gemini AI API key
- Cloudinary account for file storage

## Installation 🚀

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jinish2170/talknotes.git
   cd talknotes
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   Copy the example environment file and configure your values:
   ```bash
   cp .env.example .env
   ```
   
   Then edit the `.env` file with your actual configuration values. See the [Environment Variables](#environment-variables-🔐) section for detailed descriptions.

4. **Start the development server**
   ```bash
   npm run dev
   ```

5. **Start the production server**
   ```bash
   npm start
   ```

## API Endpoints 📡

### Base URL
All endpoints are prefixed with `/api`

### User Routes (`/api/user`)

| Method | Endpoint | Description | Body Parameters |
|--------|----------|-------------|-----------------|
| POST | `/registerUser` | Register a new user | `email`, `password`, `name` |
| POST | `/loginUser` | User login | `email`, `password` |
| PUT | `/updateUser/:userId` | Update user profile | User data fields |
| GET | `/noteStyles` | Get available note styles | - |
| POST | `/createNote` | Create a new note | Note data |
| GET | `/getNotes` | Retrieve all notes | - |
| PUT | `/updateNote/:noteId` | Update a note | Updated note data |
| DELETE | `/deleteNote/:noteId` | Delete a note | - |
| POST | `/saveAudioNote` | Save audio note | `audio_note` |
| POST | `/processAudioNote` | Process audio file with AI | `audioFile` (multipart), `styleName` |

### Admin Routes (`/api/admin`)

| Method | Endpoint | Description | Body Parameters |
|--------|----------|-------------|-----------------|
| POST | `/adminLogin` | Admin login | `email`, `password` |
| POST | `/userDeactivate/:userId` | Deactivate a user | - |
| POST | `/noteStyles` | Create note style | `style_name`, `style_description` |
| GET | `/noteStyles` | Get all note styles | - |
| PUT | `/noteStyles/:id` | Update note style | Style data |
| DELETE | `/noteStyles/:id` | Delete note style | - |

## Usage Examples 💡

### Processing an Audio Note

```javascript
// Upload and process audio file
const formData = new FormData();
formData.append('audioFile', audioBlob, 'recording.wav');
formData.append('styleName', 'Meeting Notes');

const response = await fetch('/api/user/processAudioNote', {
  method: 'POST',
  body: formData
});

const result = await response.json();
console.log('Processed note:', result.data);
```

### Creating a Note Style

```javascript
// Create a new note style (Admin only)
const noteStyle = {
  style_name: "Technical Documentation",
  style_description: "Format notes as structured technical documentation with headers and bullet points"
};

const response = await fetch('/api/admin/noteStyles', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(noteStyle)
});
```

## Testing 🧪

The project includes test files for various components:

```bash
# Test Gemini AI integration
npm run test:gemini

# Test speech-to-text functionality
npm run test:speech

# Test audio processing
npm run test:audio
```

## Project Structure 📁

```
src/
├── configs/           # Configuration files
│   ├── express.config.js
│   ├── gemini.config.js
│   └── cloudinary.config.js
├── controllers/       # Route controllers
│   ├── note.controller.js
│   ├── noteStyle.controller.js
│   ├── user.controller.js
│   └── admin.controller.js
├── models/           # Database models
│   ├── note.model.js
│   ├── noteStyle.model.js
│   └── user.model.js
├── routes/           # API routes
│   ├── user/
│   └── admin/
├── services/         # Business logic
├── utils/            # Utility functions
├── middlewares/      # Custom middleware
├── tests/            # Test files
└── index.js          # Application entry point
```

## Environment Variables 🔐

| Variable | Description | Required |
|----------|-------------|----------|
| `PORT` | Server port (default: 3000) | No |
| `MONGODB_URL_STG` | MongoDB connection string | Yes |
| `DB_NAME` | Database name | Yes |
| `TOKEN_SECRET_KEY` | JWT secret key | Yes |
| `GEMINI_API_KEY` | Google Gemini AI API key | Yes |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to Google Cloud service account key | Yes |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name | Yes |
| `CLOUDINARY_API_KEY` | Cloudinary API key | Yes |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret | Yes |
| `FRONTEND_BASE_URL` | Frontend URL for CORS | Yes |

## Contributing 🤝

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Error Handling 🚨

The API uses consistent error responses:

```json
{
  "status": 0,
  "message": "Error description",
  "data": null
}
```

Success responses:
```json
{
  "status": 1,
  "message": "Success message",
  "data": { /* response data */ }
}
```

## Troubleshooting 🔍

### Common Issues

1. **MongoDB Connection Issues**
   - Ensure MongoDB is running on your system
   - Check if the `MONGODB_URL_STG` and `DB_NAME` are correct in your `.env` file
   - Verify network connectivity to your MongoDB instance

2. **Google Cloud API Issues**
   - Verify your service account key file exists and path is correct
   - Ensure Speech-to-Text API is enabled in Google Cloud Console
   - Check if your Google Cloud project ID is correctly configured

3. **Gemini API Issues**
   - Verify your `GEMINI_API_KEY` is valid and active
   - Check if you have sufficient quota/credits in your Google AI account

4. **Cloudinary Upload Issues**
   - Verify all Cloudinary credentials are correct
   - Check if your Cloudinary account has sufficient storage quota

5. **File Upload Issues**
   - Ensure the `/tmp` directory has write permissions
   - Check file size limits (current limit: 50MB)

### Debug Mode
Enable debug logging by setting `NODE_ENV=development` in your `.env` file.

## License 📄

This project is licensed under the ISC License.

## Support & Contact 📧

- **Author**: Jinish K.
- **GitHub**: [Jinish2170](https://github.com/Jinish2170)

For issues and feature requests, please create an issue on GitHub.

---

**Note**: This is the backend API for TalkNotes. Make sure to configure all required environment variables before running the application.
# Audio Processing API Documentation

## Overview
This API processes audio files through a complete pipeline: upload to Cloudinary, speech-to-text conversion, and AI content generation using Gemini.

## Endpoint
```
POST /api/user/processAudioNote
```

## Request Format
- **Content-Type**: `multipart/form-data`
- **Method**: POST

### Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `audioFile` | File | Yes | Audio file (WAV, MP3, MP4, WebM) |
| `styleName` | String | Yes | Processing style name (e.g., "Meeting Notes", "Action Items") |

## Response Format

### Success Response (STATUS: 1)
```json
{
  "RESULT": {
    "audio_note": "https://res.cloudinary.com/your-cloud/video/upload/v123/audio.wav",
    "audio_transcription": "This is the transcribed text from the audio file...",
    "ai_note": "# Meeting Notes\n\n## Key Points\n- Point 1\n- Point 2...",
    "summary": "Brief summary of the audio content...",
    "style_name": "Meeting Notes",
    "success": true
  },
  "MESSAGE": "Audio note processed successfully",
  "STATUS": 1,
  "IS_TOKEN_EXPIRE": 0
}
```

### Error Response (STATUS: 0)
```json
{
  "RESULT": null,
  "MESSAGE": "Error description",
  "STATUS": 0,
  "IS_TOKEN_EXPIRE": 0
}
```

## Processing Pipeline

1. **File Upload**: Audio file is uploaded to Cloudinary
2. **Speech-to-Text**: Google Cloud Speech-to-Text converts audio to text
3. **AI Processing**: Gemini AI processes the transcription with the selected style
4. **Summary Generation**: Gemini generates a concise summary
5. **Response**: All processed data is returned

## Supported Audio Formats
- WAV (audio/wav)
- MP3 (audio/mpeg, audio/mp3)
- MP4 (audio/mp4)
- WebM (audio/webm)

## Style Names
You can use any descriptive style name. Common examples:
- "Meeting Notes"
- "Action Items"
- "Personal Notes"
- "Interview Summary"
- "Lecture Notes"
- "Daily Journal"

## Example Usage

### JavaScript (Frontend)
```javascript
const processAudio = async (audioFile, styleName) => {
  const formData = new FormData();
  formData.append('audioFile', audioFile);
  formData.append('styleName', styleName);

  const response = await fetch('/api/user/processAudioNote', {
    method: 'POST',
    body: formData
  });

  return response.json();
};

// Usage
const audioFile = document.getElementById('audioInput').files[0];
const result = await processAudio(audioFile, 'Meeting Notes');
```

### cURL
```bash
curl -X POST http://localhost:3000/api/user/processAudioNote \
  -F "audioFile=@path/to/audio.wav" \
  -F "styleName=Meeting Notes"
```

## Error Handling

### Common Errors
- **400 Bad Request**: Missing audio file or style name
- **400 Bad Request**: Invalid audio file format
- **500 Internal Server Error**: Processing pipeline failure

### Error Messages
- `"Audio file is required. Please upload a file with field name 'audioFile'"`
- `"Style name is required"`
- `"Invalid audio file format. Supported formats: WAV, MP3, MP4, WebM"`
- `"Audio processing failed: [specific error]"`

## Performance Notes
- Processing time depends on audio length and file size
- Typical processing time: 5-30 seconds for 1-10 minute audio files
- Large files may take longer to upload and process

## Rate Limits
- Follows standard API rate limits
- Cloud service limits apply (Cloudinary, Google Speech-to-Text, Gemini)

## Security
- File uploads are temporarily stored and cleaned up automatically
- Audio files are stored securely on Cloudinary
- No persistent local file storage

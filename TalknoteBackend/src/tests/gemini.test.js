import {
  generateNoteStyle,
  generateSmartSummary,
  generateActionList,
  generatePostContent
} from '../configs/gemini.config.js';
import { testAudioProcessor } from '../configs/speesh-to-text.config.js'; // Assuming this is where the transcribed text is stored
import fs from 'fs';

/**
 * Test the Gemini API configuration for TalkNotes (Voice Notes App)
 */
async function testGeminiNoteProcessing() {
  console.log('🚀 Starting TalkNotes Gemini API Voice Notes Tests...\n');

  try {
    const sampleTranscribedText = processResult.transcript;

    // Test 1: Generate a smart summary
    console.log('📄 Test 1: Generating smart summary...');
    const summary = await generateSmartSummary(sampleTranscribedText, 1100);
    console.log('✅ Summary generated successfully!');
    console.log('Summary:', summary, '\n');

    // Test 2: Generate an action/task list
    console.log('✅ Test 2: Extracting action items...');
    const actions = await generateActionList(sampleTranscribedText, 1100);
    console.log('✅ Action list generated successfully!');
    console.log('Action Items:', actions, '\n');

    // Test 3: Generate a styled note (example: social media post or professional report)
    console.log('📝 Test 3: Generating formatted note content...');
    const styledNote = await generateNoteStyle(sampleTranscribedText, 'formal');
    console.log('✅ Styled note generated successfully!');
    console.log('Note preview:', styledNote.substring(0, 200) + '...\n');

    // Test 4: Generate a content-ready post (optional)
    console.log('📢 Test 4: Generating post content...');
    const post = await generatePostContent(sampleTranscribedText);
    console.log('✅ Post generated successfully!');
    console.log('Post preview:', post.substring(0, 200) + '...\n');

    console.log('🎉 All Gemini AI note-processing tests passed!');
    console.log('📊 Test Summary:');
    console.log('   - Summary: ✅');
    console.log('   - Action List: ✅');
    console.log('   - Styled Note: ✅');
    console.log('   - Post Content: ✅');

  } catch (error) {
    console.error('❌ Gemini test failed:', error.message);
    console.error('🔍 Error details:', error);
    console.log('\n💡 Troubleshooting tips:');
    console.log('   1. Verify your GEMINI_API_KEY in the .env file');
    console.log('   2. Ensure @google/generative-ai is properly installed');
    console.log('   3. Validate all functions in gemini.config.js return Gemini API responses');
  }
}

// Run the test
testGeminiNoteProcessing();

export { testGeminiNoteProcessing };

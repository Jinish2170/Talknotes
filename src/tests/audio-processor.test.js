import { processAudioFile, processAudioBuffer, getTranscriptFromFile, getTranscriptFromBuffer } from '../utils/audio-processor.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Test the audio processor utility
 */
async function testAudioProcessor() {
  console.log('🎵 Starting TalkNotes Audio Processor tests...\n');

  const audioFilePath = path.join(__dirname, '../configs/harvard.wav');

  try {
    // Test 1: Process audio file with full details
    console.log('🔄 Test 1: Processing audio file...');
    const processResult = await processAudioFile(audioFilePath);
    
    if (processResult.success) {
      console.log('✅ Audio processing successful!');
      console.log('📝 Full transcript:', processResult.transcript);
      console.log('🎯 Confidence:', (processResult.confidence * 100).toFixed(1) + '%');
      console.log('📊 Word count:', processResult.wordCount);
      console.log('⏱️  Duration:', processResult.duration, 'seconds');
      console.log('🔤 First 3 words with timing:');
      if (processResult.words) {
        processResult.words.slice(0, 3).forEach(word => {
          console.log(`   "${word.word}" - ${word.startTime?.seconds || 0}s`);
        });
      }
    } else {
      console.log('❌ Audio processing failed:', processResult.error);
    }
    console.log();

    // Test 2: Quick transcript extraction
    console.log('🔄 Test 2: Quick transcript extraction...');
    const quickTranscript = await getTranscriptFromFile(audioFilePath);
    
    if (quickTranscript) {
      console.log('✅ Quick transcript successful!');
      console.log('📝 Transcript:', quickTranscript);
    } else {
      console.log('❌ Quick transcript failed');
    }
    console.log();

    // Test 3: Process audio buffer
    console.log('🔄 Test 3: Processing audio buffer...');
    const audioBuffer = fs.readFileSync(audioFilePath);
    const bufferResult = await processAudioBuffer(audioBuffer);
    
    if (bufferResult.success) {
      console.log('✅ Buffer processing successful!');
      console.log('📝 Buffer transcript:', bufferResult.transcript.substring(0, 100) + '...');
      console.log('🎯 Buffer confidence:', (bufferResult.confidence * 100).toFixed(1) + '%');
      console.log('📊 Buffer word count:', bufferResult.wordCount);
    } else {
      console.log('❌ Buffer processing failed:', bufferResult.error);
    }
    console.log();

    // Test 4: Quick buffer transcript
    console.log('🔄 Test 4: Quick buffer transcript...');
    const quickBufferTranscript = await getTranscriptFromBuffer(audioBuffer);
    
    if (quickBufferTranscript) {
      console.log('✅ Quick buffer transcript successful!');
      console.log('📝 Quick transcript length:', quickBufferTranscript.length, 'characters');
    } else {
      console.log('❌ Quick buffer transcript failed');
    }
    console.log();

    console.log('🎉 All Audio Processor tests completed!');
    console.log('📊 Available Functions:');
    console.log('   ✅ processAudioFile() - Full processing with metadata');
    console.log('   ✅ processAudioBuffer() - Buffer processing with metadata');
    console.log('   ✅ getTranscriptFromFile() - Quick text extraction from file');
    console.log('   ✅ getTranscriptFromBuffer() - Quick text extraction from buffer');
    console.log('\n🔧 Ready for TalkNotes integration!');

  } catch (error) {
    console.error('❌ Audio processor test failed:', error);
  }
}

// Run the test
testAudioProcessor();

export { testAudioProcessor };

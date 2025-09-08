/**
 * Test for long-running Google Speech-to-Text operations
 * This test demonstrates how the enhanced progress monitoring works
 */

const { processAudioNoteFromDB } = require('../configs/speesh-to-text.config');
const fs = require('fs');
const path = require('path');

// Mock audio URL for testing (you would replace this with a real long audio file)
const testLongAudioUrl = 'https://example.com/long-audio.wav';

/**
 * Test long-running operation with progress monitoring
 * NOTE: This test requires a real audio file > 1 minute to see the progress monitoring in action
 */
async function testLongRunningOperation() {
  console.log('=== Testing Long-Running Speech-to-Text Operation ===\n');
  
  try {
    // For demonstration, we'll use a local test file if it exists
    const testAudioPath = path.join(__dirname, '../configs/harvard.wav');
    
    if (fs.existsSync(testAudioPath)) {
      console.log('Using local test audio file...');
      
      // Read the test file and create a larger version by repeating the content
      // This simulates a longer audio file for testing purposes
      const originalBuffer = fs.readFileSync(testAudioPath);
      const repeatedBuffer = Buffer.concat([
        originalBuffer, originalBuffer, originalBuffer, originalBuffer, originalBuffer
      ]);
      
      console.log(`Original file size: ${(originalBuffer.length / 1024).toFixed(2)} KB`);
      console.log(`Simulated large file size: ${(repeatedBuffer.length / 1024 / 1024).toFixed(2)} MB`);
      
      // Create a temporary file for testing
      const tempLargeFile = path.join(__dirname, '../../tmp/test-large-audio.wav');
      fs.writeFileSync(tempLargeFile, repeatedBuffer);
      
      console.log('\nStarting transcription with progress monitoring...\n');
      
      const startTime = Date.now();
      const result = await processAudioNoteFromDB(`file://${tempLargeFile}`);
      const totalTime = (Date.now() - startTime) / 1000;
      
      console.log('\n=== Results ===');
      console.log(`Success: ${result.success}`);
      console.log(`Total processing time: ${totalTime.toFixed(1)}s`);
      console.log(`Transcript length: ${result.transcript ? result.transcript.length : 0} characters`);
      
      if (result.transcript) {
        console.log(`First 200 characters: "${result.transcript.substring(0, 200)}..."`);
      }
      
      if (result.error) {
        console.log(`Error: ${result.error}`);
      }
      
      // Clean up temp file
      if (fs.existsSync(tempLargeFile)) {
        fs.unlinkSync(tempLargeFile);
        console.log('\nCleaned up temporary test file');
      }
      
    } else {
      console.log('Test audio file not found. To test with a real long audio file:');
      console.log('1. Place a >1 minute audio file in the configs directory');
      console.log('2. Update the testAudioPath variable');
      console.log('3. Run this test again');
    }
    
  } catch (error) {
    console.error('Test failed:', error.message);
    console.error('Stack trace:', error.stack);
  }
}

/**
 * Test the duration estimation function
 */
function testDurationEstimation() {
  console.log('\n=== Testing Duration Estimation ===\n');
  
  const testCases = [
    { sizeMB: 1, encoding: 'MP3', expected: '~1 min' },
    { sizeMB: 5, encoding: 'MP3', expected: '~5 min' },
    { sizeMB: 10, encoding: 'LINEAR16', expected: '~1 min (WAV)' },
    { sizeMB: 2, encoding: 'OGG_OPUS', expected: '~2.5 min' },
    { sizeMB: 0.5, encoding: 'WEBM_OPUS', expected: '~0.6 min' },
  ];
  
  // Note: We can't directly test the estimateAudioDuration function since it's not exported
  // but we can see the estimates in the console output when processing files
  
  testCases.forEach(({ sizeMB, encoding, expected }) => {
    console.log(`${sizeMB}MB ${encoding} file -> Expected: ${expected}`);
  });
  
  console.log('\nActual estimates will be shown in console during audio processing.');
}

// Run tests if this file is executed directly
if (require.main === module) {
  testDurationEstimation();
  testLongRunningOperation().catch(console.error);
}

module.exports = {
  testLongRunningOperation,
  testDurationEstimation
};

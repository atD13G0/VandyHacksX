import 'dart:convert';
import 'dart:io'; // Make sure you have this import
import 'dart:typed_data'; // Import for Uint8List
import 'package:googleapis/texttospeech/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:audioplayers/audioplayers.dart';

class TextToSpeech {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _credentials;

  TextToSpeech(String credentialsPath)
      : _credentials = ServiceAccountCredentials.fromJson({
          'credentials': jsonDecode(File(credentialsPath).readAsStringSync())
        });

  Future<void> speak(String text) async {
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    final client = await clientViaServiceAccount(_credentials, scopes);

    try {
      var ttsApi = TexttospeechApi(client);
      var response = await ttsApi.text.synthesize(
        SynthesizeSpeechRequest(
          input: SynthesisInput(text: text),
          voice: VoiceSelectionParams(
            languageCode: 'en-US',
            name: 'en-US-Wavenet-D',
            ssmlGender: 'NEUTRAL',
          ),
          audioConfig: AudioConfig(
            audioEncoding: 'LINEAR16',
          ),
        ),
      );
      
      var audioBytes = response.audioContent;
      await _audioPlayer.playBytes(Uint8List.fromList(audioBytes)); // Ensure Uint8List is recognized

    } finally {
      client.close();
    }
  }
}

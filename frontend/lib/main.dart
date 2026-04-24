import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const FootballAIApp());
}

class FootballAIApp extends StatelessWidget {
  const FootballAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agentic Football AI',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const FootballDashboard(),
    );
  }
}

class FootballDashboard extends StatefulWidget {
  const FootballDashboard({super.key});

  @override
  State<FootballDashboard> createState() => _FootballDashboardState();
}

class _FootballDashboardState extends State<FootballDashboard> {
  VideoPlayerController? _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isAnalyzing = false;
  
  String _visionText = "Waiting for analysis...";
  String _refereeText = "Waiting for analysis...";
  String _commentaryText = "Waiting for analysis...";
  String _fanText = "Waiting for analysis...";
  String _mediaText = "Waiting for analysis...";
  int _excitementLevel = 0;

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      _controller?.dispose();
      _controller = VideoPlayerController.file(File(result.files.single.path!))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
          _isPlaying = true;
        });
    }
  }

  Future<void> _analyzeCurrentPlay() async {
    if (_controller == null) return;
    
    setState(() {
      _isAnalyzing = true;
    });

    final position = _controller!.value.position.inSeconds;
    final context = "Analyzing video at timestamp $position seconds. Please describe the action, check for fouls, and provide commentary.";

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'video_description': context}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _visionText = data['vision_analysis'] ?? "No vision data";
          _refereeText = data['referee_decision'] ?? "No referee data";
          _commentaryText = data['commentary_text'] ?? "No commentary data";
          _excitementLevel = data['excitement_level'] ?? 5;
          _fanText = data['fan_insight'] ?? "No fan data";
          _mediaText = data['video_generation_prompt'] ?? "No media prompt";
        });
        
        // Play TTS Audio if available
        final audioB64 = data['audio_base64'] as String?;
        if (audioB64 != null && audioB64.isNotEmpty) {
          try {
            Uint8List audioBytes = base64Decode(audioB64);
            await _audioPlayer.play(BytesSource(audioBytes));
          } catch (e) {
            print("Failed to play audio: $e");
          }
        }
      } else {
        setState(() {
          _visionText = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
         _visionText = "Connection error. Make sure backend is running on port 8000.";
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚽ Football Match AI Analyst', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _pickVideo,
            tooltip: 'Upload Video',
          )
        ],
      ),
      body: Row(
        children: [
          // Left Side: Video Player
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: _controller != null && _controller!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          )
                        : const Text('Please upload a video to start', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
                        onPressed: () {
                          setState(() {
                            if (_isPlaying) {
                              _controller?.pause();
                            } else {
                              _controller?.play();
                            }
                            _isPlaying = !_isPlaying;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        icon: _isAnalyzing 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.analytics),
                        label: const Text("Analyze Live Action"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _isAnalyzing ? null : _analyzeCurrentPlay,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Right Side: Agent Insights
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.white12, width: 2))
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Live Agent Insights", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                        if (_excitementLevel > 0)
                          Chip(label: Text("Excitement: $_excitementLevel/10", style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent.withOpacity(0.8)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildInsightCard("Commentator (Audio Active)", Icons.mic, _commentaryText, Colors.purpleAccent),
                    const SizedBox(height: 16),
                    
                    _buildInsightCard("Vision Analyst", Icons.remove_red_eye, _visionText, Colors.blueAccent),
                    const SizedBox(height: 16),
                    
                    _buildInsightCard("Referee Agent", Icons.sports, _refereeText, Colors.orangeAccent),
                    const SizedBox(height: 16),
                    
                    _buildInsightCard("Fan Engagement", Icons.people_alt, _fanText, Colors.pinkAccent),
                    const SizedBox(height: 16),
                    
                    _buildInsightCard("Media / AR Generator", Icons.video_camera_back, _mediaText, Colors.greenAccent),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, IconData icon, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

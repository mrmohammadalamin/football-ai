import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

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
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _chatController = TextEditingController();
  Timer? _pollingTimer;
  bool _isPlaying = false;
  bool _isAnalyzing = false;
  
  String _visionText = "Waiting for analysis...";
  String _refereeText = "Waiting for analysis...";
  String _commentaryText = "Waiting for analysis...";
  String _fanText = "Waiting for analysis...";
  String _mediaText = "Waiting for analysis...";
  int _excitementLevel = 0;

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_isPlaying && !_isAnalyzing) {
        _analyzeCurrentPlay();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    
    if (video != null) {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(video.path))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
          _isPlaying = true;
          _startPolling();
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
    final query = _chatController.text.isNotEmpty ? _chatController.text : null;
    if (query != null) {
      _chatController.clear();
    }

    try {
      final response = await http.post(
        Uri.parse('https://football-ai-backend-480523353991.us-central1.run.app/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'video_description': context,
          if (query != null) 'custom_query': query,
        }),
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
        
        // Play TTS Audio client-side with dynamic energy
        if (_commentaryText.isNotEmpty) {
          try {
            await _flutterTts.setLanguage("en-GB"); // British accent for classic football commentary feel
            
            // Dynamically adjust energy based on the match excitement level
            if (_excitementLevel > 8) {
              await _flutterTts.setPitch(1.3);
              await _flutterTts.setSpeechRate(1.1); // Fast and high pitched
              await _flutterTts.setVolume(1.0);
            } else if (_excitementLevel > 5) {
              await _flutterTts.setPitch(1.1);
              await _flutterTts.setSpeechRate(1.0); // Normal pace
              await _flutterTts.setVolume(0.8);
            } else {
              await _flutterTts.setPitch(1.0);
              await _flutterTts.setSpeechRate(0.9); // Slower, calmer
              await _flutterTts.setVolume(0.7);
            }
            
            await _flutterTts.speak(_commentaryText);
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
         _visionText = "Connection error. Failed to reach the Cloud Run backend.";
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
    _flutterTts.stop();
    _chatController.dispose();
    _pollingTimer?.cancel();
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
                            child: Stack(
                              children: [
                                VideoPlayer(_controller!),
                                // Mock Visual Overlay (Scoreboard)
                                if (_visionText != "Waiting for analysis...")
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal)),
                                      child: const Text("FCB 2 - 1 RMA  |  89:42", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                // Mock Bounding Box
                                if (_visionText != "Waiting for analysis...")
                                  Positioned(
                                    top: 100,
                                    left: 150,
                                    width: 120,
                                    height: 200,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.redAccent, width: 3),
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Align(
                                        alignment: Alignment.topCenter,
                                        child: Text("Key Player", style: TextStyle(color: Colors.redAccent, backgroundColor: Colors.black54, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                // Dynamic Breaking Insight Banner
                                if (_visionText != "Waiting for analysis..." && (_excitementLevel > 7 || _commentaryText.contains("answer to your question")))
                                  Positioned(
                                    bottom: 30,
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text("🔥 BREAKING INSIGHT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 8),
                                          Text(_commentaryText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.video_library, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text('Please upload a video to start', style: TextStyle(color: Colors.grey, fontSize: 18)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Select Video File"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
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
                              _stopPolling();
                            } else {
                              _controller?.play();
                              _startPolling();
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
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.black87,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Ask the Agent a custom question (e.g., "Was that a foul?")',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Ask Agent"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

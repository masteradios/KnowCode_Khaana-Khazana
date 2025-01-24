import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:alz/screens/AddNoteScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class Note {
  final String title;
  final String description;
  final String? audioUrl;
  final String? imageUrl;
  final DateTime timestamp;

  Note({
    required this.title,
    required this.description,
    this.audioUrl,
    this.imageUrl,
    required this.timestamp,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Note(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      audioUrl: data['audioUrl'] as String?,
      imageUrl: data['imageUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, bool> _audioPrefetched = {};

  Future<List<Note>> _fetchNotes({required String userId}) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
  }

  Future<void> _preloadAudio(String url) async {
    if (!_audioPrefetched.containsKey(url)) {
      try {
        await _audioPlayer.setUrl(url);
        _audioPrefetched[url] = true;
      } catch (e) {
        print('Error preloading audio: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context).userModel!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Notes'),
      ),
      body: FutureBuilder<List<Note>>(
        future: _fetchNotes(userId: user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notes found.'));
          }

          List<Note> notes = snapshot.data!;

          return Container(
            color: Color(0xFFF5ECFF),
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                if (note.audioUrl != null) {
                  _preloadAudio(note.audioUrl!);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.imageUrl != null)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(child: CircularProgressIndicator()), // Show while loading
                                Image.network(
                                  note.imageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, color: Colors.grey, size: 100),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          if (note.audioUrl != null)
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                color: isPlaying ? Colors.green : Colors.blue,
                              ),
                              onPressed: () async {
                                if (isPlaying) {
                                  await _audioPlayer.pause();
                                  setState(() {
                                    isPlaying = false;
                                  });
                                } else {
                                  try {
                                    await _audioPlayer.play();
                                    setState(() {
                                      isPlaying = true;
                                    });

                                    _audioPlayer.playerStateStream.listen((state) {
                                      if (state.processingState == ProcessingState.completed) {
                                        setState(() {
                                          isPlaying = false;
                                        });
                                      }
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error playing audio: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          const SizedBox(height: 10),
                          Text(
                            note.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            note.description,
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              height: 1.0,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Created: ${note.timestamp.toLocal()}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

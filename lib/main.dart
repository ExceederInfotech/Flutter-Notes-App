import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_check/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: "AIzaSyCRswsBDZUwkX--R50Aa3FSt4KFP4k5D8Q",
  authDomain: "notes-fe4d9.firebaseapp.com",
  projectId: "notes-fe4d9",
  storageBucket: "notes-fe4d9.firebasestorage.app",
  messagingSenderId: "625979080773",
  appId: "1:625979080773:web:6616388a63dadc94e6a32c",
  measurementId: "G-5VRZFE8310"
    ),
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Notes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PhoneAuthScreen(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _noteController = TextEditingController();

  void _openNoteDialog({String? docId, String? existingNote}) {
    _noteController.text = existingNote ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Add Note' : 'Edit Note'),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(hintText: 'Enter your note'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = _noteController.text.trim();
              if (text.isNotEmpty) {
                if (docId == null) {
                  await _firestore.collection('notes').add({'text': text});
                } else {
                  await _firestore.collection('notes').doc(docId).update({'text': text});
                }
              }
              _noteController.clear();
              Navigator.pop(context);
            },
            child: Text(docId == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(String docId) async {
    await _firestore.collection('notes').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Notes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('notes').snapshots(),
        builder: (context, snapshot) {
          //if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        print("Snapshot: ${snapshot.connectionState} | HasData: ${snapshot.hasData}");

  if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
  }

  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Center(child: Text('No notes yet.'));
  }
          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final doc = notes[index];
              final noteText = doc['text'];

              return ListTile(
                title: Text(noteText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openNoteDialog(docId: doc.id, existingNote: noteText),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteNote(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
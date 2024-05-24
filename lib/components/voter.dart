import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iesportocristo_exposed/auth/auth_manager.dart';
import 'package:provider/provider.dart';

enum CurrentVote { upvote, downvote, none }

class Voter extends StatefulWidget {
  const Voter({super.key, required this.name, required this.type});

  final String type;
  final String name;

  @override
  State<Voter> createState() => _VoterState();
}

class _VoterState extends State<Voter> {
  final db = FirebaseFirestore.instance;

  int vote = 0;
  CurrentVote currentVote = CurrentVote.none;

  void _updateVoteState(Map<String, dynamic> docData, String? userId) {
    final upvotes = List<String>.from(docData["upvotes"] ?? []);
    final downvotes = List<String>.from(docData["downvotes"] ?? []);

    vote = upvotes.length - downvotes.length;
    if (upvotes.contains(userId)) {
      currentVote = CurrentVote.upvote;
    } else if (downvotes.contains(userId)) {
      currentVote = CurrentVote.downvote;
    } else {
      currentVote = CurrentVote.none;
    }
  }

  Future<void> updateVote(CurrentVote newVote) async {
    final userId = context.read<AuthManager>().uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Debes iniciar sesión para votar"),
          duration: Duration(seconds: 1)));
      debugPrint("User not logged in");
      return;
    }

    final query = db.collection(widget.type).doc(widget.name);
    final doc = await query.get();
    final docData = doc.data();
    if (docData == null) return;

    final upvotes = List<String>.from(docData["upvotes"] ?? []);
    final downvotes = List<String>.from(docData["downvotes"] ?? []);

    if (currentVote == newVote) {
      if (newVote == CurrentVote.upvote) {
        upvotes.remove(userId);
        setState(() {
          vote--;
          currentVote = CurrentVote.none;
        });
      } else if (newVote == CurrentVote.downvote) {
        downvotes.remove(userId);
        setState(() {
          vote++;
          currentVote = CurrentVote.none;
        });
      }
    } else {
      if (newVote == CurrentVote.upvote) {
        if (downvotes.contains(userId)) downvotes.remove(userId);
        upvotes.add(userId);
        setState(() {
          vote = vote + 1 + (currentVote == CurrentVote.downvote ? 1 : 0);
          currentVote = CurrentVote.upvote;
        });
      } else if (newVote == CurrentVote.downvote) {
        if (upvotes.contains(userId)) upvotes.remove(userId);
        downvotes.add(userId);
        setState(() {
          vote = vote - 1 - (currentVote == CurrentVote.upvote ? 1 : 0);
          currentVote = CurrentVote.downvote;
        });
      }
    }

    await query
        .update({"upvotes": upvotes, "downvotes": downvotes, "score": vote});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(builder: (context, auth, _) {
      final userId = auth.uid;
      return StreamBuilder<DocumentSnapshot>(
        stream: db.collection(widget.type).doc(widget.name).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
                child: Text("${widget.type} ${widget.name} not found"));
          }

          final docData = snapshot.data!.data() as Map<String, dynamic>;

          _updateVoteState(docData, userId);

          return AnimatedContainer(
            padding: const EdgeInsets.all(8),
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[900]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward_rounded,
                      color: currentVote == CurrentVote.upvote
                          ? Colors.deepOrange
                          : Colors.grey),
                  onPressed: () => updateVote(CurrentVote.upvote),
                ),
                const SizedBox(width: 4),
                AnimatedFlipCounter(
                    value: vote,
                    fractionDigits: 0,
                    textStyle: const TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.arrow_downward_rounded,
                      color: currentVote == CurrentVote.downvote
                          ? Colors.deepPurple
                          : Colors.grey),
                  onPressed: () => updateVote(CurrentVote.downvote),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

// hub_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iseeyou_final/record_detail_1.dart';

class HubScreen extends StatefulWidget {
  final String projectId; // 프로젝트 문서 ID

  const HubScreen({super.key, required this.projectId});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  String projectTitle = '';
  bool isLoadingTitle = true;

  @override
  void initState() {
    super.initState();
    _loadProjectTitle();
  }

  Future<void> _loadProjectTitle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('projects')
            .doc(widget.projectId)
            .get();

    setState(() {
      projectTitle = doc.data()?['projectTitle'] ?? '제목 없음';
      isLoadingTitle = false;
    });
  }

  Future<void> _addObject() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final objectsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('projects')
        .doc(widget.projectId)
        .collection('objects');

    // 모든 objectTitle을 가져옴
    final snapshot = await objectsRef.get();
    final existingTitles =
        snapshot.docs
            .map((doc) => doc.data()['objectTitle'] as String)
            .toList();

    // 기본 이름
    String baseTitle = '새 오브젝트';
    String newTitle = baseTitle;
    int suffix = 1;

    // 중복 검사 및 이름 생성
    while (existingTitles.contains(newTitle)) {
      newTitle = '$baseTitle ($suffix)';
      suffix++;
    }

    // 저장
    await objectsRef.add({
      'objectTitle': newTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'index': DateTime.now().millisecondsSinceEpoch,
    });

    setState(() {}); // 새로고침
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [BackButton()],
              ),
              const SizedBox(height: 20),
              const Icon(Icons.folder_open, size: 70, color: Color(0xFF867FED)),
              const SizedBox(height: 8),
              isLoadingTitle
                  ? const CircularProgressIndicator()
                  : Text(
                    projectTitle,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF867FED),
                    ),
                  ),

              const SizedBox(height: 40),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 100),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                color: Colors.black12,
                                child: const Center(
                                  child: Text(
                                    'Unable to load asset image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _addObject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF867FED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              '추가',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          // SizedBox(height: 30),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50),
                    Expanded(
                      flex: 4,
                      child: FutureBuilder<QuerySnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .collection('projects')
                                .doc(widget.projectId)
                                .collection('objects')
                                .orderBy('index')
                                .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          if (docs.isEmpty) {
                            return const Center(child: Text('기록이 없습니다.'));
                          }

                          return ReorderableListView.builder(
                            itemCount: docs.length,
                            onReorder: (oldIndex, newIndex) async {
                              if (oldIndex < newIndex) newIndex--;
                              final docList = List.from(docs);
                              final moved = docList.removeAt(oldIndex);
                              docList.insert(newIndex, moved);

                              final batch = FirebaseFirestore.instance.batch();
                              for (int i = 0; i < docList.length; i++) {
                                batch.update(docList[i].reference, {
                                  'index': i,
                                });
                              }
                              await batch.commit();
                              setState(() {});
                            },
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              return ListTile(
                                key: ValueKey(docs[index].id),
                                title: Text(data['objectTitle'] ?? '제목 없음'),
                                subtitle: Text(
                                  data['createdAt'] != null
                                      ? (data['createdAt'] as Timestamp)
                                          .toDate()
                                          .toString()
                                      : '날짜 없음',
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              const RecordDetail1(), // <- 대상 페이지
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 100),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

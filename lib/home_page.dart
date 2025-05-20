import 'package:flutter/material.dart';
import 'package:iseeyou_final/ar_preview_screen.dart';
import 'package:iseeyou_final/hub_screen.dart';
import 'package:iseeyou_final/login_page.dart';
import 'package:iseeyou_final/user_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Project {
  String name;
  Project(this.name);
}

class ProjectHomePage extends StatefulWidget {
  const ProjectHomePage({super.key});

  @override
  State<ProjectHomePage> createState() => _ProjectHomePageState();
}

class _ProjectHomePageState extends State<ProjectHomePage> {
  List<Project> deletedProjects = [];

  bool isEditMode = false;
  Set<String> selectedProjectIds = {};

  Future<void> _deleteSelectedProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final toDelete = selectedProjectIds.toList();

    for (final docId in toDelete) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('projects')
          .doc(docId)
          .delete();
    }

    setState(() {
      selectedProjectIds.clear();
    });
  }

  void _addProject() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("새 프로젝트 추가"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "프로젝트 이름을 입력하세요"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(ctx, controller.text.trim());
                  }
                },
                child: const Text("추가"),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('projects')
            .add({
              'projectTitle': result,
              'createdAt': FieldValue.serverTimestamp(),
              'index': DateTime.now().millisecondsSinceEpoch,
            });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ARPreviewScreen()),
        );
      }
    }
  }

  void _openMenu() {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.only(top: 60, right: 30),
            alignment: Alignment.topRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Center(
                      child: Text("환경설정", textScaler: TextScaler.linear(1.5)),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserSettingsPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Center(
                      child: Text("로그아웃", textScaler: TextScaler.linear(1.5)),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                  SizedBox(height: 5),
                  const Divider(),
                  SizedBox(height: 5),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, size: 30),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFF),
      body: Column(
        children: [
          SizedBox(
            width: screenWidth,
            height: screenHeight / 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Transform.scale(
                  scale: 0.4,
                  child: Image.asset('assets/images/iseeyoulogo.png'),
                ),
                Spacer(flex: 2),
                Text(
                  'Project',
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF867FED),
                  ),
                ),
                Spacer(flex: 3),
                IconButton(
                  onPressed: _openMenu,
                  icon: Icon(Icons.account_circle_rounded),
                  color: Color(0xFF867FED),
                  iconSize: 60,
                  padding: EdgeInsets.only(right: 40),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.only(right: 300),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (isEditMode) {
                        // 삭제 실행
                        _deleteSelectedProjects();
                        isEditMode = false;
                        selectedProjectIds.clear();
                      } else {
                        isEditMode = true;
                      }
                    });
                  },
                  child: Text(
                    isEditMode ? '삭제' : '편집',
                    textScaler: TextScaler.linear(2),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('projects')
                      .orderBy('index')
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 200),
                    child: Text(
                      '프로젝트가 존재하지 않습니다.',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ReorderableListView(
                  padding: const EdgeInsets.only(
                    left: 300,
                    right: 300,
                    top: 20,
                    bottom: 200,
                  ),
                  onReorder: (oldIndex, newIndex) async {
                    if (oldIndex < newIndex) newIndex--;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final projectDocs = snapshot.data!.docs;
                    final movedDoc = projectDocs.removeAt(oldIndex);
                    projectDocs.insert(newIndex, movedDoc);

                    WriteBatch batch = FirebaseFirestore.instance.batch();

                    for (int i = 0; i < projectDocs.length; i++) {
                      final docRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('projects')
                          .doc(projectDocs[i].id);

                      batch.update(docRef, {'index': i});
                    }

                    await batch.commit();
                    setState(() {}); // UI 갱신
                  },

                  children: [
                    for (int index = 0; index < docs.length; index++)
                      Dismissible(
                        key: ValueKey(docs[index].id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          final doc = docs[index];
                          final deletedData =
                              doc.data() as Map<String, dynamic>;
                          final deletedId = doc.id;
                          final user = FirebaseAuth.instance.currentUser;

                          // 삭제
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('projects')
                              .doc(deletedId)
                              .delete();

                          // 스낵바로 되돌리기 옵션 제공
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "'${deletedData['projectTitle']}' 삭제됨",
                              ),
                              action: SnackBarAction(
                                label: "되돌리기",
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .collection('projects')
                                      .doc(deletedId)
                                      .set(deletedData);
                                  setState(() {});
                                },
                              ),
                            ),
                          );

                          setState(() {}); // 삭제 후 UI 갱신
                        },

                        background: Container(
                          padding: const EdgeInsets.only(right: 30),
                          margin: const EdgeInsets.only(bottom: 30),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 30),
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            child: ListTile(
                              onTap:
                                  isEditMode
                                      ? null
                                      : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => HubScreen(
                                                  projectId: docs[index].id,
                                                ),
                                          ),
                                        );
                                      },

                              leading:
                                  isEditMode
                                      ? Checkbox(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        value: selectedProjectIds.contains(
                                          docs[index].id,
                                        ),
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              selectedProjectIds.add(
                                                docs[index].id,
                                              );
                                            } else {
                                              selectedProjectIds.remove(
                                                docs[index].id,
                                              );
                                            }
                                          });
                                        },
                                      )
                                      : const Icon(
                                        Icons.folder,
                                        color: Color(0xFF867FED),
                                        size: 35,
                                      ),

                              title: Text(
                                docs[index]['projectTitle'],
                                textScaler: TextScaler.linear(1.5),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // 프로젝트 생성 버튼
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: _addProject,
          backgroundColor: Color(0xFF867FED),
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          child: const Icon(Icons.add, size: 40),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

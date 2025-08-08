
// consult_specialist.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------
// Specialist Model
// ---------------------------
class Specialist {
  final String name;
  final String image;
  final String qualification;
  final String phone;

  Specialist({
    required this.name,
    required this.image,
    required this.qualification,
    required this.phone,
  });
}

// ---------------------------
// Consult Specialist Page
// ---------------------------
class ConsultSpecialistPage extends StatefulWidget {
  const ConsultSpecialistPage({Key? key}) : super(key: key);

  @override
  _ConsultSpecialistPageState createState() => _ConsultSpecialistPageState();
}

class _ConsultSpecialistPageState extends State<ConsultSpecialistPage> {
  final List<Specialist> specialists = [
    Specialist(
      name: "Dr. Aarav Gupta",
      image: "assets/doctor1.jpg",
      qualification: "MBBS, MD (General Medicine)",
      phone: "+919876543210",
    ),
    Specialist(
      name: "Dr. Aisha Khan",
      image: "assets/doctor2.jpg",
      qualification: "MBBS, MD (Cardiology)",
      phone: "+918765432109",
    ),
    Specialist(
      name: "Dr. Aman Verma",
      image: "assets/doctor3.jpg",
      qualification: "MBBS, MS (Orthopedics)",
      phone: "+917654321098",
    ),
    Specialist(
      name: "Dr. Ananya Sharma",
      image: "assets/doctor4.jpg",
      qualification: "MBBS, MD (Gynecology)",
      phone: "+916543210987",
    ),
    Specialist(
      name: "Dr. Arjun Patel",
      image: "assets/doctor5.jpg",
      qualification: "MBBS, MD (Dermatology)",
      phone: "+915432109876",
    ),
    Specialist(
      name: "Dr. Devika Singh",
      image: "assets/doctor6.jpg",
      qualification: "MBBS, MD (Psychiatry)",
      phone: "+914321098765",
    ),
    Specialist(
      name: "Dr. Harsh Mehta",
      image: "assets/doctor7.jpg",
      qualification: "MBBS, MD (Neurology)",
      phone: "+913210987654",
    ),
    Specialist(
      name: "Dr. Ishaan Reddy",
      image: "assets/doctor8.jpg",
      qualification: "MBBS, MS (General Surgery)",
      phone: "+912109876543",
    ),
    Specialist(
      name: "Dr. Kavya Joshi",
      image: "assets/doctor9.jpg",
      qualification: "MBBS, MD (General Medicine)",
      phone: "+911098765432",
    ),
    Specialist(
      name: "Dr. Kunal Kapoor",
      image: "assets/doctor10.jpg",
      qualification: "MBBS, MD (Orthopedics)",
      phone: "+910987654321",
    ),
    Specialist(
      name: "Dr. Meera Nair",
      image: "assets/doctor11.jpg",
      qualification: "MBBS, MD (General Medicine)",
      phone: "+919812345678",
    ),
    Specialist(
      name: "Dr. Mohit Kumar",
      image: "assets/doctor12.jpg",
      qualification: "MBBS, MD (Cardiology)",
      phone: "+918712345679",
    ),
    Specialist(
      name: "Dr. Nandini Roy",
      image: "assets/doctor13.jpg",
      qualification: "MBBS, MD (Dermatology)",
      phone: "+917612345670",
    ),
    Specialist(
      name: "Dr. Neha Iyer",
      image: "assets/doctor14.jpg",
      qualification: "MBBS, MD (Psychiatry)",
      phone: "+916512345671",
    ),
    Specialist(
      name: "Dr. Pranav Desai",
      image: "assets/doctor15.jpg",
      qualification: "MBBS, MD (Neurology)",
      phone: "+915412345672",
    ),
    Specialist(
      name: "Dr. Rhea Chatterjee",
      image: "assets/doctor16.jpg",
      qualification: "MBBS, MD (Gynecology)",
      phone: "+914312345673",
    ),
    Specialist(
      name: "Dr. Rohan Malhotra",
      image: "assets/doctor17.jpg",
      qualification: "MBBS, MD (General Surgery)",
      phone: "+913212345674",
    ),
    Specialist(
      name: "Dr. Sakshi Bhatia",
      image: "assets/doctor18.jpg",
      qualification: "MBBS, MD (General Medicine)",
      phone: "+912112345675",
    ),
    Specialist(
      name: "Dr. Sanjay Verma",
      image: "assets/doctor19.jpg",
      qualification: "MBBS, MD (Orthopedics)",
      phone: "+911012345676",
    ),
    Specialist(
      name: "Dr. Simran Kaur",
      image: "assets/doctor20.jpg",
      qualification: "MBBS, MD (Pediatrics)",
      phone: "+910912345677",
    ),
    Specialist(
      name: "Dr. Varun Jain",
      image: "assets/doctor21.jpg",
      qualification: "MBBS, MD (General Medicine)",
      phone: "+919012345678",
    ),
  ];

  List<Specialist> filteredSpecialists = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSpecialists = specialists;
  }

  void filterSpecialists(String query) {
    final lowerQuery = query.toLowerCase();
    final results = specialists.where((specialist) {
      return specialist.name.toLowerCase().contains(lowerQuery) ||
          specialist.qualification.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      filteredSpecialists = results;
    });
  }

  Future<void> _sendMessageToSpecialist(Specialist specialist) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Messaging feature for ${specialist.name} coming soon."),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _startInAppCall(Specialist specialist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppCallPage(specialist: specialist),
      ),
    );
  }

  void _showConsultOptions(Specialist specialist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                specialist.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.call,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "In-App Call",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _startInAppCall(specialist);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  "Schedule Consultation",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Scheduling consultation with ${specialist.name}..."),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.message,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: Text(
                  "Send a Message",
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessageToSpecialist(specialist);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Consult a Specialist",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: TextField(
                controller: searchController,
                onChanged: filterSpecialists,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Search specialists...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          // List of Specialists
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredSpecialists.length,
              itemBuilder: (context, index) {
                final specialist = filteredSpecialists[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(specialist.image),
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      title: Text(
                        specialist.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          specialist.qualification,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: () => _showConsultOptions(specialist),
                      ),
                      onTap: () => _showConsultOptions(specialist),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// In-App Call Page
// ---------------------------
class InAppCallPage extends StatefulWidget {
  final Specialist specialist;
  const InAppCallPage({Key? key, required this.specialist}) : super(key: key);

  @override
  _InAppCallPageState createState() => _InAppCallPageState();
}

class _InAppCallPageState extends State<InAppCallPage> {
  late Timer _timer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get callTimerText {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top bar with specialist info and call timer
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      widget.specialist.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.specialist.qualification,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      callTimerText,
                      style: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Center specialist profile image
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(widget.specialist.image),
                    radius: 80,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ),
              // Bottom control panel
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Control buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          label: "Mute",
                          isActive: _isMuted,
                          onPressed: () {
                            setState(() {
                              _isMuted = !_isMuted;
                            });
                          },
                        ),
                        _buildControlButton(
                          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                          label: "Speaker",
                          isActive: _isSpeakerOn,
                          onPressed: () {
                            setState(() {
                              _isSpeakerOn = !_isSpeakerOn;
                            });
                          },
                        ),
                        _buildControlButton(
                          icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                          label: "Video",
                          isActive: !_isVideoOff,
                          onPressed: () {
                            setState(() {
                              _isVideoOff = !_isVideoOff;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Hang up button
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.call_end, size: 28),
                      label: const Text(
                        "Hang Up",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

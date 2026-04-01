import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedHalls() async {
  final halls = [
    {
      'title': 'Seminar Room',
      'description': 'Perfect for focused professional discussions.',
      'price': 1000,
      'image': 'assets/images/seminar.jpg',
      'facilities': ['Projector', 'WiFi', 'Microphones'],
    },
    {
      'title': 'Community Hall',
      'description': 'Spacious hall ideal for public gatherings.',
      'price': 2000,
      'image': 'assets/images/community.jpg',
      'facilities': ['Stage', 'Fans', 'WiFi'],
    },
    {
      'title': 'Studio Space',
      'description': 'Creative space for artists and photographers.',
      'price': 1500,
      'image': 'assets/images/studio.jpg',
      'facilities': ['Lighting', 'Soundproofing', 'Backdrop'],
    },
    {
      'title': 'Rooftop Venue',
      'description': 'Breathtaking views for unforgettable events.',
      'price': 2500,
      'image': 'assets/images/rooftop.jpg',
      'facilities': ['Stage', 'Lighting', 'Outdoor Seating'],
    },
    {
      'title': 'Ballroom',
      'description': 'Elegant venue for large formal events.',
      'price': 3500,
      'image': 'assets/images/ballroom.jpg',
      'facilities': ['Chandeliers', 'Sound System', 'Dance Floor'],
    },
  ];

  final hallsRef = FirebaseFirestore.instance.collection('Halls');

  for (var hall in halls) {
    final docId = hall['title'] as String;
    await hallsRef.doc(docId).set(hall);
    print('Seeded: $docId');
  }

  print('✅ All halls seeded successfully.');
}

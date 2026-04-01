import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'styled_page_scaffold.dart';
import 'booking_card.dart';

class ProfileUpdatePage extends StatefulWidget {
  final String username;

  ProfileUpdatePage({required this.username});

  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  String? userDocId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = true;
  bool _obscurePassword = true;

  List<String> _normalizeFacilities(dynamic raw) {
    if (raw == null) return [];
    if (raw is String) {
      return raw.split(',').map((e) => e.trim()).toList();
    }
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('username', isEqualTo: widget.username)
              .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();

        // Save the user doc ID
        userDocId = doc.id;

        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _passwordController.text = data['password'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final query =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('username', isEqualTo: widget.username)
              .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await FirebaseFirestore.instance.collection('Users').doc(docId).update({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text.trim(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));

        Navigator.pop(context);
      }
    }
  }

  void _confirmDeleteBooking(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Cancel Booking"),
          content: Text("Are you sure you want to cancel this booking?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection('hallbook')
                    .doc(docId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking cancelled successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _updateBooking(
    String docId,
    List<String> selectedFacilities,
    double updatedPrice,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('hallbook').doc(docId).update(
        {'AddItem': selectedFacilities, 'Price': updatedPrice},
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating booking: $e')));
    }
  }

  Widget _buildEditProfileForm() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter your email';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Enter your phone number'
                            : null,
              ),
              SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setStateSB) {
                  return TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setStateSB(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Enter a password'
                                : null,
                  );
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        );
  }

  Widget _buildBookingHistory() {
    if (isLoading || userDocId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('hallbook')
                .where('UserID', isEqualTo: userDocId)
                .orderBy('BookTime', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return BookingCard(
                hallName: data['HallType'] ?? 'Hall',
                eventTime: data['EventTime'] ?? '',
                basePrice:
                    (data['Price'] ?? 0) - (data['AddItem']?.length ?? 0) * 50,
                bookedFacilities: _normalizeFacilities(data['AddItem']),
                hallType: data['HallType'] ?? '',
                bookTime: data['BookTime'] ?? Timestamp.now(),
                onDelete: () => _confirmDeleteBooking(docId),
                onEdit:
                    (selectedFacilities, updatedPrice) =>
                        _updateBooking(docId, selectedFacilities, updatedPrice),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: StyledPageScaffold(
        title: 'My Profile',
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Edit Profile', icon: Icon(Icons.person)),
                Tab(text: 'My Bookings', icon: Icon(Icons.event_note)),
              ],
              labelColor: Colors.blueAccent,
              indicatorColor: Colors.blueAccent,
            ),
            Expanded(
              child: TabBarView(
                children: [_buildEditProfileForm(), _buildBookingHistory()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

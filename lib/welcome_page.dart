import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'booking_detail_page.dart';
import 'firestore.dart';
import 'styled_page_scaffold.dart';

enum HallSortOption { alphabeticalAZ, priceLowToHigh, priceHighToLow }

class WelcomePage extends StatefulWidget {
  final String username;
  final VoidCallback onLogout;

  const WelcomePage({
    super.key,
    required this.username,
    required this.onLogout,
  });

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final Map<String, IconData> hallIcons = {
    'Seminar Room': Icons.meeting_room,
    'Community Hall': Icons.groups,
    'Studio Space': Icons.music_video,
    'Rooftop Venue': Icons.terrain,
    'Ballroom': Icons.cake,
  };

  late Future<QuerySnapshot> _hallFuture;
  bool _isSeeding = false;
  double _maxPrice = 5000; // Filter value
  HallSortOption _selectedSort = HallSortOption.alphabeticalAZ;

  double _normalizePrice(dynamic rawPrice) {
    if (rawPrice is num) return rawPrice.toDouble();
    if (rawPrice is String) {
      final cleaned = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  String _sortOptionLabel(HallSortOption option) {
    switch (option) {
      case HallSortOption.alphabeticalAZ:
        return 'Alphabetical A-Z';
      case HallSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case HallSortOption.priceHighToLow:
        return 'Price: High to Low';
    }
  }

  Future<void> _showFiltersBottomSheet() async {
    HallSortOption tempSort = _selectedSort;
    double tempMaxPrice = _maxPrice;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Sort By',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    RadioListTile<HallSortOption>(
                      value: HallSortOption.alphabeticalAZ,
                      groupValue: tempSort,
                      title: const Text('Alphabetical A-Z'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => tempSort = value);
                      },
                    ),
                    RadioListTile<HallSortOption>(
                      value: HallSortOption.priceLowToHigh,
                      groupValue: tempSort,
                      title: const Text('Price: Low to High'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => tempSort = value);
                      },
                    ),
                    RadioListTile<HallSortOption>(
                      value: HallSortOption.priceHighToLow,
                      groupValue: tempSort,
                      title: const Text('Price: High to Low'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => tempSort = value);
                      },
                    ),
                    const Divider(height: 24),
                    Text(
                      'Price Range',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('RM 0 - RM ${tempMaxPrice.toInt()}'),
                    Slider(
                      value: tempMaxPrice,
                      min: 0,
                      max: 5000,
                      divisions: 10,
                      label: 'RM ${tempMaxPrice.toInt()}',
                      onChanged: (val) {
                        setModalState(() => tempMaxPrice = val);
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Min price',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'RM 0',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Max price',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'RM ${tempMaxPrice.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSort = tempSort;
                            _maxPrice = tempMaxPrice;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<QuerySnapshot> _loadHalls({bool attemptAutoSeed = true}) async {
    final hallsRef = FirebaseFirestore.instance.collection('Halls');
    var snapshot = await hallsRef.get();

    if (attemptAutoSeed && snapshot.docs.isEmpty) {
      try {
        await seedHalls();
        snapshot = await hallsRef.get();
      } catch (_) {
        // Keep the empty-state UI when seeding fails (e.g. permission denied).
      }
    }

    return snapshot;
  }

  @override
  void initState() {
    super.initState();
    _hallFuture = _loadHalls();
  }

  Widget _buildFilterBar() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.tune, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'RM${_maxPrice.toInt()}',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    color: cs.primary,
                  ),
                ),
              ),
              PopupMenuButton<HallSortOption>(
                tooltip: 'Sort halls',
                initialValue: _selectedSort,
                onSelected: (value) {
                  setState(() => _selectedSort = value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: HallSortOption.alphabeticalAZ,
                    child: Text('Alphabetical A-Z'),
                  ),
                  const PopupMenuItem(
                    value: HallSortOption.priceLowToHigh,
                    child: Text('Price: Low to High'),
                  ),
                  const PopupMenuItem(
                    value: HallSortOption.priceHighToLow,
                    child: Text('Price: High to Low'),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _sortOptionLabel(_selectedSort),
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.expand_more, color: cs.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _maxPrice,
              min: 0,
              max: 5000,
              divisions: 10,
              activeColor: cs.primary,
              label: 'RM${_maxPrice.toInt()}',
              onChanged: (val) {
                setState(() => _maxPrice = val);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('RM 0', style: TextStyle(color: Colors.black54)),
              Text('RM 5000', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Min price', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 2),
                      Text(
                        'RM 0',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max price', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 2),
                      Text(
                        'RM ${_maxPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _seedSampleHalls() async {
    setState(() {
      _isSeeding = true;
    });

    try {
      await seedHalls();
      setState(() {
        _hallFuture = _loadHalls(attemptAutoSeed: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sample halls added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to seed halls: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledPageScaffold(
      title: 'EventWize',
      actions: [
        if (widget.username.isNotEmpty)
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Update Profile',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {'username': widget.username},
              );
            },
          ),
        IconButton(
          icon: Icon(
            widget.username.isEmpty ? Icons.login : Icons.logout,
            color: Colors.white,
          ),
          tooltip: widget.username.isEmpty ? 'Login' : 'Logout',
          onPressed: () {
            if (widget.username.isEmpty) {
              Navigator.pushNamed(context, '/login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged out successfully')),
              );

              // Navigate after a short delay to avoid setState on unmounted widget
              Future.delayed(Duration(milliseconds: 300), () {
                if (mounted) {
                  widget.onLogout();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              });
            }
          },
        ),
      ],
      body: FutureBuilder<QuerySnapshot>(
        future: _hallFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading halls: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final halls = snapshot.data?.docs ?? [];
          final filteredHalls = halls.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price = _normalizePrice(data['price']);
            return price <= _maxPrice;
          }).toList();

          filteredHalls.sort((a, b) {
            final first = a.data() as Map<String, dynamic>;
            final second = b.data() as Map<String, dynamic>;
            final firstTitle = (first['title'] ?? '').toString().toLowerCase();
            final secondTitle = (second['title'] ?? '')
                .toString()
                .toLowerCase();
            final firstPrice = _normalizePrice(first['price']);
            final secondPrice = _normalizePrice(second['price']);

            switch (_selectedSort) {
              case HallSortOption.alphabeticalAZ:
                return firstTitle.compareTo(secondTitle);
              case HallSortOption.priceLowToHigh:
                return firstPrice.compareTo(secondPrice);
              case HallSortOption.priceHighToLow:
                return secondPrice.compareTo(firstPrice);
            }
          });

          if (filteredHalls.isEmpty) {
            return Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Find Your Perfect Venue',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Browse curated halls with pricing and facilities',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            halls.isEmpty
                                ? 'No halls available yet.\nTap "Add Sample Halls" to create starter data.'
                                : 'No halls found for RM${_maxPrice.toInt()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          if (halls.isEmpty) ...[
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isSeeding ? null : _seedSampleHalls,
                              icon: _isSeeding
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(Icons.add),
                              label: Text(
                                _isSeeding ? 'Seeding...' : 'Add Sample Halls',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredHalls.length,
                  itemBuilder: (context, index) {
                    final hall =
                        filteredHalls[index].data() as Map<String, dynamic>;
                    final title = hall['title'] ?? '';
                    final price = _normalizePrice(hall['price']);

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.97, end: 1),
                      duration: Duration(milliseconds: 260 + (index * 55)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 30),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingDetailsPage(
                                  username: widget.username,
                                  hallData: hall,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.08),
                                  Colors.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.12),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  hallIcons[title] ?? Icons.event,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                'From RM ${price.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.black54),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

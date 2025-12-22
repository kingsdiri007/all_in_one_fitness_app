import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/gym_model.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GymModel> _gyms = [];
  bool _isLoadingGyms = false;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    setState(() {
      _isLoadingGyms = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final location = authProvider.user?.location ?? 'Current Location';
    
    final gyms = await authProvider.getNearbyGyms(location);
    
    setState(() {
      _gyms = gyms;
      _isLoadingGyms = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.splashRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGyms,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome,',
                      style: AppTheme.bodyStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.fullName ?? 'User',
                      style: AppTheme.headingStyle.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    if (user?.fitnessGoal != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Goal: ${user!.fitnessGoal}',
                            style: AppTheme.bodyStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Nearby Gyms Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Gyms',
                    style: AppTheme.subheadingStyle,
                  ),
                  if (user?.location != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user!.location!,
                          style: AppTheme.bodySecondaryStyle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Gyms List
              if (_isLoadingGyms)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_gyms.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: AppTheme.textSecondaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No gyms found',
                          style: AppTheme.bodySecondaryStyle,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _gyms.length,
                  itemBuilder: (context, index) {
                    final gym = _gyms[index];
                    return _buildGymCard(gym);
                  },
                ),

              // Placeholder sections for future features
              const SizedBox(height: 32),
              
              // Uncomment below for future feature sections
              /*
              Text(
                'Your Progress',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 16),
              // Progress widgets here
              
              const SizedBox(height: 32),
              
              Text(
                'Today\'s Workout',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 16),
              // Workout widgets here
              
              const SizedBox(height: 32),
              
              Text(
                'Meal Plan',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 16),
              // Meal plan widgets here
              */
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGymCard(GymModel gym) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    gym.name,
                    style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gym.rating.toStringAsFixed(1),
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    gym.address,
                    style: AppTheme.bodySecondaryStyle,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            Row(
              children: [
                const Icon(
                  Icons.directions_walk,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  gym.distance,
                  style: AppTheme.bodySecondaryStyle,
                ),
              ],
            ),
            
            if (gym.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gym.phone!,
                    style: AppTheme.bodySecondaryStyle,
                  ),
                ],
              ),
            ],
            
            if (gym.amenities.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gym.amenities.map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      amenity,
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

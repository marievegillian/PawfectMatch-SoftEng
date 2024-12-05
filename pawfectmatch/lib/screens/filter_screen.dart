
import 'package:flutter/material.dart';
import 'package:pawfectmatch/screens/home_screen.dart';
import 'package:pawfectmatch/utils/filter_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String selectedGender = "Any";
  RangeValues ageRange = const RangeValues(1, 20);
  double maxDistance = 200;
  List<String> preferredBreeds = [];

  final List<String> genderOptions = ["Any", "Male", "Female"];
 
  final List<String> allBreeds = [
    "Golden Retriever",
    "Labrador",
    "Chihuahua",    
    "Bulldog",    
    // Add more breeds as needed
  ];

  @override
  void initState() {
    super.initState();
    clearPreferences();
    _loadFilters();
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


  Future<void> _loadFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGender = prefs.getString('gender') ?? "Any";
      ageRange = RangeValues(
        prefs.getDouble('ageRangeStart') ?? 0,
        prefs.getDouble('ageRangeEnd') ?? 20,
      );
      maxDistance = prefs.getDouble('maxDistance') ?? 200;
      preferredBreeds = prefs.getStringList('preferredBreeds') ?? [];
    });
  }


  Future<void> _applyFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', selectedGender);
    await prefs.setDouble('ageRangeStart', ageRange.start);
    await prefs.setDouble('ageRangeEnd', ageRange.end);
    await prefs.setDouble('maxDistance', maxDistance);
    await prefs.setStringList('preferredBreeds', preferredBreeds);

    FilterManager().updateFilters({
      'gender': selectedGender,
      'ageRange': ageRange,
      'breeds': preferredBreeds,
      'maxDistance': maxDistance,
    });

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Set Filters",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Color(0xff011F3F),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the screen
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red, // Optional: Change button color
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dog's Gender",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            DropdownButton<String>(
              value: selectedGender,
              isExpanded: true,
              items: genderOptions
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Dog's Age Range",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            RangeSlider(
              values: ageRange,
              min: 0,
              max: 20,
              divisions: 20,
              labels: RangeLabels(
                ageRange.start.round().toString(),
                ageRange.end.round().toString(),
              ),
              onChanged: (values) {
                setState(() {
                  ageRange = values;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Maximum Distance (km)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: maxDistance,
              min: 1,
              max: 200,
              divisions: 100,
              label: maxDistance.round().toString(),
              onChanged: (value) {
                setState(() {
                  maxDistance = value;
                });
              },
            ),
            const SizedBox(height: 20),
            //TEMPORARILY COMMENTED OUT
            //DO NOT REMOVE!!
            // const Text(
            //   "Preferred Breeds",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            // ),
            // Wrap(
            //   spacing: 8,
            //   children: allBreeds.map((breed) {
            //     final isSelected = preferredBreeds.contains(breed);
            //     return FilterChip(
            //       label: Text(breed),
            //       selected: isSelected,
            //       onSelected: (selected) {
            //         setState(() {
            //           if (selected) {
            //             preferredBreeds.add(breed);
            //           } else {
            //             preferredBreeds.remove(breed);
            //           }
            //         });
            //       },
            //     );
            //   }).toList(),
            // ),
            const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _applyFilters,
                  child: const Text(
                    "Apply Filters",
                    style: TextStyle(fontSize: 16),
                  ),
              ),
            ),
          ],
        ),
      ),
    );


    
  }
}

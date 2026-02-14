import 'package:flutter/material.dart';

import '../../../../model/ride/locations.dart';
import '../../../../model/ride_pref/ride_pref.dart';
import '../../../../utils/date_time_utils.dart';
import '../../../theme/theme.dart';
import '../../../widgets/actions/bla_button.dart';
import '../../../../data/dummy_data.dart';

///
/// A Ride Preference Form is a view to select:
///   - A departure location
///   - An arrival location
///   - A date
///   - A number of seats
///
/// The form can be created with an existing RidePref (optional).
///
class RidePrefForm extends StatefulWidget {
  // The form can be created with an optional initial RidePref.
  final RidePref? initRidePref;
  
  // Optional callback when user submits the form
  final Function(RidePref)? onSubmit;

  const RidePrefForm({super.key, this.initRidePref, this.onSubmit});

  @override
  State<RidePrefForm> createState() => _RidePrefFormState();
}

class _RidePrefFormState extends State<RidePrefForm> {
  late Location? departure;
  late DateTime departureDate;
  late Location? arrival;
  late int requestedSeats;


  // Initialize the Form attributes


  @override
  void initState() {
    super.initState();
    
    // Initialize with provided RidePref or use default values
    if (widget.initRidePref != null) {
      departure = widget.initRidePref!.departure;
      departureDate = widget.initRidePref!.departureDate;
      arrival = widget.initRidePref!.arrival;
      requestedSeats = widget.initRidePref!.requestedSeats;
    } else {
      departure = null;
      departureDate = DateTime.now();
      arrival = null;
      requestedSeats = 1;
    }
  }


  // Handle events


  /// Handle departure location selection
  void _selectDeparture() async {
    final selectedLocation = await _showLocationPicker('Select Departure');
    if (selectedLocation != null) {
      setState(() {
        departure = selectedLocation;
      });
    }
  }

  /// Handle arrival location selection
  void _selectArrival() async {
    final selectedLocation = await _showLocationPicker('Select Arrival');
    if (selectedLocation != null) {
      setState(() {
        arrival = selectedLocation;
      });
    }
  }

  /// Handle date selection
  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      setState(() {
        departureDate = pickedDate;
      });
    }
  }

  /// Handle swapping departure and arrival locations
  void _swapLocations() {
    setState(() {
      final temp = departure;
      departure = arrival;
      arrival = temp;
    });
  }

  /// Handle seats increment
  void _incrementSeats() {
    if (requestedSeats < 6) {
      setState(() {
        requestedSeats++;
      });
    }
  }

  /// Handle seats decrement
  void _decrementSeats() {
    if (requestedSeats > 1) {
      setState(() {
        requestedSeats--;
      });
    }
  }

  /// Handle form submission (search button)
  void _submitForm() {
    // Check if all required fields are filled
    if (departure == null || arrival == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select departure and arrival locations')),
      );
      return;
    }

    // Create RidePref object with current form values
    final ridePref = RidePref(
      departure: departure!,
      departureDate: departureDate,
      arrival: arrival!,
      requestedSeats: requestedSeats,
    );

    // Call the onSubmit callback if provided
    if (widget.onSubmit != null) {
      widget.onSubmit!(ridePref);
    }
  }

  /// Show location picker dialog
  Future<Location?> _showLocationPicker(String title) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: fakeLocations.length,
            itemBuilder: (context, index) {
              final location = fakeLocations[index];
              return ListTile(
                title: Text(location.name),
                subtitle: Text(location.country.name),
                onTap: () => Navigator.pop(context, location),
              );
            },
          ),
        ),
      ),
    );
  }


  // Build helper widgets


  /// Build location input field
  Widget _buildLocationInput({
    required String label,
    required Location? value,
    required VoidCallback onTap,
    bool showSwapIcon = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BlaSpacings.m,
              vertical: BlaSpacings.m,
            ),
            child: Row(
              children: [
                // Location icon
                Icon(Icons.location_on_outlined, color: BlaColors.iconLight, size: 20),
                const SizedBox(width: BlaSpacings.m),
                
                // Location text or placeholder
                Expanded(
                  child: value != null
                      ? Text(
                          '${value.name}, ${value.country.name}',
                          style: BlaTextStyles.body.copyWith(color: BlaColors.textNormal),
                        )
                      : Text(
                          label,
                          style: BlaTextStyles.body.copyWith(color: BlaColors.textLight),
                        ),
                ),
                
                // Swap icon (only for departure)
                if (showSwapIcon)
                  GestureDetector(
                    onTap: _swapLocations,
                    child: Icon(Icons.swap_vert, color: BlaColors.primary, size: 18),
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: BlaColors.greyLight),
      ],
    );
  }

  /// Build date input field
  Widget _buildDateInput() {
    return Column(
      children: [
        GestureDetector(
          onTap: _selectDate,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BlaSpacings.m,
              vertical: BlaSpacings.m,
            ),
            child: Row(
              children: [
                // Calendar icon
                Icon(Icons.calendar_today, color: BlaColors.iconLight, size: 20),
                const SizedBox(width: BlaSpacings.m),
                
                // Date text
                Text(
                  DateTimeUtils.formatDateTime(departureDate),
                  style: BlaTextStyles.body.copyWith(color: BlaColors.textNormal),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: BlaColors.greyLight),
      ],
    );
  }

  /// Build seats input field
  Widget _buildSeatsInput() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BlaSpacings.m,
            vertical: BlaSpacings.m,
          ),
          child: Row(
            children: [
              // People icon
              Icon(Icons.person, color: BlaColors.iconLight, size: 20),
              const SizedBox(width: BlaSpacings.m),
              
              // Seats count
              Text(
                '$requestedSeats',
                style: BlaTextStyles.body.copyWith(color: BlaColors.textNormal),
              ),
              
              // Increment/Decrement buttons
              const Spacer(),
              GestureDetector(
                onTap: _decrementSeats,
                child: Icon(Icons.remove_circle_outline, color: BlaColors.primary),
              ),
              const SizedBox(width: BlaSpacings.m),
              GestureDetector(
                onTap: _incrementSeats,
                child: Icon(Icons.add_circle_outline, color: BlaColors.primary),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: BlaColors.greyLight),
      ],
    );
  }

  /// Build search button
  Widget _buildSearchButton() {
    return BlaButton(
      text: 'Search',
      onPressed: _submitForm,
      type: ButtonType.primary,
    );
  }


  // Build the main widget
 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Departure location input
          _buildLocationInput(
            label: 'Where from?',
            value: departure,
            onTap: _selectDeparture,
            showSwapIcon: true,
          ),

          // Arrival location input
          _buildLocationInput(
            label: 'Where to?',
            value: arrival,
            onTap: _selectArrival,
            showSwapIcon: false,
          ),

          // Date input
          _buildDateInput(),

          // Seats input
          _buildSeatsInput(),

          // Search button
          const SizedBox(height: BlaSpacings.m),
          _buildSearchButton(),
        ],
      ),
    );
  }
}
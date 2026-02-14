import 'package:flutter/material.dart';

import '../../../../model/ride/locations.dart';
import '../../../../model/ride_pref/ride_pref.dart';
import '../../../../utils/date_time_utils.dart';
import '../../../theme/theme.dart';
import '../../../widgets/actions/bla_button.dart';
import '../../../../data/dummy_data.dart';
import 'location_picker_dialog.dart';

class RidePrefForm extends StatefulWidget {
  final RidePref? initRidePref;
  final Function(RidePref)? onSubmit;

  const RidePrefForm({super.key, this.initRidePref, this.onSubmit});

  @override
  State<RidePrefForm> createState() => _RidePrefFormState();
}

class _RidePrefFormState extends State<RidePrefForm> {
  late Location? departure;
  late Location? arrival;
  late DateTime departureDate;
  late int requestedSeats;

  @override
  void initState() {
    super.initState();
    if (widget.initRidePref != null) {
      departure = widget.initRidePref!.departure;
      arrival = widget.initRidePref!.arrival;
      departureDate = widget.initRidePref!.departureDate;
      requestedSeats = widget.initRidePref!.requestedSeats;
    } else {
      departure = null;
      arrival = null;
      departureDate = DateTime.now();
      requestedSeats = 1;
    }
  }

  void _selectLocation(bool isDeparture) async {
    final selectedLocation = await _showLocationPicker();
    if (selectedLocation != null) {
      setState(() {
        if (isDeparture) {
          departure = selectedLocation;
        } else {
          arrival = selectedLocation;
        }
      });
    }
  }

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

  void _swapLocations() {
    setState(() {
      final temp = departure;
      departure = arrival;
      arrival = temp;
    });
  }

  void _incrementSeats() {
    if (requestedSeats < 6) {
      setState(() {
        requestedSeats++;
      });
    }
  }

  void _decrementSeats() {
    if (requestedSeats > 1) {
      setState(() {
        requestedSeats--;
      });
    }
  }

  void _submitForm() {
    if (departure == null || arrival == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select departure and arrival locations')),
      );
      return;
    }

    final ridePref = RidePref(
      departure: departure!,
      arrival: arrival!,
      departureDate: departureDate,
      requestedSeats: requestedSeats,
    );

    if (widget.onSubmit != null) {
      widget.onSubmit!(ridePref);
    }
  }

  Future<Location?> _showLocationPicker() async {
    return showDialog(
      context: context,
      builder: (context) => LocationPickerDialog(
        locations: fakeLocations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLocationInput(
            label: 'Where from?',
            value: departure,
            onTap: () => _selectLocation(true),
            showSwapIcon: true,
          ),
          _buildLocationInput(
            label: 'Where to?',
            value: arrival,
            onTap: () => _selectLocation(false),
            showSwapIcon: false,
          ),
          _buildDateInput(),
          _buildSeatsInput(),
          const SizedBox(height: 16),
          BlaButton(
            text: 'Search',
            onPressed: _submitForm,
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }

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
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: BlaColors.iconLight, size: 20),
                const SizedBox(width: 16),
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

  Widget _buildDateInput() {
    return Column(
      children: [
        GestureDetector(
          onTap: _selectDate,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: BlaColors.iconLight, size: 20),
                const SizedBox(width: 16),
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

  Widget _buildSeatsInput() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: BlaColors.iconLight, size: 20),
              const SizedBox(width: 16),
              Text(
                '$requestedSeats',
                style: BlaTextStyles.body.copyWith(color: BlaColors.textNormal),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _decrementSeats,
                child: Icon(Icons.remove_circle_outline, color: BlaColors.primary),
              ),
              const SizedBox(width: 16),
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
}

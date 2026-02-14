import 'package:flutter/material.dart';

import '../../../../model/ride/locations.dart';
import '../../../theme/theme.dart';

class LocationPickerDialog extends StatefulWidget {
  final List<Location> locations;

  const LocationPickerDialog({
    super.key,
    required this.locations,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late TextEditingController _searchController;
  List<Location> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLocations = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.length < 2) {
        _filteredLocations = [];
      } else {
        _filteredLocations = widget.locations
            .where((location) =>
                location.name.toLowerCase().contains(query.toLowerCase()) ||
                location.country.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: BlaColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterLocations,
                    decoration: InputDecoration(
                      hintText: 'Search location',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: BlaTextStyles.body,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: BlaColors.textLight),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: BlaColors.greyLight),
          // Location list
          Flexible(
            child: _filteredLocations.isEmpty && _searchController.text.length < 2
                ? Center(
                    child: Text(
                      'Type to search',
                      style: BlaTextStyles.body.copyWith(color: BlaColors.textLight),
                    ),
                  )
                : _filteredLocations.isEmpty
                    ? Center(
                        child: Text(
                          'No results found',
                          style: BlaTextStyles.body.copyWith(color: BlaColors.textLight),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredLocations.length,
                        itemBuilder: (context, index) {
                          final location = _filteredLocations[index];
                          return _LocationRow(
                            location: location,
                            onTap: () => Navigator.pop(context, location),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;

  const _LocationRow({
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: BlaColors.iconLight, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            // Location details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: BlaTextStyles.body.copyWith(color: BlaColors.textNormal),
                  ),
                  Text(
                    location.country.name,
                    style: BlaTextStyles.body.copyWith(
                      color: BlaColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Right arrow
            Icon(Icons.chevron_right, color: BlaColors.iconLight),
          ],
        ),
      ),
    );
  }
}

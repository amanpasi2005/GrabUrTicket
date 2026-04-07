import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminMapPicker extends StatefulWidget {
  const AdminMapPicker({super.key});

  @override
  State<AdminMapPicker> createState() => _AdminMapPickerState();
}

class _AdminMapPickerState extends State<AdminMapPicker> {

  LatLng selectedLocation = const LatLng(19.0760, 72.8777); // Mumbai default

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Theatre Location"),
      ),

      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation,
              zoom: 14,
            ),

            onTap: (LatLng location){
              setState(() {
                selectedLocation = location;
              });
            },

            markers: {
              Marker(
                markerId: const MarkerId("theatre"),
                position: selectedLocation,
              )
            },
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: (){
                Navigator.pop(context, selectedLocation);
              },
              child: const Text("Select Location"),
            ),
          )

        ],
      ),
    );
  }
}
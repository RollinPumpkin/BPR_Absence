import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class LeafletService {
  static void initializeMap(String containerId, double lat, double lng) {
    if (kIsWeb) {
      // Create map container if it doesn't exist
      final container = html.document.getElementById(containerId);
      if (container != null) {
        // Initialize Leaflet map
        js.context.callMethod('eval', ['''
          if (typeof window.maps === 'undefined') {
            window.maps = {};
          }
          
          // Remove existing map if any
          if (window.maps['$containerId']) {
            window.maps['$containerId'].remove();
          }
          
          // Create new map
          var map = L.map('$containerId').setView([$lat, $lng], 15);
          
          // Add OpenStreetMap tiles
          L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
          }).addTo(map);
          
          // Add marker
          var marker = L.marker([$lat, $lng]).addTo(map);
          
          // Store map reference
          window.maps['$containerId'] = map;
          window.maps['$containerId'].marker = marker;
        ''']);
      }
    }
  }

  static void updateMapLocation(String containerId, double lat, double lng) {
    if (kIsWeb) {
      js.context.callMethod('eval', ['''
        if (window.maps && window.maps['$containerId']) {
          var map = window.maps['$containerId'];
          var marker = window.maps['$containerId'].marker;
          
          // Update map view
          map.setView([$lat, $lng], 15);
          
          // Update marker position
          if (marker) {
            marker.setLatLng([$lat, $lng]);
          } else {
            // Create new marker if doesn't exist
            window.maps['$containerId'].marker = L.marker([$lat, $lng]).addTo(map);
          }
        }
      ''']);
    }
  }

  static void removeMap(String containerId) {
    if (kIsWeb) {
      js.context.callMethod('eval', ['''
        if (window.maps && window.maps['$containerId']) {
          window.maps['$containerId'].remove();
          delete window.maps['$containerId'];
        }
      ''']);
    }
  }
}
//
//  MapViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import UIKit
import MapKit

/// MapViewController - A simple, embeddable map view controller
/// Can be embedded into any parent view controller when needed to display a map
/// Follows the app's architecture pattern by inheriting from EcoViewController
public final class MapViewController: EcoViewController {
    
    // MARK: - Public Properties
    
    /// The map view instance - exposed for direct access if needed
    public let mapView = MKMapView()
    
    /// Map controller - accessed through controller property from EcoViewController
    private var mapController: MapController! {
        get { controller as? MapController }
    }
    
    // MARK: - Private Properties
    
    private var isInitialSetup = false
    
    // MARK: - Lifecycle
    
    /// Factory method to create MapViewController with MapController
    /// - Parameter mapController: The map controller instance
    /// - Returns: Configured MapViewController instance
    public static func create(
        with mapController: MapController
    ) -> MapViewController {
        let viewController = MapViewController.instantiateViewController()
        // Inject controller for EcoViewController - DI pattern
        viewController.controller = mapController
        
        // Set reference in controller for direct access if needed
        if let defaultController = mapController as? DefaultMapController {
            defaultController.setMapViewController(viewController)
        }
        
        return viewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapController?.onViewWillAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapController?.onViewDidDisappear()
    }
    
    deinit {
        mapView.delegate = nil
    }
    
    // MARK: - Common Binding Override
    
    public override func bindCommon() {
        super.bindCommon()
        bindMapSpecific()
    }
    
    // MARK: - Map-Specific Binding
    
    private func bindMapSpecific() {
        guard let controller = mapController else { return }
        
        // Bind locations
        controller.locations.observe(on: self) { [weak self] locations in
            self?.renderLocations(locations)
        }
        
        // Bind current location
        controller.currentLocation.observe(on: self) { [weak self] coordinate in
            guard let coordinate = coordinate else { return }
            self?.moveCamera(to: coordinate)
        }
    }
    
    // MARK: - Loading Handler Override
    
    public override func handleLoading(_ isLoading: Bool) {
        super.handleLoading(isLoading)
        // Handle loading state if needed
        // For example: show/hide loading indicator on map
    }
    
    // MARK: - Error Handler Override
    
    public override func handleError(_ error: Error?) {
        guard let error = error else { return }
        // Use default error handling from EcoViewController
        showAlert(title: mapController?.screenTitle ?? "Error", message: error.localizedDescription)
    }
    
    // MARK: - Setup
    
    private func setup() {
        guard !isInitialSetup else { return }
        isInitialSetup = true
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        // Configure map appearance
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = false
    }
}

// MARK: - Public Map Methods

extension MapViewController {
    
    /// Render locations on the map
    /// - Parameter locations: Array of location models to display
    public func renderLocations(_ locations: [MapLocationModel]) {
        mapView.removeAnnotations(mapView.annotations)
        
        guard !locations.isEmpty else { return }
        
        let annotations = locations.map { model -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.coordinate = model.coordinate
            pin.title = model.title
            pin.subtitle = model.subtitle
            return pin
        }
        
        mapView.addAnnotations(annotations)
        
        // Show all annotations with appropriate padding
        if annotations.count == 1 {
            // Single location: center on it with default distance
            moveCamera(to: annotations[0].coordinate)
        } else {
            // Multiple locations: show all with padding
            mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    /// Render route on the map
    /// - Parameter route: Route model containing polyline and route information
    public func renderRoute(_ route: MapRouteModel) {
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(route.polyline)
        
        // Adjust map to show the entire route
        let padding: CGFloat = 50
        let insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        mapView.setVisibleMapRect(
            route.polyline.boundingMapRect,
            edgePadding: insets,
            animated: true
        )
    }
    
    /// Move camera to a specific coordinate
    /// - Parameters:
    ///   - coordinate: Target coordinate
    ///   - distance: Distance in meters for the region (default: 800m)
    public func moveCamera(to coordinate: CLLocationCoordinate2D,
                          distance: CLLocationDistance = 800) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: distance,
            longitudinalMeters: distance
        )
        mapView.setRegion(region, animated: true)
    }
    
    /// Clear all annotations from the map
    public func clearLocations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    /// Clear all overlays (routes) from the map
    public func clearRoute() {
        mapView.removeOverlays(mapView.overlays)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView,
                        rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Handle annotation selection if needed
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Handle annotation deselection if needed
    }
}

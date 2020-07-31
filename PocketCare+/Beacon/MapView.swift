/*
Copyright 2020 University at Buffalo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import MapKit

struct MapView {
    
    var southCampus: MKPolygon
    var northCampus: MKPolygon
    var medicalCampus: MKPolygon
    
    init() {
        // MARK: North Campus
        let n1 = CLLocation(latitude: 43.004205, longitude: -78.777978)
        let n2 = CLLocation(latitude: 43.002959, longitude: -78.774168)
        let n3 = CLLocation(latitude: 42.997753, longitude: -78.774152)
        let n4 = CLLocation(latitude: 42.996836, longitude: -78.787486)
        let n5 = CLLocation(latitude: 42.991398, longitude: -78.788720)
        let n6 = CLLocation(latitude: 42.991178, longitude: -78.798698)
        let n7 = CLLocation(latitude: 42.992151, longitude: -78.799813)
        let n8 = CLLocation(latitude: 42.993697, longitude: -78.799663)
        let n9 = CLLocation(latitude: 42.994686, longitude: -78.801621)
        let n10 = CLLocation(latitude: 42.995722, longitude: -78.800934)
        let n11 = CLLocation(latitude: 42.997856, longitude: -78.798638)
        let n12 = CLLocation(latitude: 42.998209, longitude: -78.796310)
        let n13 = CLLocation(latitude: 43.005418, longitude: -78.792965)
        let n14 = CLLocation(latitude: 43.012328, longitude: -78.793722)
        let n15 = CLLocation(latitude: 43.012484, longitude: -78.792227)
        let n16 = CLLocation(latitude: 43.010867, longitude: -78.788599)
        let n17 = CLLocation(latitude: 43.011293, longitude: -78.782253)
        let n18 = CLLocation(latitude: 43.007702, longitude: -78.781399)
        let n19 = CLLocation(latitude: 43.005361, longitude: -78.785824)
        let n20 = CLLocation(latitude: 43.003488, longitude: -78.785901)
        
        let northCampusCoordinates = [n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11,n12,n13,n14,n15,n16,n17,n18,n19,n20,n1]
        let northcoordinates = northCampusCoordinates.map { $0.coordinate }
        northCampus = MKPolygon(coordinates: northcoordinates, count: northcoordinates.count)
        
        // MARK: South campus
        let s0 = CLLocation(latitude: 42.958522, longitude: -78.814031)
        let s1 = CLLocation(latitude: 42.958479, longitude: -78.815913)
        let s2 = CLLocation(latitude: 42.957462, longitude: -78.818585)
        let s3 = CLLocation(latitude: 42.955535, longitude: -78.820811)
        let s4 = CLLocation(latitude: 42.954855, longitude: -78.819690)
        let s5 = CLLocation(latitude: 42.954121, longitude: -78.820575)
        let s6 = CLLocation(latitude: 42.953865, longitude: -78.820100)
        let s7 = CLLocation(latitude: 42.952283, longitude: -78.822010)
        let s8 = CLLocation(latitude: 42.951917, longitude: -78.821538)
        let s9 = CLLocation(latitude: 42.950704, longitude: -78.822954)
        let s10 = CLLocation(latitude: 42.949730, longitude: -78.821318)
        let s11 = CLLocation(latitude: 42.950143, longitude: -78.820717)
        let s12 = CLLocation(latitude: 42.949593, longitude: -78.819569)
        let s13 = CLLocation(latitude: 42.949577, longitude: -78.818496)
        let s14 = CLLocation(latitude: 42.950103, longitude: -78.818523)
        let s15 = CLLocation(latitude: 42.950119, longitude: -78.814224)
        let s16 = CLLocation(latitude: 42.949371, longitude: -78.814202)
        let s17 = CLLocation(latitude: 42.949367, longitude: -78.813875)
        let s18 = CLLocation(latitude: 42.958522, longitude: -78.814031)
        
        let locationCoordinates = [s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s0]
        let coordinates = locationCoordinates.map { $0.coordinate }
        southCampus = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        // MARK: Medical campus
        let c1 = CLLocation(latitude: 42.902094, longitude: -78.861505)
        let c2 = CLLocation(latitude: 42.902166, longitude: -78.868886)
        let c3 = CLLocation(latitude: 42.898646, longitude: -78.870002)
        let c4 = CLLocation(latitude: 42.898572, longitude: -78.869084)
        let c5 = CLLocation(latitude: 42.896851, longitude: -78.869620)
        let c6 = CLLocation(latitude: 42.896804, longitude: -78.868451)
        let c7 = CLLocation(latitude: 42.894961, longitude: -78.868946)
        let c8 = CLLocation(latitude: 42.894307, longitude: -78.865062)
        let c9 = CLLocation(latitude: 42.898521, longitude: -78.863593)
        let c10 = CLLocation(latitude: 42.898557, longitude: -78.862649)
        
        let mecidalCampusCoordinates = [c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c1]
        let medicalcoordinates = mecidalCampusCoordinates.map { $0.coordinate }
        medicalCampus = MKPolygon(coordinates: medicalcoordinates, count: medicalcoordinates.count)
        
    }

}
    
    

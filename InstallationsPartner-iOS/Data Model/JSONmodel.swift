struct JSONlogin: Codable {
    let access_token: String?
    let token_type: String?
    let emailConfirmed: String?
    let expires_in : Int?
    let roles: String?
    let userName: String?
    let expires: String?
    let issued: String?
    
    let error: String?
    let error_description: String?
}

struct JSONgetUserData: Codable {
    let userDisplayName: String?
    let userId: String?
    let companyId: String?
    let companyName: String?
    let roles: [String?]
    
    let error: String?
    let error_description: String?
}

struct JSONgetCompanyAddress: Codable {
    let address_id: Int?
    let is_shipping_address: Bool?
    let street_address: String?
    let city_name: String?
    let postal_code: String?
    let region_name: String?
    let country_name: String?
    
    let first_name: String?
    let last_name: String?
    let company_name: String?
    let contact_telephone: String?
    let geocoding_not_found: Bool?
    
    let numeric_telephone_1: String?
    let numeric_telephone_2: Int?
}

//MARK: - Post Protocol
struct JSONpostProtocolBody: Encodable {
    let Title: String = "Protokoll"
    var OrderId: Int?
    var installationProtocolType: ProtocolType?
    var InstallerName: String?
    var otherSignature: Bool?
    var SignatureName: String?
    var signaturePersonalNumber: String?
    
    //Base64
    var signatureData: String?
    var PhotoBase64: String?
    
    //Lists
    var checkList: ProtocolCheckList?
    var heatPumps: [ProtocolHeatPump]?
}
struct ProtocolType: Encodable {
    let val: Int?
    let name: String?
}
struct ProtocolCheckList: Encodable  {
    var extraWork: Int? //extra payment
    var comment: String?
    var certNumber: Int?
    
    //ll 5ea
    var runOffCheck: Int?
    var heatPumpOperationWalkthrough: Int?
    var installationCompleted: Int?
    var installedWithPlug: Int?
    var customerElectrician: Int?
        
    //lvfl 18ea
    var filterInstalled: Int?
    var circulationPumpVerified: Int?
    var manometerPressure: Int?
    var ventilatedBuilding: Int?
    var valveCheck: Int?
    var circulationPumpRate: String?
    var spillWaterCheck: Int?
    var instructionWalkthrough: Int?
    var floorHeating: Int?
    var floorHeatingInstallationOnly: Int?
    var controlSystemParametersCheck: Int?
    var clearUp: Int?
    var ppElectricalInstallation: Int?
    var cableThickness: String?
    var inPower: Int?
    var switchCheck: Int?
    var pumpStartCheck: Int?
    var installationNotCompleted: Int?
    
    //reclaim 5ea
    var productError: Int?
    var installationError: Int?
    var productMisplaced: Int?
    var buildingError: Int?
    var errorSolved: Int?
}
struct ProtocolHeatPump: Encodable {
    var name: String?
    var serialNumbers: [Pump]?
}
struct Pump: Encodable {
    var serialNumber: String?
    var type: PumpType?
}
struct PumpType: Encodable {
    var val: Int?
    var name: String?
}

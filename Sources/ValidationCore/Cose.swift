//
//  Cose.swift
//  
//
//  Created by Dominik Mocher on 07.04.21.
//

import Foundation

struct Cose {
    let header : CoseHeader
    let payload : VaccinationData
    let signature : Data
    //READABLE COSE
            //18([<< {4: "H2RriOS8J/Y=", 1: -7} >>, {}, << {"person": {"name": {"family": "Musterfrau", "given": "Gabi"}, "birthDate": "1999-04-20", "gender": "female", "identifier": {"system": "some URI e.g. defining citizen ID", "varue": "c228f2ff"}}, "pastInfection": {"disease": "U07.1", "dateFirstPositiveTest": "2020-12-20", "countryOfTest": "AT"}, "certificateMetadata": {"issuer": "BMGSPK, Vienna, Austria", "identifier": "01ATBA712FE030C797287CB97334452966470042", "validFrom": "2021-01-20", "validUntil": "2021-07-20", "schemaVersion": "1.0.0"}} >>, h'FED92618A2C4EBEE97E8A5B73509CE27F3FA28641558A05693AC49F5C1C96F9E9182E3A125039ADFC81E4488BEAC86DDA71E88E769200B53AAF342D555C28009'])
            
            //Data
            /*
             D2                                      # tag(18)
                84                                   # array(4)
                   51                                # bytes(17)
                      A2046C48325272694F53384A2F593D0126 # "\xA2\x04lH2RriOS8J/Y=\x01&"
                   A0                                # map(0)
                   59 0191                           # bytes(401)
                      BF66706572736F6EBF646E616D65BF6666616D696C796A4D75737465726672617565676976656E6447616269FF696269727468446174656A313939392D30342D32306667656E6465726666656D616C656A6964656E746966696572BF6673797374656D7821736F6D652055524920652E672E20646566696E696E6720636974697A656E2049446576616C7565686332323866326666FFFF6D70617374496E66656374696F6EBF6764697365617365655530372E3175646174654669727374506F736974697665546573746A323032302D31322D32306D636F756E7472794F6654657374624154FF7363657274696669636174654D65746164617461BF6669737375657277424D4753504B2C205669656E6E612C20417573747269616A6964656E7469666965727828303141544241373132464530333043373937323837434239373333343435323936363437303034326976616C696446726F6D6A323032312D30312D32306A76616C6964556E74696C6A323032312D30372D32306D736368656D6156657273696F6E65312E302E30FFFF # "\xBFfperson\xBFdname\xBFffamilyjMusterfrauegivendGabi\xFFibirthDatej1999-04-20fgenderffemalejidentifier\xBFfsystemx!some URI e.g. defining citizen IDevaluehc228f2ff\xFF\xFFmpastInfection\xBFgdiseaseeU07.1udateFirstPositiveTestj2020-12-20mcountryOfTestbAT\xFFscertificateMetadata\xBFfissuerwBMGSPK, Vienna, Austriajidentifierx(01ATBA712FE030C797287CB97334452966470042ivalidFromj2021-01-20jvalidUntilj2021-07-20mschemaVersione1.0.0\xFF\xFF"
                   58 40                             # bytes(64)
                      FED92618A2C4EBEE97E8A5B73509CE27F3FA28641558A05693AC49F5C1C96F9E9182E3A125039ADFC81E4488BEAC86DDA71E88E769200B53AAF342D555C28009 # "\xFE\xD9&\x18\xA2\xC4\xEB\xEE\x97\xE8\xA5\xB75\t\xCE'\xF3\xFA(d\x15X\xA0V\x93\xACI\xF5\xC1\xC9o\x9E\x91\x82\xE3\xA1%\x03\x9A\xDF\xC8\x1ED\x88\xBE\xAC\x86\xDD\xA7\x1E\x88\xE7i \vS\xAA\xF3B\xD5U\xC2\x80\t"
             */
}

struct CoseHeader {
    var keyId : String
    var algorithm : Int
    
    enum Headers : Int {
        case keyId = 4
        case algorithm = 1
    }
    
    init?(from object: NSObject?){
        guard let dict = object as? [Int: NSObject],
              let keyId = dict[Headers.keyId.rawValue] as? String,
              let algorithm = dict[Headers.algorithm.rawValue] as? Int
              else {
            return nil
        }
        self.keyId = keyId
        self.algorithm = algorithm
    }
}




struct VaccinationData : Decodable {
    var person: Person?
    var vaccinations: [Vaccination]?
    var pastInfection: PastInfection?
    var test: Test?
    var certificateMetadata: CertificateMetadata?
}

struct Person : Decodable {
    var name: Name?
    var birthDate: String?
    var gender: String?
    var identifier: Identifier?
}

struct Identifier : Decodable {
    var system: String?
    var value: String?
}

struct Name : Decodable {
    var family: String?
    var given: String?
}

struct Vaccination : Decodable {
    var disease: String?
    var vaccine: String?
    var medicinialProduct: String?
    var marketingAuthorizationHolder: String?
    var manufacturer: String?
    var number: Int?
    var numberOf: Int?
    var lotNumber: String?
    var batch: String?
    var vaccinationDate: String?
    var nextVaccinationDate: String?
    var administeringCentre: String?
    var healthprofessionaIdentification: String?
    var countryOfVaccination: String?
    var country: String?
}

struct PastInfection : Decodable {
    var disease: String?
    var dateFirstPositiveTest: String?
    var countryOfTest: String?
}

struct CertificateMetadata : Decodable {
    var issuer: String?
    var identifier: String?
    var validFrom: String?
    var validUntil: String?
    var validUntilextended: String?
    var revokelistidentifier: String?
    var schemaVersion: String?
}

struct Test : Decodable {
    var disease: String?
    var type: String?
    var name: String?
    var manufacturer: String?
    var sampleOrigin: String?
    var timeStampSample: String?
    var timeStampResult: String?
    var result: String?
    var facility: String?
    var facilityAddress: String?
    var healthprofessionaIdentification: String?
    var country: String?
}

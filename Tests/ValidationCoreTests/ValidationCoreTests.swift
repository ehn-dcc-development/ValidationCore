import Foundation
import Quick
import Nimble
import OHHTTPStubsSwift
import OHHTTPStubs
import XCTest
import ValidationCore


class ValidationCoreSpec: QuickSpec {
    
    override func spec() {
        describe("The validation core") {
            
            var validationCore : ValidationCore!
            
            beforeEach {
                validationCore = ValidationCore()
            }
            
            it("should verify correct test certificate") {
                let encodedEHNCert = "AT01NCFFZAFY7AP2Z33V94*GRH9CYNOMKQ2JED4O3/J8UNL81+UKI7D16L1LI*KGDWMO4FI/D*XOD+T070Q+18I1E72U844PKZ*IAHE5.APZMR*O67RV9W/ TN9L/ SMOH+$V2UFJ1U68UHSJP:O5%KU2S0YP*FGCCMM NVTM5AOEDJESL/2AJCJYAA3RFVJQUU7.4SLSD/YTEJLB/AL9J67M4SAH1KENJPSG H85$5V73+T5NKTFOV1TN ENZ 7GXS-PIA3VR*RLBFALHNYT23E/E4OERV:DQXETMTTWA9 6KI9OYA  29YM-ENE02/C64MNX5CINF$K4AQON 29$QP3NN3J$3VVT7RH8FBNQJGKLCQ/APA9823TGR162E:H$I72/6EDQ176GR71CUIV3*29J*SAJ0WZSI19400OAJK92EQ29+KI6R$B3KT9J VDGS:*2SCHQZN9Y26+ELGN.T2CJD/+N1I6+%MI*MB*OQLOGXAAL3M8CFLI7G6PP15001C4CIPWSBUBE1-O-52CG4OA9LGM%LNNZJOG8CY5OLO:CAT0HK-O3P8P9Q00EMQQA2P4OJAPNVYBVW7T 5-$J82L1TBA3EC:F2-T-$F.ZJ*%BO3SU8K4GWVSQQRERYQ.6MW-FWXM3/T:6B0MVW.FDRR0O3:YPR7HXWUOOU8.R/2HJI0:ZI 1"
                let keyId = "iKfg6J9vRAs="
                let encodedSignatureCert = "MIIBHTCBxaADAgECAgUAmPnkfDAKBggqhkjOPQQDAjANMQswCQYDVQQDDAJNZTAeFw0yMTA0MTMwODUwNDBaFw0yMTA1MTMwODUwNDBaMA0xCzAJBgNVBAMMAk1lMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEee/SfuBBqhUjuOla5zGjT/k+jN0jVyEg6p3NBoCMNSpZe48/rQAXixsBoyFFY9b7klfE9zLFlDnOyBb5yxGSFqMSMBAwDgYDVR0PAQH/BAQDAgWgMAoGCCqGSM49BAMCA0cAMEQCIEFlEb8tnqoG8m03ScuHp1tEI40IXO4fFyT1JuJ4C5xrAiBk3ZoQtLVyujUfHiNVe6+EL5aQYgzD4zTCA7pVSxcG/w=="
                self.mockSignatureCert(keyId, encodedSignatureCert)
                validationCore.validate(encodedData: encodedEHNCert) { result in
                    switch result {
                    case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                    case .failure: XCTFail("Should not result in error")
                    }
                }
                
            }
            
            it("should verify correct vaccination certificate") {
                let encodedEHNCert = "AT01NCFI.L29OZVQ9S2H-IQC0K GF94AKI: QBD2AEU /7.-1791I:KI-MSTLWNIAYNOA7XQC1SGG*6K.5NL4LR9+N0MFUBQ2J89V/J%I0JFISAISICB3B+60Z$0BANGAL%ZQ8ZUD4E06D :SBR4TU0%DVF2BJ8V$VLY-G%WKR+KNOEGH7X1HPF33VH0-02URPJ7L:BU/89WSHWPULBIKMD%U7X9Y4I8V18FN14DM6LNI9E4TFR6S3KZ86QVJZ CR*5RCG3W88ZG4NB%+OJQG8E4.VG2 R4 BKF6AZHDOLRU0TTN.XUL$4K%6M/INJSTKR1R8%DFQ37X$1VMVTPNZVNOHBKLBRIOY+8GX2.6E6X9M009BCGEMNCS3C61CL7QHNU2AECF/EV%NKTD774PI2GLC2F7*N8UMRL1DC6NUOCAD2XE24462%AP*HSLO.O4-0N9O9E.JCSVEXAFAOI.A4BL2+V:$C861OM7+/SS2KTNIRUDN7OJ$KJXA+EQQD0+*GE69D$5T$7YGI 32-.U:G4C6SG+HJATU-5D3N-Y5WHEO 046NNO7PWK0 EDN3.I4E*HMZTFZ8Z Q$87A9BI BKKIQW0CD0Y 680G818IFCZQVXCKU-F3PTQRI06CS15COJT%HQR7E4VO$T/NRYTKG38%5O*43J-CFITPGBGSPOOQQWTNEVOWNNAT:7UV1ATP7M/5V6F$1"
                let keyId = "iKfg6J9vRAs="
                let encodedSignatureCert = "MIIBHTCBxaADAgECAgUAmPnkfDAKBggqhkjOPQQDAjANMQswCQYDVQQDDAJNZTAeFw0yMTA0MTMwODUwNDBaFw0yMTA1MTMwODUwNDBaMA0xCzAJBgNVBAMMAk1lMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEee/SfuBBqhUjuOla5zGjT/k+jN0jVyEg6p3NBoCMNSpZe48/rQAXixsBoyFFY9b7klfE9zLFlDnOyBb5yxGSFqMSMBAwDgYDVR0PAQH/BAQDAgWgMAoGCCqGSM49BAMCA0cAMEQCIEFlEb8tnqoG8m03ScuHp1tEI40IXO4fFyT1JuJ4C5xrAiBk3ZoQtLVyujUfHiNVe6+EL5aQYgzD4zTCA7pVSxcG/w=="
                self.mockSignatureCert(keyId, encodedSignatureCert)
                validationCore.validate(encodedData: encodedEHNCert) { result in
                    switch result {
                    case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                    case .failure: XCTFail("Should not result in error")
                    }
                }
                
            }
            
            it("should verify correct recovery certificate") {
                let encodedEHNCert = "AT01NCFOXNMG2N9HP15TL7Z1S XPYT5XLM60JO DJS4L$S-%27XK3/PAVDK81 CS 43ZP32S4/-2F*8XJ6K0AI%5WSRLZI19JA2K7VA$IJVTIDZI59JVOBSVBDKBO.A29BWZJ$7K+ CUEDDIKZ9C.PD 1JC2KG7JY1J/QJAVANGJE5G6JC/JEDAGZJCI1I$II6IHPUK8WM7KMUPSFGWGTIYJAKET71AKJP-5Q746B46O1N646IN9CB9QJPNF6OE6%K3UCIQYJLE1YCPQBWAMPGX88 VOH6CN5B$FNXUJRH0LH%Y2 UQ7S7TK24H9GUE7R3V-D%PPYO0N3B-.DGFTVJC9VCREDDKDG8C6/DDVCE8CFVCTJC3VC-.DBVCM+CWU62 Q%559VA7%0*CP.BH PP394AL8322/9719DLIAKCA:IJ63KFGW172S8J E7I*C69O8$JDCFG6L-C42ES2AO3UMSVVKPJ*1WFMB9FWK SIQF**CSIN7-910W%ISF5MA-F.K5I921PSG7K/VA5.4H8W:8F*DQ2206QN-2"
                let keyId = "iKfg6J9vRAs="
                let encodedSignatureCert = "MIIBHTCBxaADAgECAgUAmPnkfDAKBggqhkjOPQQDAjANMQswCQYDVQQDDAJNZTAeFw0yMTA0MTMwODUwNDBaFw0yMTA1MTMwODUwNDBaMA0xCzAJBgNVBAMMAk1lMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEee/SfuBBqhUjuOla5zGjT/k+jN0jVyEg6p3NBoCMNSpZe48/rQAXixsBoyFFY9b7klfE9zLFlDnOyBb5yxGSFqMSMBAwDgYDVR0PAQH/BAQDAgWgMAoGCCqGSM49BAMCA0cAMEQCIEFlEb8tnqoG8m03ScuHp1tEI40IXO4fFyT1JuJ4C5xrAiBk3ZoQtLVyujUfHiNVe6+EL5aQYgzD4zTCA7pVSxcG/w=="
                self.mockSignatureCert(keyId, encodedSignatureCert)
                validationCore.validate(encodedData: encodedEHNCert) { result in
                    switch result {
                    case .success(let validationResult): expect(validationResult.isValid).to(be(true))
                    case .failure: XCTFail("Should not result in error")
                    }
                }
                
            }
        }
    }
    
    private func mockSignatureCert(_ keyId : String, _ cert: String) {
        stub(condition: pathEndsWith(keyId)) { _ in
            return HTTPStubsResponse(data: cert.data(using: .utf8)!, statusCode: 200, headers: nil)
        }
    }
}

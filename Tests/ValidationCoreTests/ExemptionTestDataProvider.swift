import Foundation

struct ExemptionTestDataProvider {
    private func decodeTest(from jsonText: String) -> EuTestData? {
        if let data = jsonText.data(using: .utf8) {
            do {
            return try jsonTestDecoder().decode(EuTestData.self, from: data)
            } catch let e {
                print(e)
            }
        }
        return nil
    }
    
    var validVe : EuTestData {
        get {
            return decodeTest(from: """
                                    {
                                        "PREFIX": "AT1:NCFOXN%TS3DH%WST9OZQ9 RQI.4A.Q/R8JF62FCGJ9%VEQFG4G5*MGQD0ZMIN9HNO4*J85W4F%C %H4SI/J9WVHWVH+ZE1YH/T1$NICZUDQQ*LPKW2GHKW/F3IKJ5QH*AA:GP/HG:A81HJ1M23LG:IC4MX*20.C+0EO1PS%40-9N2LL0H**481HI6Q13PZJJ6Y2D4OYGFO-O%Z8JH1PCDJ*3TFH2V48F7M1IE78+*PA KZ*U0I1-I0*OC6H0HXM*%NH$R KP8EF+.K9KKRB4AC8.C85HKR9U74MLLO42GE1MSC91HFE2O%%D*Y8QZ8 .K/6UW6NH2KYIJ%0KJZIZ0KQPI59U%S2WPT YSLZI19JA2K7VA$IJVTIWVBDKBOKS:NK1DLNCKUCI5OI9YI:8DGCD1UU*GICZGKR21KTMARXAMO47DT3SNEA2OV8I%XGDUSL.KSXN3D2WKT65O3BV ZSY3UPBU2CO9WR$9MM6O/4VI/SVRR%CT81VG7FM$6VUMY*N+0O+30VKO64",
                                        "TESTCTX": {
                                            "VERSION": 1,
                                            "SCHEMA": "AT-1.0.0",
                                            "CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                            "AT_CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                            "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                                            "DESCRIPTION": "Good (AT1 + 1x VE + passende KID im AT Trust store ohne T/R/V OID = SUCCESS, AT_CERTIFICATE correct)"
                                        },
                                        "EXPECTEDRESULTS": {
                                            "EXPECTEDVALIDOBJECT": true,
                                            "EXPECTEDSCHEMAVALIDATION": true,
                                            "EXPECTEDENCODE": true,
                                            "EXPECTEDDECODE": true,
                                            "EXPECTEDVERIFY": true,
                                            "EXPECTEDUNPREFIX": true,
                                            "EXPECTEDVALIDJSON": true,
                                            "EXPECTEDCOMPRESSION": true,
                                            "EXPECTEDB45DECODE": true,
                                            "EXPECTEDPICTUREDECODE": true,
                                            "EXPECTEDEXPIRATIONCHECK": false,
                                            "EXPECTEDKEYUSAGE": true
                                        }
                                    }
                                    """)!
        }
    }
    
    var invalidHc1SignedWithAtCert : EuTestData {
        get {
            return decodeTest(from: """
                                    {
                                       "PREFIX": "HC1:NCFTW2EM75VOP10KHHAVMWNA19H:H7JMMR5TJVIX9C0AN18CAQQ2VER:6HWQ9RRX$9TGA9:07.O/U5H60J+QRY8NYJ0R80 E-:32TG*N2IZ3G+088RSDS$N7KQBKUKNNTO1SZA5AXFGVPU/1553*JRBGB1RFJL76UP+*IQEM8EA/5VV1LE9RA-9K:I:DN69JCU9BPG1005HUUROV$IWWGA82DV0787BY03.7CT37A7-QCNO3XCM$UTXG6.ZA.CCLGL4DLV73.B0C$OICA765U.GV58KE0$DIP:40F9C7L$25-IT$ZMYS8UR118FTPGQ:5BKA DVF11--IT2C5VP61FZ.MQC8KEJ%ML.8442MGXRVESIBB.KIE+BF*EJ BAG7ZE34OA*H7L%PIILZZS.P3E8LKSM/G6X:H8RAM-QKSE7*BU H:UHQ$F  7E3F:H3UU1717Z6D0FCX3T8O31 O*ONU1QEZB$QO/484RB8W0.75F3GO28.87K8VS F-SF4GBDDT18S/LM9DRR$U1D5FHU//LDAW-6S8OFKY7.P4EKIEWPVVLILQ7.TD.T028LZ727Q76PZYQ7%I-14KJ0I2L04",
                                        "TESTCTX": {
                                            "VERSION": 1,
                                            "SCHEMA": "1.0.0",
                                            "CERTIFICATE": "MIIBezCCASGgAwIBAgIFAKasfsIwCgYIKoZIzj0EAwIwIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwHhcNMjEwNTAzMTgwMDAwWhcNMjEwNjAyMTgwMDAwWjAiMRMwEQYDVQQDDApTZWxmU2lnbmVkMQswCQYDVQQGEwJYWDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCKMw7w+2/fsjSPawOor2AMNTSQTrZ7mBTFJo1ALUOMewyO7nMYN3kf8KgrxW1CS4W+uc6zjcbp2G+Pu4+qeX4GjRDBCMA4GA1UdDwEB/wQEAwIFoDAwBgNVHSUEKTAnBgsrBgEEAY43j2UBAQYLKwYBBAGON49lAQIGCysGAQQBjjePZQEDMAoGCCqGSM49BAMCA0gAMEUCIQDA0Qs+E5TNRXGlYcZULUCYlrlxK4GLUfDqekWpWQyICgIgEO1TCowAzYpbHSgPfQGGP4RSp2NjlUYyn/k6THbgO1k=",
                                            "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                                            "DESCRIPTION": "Bad (HC1 signiert mit AT-impfausnahme-zert = KEY_NOT_IN_TRUST_LIST"
                                        },
                                        "EXPECTEDRESULTS": {
                                            "EXPECTEDVALIDOBJECT": true,
                                            "EXPECTEDSCHEMAVALIDATION": true,
                                            "EXPECTEDENCODE": true,
                                            "EXPECTEDDECODE": true,
                                            "EXPECTEDVERIFY": false,
                                            "EXPECTEDUNPREFIX": true,
                                            "EXPECTEDVALIDJSON": true,
                                            "EXPECTEDCOMPRESSION": true,
                                            "EXPECTEDB45DECODE": true,
                                            "EXPECTEDPICTUREDECODE": true,
                                            "EXPECTEDEXPIRATIONCHECK": false
                                        }
                                    }
                                    """)!
        }
    }
    
    var invalidMultipleVe : EuTestData {
        get {
            return decodeTest(from: """
                                    {
                                       "PREFIX": "AT1:NCFOXN%TS3DH%WST9OZQ9 RQI.4A.Q/R8A+A2FCGJ9%VEQFG4G5*MGQD0ZMIN9HNO4*J85W4F%CWY94SI/J9WVHWVH+ZE1YH/T1$NICZUDQQ*LPKW2GHKW/F3IKJ5QH*AA:GP/HG:A81HJ1M23LG:IC4MX*20.C+0EO1PS%40-9N2LL0H**481HI6Q13PZJJ6Y2D4OYGFO-O%Z8JH1PCDJ*3TFH2V48F7M1IE78+*PA KZ*U0I1-I0*OC6H00M6XPFYMTB8MSKE MCTPI8%MIMIBDSUES$8RZ6N*8PBL3C7GKGS$0AY6F*DK8%MRIACEKT*QR$M% OP*B9YOB*16CQJN9TW5F/94O5 9E6UEDTUD1VVY95CQ-8EDS9%PP%.P3Y9UM9TQP-R1A 6YO6XL69/9-3AKI60%MO50RSPST5NE8J0A:AD+3M.+B2KPK08I95EIIVO254E$IN7FBY0SAO6C7WD+P6 1B3UL-4WAQQLNJ0CB/DS.VZZ4LSQVIC/M502WX.KUF6JMUPXA420S*4O4",
                                        "TESTCTX": {
                                            "VERSION": 1,
                                            "SCHEMA": "AT-1.0.0",
                                            "CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                            "AT_CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                            "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                                            "DESCRIPTION": "Bad AT1 + >1 VE = SCHEMA_VALIDATION_FAILED / CBOR_DESERIALIZATION_FAILED"
                                        },
                                        "EXPECTEDRESULTS": {
                                            "EXPECTEDVALIDOBJECT": true,
                                            "EXPECTEDSCHEMAVALIDATION": false,
                                            "EXPECTEDENCODE": true,
                                            "EXPECTEDUNPREFIX": true,
                                            "EXPECTEDCOMPRESSION": true,
                                            "EXPECTEDB45DECODE": true,
                                            "EXPECTEDPICTUREDECODE": true,
                                            "EXPECTEDEXPIRATIONCHECK": false
                                        }
                                    }
                                    """)!
        }
    }
    
    var invalidSignedVe : EuTestData {
        get {
            return decodeTest(from: """
                                    {
                                       "PREFIX": "AT1:NCFOXN%TS3DHRO4WCE18IAB6KC1A.Q/R8JF62FCGJ9%VEQFG4G5*MGQD0ZMIN9HNO4*J85W4F%C %H4SI/J9WVHWVH+ZE1YH/T1$NICZUDQQ*LPKW2GHKW/F3IKJ5QH*AA:GP/HG:A81HJ1M23LG:IC4MX*20.C+0EO1PS%40-9N2LL0H**481HI6Q13PZJJ6Y2D4OYGFO-O%Z8JH1PCDJ*3TFH2V48F7M1IE78+*PA KZ*U0I1-I0*OC6H0HXM*%NH$R KP8EF+.K9KKRB4AC8.C85HKR9U74MLLO42GE1MSC91HFE2O%%D*Y8QZ8 .K/6UW6NH2KYIJ%0KJZIZ0KQPI59U%S2WPT YSLZI19JA2K7VA$IJVTIWVBDKBOKS:NK1DLNCKUCI5OI9YI:8DGCD1UU*GICZGK:6UMPVV4%SF0ZUB/4QADX 1MKEGTV31T33OE*4F:3X$N-QK2Z6/LPMSV1ESTCDR8M U1HETFM5W6M+RKGN751O1VHH$1I1GJYACN1VW97CF",
                                        "TESTCTX": {
                                            "VERSION": 1,
                                            "SCHEMA": "AT-1.0.0",
                                            "CERTIFICATE": "MIIBejCCASGgAwIBAgIFAOHyGukwCgYIKoZIzj0EAwIwIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwHhcNMjEwNTAzMTgwMDAwWhcNMjEwNjAyMTgwMDAwWjAiMRMwEQYDVQQDDApTZWxmU2lnbmVkMQswCQYDVQQGEwJYWDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCJ2mnRzlwMJCqS0AB7KWo8kbfY9FpmoSJ+0Xv8LprtYSRJ+IgT1/Gy2m+LT4ajgNfRxv0W3z81mYqGJYeh1mR+jRDBCMA4GA1UdDwEB/wQEAwIFoDAwBgNVHSUEKTAnBgsrBgEEAY43j2UBAQYLKwYBBAGON49lAQIGCysGAQQBjjePZQEDMAoGCCqGSM49BAMCA0cAMEQCIHm3tkQ2L/IkP5d396S2jN0peNNS74jpk3Nrq0AG4tv5AiB5uTFRNK+CLXkugxqXNRxc2LJo2Gg4bLFhHavm7PLU4A==",
                                            "AT_CERTIFICATE": "MIIBejCCASGgAwIBAgIFAOHyGukwCgYIKoZIzj0EAwIwIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwHhcNMjEwNTAzMTgwMDAwWhcNMjEwNjAyMTgwMDAwWjAiMRMwEQYDVQQDDApTZWxmU2lnbmVkMQswCQYDVQQGEwJYWDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCJ2mnRzlwMJCqS0AB7KWo8kbfY9FpmoSJ+0Xv8LprtYSRJ+IgT1/Gy2m+LT4ajgNfRxv0W3z81mYqGJYeh1mR+jRDBCMA4GA1UdDwEB/wQEAwIFoDAwBgNVHSUEKTAnBgsrBgEEAY43j2UBAQYLKwYBBAGON49lAQIGCysGAQQBjjePZQEDMAoGCCqGSM49BAMCA0cAMEQCIHm3tkQ2L/IkP5d396S2jN0peNNS74jpk3Nrq0AG4tv5AiB5uTFRNK+CLXkugxqXNRxc2LJo2Gg4bLFhHavm7PLU4A==",
                                            "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                                            "DESCRIPTION": "Bad AT1 + V/R/T OID in Zert = UNSUITABLE_PUBLIC_KEY_TYPE"
                                        },
                                        "EXPECTEDRESULTS": {
                                            "EXPECTEDVALIDOBJECT": true,
                                            "EXPECTEDSCHEMAVALIDATION": true,
                                            "EXPECTEDENCODE": true,
                                            "EXPECTEDUNPREFIX": true,
                                            "EXPECTEDCOMPRESSION": true,
                                            "EXPECTEDB45DECODE": true,
                                            "EXPECTEDPICTUREDECODE": true,
                                            "EXPECTEDEXPIRATIONCHECK": false,
                                            "EXPECTEDKEYUSAGE": false
                                        }
                                    }
                                    """)!
        }
    }
    
    var invalidMixedVe : EuTestData {
        get {
            return decodeTest(from: """
                                    {
                                       "PREFIX": "AT1:NCFOXN%TS3DH%WST9OZQ9 RQI.4A.Q/R8/D32FCGJ9%VEQFG4G5*MGQD0ZMIN9HNO4*J8OX4W$C2VL*LA 43/IE%TE6UG+ZEAT1HQ13W1:O1YUI%F1PN1/T1%%HRP5 R14SI.J9DYHZROVZ05QNZ 20OP748$NI4L6YO1%UG/YL WO*Z7ON1 *L:O8PN1QP5O PLU9A/RUX96 B0V1ZZB.T12.H.ZJ$%HN 9GTBIQ16-I5NI5K1*TB3:U-1VVS1UU15%HVLIWQHYZKOP6OH6XO9IE5IVU5P2-GA*PE1H6IO2OO9$G40GHS-O:S9UZ4+FJE 4Y3L 78OAJ/9TL4T1C9 UPVD5BT17$1MV15K1DR1FIEC2F5+1T+UC2FSH9 UP+/UXJDTW5CL52U50$EZ*N.KUW*P .UUQKC.U%KIP3FY5LG1A614I%KZYNNEVQ KB+P8$J1-ST*QGTA W7G 7G+SB.V Q5FN9ZK1117D P+T3LRJVM946D.V7YCVZ5WXW0HH9WVPQY2WCJJV9:Z1J8CBRPD5CX17.VVGNOVWFKW7K%4R%K3GA:3C5/U *0NWHK%JNVQ FJQ7KI-6YM0QONW/G",
                                        "TESTCTX": {
                                            "VERSION": 1,
                                            "SCHEMA": "AT-1.0.0",
                                            "CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                            "AT_CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                            "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                                            "DESCRIPTION": "Bad AT1 + T/R/V = SCHEMA_VALIDATION_FAILED / CBOR_DESERIALIZATION_FAILED"
                                        },
                                        "EXPECTEDRESULTS": {
                                            "EXPECTEDVALIDOBJECT": true,
                                            "EXPECTEDSCHEMAVALIDATION": false,
                                            "EXPECTEDENCODE": true,
                                            "EXPECTEDUNPREFIX": true,
                                            "EXPECTEDCOMPRESSION": true,
                                            "EXPECTEDB45DECODE": true,
                                            "EXPECTEDPICTUREDECODE": true,
                                            "EXPECTEDEXPIRATIONCHECK": false,
                                            "EXPECTEDKEYUSAGE": true
                                        }
                                    }
                                    """)!
        }
    }
    
    var invalidHc1WithVe : EuTestData {
        get {
            return decodeTest(from: """
                                    {
                                       "PREFIX": "HC1:NCFOXN%TS3DH8YSV7P80K9*F PBCID:D4PA3%CM8W4.QN5DOW%IRJO/EGPJPC%OQHIZC4AOIFRM35P9B9T+KG%89-8CNNG.8 .GYE9/MV7OTR-SAG10EQ928GEQW2DVJ55M8K7P8M54N8W0B1OA8M962B*J10L6K07CNCEJ20/4YNAXM8.J24N893D1ZSP+PAE17DS2*N.SSBNKA.G.P6A8IM%O%KI4U3-8P$BKK.C5IAXMFU*GSHGRKMXGG%DB.-B97U3-SY$NKLACIQ 52564L64W5A 4F4DR+7C218UBR: KF N04C45NRPK/PKPIAMEV8VR9CQ9$PJ0AWH9P8Q/KPP4FCH1GZEPEEQK9FWP51AJI5-V90C9G%5MZ5J7E7KQ8$QJEQF69AKPCPP0%M0YM1QVYDPHOOXJMH$DL+SBRF%3NV6ON1A**SZ*PJQCMEB9TIPURXX9$Q0BSVYFHJMEO0V8MPUUJ%8LB3M+$UPYC7BRCS1W:V+.5Q G2EPXH4:5WAQS7306XQA2",
                                        "TESTCTX": {
                                            "VERSION": 1,
                                            "SCHEMA": "1.0.0",
                                            "CERTIFICATE": "MIIBezCCASGgAwIBAgIFAKasfsIwCgYIKoZIzj0EAwIwIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwHhcNMjEwNTAzMTgwMDAwWhcNMjEwNjAyMTgwMDAwWjAiMRMwEQYDVQQDDApTZWxmU2lnbmVkMQswCQYDVQQGEwJYWDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCKMw7w+2/fsjSPawOor2AMNTSQTrZ7mBTFJo1ALUOMewyO7nMYN3kf8KgrxW1CS4W+uc6zjcbp2G+Pu4+qeX4GjRDBCMA4GA1UdDwEB/wQEAwIFoDAwBgNVHSUEKTAnBgsrBgEEAY43j2UBAQYLKwYBBAGON49lAQIGCysGAQQBjjePZQEDMAoGCCqGSM49BAMCA0gAMEUCIQDA0Qs+E5TNRXGlYcZULUCYlrlxK4GLUfDqekWpWQyICgIgEO1TCowAzYpbHSgPfQGGP4RSp2NjlUYyn/k6THbgO1k=",
                                            "AT_CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                            "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                                            "DESCRIPTION": "Bad HC1 + VE = SCHEMA_VALIDATION_FAILED / CBOR_DESERIALIZATION_FAILED"
                                        },
                                        "EXPECTEDRESULTS": {
                                            "EXPECTEDVALIDOBJECT": true,
                                            "EXPECTEDSCHEMAVALIDATION": false,
                                            "EXPECTEDENCODE": true,
                                            "EXPECTEDUNPREFIX": true,
                                            "EXPECTEDCOMPRESSION": true,
                                            "EXPECTEDB45DECODE": true,
                                            "EXPECTEDPICTUREDECODE": true,
                                            "EXPECTEDEXPIRATIONCHECK": false
                                        }
                                    }
                                    """)!
        }
    }
    
    var invalidVeWithoutKey : EuTestData {
        get {
            return decodeTest(from: """
                                    {
                                   "PREFIX": "AT1:NCFOXN%TS3DH%WST9OZQ9 RQI.4A.Q/R8JF62FCGJ9%VEQFG4G5*MGQD0ZMIN9HNO4*J85W4F%C %H4SI/J9WVHWVH+ZE1YH/T1$NICZUDQQ*LPKW2GHKW/F3IKJ5QH*AA:GP/HG:A81HJ1M23LG:IC4MX*20.C+0EO1PS%40-9N2LL0H**481HI6Q13PZJJ6Y2D4OYGFO-O%Z8JH1PCDJ*3TFH2V48F7M1IE78+*PA KZ*U0I1-I0*OC6H0HXM*%NH$R KP8EF+.K9KKRB4AC8.C85HKR9U74MLLO42GE1MSC91HFE2O%%D*Y8QZ8 .K/6UW6NH2KYIJ%0KJZIZ0KQPI59U%S2WPT YSLZI19JA2K7VA$IJVTIWVBDKBOKS:NK1DLNCKUCI5OI9YI:8DGCD1UU*GI0VGW9N*J8NQG1MSI0CKC907BQCP :PU3NU6G+2TT*N$WTORPHNN4.N/RM0IUXHMD/T9ES*.PMTFI1TR0O5S13EB1BNXA4MOSG:M%1Q.GMBMD6IF",
                                    "TESTCTX": {
                                        "VERSION": 1,
                                        "SCHEMA": "AT-1.0.0",
                                        "CERTIFICATE": "MIIBUzCB+aADAgECAgQB6L5ZMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQ5owHAr1Za4S+F0NKDpUG/vfKffr/RSZbMHOli7SK10HfK2Q0Vf4ApQRFlH8ra5Xnjls0N8HQ7Y2v/a3c26Z73ox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNJADBGAiEAmjWAn9XyMXIqSamaPqaRVpAaknrnFHvnhzWAUPcNjL4CIQCjnWZZIPNq7ryPA+ClyknXnNKAX80XU16bFF5FHod76A==",
                                        "AT_CERTIFICATE": "MIIBUTCB+aADAgECAgRbfFTvMAoGCCqGSM49BAMCMCIxEzARBgNVBAMMClNlbGZTaWduZWQxCzAJBgNVBAYTAlhYMB4XDTIxMDUwMzE4MDAwMFoXDTIxMDYwMjE4MDAwMFowIjETMBEGA1UEAwwKU2VsZlNpZ25lZDELMAkGA1UEBhMCWFgwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAThU/5Y+4vJy2Mdkv+GhN+mg3S3G9F3uqLZZGPnXVOE9apu9Eb3hPnedxqnTyIHUsT45u2eZ/3rtzF3FhbsUzJdox0wGzAOBgNVHQ8BAf8EBAMCBaAwCQYDVR0lBAIwADAKBggqhkjOPQQDAgNHADBEAiA3jqEdk4WF9WygYz/Qeu/eJGWRET6ZdR2SdZjIFD9yYgIgc0unkwUGu79PaxoTNxDjpk2sQvn5MCXZ0ytE50iAUd8=",
                                        "VALIDATIONCLOCK": "2021-05-03T18:01:00Z",
                                        "DESCRIPTION": "Bad (AT1 + keine passende KID in AT Trust store = KEY_NOT_IN_TRUST_LIST, AT_CERTIFICATE=RANDOM, unpassend)"
                                    },
                                    "EXPECTEDRESULTS": {
                                        "EXPECTEDVALIDOBJECT": true,
                                        "EXPECTEDSCHEMAVALIDATION": true,
                                        "EXPECTEDENCODE": true,
                                        "EXPECTEDVERIFY": false,
                                        "EXPECTEDUNPREFIX": true,
                                        "EXPECTEDCOMPRESSION": true,
                                        "EXPECTEDB45DECODE": true,
                                        "EXPECTEDPICTUREDECODE": true,
                                        "EXPECTEDEXPIRATIONCHECK": false
                                    }
                                }
                                """)!
        }
    }
}



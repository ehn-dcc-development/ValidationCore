//
//  DGCValueSets.swift
//  
//
//  Created by Dominik Mocher on 19.05.21.
//

import Foundation

public enum DiseaseAgentTargeted : String, Codable {
    case COVID19 = "840539006"
    
    public func humanReadable() -> String {
        switch self {
        case .COVID19:
            return "COVID-19"
        }
    }
}

public enum TestManufacturer : String, Codable {
    case manufacturer_1232 = "1232"
    case manufacturer_1304 = "1304"
    case manufacturer_1065 = "1065"
    case manufacturer_1331 = "1331"
    case manufacturer_1484 = "1484"
    case manufacturer_1242 = "1242"
    case manufacturer_1223 = "1223"
    case manufacturer_1173 = "1173"
    case manufacturer_1244 = "1244"
    case manufacturer_1360 = "1360"
    case manufacturer_1363 = "1363"
    case manufacturer_1767 = "1767"
    case manufacturer_1333 = "1333"
    case manufacturer_1268 = "1268"
    case manufacturer_1180 = "1180"
    case manufacturer_1481 = "1481"
    case manufacturer_1162 = "1162"
    case manufacturer_1271 = "1271"
    case manufacturer_1341 = "1341"
    case manufacturer_1097 = "1097"
    case manufacturer_1489 = "1489"
    case manufacturer_344 = "344"
    case manufacturer_345 = "345"
    case manufacturer_1218 = "1218"
    case manufacturer_1278 = "1278"
    case manufacturer_1343 = "1343"
    
    public func humanReadable() -> String {
        switch self {
        case .manufacturer_1232: return "Abbott Rapid Diagnostics, Panbio COVID-19 Ag Test"
        case .manufacturer_1304: return "AMEDA Labordiagnostik GmbH, AMP Rapid Test SARS-CoV-2 Ag"
        case .manufacturer_1065: return "Becton Dickinson, Veritor System Rapid Detection of SARS-CoV-2"
        case .manufacturer_1331: return "Beijing Lepu Medical Technology Co., Ltd, SARS-CoV-2 Antigen Rapid Test Kit"
        case .manufacturer_1484: return "Beijing Wantai Biological Pharmacy Enterprise Co., Ltd, Wantai SARS-CoV-2 Ag Rapid Test (FIA)"
        case .manufacturer_1242: return "Bionote, Inc, NowCheck COVID-19 Ag Test"
        case .manufacturer_1223: return "BIOSYNEX SWISS SA, BIOSYNEX COVID-19 Ag BSS"
        case .manufacturer_1173: return "CerTest Biotec, S.L., CerTest SARS-CoV-2 Card test"
        case .manufacturer_1244: return "GenBody, Inc, Genbody COVID-19 Ag Test"
        case .manufacturer_1360: return "Guangdong Wesail Biotech Co., Ltd, COVID-19 Ag Test Kit"
        case .manufacturer_1363: return "Hangzhou Clongene Biotech Co., Ltd, Covid-19 Antigen Rapid Test Kit"
        case .manufacturer_1767: return "Healgen Scientific Limited Liability Company, Coronavirus Ag Rapid Test Cassette"
        case .manufacturer_1333: return "Joinstar Biomedical Technology Co., Ltd, COVID-19 Rapid Antigen Test (Colloidal Gold)"
        case .manufacturer_1268: return "LumiraDX UK Ltd, LumiraDx SARS-CoV-2 Ag Test"
        case .manufacturer_1180: return "MEDsan GmbH, MEDsan SARS-CoV-2 Antigen Rapid Test"
        case .manufacturer_1481: return "MP Biomedicals Germany GmbH, Rapid SARS-CoV-2 Antigen Test Card"
        case .manufacturer_1162: return "Nal von minden GmbH, NADAL COVID-19 Ag Test"
        case .manufacturer_1271: return "Precision Biosensor, Inc, Exdia COVID-19 Ag"
        case .manufacturer_1341: return "Qingdao Hightop Biotech Co., Ltd, SARS-CoV-2 Antigen Rapid Test (Immunochromatography)"
        case .manufacturer_1097: return "Quidel Corporation, Sofia SARS Antigen FIA"
        case .manufacturer_1489: return "Safecare Biotech (Hangzhou) Co. Ltd, COVID-19 Antigen Rapid Test Kit (Swab)"
        case .manufacturer_344: return "SD BIOSENSOR Inc, STANDARD F COVID-19 Ag FIA"
        case .manufacturer_345: return "SD BIOSENSOR Inc, STANDARD Q COVID-19 Ag Test"
        case .manufacturer_1218: return "Siemens Healthineers, CLINITEST Rapid Covid-19 Antigen Test"
        case .manufacturer_1278: return "Xiamen Boson Biotech Co. Ltd, Rapid SARS-CoV-2 Antigen Test Card"
        case .manufacturer_1343: return "Zhejiang Orient Gene Biotech, Coronavirus Ag Rapid Test Cassette (Swab)"
        }
    }
}

public enum TestResult : String, Codable {
    case result_260415000 = "260415000"
    case result_26037300 = "26037300"
    
    public func humanReadable() -> String {
        switch self {
        case .result_260415000: return "Not detected"
        case .result_26037300: return "Detected"
        }
    }
}


public enum TestType : String, Codable {
    case LP64644 = "LP6464-4"
    case LP2171983 = "LP217198-3"
    
    public func humanReadable() -> String {
        switch self {
        case .LP64644: return "Nucleic acid amplification with probe detection"
        case .LP2171983: return "Rapid immunoassay"
        }
    }
}

public enum VaccineManufacturer : String, Codable {
    case ORG100001699 = "ORG-100001699"
    case ORG100030215 = "ORG-100030215"
    case ORG100001417 = "ORG-100001417"
    case ORG100031184 = "ORG-100031184"
    case ORG100006270 = "ORG-100006270"
    case ORG100013793 = "ORG-100013793"
    case ORG100020693 = "ORG-100020693"
    case ORG100010771 = "ORG-100010771"
    case ORG100024420 = "ORG-100024420"
    case ORG100032020 = "ORG-100032020"
    case GamaleyaResearchInstitute = "Gamaleya-Research-Institute"
    case VectorInstitute = "Vector-Institute"
    case SinovacBiotech = "Sinovac-Biotech"
    case BharatBiotech = "Bharat-Biotech"
    
    public func humanReadable() -> String {
        switch self {
        case .ORG100001699: return "AstraZeneca AB"
        case .ORG100030215: return "Biontech Manufacturing GmbH"
        case .ORG100001417: return "Janssen-Cilag International"
        case .ORG100031184: return "Moderna Biotech Spain S.L."
        case .ORG100006270: return "Curevac AG"
        case .ORG100013793: return "CanSino Biologics"
        case .ORG100020693: return "China Sinopharm International Corp. - Beijing location"
        case .ORG100010771: return "Sinopharm Weiqida Europe Pharmaceutical s.r.o. - Prague location"
        case .ORG100024420: return "Sinopharm Zhijun (Shenzhen) Pharmaceutical Co. Ltd. - Shenzhen location"
        case .ORG100032020: return "Novavax CZ AS"
        case .GamaleyaResearchInstitute: return "Gamaleya Research Institute"
        case .VectorInstitute: return "Vector Institute"
        case .SinovacBiotech: return "Sinovac Biotech"
        case .BharatBiotech: return "Bharat Biotech"
        }}
}

public enum VaccineMedicinialProduct : String, Codable {
    case EU1201528 =  "EU/1/20/1528"
    case EU1201507 = "EU/1/20/1507"
    case EU1211529 = "EU/1/21/1529"
    case EU1201525 = "EU/1/20/1525"
    case CVnCoV = "CVnCoV"
    case SputnikV = "Sputnik-V"
    case Convidecia = "Convidecia"
    case EpiVacCorona = "EpiVacCorona"
    case BBIBPCorV = "BBIBP-CorV"
    case InactivatedSARSCoV2VeroCell = "Inactivated-SARS-CoV-2-Vero-Cell"
    case CoronaVac = "CoronaVac"
    case Covaxin = "Covaxin"
    
    public func humanReadable() -> String {
        switch self {
        case .EU1201528: return "Comirnaty"
        case .EU1201507: return "COVID-19 Vaccine Moderna"
        case .EU1211529: return "Vaxzevria"
        case .EU1201525: return "COVID-19 Vaccine Janssen"
        case .CVnCoV: return "CVnCoV"
        case .SputnikV: return "Sputnik-V"
        case .Convidecia: return "Convidecia"
        case .EpiVacCorona: return "EpiVacCorona"
        case .BBIBPCorV: return "BBIBP-CorV"
        case .InactivatedSARSCoV2VeroCell: return "Inactivated SARS-CoV-2 (Vero Cell)"
        case .CoronaVac: return "CoronaVac"
        case .Covaxin: return "Covaxin (also known as BBV152 A, B, C)"
        }
    }
}

public enum VaccineProphylaxis : String, Codable {
    case vaccine_1119349007 = "1119349007"
    case vaccine_1119305005 = "1119305005"
    case vaccine_J07BX03 = "J07BX03"
    
    public func humanReadable() -> String {
        switch self {
        case .vaccine_1119349007: return "SARS-CoV-2 mRNA vaccine"
        case .vaccine_1119305005: return "SARS-CoV-2 antigen vaccine"
        case .vaccine_J07BX03: return "covid-19 vaccines"
        }
    }
}

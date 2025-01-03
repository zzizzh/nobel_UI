
// ignore_for_file: constant_identifier_names, non_constant_identifier_names

class Constants {
  // Prevent instantiation
  Constants._();


  static const FIRST = 0;
  static const MIDDLE = 1;
  static const LAST = 2;
  static const VALUE_LENGTH = 3;

  // General DATA Constants

  static List getDataParams(String name){
    switch(name){
      // 소재 이름, [기준값...], [오차값-규격한계, 오차값-관리한계...], [검사항목 번호...]
      case 'MS-010': return MS010;
      case 'MS-011': return MS011;
      case 'MS-012': return MS012;
      case 'MS-013': return MS013;
      case 'MS-014': return MS014;
      case 'MS-015': return MS015;
    }
    return [];
  }

  static const MS010 = ['MS-010', [10.98], ["3"], [0.15, -0.15]];
  static const MS011 = ['MS-011', [16.51], ["3"], [0.25, -0.25]];
  static const MS012 = ['MS-012', [8.8, 9.0], ["3", "4"], [0.2, -0.2, 0.2, -0.2]];
  static const MS013 = ['MS-013', [13.5], ["3"], [0.2, -0.2]];
  static const MS014 = ['MS-014', [7.1, 3.2, 115.0], ["2", "3", "4"], [0.4, -0.18, 0.2, -0.1, 2.0, -2.0], [0.38, -0.16, 0.18, -0.08, 1.97, -1.97]];
  static const MS015 = ['MS-015', [7.1, 3.2, 120.0], ["2", "3", "5"], [0.4, -0.2, 0.2, -0.1, 2.0, -2.0], [0.38, -0.18, 0.18, -0.08, 1.97, -1.97]];

  static Map<String, Map> JSON_DATA_MAP = Map.unmodifiable({
      "MS-010" : {

      },
      "MS-011" : {

      },
      "MS-012" : {

      },
      "MS-013" : {

      },
      "MS-014" : {

      },
      "MS-015" : {
        
      }
    });


}
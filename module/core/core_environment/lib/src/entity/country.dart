// TODO: move this file to enum directory
import 'package:collection/collection.dart';

enum Country {
  // "AF": {
  // "name": "افغانستان",
  // "alpha2Code": "AF",
  // "dial_code": "+93",
  // },
  // "AX": {
  // "name": "Åland",
  // "alpha2Code": "AX",
  // "dial_code": "+358",
  // },
  // "AL": {
  // "name": "Shqipëria",
  // "alpha2Code": "AL",
  // "dial_code": "+355",
  // },
  // "DZ": {
  // "name": "الجزائر",
  // "alpha2Code": "DZ",
  // "dial_code": "+213",
  // },
  // "AS": {
  // "name": "American Samoa",
  // "alpha2Code": "AS",
  // "dial_code": "+1684",
  // },
  // "AD": {
  // "name": "Andorra",
  // "alpha2Code": "AD",
  // "dial_code": "+376",
  // },
  // "AO": {
  // "name": "Angola",
  // "alpha2Code": "AO",
  // "dial_code": "+244",
  // },
  // "AI": {
  // "name": "Anguilla",
  // "alpha2Code": "AI",
  // "dial_code": "+1264",
  // },
  // "AQ": {
  // "name": "Antarctica",
  // "alpha2Code": "AQ",
  // "dial_code": "+672",
  // },
  // "AG": {
  // "name": "Antigua and Barbuda",
  // "alpha2Code": "AG",
  // "dial_code": "+1268",
  // },
  // "AR": {
  // "name": "Argentina",
  // "alpha2Code": "AR",
  // "dial_code": "+54",
  // },
  // "AM": {
  // "name": "Հայաստան",
  // "alpha2Code": "AM",
  // "dial_code": "+374",
  // },
  // "AW": {
  // "name": "Aruba",
  // "alpha2Code": "AW",
  // "dial_code": "+297",
  // },
  // "AU": {
  // "name": "Australia",
  // "alpha2Code": "AU",
  // "dial_code": "+61",
  // },
  // "AT": {
  // "name": "Österreich",
  // "alpha2Code": "AT",
  // "dial_code": "+43",
  // },
  // "AZ": {
  // "name": "Azərbaycan",
  // "alpha2Code": "AZ",
  // "dial_code": "+994",
  // },
  // "BS": {
  // "name": "Bahamas",
  // "alpha2Code": "BS",
  // "dial_code": "+1242",
  // },
  // "BH": {
  // "name": "‏البحرين",
  // "alpha2Code": "BH",
  // "dial_code": "+973",
  // },
  // "BD": {
  // "name": "Bangladesh",
  // "alpha2Code": "BD",
  // "dial_code": "+880",
  // },
  // "BB": {
  // "name": "Barbados",
  // "alpha2Code": "BB",
  // "dial_code": "+1246",
  // },
  // "BY": {
  // "name": "Белару́сь",
  // "alpha2Code": "BY",
  // "dial_code": "+375",
  // },
  // "BE": {
  // "name": "België",
  // "alpha2Code": "BE",
  // "dial_code": "+32",
  // },
  // "BZ": {
  // "name": "Belize",
  // "alpha2Code": "BZ",
  // "dial_code": "+501",
  // },
  // "BJ": {
  // "name": "Bénin",
  // "alpha2Code": "BJ",
  // "dial_code": "+229",
  // },
  // "BM": {
  // "name": "Bermuda",
  // "alpha2Code": "BM",
  // "dial_code": "+1441",
  // },
  // "BT": {
  // "name": "ʼbrug-yul",
  // "alpha2Code": "BT",
  // "dial_code": "+975",
  // },
  // "BO": {
  // "name": "Bolivia",
  // "alpha2Code": "BO",
  // "dial_code": "+591",
  // },
  // "BA": {
  // "name": "Bosna i Hercegovina",
  // "alpha2Code": "BA",
  // "dial_code": "+387",
  // },
  // "BW": {
  // "name": "Botswana",
  // "alpha2Code": "BW",
  // "dial_code": "+267",
  // },
  // "BV": {
  // "name": "Bouvetøya",
  // "alpha2Code": "BV",
  // "dial_code": "+47",
  // },
  // "BR": {
  // "name": "Brasil",
  // "alpha2Code": "BR",
  // "dial_code": "+55",
  // },
  // "IO": {
  // "name": "British Indian Ocean Territory",
  // "alpha2Code": "IO",
  // "dial_code": "+246",
  // },
  // "BN": {
  // "name": "Negara Brunei Darussalam",
  // "alpha2Code": "BN",
  // "dial_code": "+673",
  // },
  // "BG": {
  // "name": "България",
  // "alpha2Code": "BG",
  // "dial_code": "+359",
  // },
  // "BF": {
  // "name": "Burkina Faso",
  // "alpha2Code": "BF",
  // "dial_code": "+226",
  // },
  // "BI": {
  // "name": "Burundi",
  // "alpha2Code": "BI",
  // "dial_code": "+257",
  // },
  // "BQ": {
  // "name": "Bonaire, Sint Eustatius and Saba",
  // "alpha2Code": "BQ",
  // "dial_code": "+599",
  // },
  // "KH": {
  // "name": "Kâmpŭchéa",
  // "alpha2Code": "KH",
  // "dial_code": "+855",
  // },
  // "CM": {
  // "name": "Cameroon",
  // "alpha2Code": "CM",
  // "dial_code": "+237",
  // },
  // "CA": {
  // "name": "Canada",
  // "alpha2Code": "CA",
  // "dial_code": "+1",
  // },
  // "CV": {
  // "name": "Cabo Verde",
  // "alpha2Code": "CV",
  // "dial_code": "+238",
  // },
  // "KY": {
  // "name": "Cayman Islands",
  // "alpha2Code": "KY",
  // "dial_code": "+ 345",
  // },
  // "CF": {
  // "name": "Ködörösêse tî Bêafrîka",
  // "alpha2Code": "CF",
  // "dial_code": "+236",
  // },
  // "TD": {
  // "name": "Tchad",
  // "alpha2Code": "TD",
  // "dial_code": "+235",
  // },
  // "CL": {
  // "name": "Chile",
  // "alpha2Code": "CL",
  // "dial_code": "+56",
  // },
  // "CN": {
  // "name": "中国",
  // "alpha2Code": "CN",
  // "dial_code": "+86",
  // },
  // "CX": {
  // "name": "Christmas Island",
  // "alpha2Code": "CX",
  // "dial_code": "+61",
  // },
  // "CC": {
  // "name": "Cocos (Keeling) Islands",
  // "alpha2Code": "CC",
  // "dial_code": "+61",
  // },
  // "CO": {
  // "name": "Colombia",
  // "alpha2Code": "CO",
  // "dial_code": "+57",
  // },
  // "KM": {
  // "name": "Komori",
  // "alpha2Code": "KM",
  // "dial_code": "+269",
  // },
  // "CG": {
  // "name": "République du Congo",
  // "alpha2Code": "CG",
  // "dial_code": "+242",
  // },
  // "CD": {
  // "name": "République démocratique du Congo",
  // "alpha2Code": "CD",
  // "dial_code": "+243",
  // },
  // "CK": {
  // "name": "Cook Islands",
  // "alpha2Code": "CK",
  // "dial_code": "+682",
  // },
  // "CR": {
  // "name": "Costa Rica",
  // "alpha2Code": "CR",
  // "dial_code": "+506",
  // },
  // "CI": {
  // "name": "Côte d'Ivoire",
  // "alpha2Code": "CI",
  // "dial_code": "+225",
  // },
  // "HR": {
  // "name": "Hrvatska",
  // "alpha2Code": "HR",
  // "dial_code": "+385",
  // },
  // "CU": {
  // "name": "Cuba",
  // "alpha2Code": "CU",
  // "dial_code": "+53",
  // },
  // "CW": {
  // "name": "Curaçao",
  // "alpha2Code": "CW",
  // "dial_code": "+599",
  // },
  // "CY": {
  // "name": "Κύπρος",
  // "alpha2Code": "CY",
  // "dial_code": "+357",
  // },
  // "CZ": {
  // "name": "Česká republika",
  // "alpha2Code": "CZ",
  // "dial_code": "+420",
  // },
  // "DK": {
  // "name": "Danmark",
  // "alpha2Code": "DK",
  // "dial_code": "+45",
  // },
  // "DJ": {
  // "name": "Djibouti",
  // "alpha2Code": "DJ",
  // "dial_code": "+253",
  // },
  // "DM": {
  // "name": "Dominica",
  // "alpha2Code": "DM",
  // "dial_code": "+1767",
  // },
  // "DO": {
  // "name": "República Dominicana",
  // "alpha2Code": "DO",
  // "dial_code": "+1",
  // },
  // "EC": {
  // "name": "Ecuador",
  // "alpha2Code": "EC",
  // "dial_code": "+593",
  // },
  // "EG": {
  // "name": "مصر‎",
  // "alpha2Code": "EG",
  // "dial_code": "+20",
  // },
  // "SV": {
  // "name": "El Salvador",
  // "alpha2Code": "SV",
  // "dial_code": "+503",
  // },
  // "GQ": {
  // "name": "Guinea Ecuatorial",
  // "alpha2Code": "GQ",
  // "dial_code": "+240",
  // },
  // "ER": {
  // "name": "ኤርትራ",
  // "alpha2Code": "ER",
  // "dial_code": "+291",
  // },
  // "EE": {
  // "name": "Eesti",
  // "alpha2Code": "EE",
  // "dial_code": "+372",
  // },
  // "EH": {
  // "name": " الصحراء الغربية‎‎",
  // "alpha2Code": "EH",
  // "dial_code": "+212",
  // },
  // "ET": {
  // "name": "ኢትዮጵያ",
  // "alpha2Code": "ET",
  // "dial_code": "+251",
  // },
  // "FK": {
  // "name": "Falkland Islands",
  // "alpha2Code": "FK",
  // "dial_code": "+500",
  // },
  // "FO": {
  // "name": "Føroyar",
  // "alpha2Code": "FO",
  // "dial_code": "+298",
  // },
  // "FJ": {
  // "name": "Fiji",
  // "alpha2Code": "FJ",
  // "dial_code": "+679",
  // },
  // "FI": {
  // "name": "Suomi",
  // "alpha2Code": "FI",
  // "dial_code": "+358",
  // },
  // "FR": {
  // "name": "France",
  // "alpha2Code": "FR",
  // "dial_code": "+33",
  // },
  // "GF": {
  // "name": "Guyane française",
  // "alpha2Code": "GF",
  // "dial_code": "+594",
  // },
  // "PF": {
  // "name": "Polynésie française",
  // "alpha2Code": "PF",
  // "dial_code": "+689",
  // },
  // "TF": {
  // "name": "Territoire des Terres australes et antarctiques fr",
  // "alpha2Code": "TF",
  // "dial_code": "+262",
  // },
  // "GA": {
  // "name": "Gabon",
  // "alpha2Code": "GA",
  // "dial_code": "+241",
  // },
  // "GM": {
  // "name": "Gambia",
  // "alpha2Code": "GM",
  // "dial_code": "+220",
  // },
  // "GE": {
  // "name": "საქართველო",
  // "alpha2Code": "GE",
  // "dial_code": "+995",
  // },
  // "DE": {
  // "name": "Deutschland",
  // "alpha2Code": "DE",
  // "dial_code": "+49",
  // },
  // "GH": {
  // "name": "Ghana",
  // "alpha2Code": "GH",
  // "dial_code": "+233",
  // },
  // "GI": {
  // "name": "Gibraltar",
  // "alpha2Code": "GI",
  // "dial_code": "+350",
  // },
  // "GR": {
  // "name": "Ελλάδα",
  // "alpha2Code": "GR",
  // "dial_code": "+30",
  // },
  // "GL": {
  // "name": "Kalaallit Nunaat",
  // "alpha2Code": "GL",
  // "dial_code": "+299",
  // },
  // "GD": {
  // "name": "Grenada",
  // "alpha2Code": "GD",
  // "dial_code": "+1473",
  // },
  // "GP": {
  // "name": "Guadeloupe",
  // "alpha2Code": "GP",
  // "dial_code": "+590",
  // },
  // "GU": {
  // "name": "Guam",
  // "alpha2Code": "GU",
  // "dial_code": "+1671",
  // },
  // "GT": {
  // "name": "Guatemala",
  // "alpha2Code": "GT",
  // "dial_code": "+502",
  // },
  // "GG": {
  // "name": "Guernsey",
  // "alpha2Code": "GG",
  // "dial_code": "+44",
  // },
  // "GN": {
  // "name": "Guinée",
  // "alpha2Code": "GN",
  // "dial_code": "+224",
  // },
  // "GW": {
  // "name": "Guiné-Bissau",
  // "alpha2Code": "GW",
  // "dial_code": "+245",
  // },
  // "GY": {
  // "name": "Guyana",
  // "alpha2Code": "GY",
  // "dial_code": "+592",
  // },
  // "HT": {
  // "name": "Haïti",
  // "alpha2Code": "HT",
  // "dial_code": "+509",
  // },
  // "HM": {
  // "name": "Heard Island and McDonald Islands",
  // "alpha2Code": "HM",
  // "dial_code": "+0",
  // },
  // "VA": {
  // "name": "Vaticano",
  // "alpha2Code": "VA",
  // "dial_code": "+379",
  // },
  // "HN": {
  // "name": "Honduras",
  // "alpha2Code": "HN",
  // "dial_code": "+504",
  // },
  // "HK": {
  // "name": "香港",
  // "alpha2Code": "HK",
  // "dial_code": "+852",
  // },
  // "HU": {
  // "name": "Magyarország",
  // "alpha2Code": "HU",
  // "dial_code": "+36",
  // },
  // "IS": {
  // "name": "Ísland",
  // "alpha2Code": "IS",
  // "dial_code": "+354",
  // },
  // "IN": {
  // "name": "भारत",
  // "alpha2Code": "IN",
  // "dial_code": "+91",
  // },
  // "ID": {
  // "name": "Indonesia",
  // "alpha2Code": "ID",
  // "dial_code": "+62",
  // },
  // "IR": {
  // "name": "ایران",
  // "alpha2Code": "IR",
  // "dial_code": "+98",
  // },
  // "IQ": {
  // "name": "العراق",
  // "alpha2Code": "IQ",
  // "dial_code": "+964",
  // },
  // "IE": {
  // "name": "Éire",
  // "alpha2Code": "IE",
  // "dial_code": "+353",
  // },
  // "IM": {
  // "name": "Isle of Man",
  // "alpha2Code": "IM",
  // "dial_code": "+44",
  // },
  // "IL": {
  // "name": "יִשְׂרָאֵל",
  // "alpha2Code": "IL",
  // "dial_code": "+972",
  // },
  // "IT": {
  // "name": "Italia",
  // "alpha2Code": "IT",
  // "dial_code": "+39",
  // },
  // "JM": {
  // "name": "Jamaica",
  // "alpha2Code": "JM",
  // "dial_code": "+1876",
  // },
  // "JP": {
  // "name": "日本",
  // "alpha2Code": "JP",
  // "dial_code": "+81",
  // },
  // "JE": {
  // "name": "Jersey",
  // "alpha2Code": "JE",
  // "dial_code": "+44",
  // },
  // "JO": {
  // "name": "الأردن",
  // "alpha2Code": "JO",
  // "dial_code": "+962",
  // },
  // "KZ": {
  // "name": "Қазақстан",
  // "alpha2Code": "KZ",
  // "dial_code": "+7",
  // },
  // "KE": {
  // "name": "Kenya",
  // "alpha2Code": "KE",
  // "dial_code": "+254",
  // },
  // "KI": {
  // "name": "Kiribati",
  // "alpha2Code": "KI",
  // "dial_code": "+686",
  // },
  // "KP": {
  // "name": "북한",
  // "alpha2Code": "KP",
  // "dial_code": "+850",
  // },
  // "KR": {
  // "name": "대한민국",
  // "alpha2Code": "KR",
  // "dial_code": "+82",
  // },
  // "XK": {
  // // temporary code that is not yet in the ISO country list, but is still generally accepted
  // "name": "Republika e Kosovës",
  // "alpha2Code": "XK",
  // "dial_code": "+383",
  // },
  // "KW": {
  // "name": "الكويت",
  // "alpha2Code": "KW",
  // "dial_code": "+965",
  // },
  // "KG": {
  // "name": "Кыргызстан",
  // "alpha2Code": "KG",
  // "dial_code": "+996",
  // },
  // "LA": {
  // "name": "ສປປລາວ",
  // "alpha2Code": "LA",
  // "dial_code": "+856",
  // },
  // "LV": {
  // "name": "Latvija",
  // "alpha2Code": "LV",
  // "dial_code": "+371",
  // },
  // "LB": {
  // "name": "لبنان",
  // "alpha2Code": "LB",
  // "dial_code": "+961",
  // },
  // "LS": {
  // "name": "Lesotho",
  // "alpha2Code": "LS",
  // "dial_code": "+266",
  // },
  // "LR": {
  // "name": "Liberia",
  // "alpha2Code": "LR",
  // "dial_code": "+231",
  // },
  // "LY": {
  // "name": "‏ليبيا",
  // "alpha2Code": "LY",
  // "dial_code": "+218",
  // },
  // "LI": {
  // "name": "Liechtenstein",
  // "alpha2Code": "LI",
  // "dial_code": "+423",
  // },
  // "LT": {
  // "name": "Lietuva",
  // "alpha2Code": "LT",
  // "dial_code": "+370",
  // },
  // "LU": {
  // "name": "Luxembourg",
  // "alpha2Code": "LU",
  // "dial_code": "+352",
  // },
  // "MO": {
  // "name": "澳門",
  // "alpha2Code": "MO",
  // "dial_code": "+853",
  // },
  // "MK": {
  // "name": "Македонија",
  // "alpha2Code": "MK",
  // "dial_code": "+389",
  // },
  // "MG": {
  // "name": "Madagasikara",
  // "alpha2Code": "MG",
  // "dial_code": "+261",
  // },
  // "MW": {
  // "name": "Malawi",
  // "alpha2Code": "MW",
  // "dial_code": "+265",
  // },
  // "MY": {
  // "name": "Malaysia",
  // "alpha2Code": "MY",
  // "dial_code": "+60",
  // },
  // "MV": {
  // "name": "Maldives",
  // "alpha2Code": "MV",
  // "dial_code": "+960",
  // },
  // "ML": {
  // "name": "Mali",
  // "alpha2Code": "ML",
  // "dial_code": "+223",
  // },
  // "MT": {
  // "name": "Malta",
  // "alpha2Code": "MT",
  // "dial_code": "+356",
  // },
  // "MH": {
  // "name": "M̧ajeļ",
  // "alpha2Code": "MH",
  // "dial_code": "+692",
  // },
  // "MQ": {
  // "name": "Martinique",
  // "alpha2Code": "MQ",
  // "dial_code": "+596",
  // },
  // "MR": {
  // "name": "موريتانيا",
  // "alpha2Code": "MR",
  // "dial_code": "+222",
  // },
  // "MU": {
  // "name": "Maurice",
  // "alpha2Code": "MU",
  // "dial_code": "+230",
  // },
  // "YT": {
  // "name": "Mayotte",
  // "alpha2Code": "YT",
  // "dial_code": "+262",
  // },
  // "MX": {
  // "name": "México",
  // "alpha2Code": "MX",
  // "dial_code": "+52",
  // },
  // "FM": {
  // "name": "Micronesia",
  // "alpha2Code": "FM",
  // "dial_code": "+691",
  // },
  // "MD": {
  // "name": "Moldova",
  // "alpha2Code": "MD",
  // "dial_code": "+373",
  // },
  // "MC": {
  // "name": "Monaco",
  // "alpha2Code": "MC",
  // "dial_code": "+377",
  // },
  // "MN": {
  // "name": "Монгол улс",
  // "alpha2Code": "MN",
  // "dial_code": "+976",
  // },
  // "ME": {
  // "name": "Црна Гора",
  // "alpha2Code": "ME",
  // "dial_code": "+382",
  // },
  // "MS": {
  // "name": "Montserrat",
  // "alpha2Code": "MS",
  // "dial_code": "+1664",
  // },
  // "MA": {
  // "name": "المغرب",
  // "alpha2Code": "MA",
  // "dial_code": "+212",
  // },
  // "MZ": {
  // "name": "Moçambique",
  // "alpha2Code": "MZ",
  // "dial_code": "+258",
  // },
  // "MM": {
  // "name": "Myanma",
  // "alpha2Code": "MM",
  // "dial_code": "+95",
  // },
  // "NA": {
  // "name": "Namibia",
  // "alpha2Code": "NA",
  // "dial_code": "+264",
  // },
  // "NR": {
  // "name": "Nauru",
  // "alpha2Code": "NR",
  // "dial_code": "+674",
  // },
  // "NP": {
  // "name": "नेपाल",
  // "alpha2Code": "NP",
  // "dial_code": "+977",
  // },
  // "NL": {
  // "name": "Nederland",
  // "alpha2Code": "NL",
  // "dial_code": "+31",
  // },
  // "NC": {
  // "name": "Nouvelle-Calédonie",
  // "alpha2Code": "NC",
  // "dial_code": "+687",
  // },
  // "NZ": {
  // "name": "New Zealand",
  // "alpha2Code": "NZ",
  // "dial_code": "+64",
  // },
  // "NI": {
  // "name": "Nicaragua",
  // "alpha2Code": "NI",
  // "dial_code": "+505",
  // },
  // "NE": {
  // "name": "Niger",
  // "alpha2Code": "NE",
  // "dial_code": "+227",
  // },
  // "NG": {
  // "name": "Nigeria",
  // "alpha2Code": "NG",
  // "dial_code": "+234",
  // },
  // "NU": {
  // "name": "Niuē",
  // "alpha2Code": "NU",
  // "dial_code": "+683",
  // },
  // "NF": {
  // "name": "Norfolk Island",
  // "alpha2Code": "NF",
  // "dial_code": "+672",
  // },
  // "MP": {
  // "name": "Northern Mariana Islands",
  // "alpha2Code": "MP",
  // "dial_code": "+1670",
  // },
  // "NO": {
  // "name": "Norge",
  // "alpha2Code": "NO",
  // "dial_code": "+47",
  // },
  // "OM": {
  // "name": "عمان",
  // "alpha2Code": "OM",
  // "dial_code": "+968",
  // },
  // "PK": {
  // "name": "Pakistan",
  // "alpha2Code": "PK",
  // "dial_code": "+92",
  // },
  // "PW": {
  // "name": "Palau",
  // "alpha2Code": "PW",
  // "dial_code": "+680",
  // },
  // "PS": {
  // "name": "فلسطين",
  // "alpha2Code": "PS",
  // "dial_code": "+970",
  // },
  // "PA": {
  // "name": "Panamá",
  // "alpha2Code": "PA",
  // "dial_code": "+507",
  // },
  // "PG": {
  // "name": "Papua Niugini",
  // "alpha2Code": "PG",
  // "dial_code": "+675",
  // },
  // "PY": {
  // "name": "Paraguay",
  // "alpha2Code": "PY",
  // "dial_code": "+595",
  // },
  // "PE": {
  // "name": "Perú",
  // "alpha2Code": "PE",
  // "dial_code": "+51",
  // },
  // "PH": {
  // "name": "Pilipinas",
  // "alpha2Code": "PH",
  // "dial_code": "+63",
  // },
  // "PN": {
  // "name": "Pitcairn Islands",
  // "alpha2Code": "PN",
  // "dial_code": "+64",
  // },
  // "PL": {
  // "name": "Polska",
  // "alpha2Code": "PL",
  // "dial_code": "+48",
  // },
  // "PT": {
  // "name": "Portugal",
  // "alpha2Code": "PT",
  // "dial_code": "+351",
  // },
  // "PR": {
  // "name": "Puerto Rico",
  // "alpha2Code": "PR",
  // "dial_code": "+1787",
  // },
  // "QA": {
  // "name": "قطر",
  // "alpha2Code": "QA",
  // "dial_code": "+974",
  // },
  // "RO": {
  // "name": "România",
  // "alpha2Code": "RO",
  // "dial_code": "+40",
  // },
  // "RU": {
  // "name": "Россия",
  // "alpha2Code": "RU",
  // "dial_code": "+7",
  // },
  // "RW": {
  // "name": "Rwanda",
  // "alpha2Code": "RW",
  // "dial_code": "+250",
  // },
  // "RE": {
  // "name": "La Réunion",
  // "alpha2Code": "RE",
  // "dial_code": "+262",
  // },
  // "BL": {
  // "name": "Saint-Barthélemy",
  // "alpha2Code": "BL",
  // "dial_code": "+590",
  // },
  // "SH": {
  // "name": "Saint Helena",
  // "alpha2Code": "SH",
  // "dial_code": "+290",
  // },
  // "KN": {
  // "name": "Saint Kitts and Nevis",
  // "alpha2Code": "KN",
  // "dial_code": "+1869",
  // },
  // "LC": {
  // "name": "Saint Lucia",
  // "alpha2Code": "LC",
  // "dial_code": "+1758",
  // },
  // "MF": {
  // "name": "Saint Martin (French part)",
  // "alpha2Code": "MF",
  // "dial_code": "+590",
  // },
  // "PM": {
  // "name": "Saint-Pierre-et-Miquelon",
  // "alpha2Code": "PM",
  // "dial_code": "+508",
  // },
  // "VC": {
  // "name": "Saint Vincent and the Grenadines",
  // "alpha2Code": "VC",
  // "dial_code": "+1784",
  // },
  // "WS": {
  // "name": "Samoa",
  // "alpha2Code": "WS",
  // "dial_code": "+685",
  // },
  // "SM": {
  // "name": "San Marino",
  // "alpha2Code": "SM",
  // "dial_code": "+378",
  // },
  // "ST": {
  // "name": "São Tomé e Príncipe",
  // "alpha2Code": "ST",
  // "dial_code": "+239",
  // },
  // "SA": {
  // "name": "العربية السعودية",
  // "alpha2Code": "SA",
  // "dial_code": "+966",
  // },
  // "SN": {
  // "name": "Sénégal",
  // "alpha2Code": "SN",
  // "dial_code": "+221",
  // },
  serbia(name: 'Serbia', code: 'RS', dialCode: '+381'),
  seychelles(name: 'Seychelles', code: 'SC', dialCode: '+248'),
  sierraLeone(name: 'Sierra Leone', code: 'SL', dialCode: '+232'),
  singapore(name: 'Singapore', code: 'SG', dialCode: '+65'),
  slovakia(name: 'Slovakia', code: 'SK', dialCode: '+421'),
  slovenia(name: 'Slovenia', code: 'SI', dialCode: '+386'),
  solomonIslands(name: 'Solomon Islands', code: 'SB', dialCode: '+677'),
  somalia(name: 'Somalia', code: 'SO', dialCode: '+252'),
  southAfrica(name: 'South Africa', code: 'ZA', dialCode: '+27'),
  southSudan(name: 'South Sudan', code: 'SS', dialCode: '+211'),
  southGeorgia(name: 'South Georgia', code: 'GS', dialCode: '+500'),
  spain(name: 'Spain', code: 'ES', dialCode: '+34'),
  sriLanka(name: 'Sri Lanka', code: 'LK', dialCode: '+94'),
  sudan(name: 'Sudan', code: 'SD', dialCode: '+249'),
  suriname(name: 'Suriname', code: 'SR', dialCode: '+597'),
  svalbardJanMayen(name: 'Svalbard Jan Mayen', code: 'SJ', dialCode: '+47'),
  sintMaarten(name: 'Sint Maarten (Dutch part)', code: 'SX', dialCode: '+599'),
  swaziland(name: 'Swaziland', code: 'SZ', dialCode: '+268'),
  swedia(name: 'Swedia', code: 'SE', dialCode: '+46'),
  switzerland(name: 'Switzerland', code: 'CH', dialCode: '+41'),
  syria(name: 'Syria', code: 'SY', dialCode: '+963'),
  taiwan(name: 'Taiwan', code: 'TW', dialCode: '+886'),
  tajikistan(name: 'Tajikistan', code: 'TJ', dialCode: '+992'),
  tanzania(name: 'Tanzania', code: 'TZ', dialCode: '+255'),
  thailand(name: 'Thailand', code: 'TH', dialCode: '+66'),
  timorLeste(name: 'Timor-Leste', code: 'TL', dialCode: '+670'),
  togo(name: 'Togo', code: 'TG', dialCode: '+228'),
  tokelau(name: 'Tokelau', code: 'TK', dialCode: '+690'),
  tonga(name: 'Tonga', code: 'TO', dialCode: '+676'),
  trinidadAndTobago(name: 'Trinidad and Tobago', code: 'TT', dialCode: '+1868'),
  tunisia(name: 'Tunisia', code: 'TN', dialCode: '+216'),
  turkey(name: 'Turkey', code: 'TR', dialCode: '+90'),
  turkmenistan(name: 'Turkmenistan', code: 'TM', dialCode: '+993'),
  turksAndCaicosIslands(
    name: 'Turks and Caicos Islands',
    code: 'TC',
    dialCode: '+1649',
  ),
  tuvalu(name: 'Tuvalu', code: 'TV', dialCode: '+688'),
  uganda(name: 'Uganda', code: 'UG', dialCode: '+256'),
  ukraine(name: 'Ukraine', code: 'UA', dialCode: '+380'),
  uniEmiratArab(name: 'Uni Emirat Arab', code: 'AE', dialCode: '+971'),
  unitedKingdom(name: 'United Kingdom', code: 'GB', dialCode: '+44'),
  unitedStates(name: 'United States', code: 'US', dialCode: '+1'),
  unitedStatesMinorOutlyingIslands(
    name: 'United States Minor Outlying Islands (the)',
    code: 'UM',
    dialCode: '+246',
  ),
  uruguay(name: 'Uruguay', code: 'UY', dialCode: '+598'),
  uzbekistan(name: 'Uzbekistan', code: 'UZ', dialCode: '+998'),
  vanuatu(name: 'Vanuatu', code: 'VU', dialCode: '+678'),
  venezuela(name: 'Venezuela', code: 'VE', dialCode: '+58'),
  vietnam(name: 'Vietnam', code: 'VN', dialCode: '+84'),
  britishVirginIslands(
    name: 'British Virgin Islands',
    code: 'VG',
    dialCode: '+1284',
  ),
  virginIslands(
    name: 'United States Virgin Islands',
    code: 'VI',
    dialCode: '+1340',
  ),
  wallisEtFutuna(name: 'Wallis et Futuna', code: 'WF', dialCode: '+681'),
  yemen(name: 'Yemen', code: 'YE', dialCode: '+967'),
  zambia(name: 'Zambia', code: 'ZM', dialCode: '+260'),
  zimbabwe(name: 'Zimbabwe', code: 'ZW', dialCode: '+263');

  // (name: '', code: '', dialCode: '+'),

  final String name;
  final String code;
  final String dialCode;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
  });

  factory Country.fromCode(String code) {
    return Country.values.firstWhere(
      (e) => e.code == code,
      // TODO: change to indonesia
      orElse: () => Country.unitedStates,
    );
  }

  factory Country.fromName(String name) {
    return Country.values.firstWhere(
      (e) => e.name == name,
      // TODO: change to indonesia
      orElse: () => Country.unitedStates,
    );
  }

  static List<Country> get sorted =>
      values..sorted((a, b) => a.name.compareTo(b.name));
}

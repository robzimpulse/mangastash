// TODO: move this file to enum directory
import 'package:collection/collection.dart';

enum Country {
  afghanistan(name: 'Afghanistan', code: 'AF', dialCode: '+93'),
  aland(name: 'Aland', code: 'AX', dialCode: '+358'),
  albania(name: 'Albania', code: 'AL', dialCode: '+355'),
  algeria(name: 'Algeria', code: 'DZ', dialCode: '+213'),
  americanSamoa(name: 'American Samoa', code: 'AS', dialCode: '+1684'),
  andorra(name: 'Andorra', code: 'AD', dialCode: '+376'),
  angola(name: 'Angola', code: 'AO', dialCode: '+244'),
  anguilla(name: 'Anguilla', code: 'AI', dialCode: '+1264'),
  antarctica(name: 'Antarctica', code: 'AQ', dialCode: '+672'),
  antiguaAndBarbuda(name: 'Antigua and Barbuda', code: 'AG', dialCode: '+1268'),
  argentina(name: 'Argentina', code: 'AR', dialCode: '+54'),
  armenia(name: 'Armenia', code: 'AM', dialCode: '+374'),
  aruba(name: 'Aruba', code: 'AW', dialCode: '+297'),
  australia(name: 'Australia', code: 'AU', dialCode: '+61'),
  austria(name: 'Austria', code: 'AT', dialCode: '+43'),
  azerbaijan(name: 'Azerbaijan', code: 'AZ', dialCode: '+994'),
  bahamas(name: 'Bahamas', code: 'BS', dialCode: '+1242'),
  bahrain(name: 'Bahrain', code: 'BH', dialCode: '+973'),
  bangladesh(name: 'Bangladesh', code: 'BD', dialCode: '+880'),
  barbados(name: 'Barbados', code: 'BB', dialCode: '+1246'),
  belarus(name: 'Belarus', code: 'BY', dialCode: '+375'),
  belgium(name: 'Belgium', code: 'BE', dialCode: '+32'),
  belize(name: 'Belize', code: 'BZ', dialCode: '+501'),
  benin(name: 'Benin', code: 'BJ', dialCode: '+229'),
  bermuda(name: 'Bermuda', code: 'BM', dialCode: '+1441'),
  bhutan(name: 'Bhutan', code: 'BT', dialCode: '+975'),
  bolivia(name: 'Bolivia', code: 'BO', dialCode: '+591'),
  bosniaAndHerzegovina(
    name: 'Bosnia and Herzegovina',
    code: 'BA',
    dialCode: '+387',
  ),
  botswana(name: 'Botswana', code: 'BW', dialCode: '+267'),
  bouvetoya(name: 'Bouvetoya', code: 'BV', dialCode: '+47'),
  brazil(name: 'Brazil', code: 'BR', dialCode: '+55'),
  britishIndianOceanTerritory(
    name: 'British Indian Ocean Territory',
    code: 'IO',
    dialCode: '+246',
  ),
  brunei(name: 'Negara Brunei Darussalam', code: 'BN', dialCode: '+673'),
  bulgaria(name: 'Bulgaria', code: 'BG', dialCode: '+359'),
  burkinaFaso(name: 'Burkina Faso', code: 'BF', dialCode: '+226'),
  burundi(name: 'Burundi', code: 'BI', dialCode: '+257'),
  bonaireSintEustatiusAndSaba(
    name: 'Bonaire Sint Eustatius and Saba',
    code: 'BQ',
    dialCode: '+599',
  ),
  cambodia(name: 'Cambodia', code: 'KH', dialCode: '+855'),
  cameroon(name: 'Cameroon', code: 'CM', dialCode: '+237'),
  canada(name: 'Canada', code: 'CA', dialCode: '+1'),
  caboVerde(name: 'Cabo Verde', code: 'CV', dialCode: '+238'),
  caymanIslands(name: 'Cayman Islands', code: 'KY', dialCode: '+ 345'),
  centralAfricanRepublic(
    name: 'Central African Replublic',
    code: 'CF',
    dialCode: '+236',
  ),
  chad(name: 'Chad', code: 'TD', dialCode: '+235'),
  chile(name: 'Chile', code: 'CL', dialCode: '+56'),
  china(name: 'China', code: 'CN', dialCode: '+86'),
  christmasIsland(name: 'Christmas Island', code: 'CX', dialCode: '+61'),
  cocosKeelingIslands(
    name: 'Cocos (Keeling) Islands',
    code: 'CC',
    dialCode: '+61',
  ),
  colombia(name: 'Colombia', code: 'CO', dialCode: '+57'),
  comoros(name: 'Comoros', code: 'KM', dialCode: '+269'),
  congo(name: 'Congo', code: 'CG', dialCode: '+242'),
  democraticRepublicOfTheCongo(
    name: 'Democratic Republic of The Congo',
    code: 'CD',
    dialCode: '+243',
  ),
  cookIslands(name: 'Cook Islands', code: 'CK', dialCode: '+682'),
  costaRica(name: 'Costa Rica', code: 'CR', dialCode: '+506'),
  coteDIvoire(name: 'Cote d\'Ivoire', code: 'CI', dialCode: '+225'),
  croatia(name: 'Croatia', code: 'HR', dialCode: '+385'),
  cuba(name: 'Cuba', code: 'CU', dialCode: '+53'),
  curacao(name: 'Curacao', code: 'CW', dialCode: '+599'),
  cyprus(name: 'Cyprus', code: 'CY', dialCode: '+357'),
  czechRepublic(name: 'Czech Republic', code: 'CZ', dialCode: '+420'),
  denmark(name: 'Denmark', code: 'DK', dialCode: '+45'),
  djibouti(name: 'Djibouti', code: 'DJ', dialCode: '+253'),
  dominica(name: 'Dominica', code: 'DM', dialCode: '+1767'),
  dominicanRepublic(
    name: 'Dominican Republic',
    code: 'DO',
    dialCode: '+1809',
  ),
  ecuador(name: 'Ecuador', code: 'EC', dialCode: '+593'),
  egypt(name: 'Egypt', code: 'EG', dialCode: '+20'),
  elSalvador(name: 'El Salvador', code: 'SV', dialCode: '+503'),
  equatorialGuinea(name: 'Guinea Equatorial', code: 'GQ', dialCode: '+240'),
  eritrea(name: 'Eritrea', code: 'ER', dialCode: '+291'),
  estonia(name: 'Estonia', code: 'EE', dialCode: '+372'),
  ethiopia(name: 'Ethiopia', code: 'ET', dialCode: '+251'),
  falklandIslands(
    name: 'Falkland Islands (Malvinas)',
    code: 'FK',
    dialCode: '+500',
  ),
  faroeIslands(name: 'Faroe Islands', code: 'FO', dialCode: '+298'),
  fiji(name: 'Fiji', code: 'FJ', dialCode: '+679'),
  finland(name: 'Findland', code: 'FI', dialCode: '+358'),
  france(name: 'France', code: 'FR', dialCode: '+33'),
  frenchGuiana(name: 'French Guiana', code: 'GF', dialCode: '+594'),
  frenchPolynesia(name: 'French Polynesia', code: 'PF', dialCode: '+689'),
  frenchSouthernTerritories(
    name: 'French Southern Territories',
    code: 'TF',
    dialCode: '+262',
  ),
  gabon(name: 'Gabon', code: 'GA', dialCode: '+241'),
  gambia(name: 'Gambia', code: 'GM', dialCode: '+220'),
  georgia(name: 'Georgia', code: 'GE', dialCode: '+995'),
  germany(name: 'Germany', code: 'DE', dialCode: '+49'),
  ghana(name: 'Ghana', code: 'GH', dialCode: '+233'),
  gibraltar(name: 'Gibraltar', code: 'GI', dialCode: '+350'),
  greece(name: 'Greece', code: 'GR', dialCode: '+30'),
  greenland(name: 'Greenland', code: 'GL', dialCode: '+299'),
  grenada(name: 'Grenada', code: 'GD', dialCode: '+1473'),
  guadeloupe(name: 'Guadeloupe', code: 'GP', dialCode: '+590'),
  guam(name: 'Guam', code: 'GU', dialCode: '+1671'),
  guatemala(name: 'Guatemala', code: 'GT', dialCode: '+502'),
  guernsey(name: 'Guernsey', code: 'GG', dialCode: '+44'),
  guinea(name: 'Guinea', code: 'GN', dialCode: '+224'),
  guineaBissau(name: 'Guinea Bissau', code: 'GW', dialCode: '+245'),
  guyana(name: 'Guyana', code: 'GY', dialCode: '+592'),
  haiti(name: 'Haiti', code: 'HT', dialCode: '+509'),
  heardIslandAndMcDonaldIslands(
    name: 'Heard Island and McDonald Islands',
    code: 'HM',
    dialCode: '+0',
  ),
  holySee(name: 'Holy See', code: 'VA', dialCode: '+379'),
  honduras(name: 'Honduras', code: 'HN', dialCode: '+504'),
  hongKong(name: 'Hongkong', code: 'HK', dialCode: '+852'),
  hungary(name: 'Hungary', code: 'HU', dialCode: '+36'),
  iceland(name: 'Iceland', code: 'IS', dialCode: '+354'),
  india(name: 'India', code: 'IN', dialCode: '+91'),
  indonesia(name: 'Indonesia', code: 'ID', dialCode: '+62'),
  iran(name: 'Iran', code: 'IR', dialCode: '+98'),
  iraq(name: 'Iraq', code: 'IQ', dialCode: '+964'),
  ireland(name: 'Ireland', code: 'IE', dialCode: '+353'),
  isleOfMan(name: 'Isle of Man', code: 'IM', dialCode: '+44'),
  israel(name: 'Israel', code: 'IL', dialCode: '+972'),
  italy(name: 'Italia', code: 'IT', dialCode: '+39'),
  jamaica(name: 'Jamaica', code: 'JM', dialCode: '+1876'),
  japan(name: 'Japan', code: 'JP', dialCode: '+81'),
  jersey(name: 'Jersey', code: 'JE', dialCode: '+44'),
  jordan(name: 'Jordan', code: 'JO', dialCode: '+962'),
  kazakhstan(name: 'Kazakhstan', code: 'KZ', dialCode: '+7'),
  kenya(name: 'Kenya', code: 'KE', dialCode: '+254'),
  kiribati(name: 'Kiribati', code: 'KI', dialCode: '+686'),
  kuwait(name: 'Kuwait', code: 'KW', dialCode: '+965'),
  kyrgyzstan(name: 'Kyrgyzstan', code: 'KG', dialCode: '+996'),
  laos(name: 'Laos', code: 'LA', dialCode: '+856'),
  latvia(name: 'Latvia', code: 'LV', dialCode: '+371'),
  lebanon(name: 'Lebanon', code: 'LB', dialCode: '+961'),
  lesotho(name: 'Lesotho', code: 'LS', dialCode: '+266'),
  liberia(name: 'Liberia', code: 'LR', dialCode: '+231'),
  libya(name: 'Libya', code: 'LY', dialCode: '+218'),
  liechtenstein(name: 'Liechtenstein', code: 'LI', dialCode: '+423'),
  lithuania(name: 'Lithuania', code: 'LT', dialCode: '+370'),
  luxembourg(name: 'Luxembourg', code: 'LU', dialCode: '+352'),
  macao(name: 'Macao', code: 'MO', dialCode: '+853'),
  macedonia(name: 'Macedonia', code: 'MK', dialCode: '+389'),
  madagascar(name: 'Madagascar', code: 'MG', dialCode: '+261'),
  malawi(name: 'Malawi', code: 'MW', dialCode: '+265'),
  malaysia(name: 'Malaysia', code: 'MY', dialCode: '+60'),
  maldives(name: 'Maldives', code: 'MV', dialCode: '+960'),
  mali(name: 'Mali', code: 'ML', dialCode: '+223'),
  malta(name: 'Malta', code: 'MT', dialCode: '+356'),
  marshallIslands(name: 'Marshall Islands', code: 'MH', dialCode: '+692'),
  martinique(name: 'Martinique', code: 'MQ', dialCode: '+596'),
  mauritania(name: 'Mauritania', code: 'MR', dialCode: '+222'),
  mauritius(name: 'Mauritius', code: 'MU', dialCode: '+230'),
  mayotte(name: 'Mayotte', code: 'YT', dialCode: '+262'),
  mexico(name: 'Mexico', code: 'MX', dialCode: '+52'),
  micronesia(name: 'Micronesia', code: 'FM', dialCode: '+691'),
  moldova(name: 'Moldova', code: 'MD', dialCode: '+373'),
  monaco(name: 'Monaco', code: 'MC', dialCode: '+377'),
  mongolia(name: 'Монгол улс', code: 'MN', dialCode: '+976'),
  montenegro(name: 'Montenegro', code: 'ME', dialCode: '+382'),
  montserrat(name: 'Montserrat', code: 'MS', dialCode: '+1664'),
  morocco(name: 'Morocco', code: 'MA', dialCode: '+212'),
  mozambique(name: 'Mozambique', code: 'MZ', dialCode: '+258'),
  myanmar(name: 'Myanmar', code: 'MM', dialCode: '+95'),
  namibia(name: 'Namibia', code: 'NA', dialCode: '+264'),
  nauru(name: 'Nauru', code: 'NR', dialCode: '+674'),
  nepal(name: 'Nepal', code: 'NP', dialCode: '+977'),
  netherlands(name: 'Netherlands', code: 'NL', dialCode: '+31'),
  newCaledonia(name: 'New Caledonia', code: 'NC', dialCode: '+687'),
  newZealand(name: 'New Zealand', code: 'NZ', dialCode: '+64'),
  nicaragua(name: 'Nicaragua', code: 'NI', dialCode: '+505'),
  niger(name: 'Niger', code: 'NE', dialCode: '+227'),
  nigeria(name: 'Nigeria', code: 'NG', dialCode: '+234'),
  niue(name: 'Niue', code: 'NU', dialCode: '+683'),
  norfolkIsland(name: 'Norfolk Island', code: 'NF', dialCode: '+672'),
  northKorea(name: 'North Korea', code: 'KP', dialCode: '+850'),
  northernMarianaIslands(
    name: 'Northern Mariana Islands',
    code: 'MP',
    dialCode: '+1670',
  ),
  norway(name: 'Norway', code: 'NO', dialCode: '+47'),
  oman(name: 'Oman', code: 'OM', dialCode: '+968'),
  pakistan(name: 'Pakistan', code: 'PK', dialCode: '+92'),
  palau(name: 'Palau', code: 'PW', dialCode: '+680'),
  palestine(name: 'Palestine', code: 'PS', dialCode: '+970'),
  panama(name: 'Panama', code: 'PA', dialCode: '+507'),
  papuaNewGuinea(name: 'Papua New Guinea', code: 'PG', dialCode: '+675'),
  paraguay(name: 'Paraguay', code: 'PY', dialCode: '+595'),
  peru(name: 'Peru', code: 'PE', dialCode: '+51'),
  philipine(name: 'Philipine', code: 'PH', dialCode: '+63'),
  pitcairnIslands(name: 'Pitcairn Islands', code: 'PN', dialCode: '+64'),
  poland(name: 'Poland', code: 'PL', dialCode: '+48'),
  portugal(name: 'Portugal', code: 'PT', dialCode: '+351'),
  puertoRico(name: 'Puerto Rico', code: 'PR', dialCode: '+1787'),
  qatar(name: 'Qatar', code: 'QA', dialCode: '+974'),
  romania(name: 'Romania', code: 'RO', dialCode: '+40'),
  russia(name: 'Russia', code: 'RU', dialCode: '+7'),
  rwanda(name: 'Rwanda', code: 'RW', dialCode: '+250'),
  laReunion(name: 'La Reunion', code: 'RE', dialCode: '+262'),
  saintBarthelemy(name: 'Saint Barthelemy', code: 'BL', dialCode: '+590'),
  saintHelena(name: 'Saint Helena', code: 'SH', dialCode: '+290'),
  saintKittsAndNevis(
    name: 'Saint Kitts and Nevis',
    code: 'KN',
    dialCode: '+1869',
  ),
  saintLucia(name: 'Saint Lucia', code: 'LC', dialCode: '+1758'),
  saintMartin(name: 'Saint Martin (French part)', code: 'MF', dialCode: '+590'),
  saintPierreAndMiquelon(
    name: 'Saint Pierre and Miquelon',
    code: 'PM',
    dialCode: '+508',
  ),
  saintVincentAndTheGrenadines(
    name: 'Saint Vincent and The Grenadines',
    code: 'VC',
    dialCode: '+1784',
  ),
  samoa(name: 'Samoa', code: 'WS', dialCode: '+685'),
  sanMarino(name: 'San Marino', code: 'SM', dialCode: '+378'),
  saoTomeAndPrincipe(
    name: 'Sao Tomoe and Principe',
    code: 'ST',
    dialCode: '+239',
  ),
  saudiArabia(name: 'Saudi Arabia', code: 'SA', dialCode: '+966'),
  senegal(name: 'Senegal', code: '221', dialCode: '+221'),
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

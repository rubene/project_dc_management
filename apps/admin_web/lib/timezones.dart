/// A timezone a Center can be in: its IANA name, and how the list shows it.
class Timezone {
  const Timezone(this.iana, this.region);

  final String iana;

  /// Such as "Pacific – Vancouver". Empty for a zone outside the list.
  final String region;

  String get label => region.isEmpty ? iana : '$region ($iana)';
}

/// The US and Canadian zones, where v1's Centers are, east to west.
const centerTimezones = [
  Timezone('America/St_Johns', 'Newfoundland – St. John\'s'),
  Timezone('America/Halifax', 'Atlantic – Halifax'),
  Timezone('America/Moncton', 'Atlantic – Moncton'),
  Timezone('America/Toronto', 'Eastern – Toronto'),
  Timezone('America/New_York', 'Eastern – New York'),
  Timezone('America/Detroit', 'Eastern – Detroit'),
  Timezone('America/Indiana/Indianapolis', 'Eastern – Indianapolis'),
  Timezone('America/Kentucky/Louisville', 'Eastern – Louisville'),
  Timezone('America/Winnipeg', 'Central – Winnipeg'),
  Timezone('America/Chicago', 'Central – Chicago'),
  Timezone('America/Regina', 'Central, no daylight saving – Regina'),
  Timezone('America/Edmonton', 'Mountain – Edmonton'),
  Timezone('America/Denver', 'Mountain – Denver'),
  Timezone('America/Boise', 'Mountain – Boise'),
  Timezone('America/Phoenix', 'Mountain, no daylight saving – Phoenix'),
  Timezone('America/Whitehorse', 'Yukon – Whitehorse'),
  Timezone('America/Vancouver', 'Pacific – Vancouver'),
  Timezone('America/Los_Angeles', 'Pacific – Los Angeles'),
  Timezone('America/Anchorage', 'Alaska – Anchorage'),
  Timezone('Pacific/Honolulu', 'Hawaii – Honolulu'),
  Timezone('America/Puerto_Rico', 'Atlantic – Puerto Rico'),
];

/// The zones to offer, with the browser's own first if it isn't listed, so
/// the default is always there.
List<Timezone> timezonesOffered(String browserTimezone) => [
  if (!centerTimezones.any((zone) => zone.iana == browserTimezone)) Timezone(browserTimezone, ''),
  ...centerTimezones,
];

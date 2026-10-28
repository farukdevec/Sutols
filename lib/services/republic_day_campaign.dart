/// Campaign dates use Turkey's fixed UTC+03:00 timezone, independent of the
/// visitor's browser timezone. Models and saved presentation assets never expire.
final republicDayCampaignStart = DateTime.utc(2026, 10, 27, 21);
final republicDayCampaignEnd = DateTime.utc(2026, 10, 30, 21);

bool isRepublicDayCampaignActive(DateTime now) =>
    !now.toUtc().isBefore(republicDayCampaignStart) &&
    now.toUtc().isBefore(republicDayCampaignEnd);

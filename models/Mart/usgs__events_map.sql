-- Gold layer: one row per event, for the map visualization
select
    event_id,
    latitude,
    longitude,
    place,
    region,
    magnitude,
    magnitude_category,
    significance,
    significance / 100.0 as size_factor,
    depth_km,
    depth_category,
    event_time,
    alert_level,
    has_tsunami_warning,
    felt_reports,
    -- Severity from SIGNIFICANCE (same bands as the daily summary)
    case
        when significance >= 600
        then 'severe'
        when significance >= 400
        then 'major'
        when significance >= 200
        then 'moderate'
        when significance >= 100
        then 'minor'
        else 'low'
    end as severity,
    detail_url,
    current_timestamp() as _processed_at
from {{ ref('int__usgs_earthquake') }}
where latitude is not null and longitude is not null

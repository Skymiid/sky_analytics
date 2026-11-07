-- models/marts/gold__earthquake_regional_summary.sql
with
    regional as (
        select
            region,

            -- Counts
            count(*) as total_events,
            count(case when significance >= 500 then 1 end) as high_significance_events,

            -- Significance stats (primary metric)
            round(avg(significance), 0) as avg_significance,
            max(significance) as max_significance,

            -- Magnitude stats (secondary, for reference)
            round(avg(magnitude), 2) as avg_magnitude,
            max(magnitude) as max_magnitude,

            -- Depth stats
            round(avg(depth_km), 2) as avg_depth_km,

            -- Time range
            min(event_time) as first_event,
            max(event_time) as last_event,

            -- Centroid for map
            round(avg(latitude), 4) as centroid_lat,
            round(avg(longitude), 4) as centroid_lon
        from {{ ref('int__usgs_earthquake') }}
        where region is not null
        group by region
    )

select *, current_timestamp() as _processed_at
from regional

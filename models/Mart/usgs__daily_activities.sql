-- models/marts/gold__earthquake_daily_summary.sql

with daily as (
    select
        date_trunc('day', event_time)  as date,

        -- Counts
        count(*)                                                        as total_events,
        count(case when significance >= 500 then 1 end)                 as high_significance_events,
        count(case when has_tsunami_warning then 1 end)                 as tsunami_warnings,

        -- Significance stats (primary metric)
        round(avg(significance), 0)                                     as avg_significance,
        max(significance)                                               as max_significance,
        min(significance)                                               as min_significance,

        -- Magnitude stats (secondary, for reference)
        round(avg(magnitude), 2)                                        as avg_magnitude,
        max(magnitude)                                                  as max_magnitude,

        -- Depth stats
        round(avg(depth_km), 2)                                         as avg_depth_km,

        -- Impact
        sum(felt_reports)                                               as total_felt_reports,

        -- Counts by significance category
        count(case when significance >= 600 then 1 end)                 as count_severe,
        count(case when significance >= 400 and significance < 600 then 1 end) as count_major,
        count(case when significance >= 200 and significance < 400 then 1 end) as count_moderate,
        count(case when significance >= 100 and significance < 200 then 1 end) as count_minor,
        count(case when significance < 100 then 1 end)                  as count_low
    from {{ ref('int__usgs_earthquake') }}
    group by 1
)

select *, current_timestamp() as _processed_at
from daily
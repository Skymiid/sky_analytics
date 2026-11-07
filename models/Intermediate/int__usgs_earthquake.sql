
{{ config(
    materialized = 'incremental',
    unique_key = 'event_id',
    incremental_strategy = 'merge'
) }}


with
    typed as (
        select
            id as event_id,
            cast(properties['mag'] as double) as magnitude,
            properties['magType'] as magnitude_type,
            properties['place'] as place,
            cast(
                from_unixtime(cast(properties['time'] as bigint) / 1000) as timestamp
            ) as event_time,
            cast(
                from_unixtime(cast(properties['updated'] as bigint) / 1000) as timestamp
            ) as updated_time,
            cast(properties['tz'] as int) as timezone_offset,
            cast(properties['rms'] as double) as rms,
            cast(properties['gap'] as double) as gap,
            cast(properties['dmin'] as double) as dmin,
            cast(properties['nst'] as int) as station_count,
            cast(properties['sig'] as int) as significance,
            cast(properties['felt'] as int) as felt_reports,
            cast(properties['cdi'] as double) as cdi,
            cast(properties['mmi'] as double) as mmi,
            properties['alert'] as alert_level,
            cast(properties['tsunami'] as int) as tsunami_flag,
            properties['net'] as network,
            properties['code'] as event_code,
            properties['status'] as review_status,
            properties['url'] as detail_url,
            properties['detail'] as api_detail_url,
            regexp_extract(geometry['coordinates'], r"\[([^\]]+)\]", 1) as coords_clean
        from {{ ref('stg__usgs_eartquake') }}
    ),

    coords as (
        select
            *,
            cast(trim(split_part(coords_clean, ',', 1)) as double) as longitude,
            cast(trim(split_part(coords_clean, ',', 2)) as double) as latitude,
            cast(trim(split_part(coords_clean, ',', 3)) as double) as depth_km
        from typed
    ),

    enriched as (
        select
            *,
            case
                when magnitude >= 8.0
                then 'great'
                when magnitude >= 7.0
                then 'major'
                when magnitude >= 6.0
                then 'strong'
                when magnitude >= 5.0
                then 'moderate'
                when magnitude >= 4.0
                then 'light'
                when magnitude >= 2.0
                then 'minor'
                else 'micro'
            end as magnitude_category,
            case
                when depth_km < 70
                then 'shallow'
                when depth_km < 300
                then 'intermediate'
                else 'deep'
            end as depth_category,
            case
                when place like '% of %'
                then trim(regexp_extract(place, r" of (.+)$", 1))
                else place
            end as region,
            case
                when alert_level = 'red'
                then 4
                when alert_level = 'orange'
                then 3
                when alert_level = 'yellow'
                then 2
                when alert_level = 'green'
                then 1
                else 0
            end as alert_level_numeric,
            tsunami_flag = 1 as has_tsunami_warning,
            review_status = 'reviewed' as is_reviewed,
            significance >= 500 as is_significant
        from coords
    ),

    filtered as (
        select *
        from enriched
        where
            event_id is not null
            and magnitude is not null
            and latitude is not null
            and longitude is not null
            and event_time is not null
    ),

    deduped as (
        select *
        from
            (
                select
                    *,
                    row_number() over (
                        partition by event_id order by updated_time desc
                    ) as rn
                from filtered
            )
        where rn = 1
    )

select
    event_id,
    magnitude,
    magnitude_type,
    place,
    event_time,
    updated_time,
    timezone_offset,
    rms,
    gap,
    dmin,
    station_count,
    significance,
    felt_reports,
    cdi,
    mmi,
    alert_level,
    tsunami_flag,
    network,
    event_code,
    review_status,
    detail_url,
    api_detail_url,
    longitude,
    latitude,
    depth_km,
    magnitude_category,
    depth_category,
    region,
    alert_level_numeric,
    has_tsunami_warning,
    is_reviewed,
    is_significant,
    current_timestamp() as _processed_at
from deduped

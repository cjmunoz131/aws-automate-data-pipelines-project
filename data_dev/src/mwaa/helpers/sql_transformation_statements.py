class SqlQueries:
    songplay_table_insert = ("""
        SELECT
                events.start_time, 
                events.userid, 
                events.level, 
                songs.song_id, 
                songs.artist_id, 
                events.sessionid, 
                events.location, 
                events.useragent
                FROM (SELECT TIMESTAMP 'epoch' + ts/1000 * interval '1 second' AS start_time, *
            FROM staging_events
            WHERE page='NextSong') events
            LEFT JOIN staging_songs songs
            ON events.song = songs.title
                AND events.artist = songs.artist_name
                AND events.length = songs.duration
    """)

    user_table_insert = ("""
        SELECT distinct userid, firstname, lastname, gender, level
        FROM staging_events
        WHERE page='NextSong'
    """)

    song_table_insert = ("""
        SELECT distinct song_id, title, artist_id, year, duration
        FROM staging_songs
    """)

    artist_table_insert = ("""
        SELECT distinct artist_id as artist_id, artist_name as name, artist_location as location, artist_latitude as latitude, artist_longitude as longitude
        FROM staging_songs
    """)

    time_table_insert = ("""
        SELECT start_time as start_time, extract(hour from start_time) as hour, extract(day from start_time) as day, extract(week from start_time) as week, 
               extract(month from start_time) as month, extract(year from start_time) as year, extract(dayofweek from start_time) as weekday
        FROM songplays
    """)
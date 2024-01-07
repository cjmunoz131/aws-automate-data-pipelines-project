class DDLSQLQueries:
    
    # staging tables
    staging_events_table_create= ("""
        CREATE TABLE staging_events (
            artist varchar(256)  NULL,
            auth varchar(256)  NULL,
            firstName varchar(256)  NULL,
            gender varchar(256)  NULL,
            itemInSession int  NULL,
            lastName varchar(256)  NULL,
            length numeric(18,0)  NULL,
            level varchar(256)  NULL,
            location varchar(256)  NULL,
            method varchar(256) NULL,
            page varchar(256)  NULL,
            registration numeric(18,0) NULL,
            sessionId int  NOT NULL,
            song varchar(256)  NULL,
            status int  NULL,
            ts bigint  NOT NULL,
            userAgent varchar(256) NULL,
            userId int  NULL,
            id bigint identity(0,1)  NOT NULL,
            CONSTRAINT staging_events_pk PRIMARY KEY (id)
        )  DISTSTYLE EVEN;
    """)

    staging_songs_table_create = ("""
        CREATE TABLE staging_songs (
            num_songs int  NULL,
            artist_id varchar(256)  NOT NULL,
            artist_latitude numeric(18,0)  NULL,
            artist_longitude numeric(18,0)  NULL,   
            artist_location varchar(512)  NULL,
            artist_name varchar(512)  NULL,
            song_id varchar(256)  NOT NULL,
            title varchar(512)  NULL,
            duration numeric(18,0) NULL,
            year smallint  NULL,
            CONSTRAINT staging_songs_pk PRIMARY KEY (song_id)
        )  DISTSTYLE EVEN;
    """)

    #Analytics Table
    songplay_table_create = ("""
        CREATE TABLE songplays (
            songplay_id int identity(0,1)  NOT NULL,
            start_time timestamp  NOT NULL,
            level varchar(256) NOT NULL,
            session_id varchar(50)  NOT NULL,
            location varchar(256)  NULL,
            user_agent varchar(256) NULL,
            user_id int  NULL,
            artist_id varchar(256) NULL,
            song_id varchar(256)  NULL,
            CONSTRAINT songplay_id PRIMARY KEY (songplay_id)
        )  DISTSTYLE KEY DISTKEY (user_id) COMPOUND SORTKEY (user_id, start_time, song_id);
    """)

    user_table_create = ("""
        CREATE TABLE users (
            user_id int  NOT NULL,
            first_name varchar(256)  NULL,
            last_name varchar(256)  NULL,
            gender varchar(256)  NULL,
            level varchar(256)  NULL,
            CONSTRAINT id PRIMARY KEY (user_id)
        )  DISTSTYLE ALL SORTKEY (user_id);
    """)

    song_table_create = ("""
        CREATE TABLE songs (
            song_id varchar(256)  NOT NULL,
            title varchar(512)  NOT NULL,
            artist_id varchar(256)  NOT NULL,
            year smallint  NULL,
            duration numeric(18,0)  NULL,
            CONSTRAINT songs_pk PRIMARY KEY (song_id)
        )  DISTSTYLE ALL SORTKEY (song_id);
    """)

    artist_table_create = ("""
        CREATE TABLE artists (
            artist_id varchar(256)  NOT NULL,
            name varchar(512)  NULL,
            location varchar(512)  NULL,
            latitude numeric(18,0)  NULL,
            longitude numeric(18,0)  NULL,
            CONSTRAINT artists_pk PRIMARY KEY (artist_id)
        )  DISTSTYLE ALL SORTKEY (artist_id);
    """)

    time_table_create = ("""
        CREATE TABLE time (
            start_time timestamp  NOT NULL,
            hour smallint  NULL,
            day smallint  NULL,
            week smallint  NULL,
            month smallint  NULL,
            year smallint  NULL,
            weekday smallint  NULL,
            CONSTRAINT time_pk PRIMARY KEY (start_time)
        )  DISTSTYLE ALL SORTKEY (start_time);
    """)
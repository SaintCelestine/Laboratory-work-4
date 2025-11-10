CREATE TABLE user (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
        CHECK (full_name ~ '^[A-Za-z\\- ]+$'),
    age INT CHECK (age >= 0),
    email VARCHAR(150) UNIQUE NOT NULL
        CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
);

CREATE TABLE user_profile (
    profile_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL UNIQUE
        REFERENCES user (user_id) ON DELETE CASCADE,
    created_at DATE NOT NULL,
    status VARCHAR(10) NOT NULL
        CHECK (status IN ('active', 'inactive'))
);

CREATE TABLE health_history (
    history_id SERIAL PRIMARY KEY,
    profile_id INT NOT NULL
        REFERENCES user_profile (profile_id) ON DELETE CASCADE,
    record_date DATE NOT NULL
);

CREATE TABLE sensor_device (
    sensor_id SERIAL PRIMARY KEY,
    sensor_type VARCHAR(50) NOT NULL,
    model VARCHAR(100),
    unit VARCHAR(50)
);

CREATE TABLE vital_parameter (
    parameter_id SERIAL PRIMARY KEY,
    param_name VARCHAR(50) NOT NULL,
    param_value REAL NOT NULL,
    measured_at TIMESTAMP NOT NULL,
    history_id INT NOT NULL
        REFERENCES health_history (history_id) ON DELETE CASCADE,
    sensor_id INT NOT NULL
        REFERENCES sensor_device (sensor_id)
);

CREATE TABLE practice_session (
    session_id SERIAL PRIMARY KEY,
    started_at TIMESTAMP NOT NULL,
    duration INT CHECK (duration > 0),
    profile_id INT NOT NULL
        REFERENCES user_profile (profile_id) ON DELETE CASCADE
);

CREATE TABLE audio_record (
    audio_id SERIAL PRIMARY KEY,
    filename VARCHAR(200) NOT NULL,
    duration REAL CHECK (duration > 0),
    filepath VARCHAR(300) NOT NULL,
    session_id INT NOT NULL
        REFERENCES practice_session (session_id) ON DELETE CASCADE
);

CREATE TABLE pitch_analysis (
    analysis_id SERIAL PRIMARY KEY,
    accuracy REAL CHECK (accuracy BETWEEN 0 AND 100),
    stability REAL CHECK (stability BETWEEN 0 AND 100),
    rhythm REAL CHECK (rhythm BETWEEN 0 AND 100),
    audio_id INT NOT NULL UNIQUE
        REFERENCES audio_record (audio_id) ON DELETE CASCADE
);

CREATE TABLE visual_feedback (
    feedback_id SERIAL PRIMARY KEY,
    chart_type VARCHAR(50) NOT NULL,
    refresh_rate INT CHECK (refresh_rate > 0),
    analysis_id INT NOT NULL UNIQUE
        REFERENCES pitch_analysis (analysis_id) ON DELETE CASCADE,
    profile_id INT NOT NULL
        REFERENCES user_profile (profile_id) ON DELETE CASCADE
);

CREATE TABLE recommendation (
    recommendation_id SERIAL PRIMARY KEY,
    rec_text TEXT NOT NULL,
    created_at DATE NOT NULL,
    profile_id INT NOT NULL
        REFERENCES user_profile (profile_id) ON DELETE CASCADE,
    parameter_id INT
        REFERENCES vital_parameter (parameter_id) ON DELETE SET NULL,
    analysis_id INT
        REFERENCES pitch_analysis (analysis_id) ON DELETE SET NULL,
    CHECK ((parameter_id IS NOT NULL) OR (analysis_id IS NOT NULL))
);

CREATE INDEX idx_history_profile_date
    ON health_history (profile_id, record_date);

CREATE INDEX idx_param_history
    ON vital_parameter (history_id);

CREATE INDEX idx_param_sensor
    ON vital_parameter (sensor_id);

CREATE INDEX idx_audio_session
    ON audio_record (session_id);

CREATE INDEX idx_analysis_audio
    ON pitch_analysis (audio_id);

CREATE INDEX idx_feedback_profile
    ON visual_feedback (profile_id);

CREATE INDEX idx_recommendation_profile
    ON recommendation (profile_id);

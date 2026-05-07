-- Supabase schema for CCMS Expo
-- Run this in Supabase SQL Editor or as a migration script.

-- 1. Competitions / events
CREATE TABLE IF NOT EXISTS competitions (
  competition_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('setup', 'live', 'ended'))
);

-- 2. Participants / teams
CREATE TABLE IF NOT EXISTS participants (
  participant_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  competition_id BIGINT NOT NULL REFERENCES competitions(competition_id) ON DELETE CASCADE,
  real_name TEXT NOT NULL,
  alias TEXT,
  booth_code TEXT NOT NULL
);

-- 3. Judges
CREATE TABLE IF NOT EXISTS judges (
  judge_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  competition_id BIGINT NOT NULL REFERENCES competitions(competition_id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  pin_code TEXT NOT NULL
);

-- 4. Criteria / scoring rubric
CREATE TABLE IF NOT EXISTS criteria (
  criteria_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  competition_id BIGINT NOT NULL REFERENCES competitions(competition_id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  weight_percentage NUMERIC NOT NULL CHECK (weight_percentage >= 0 AND weight_percentage <= 100),
  type TEXT CHECK (type IN ('slider', 'likert')),
  description TEXT
);

-- 5. Scores / judge records
CREATE TABLE IF NOT EXISTS scores (
  score_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  judge_id BIGINT NOT NULL REFERENCES judges(judge_id) ON DELETE CASCADE,
  participant_id BIGINT NOT NULL REFERENCES participants(participant_id) ON DELETE CASCADE,
  criteria_id BIGINT NOT NULL REFERENCES criteria(criteria_id) ON DELETE CASCADE,
  competition_id BIGINT NOT NULL REFERENCES competitions(competition_id) ON DELETE CASCADE,
  score_value NUMERIC NOT NULL,
  is_locked BOOLEAN DEFAULT FALSE,
  unlock_request BOOLEAN DEFAULT FALSE,
  UNIQUE (judge_id, participant_id, criteria_id)
);

-- Optional indexes for faster filtering by competition
CREATE INDEX IF NOT EXISTS idx_participants_competition_id ON participants(competition_id);
CREATE INDEX IF NOT EXISTS idx_judges_competition_id ON judges(competition_id);
CREATE INDEX IF NOT EXISTS idx_criteria_competition_id ON criteria(competition_id);
CREATE INDEX IF NOT EXISTS idx_scores_competition_id ON scores(competition_id);

-- Notes:
-- Admin users are handled by Supabase Auth (auth.users). No custom auth table is needed here.
-- If you want unique booth codes per competition, add a unique constraint on (competition_id, booth_code).

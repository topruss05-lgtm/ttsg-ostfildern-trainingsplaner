-- Tischtennis Trainingsplaner - Supabase Schema

-- Users Tabelle
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('trainer', 'player')),
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trainings Tabelle
CREATE TABLE trainings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  time TIME NOT NULL,
  max_participants INTEGER NOT NULL,
  trainer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  trainer_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Attendances Tabelle
CREATE TABLE attendances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  training_id UUID NOT NULL REFERENCES trainings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('attending', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(training_id, user_id)
);

-- Indizes für bessere Performance
CREATE INDEX idx_trainings_date ON trainings(date);
CREATE INDEX idx_trainings_trainer ON trainings(trainer_id);
CREATE INDEX idx_attendances_training ON attendances(training_id);
CREATE INDEX idx_attendances_user ON attendances(user_id);

-- Row Level Security (RLS) aktivieren
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE trainings ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendances ENABLE ROW LEVEL SECURITY;

-- RLS Policies für Users
CREATE POLICY "Users können ihr eigenes Profil sehen" ON users
  FOR SELECT USING (true);

CREATE POLICY "Users können sich registrieren" ON users
  FOR INSERT WITH CHECK (true);

-- RLS Policies für Trainings
CREATE POLICY "Jeder kann Trainings sehen" ON trainings
  FOR SELECT USING (true);

CREATE POLICY "Nur Trainer können Trainings erstellen" ON trainings
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = trainer_id
      AND users.role = 'trainer'
    )
  );

CREATE POLICY "Nur Trainer können eigene Trainings löschen" ON trainings
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = trainer_id
      AND users.role = 'trainer'
    )
  );

-- RLS Policies für Attendances
CREATE POLICY "Jeder kann Anmeldungen sehen" ON attendances
  FOR SELECT USING (true);

CREATE POLICY "Spieler können sich anmelden" ON attendances
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Spieler können ihre Anmeldung ändern" ON attendances
  FOR UPDATE USING (true);

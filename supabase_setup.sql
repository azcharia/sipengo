-- ============================================
-- SIPEN-GO Database Setup Script
-- Supabase PostgreSQL Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: families (Kartu Keluarga)
-- ============================================
CREATE TABLE IF NOT EXISTS families (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kk_number VARCHAR(16) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    head_of_household VARCHAR(255) NOT NULL,
    house_photo_url TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Index for faster searches
CREATE INDEX idx_families_kk_number ON families(kk_number);
CREATE INDEX idx_families_head ON families(head_of_household);

-- ============================================
-- TABLE: residents (Penduduk)
-- ============================================
CREATE TABLE IF NOT EXISTS residents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    nik VARCHAR(16) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')),
    relationship VARCHAR(20) NOT NULL CHECK (relationship IN (
        'head', 'wife', 'husband', 'child', 'grandchild', 
        'parent', 'grandparent', 'sibling', 'other'
    )),
    parent_id UUID REFERENCES residents(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for faster queries
CREATE INDEX idx_residents_family_id ON residents(family_id);
CREATE INDEX idx_residents_nik ON residents(nik);
CREATE INDEX idx_residents_parent_id ON residents(parent_id);
CREATE INDEX idx_residents_name ON residents(full_name);

-- ============================================
-- FUNCTION: Auto-update updated_at timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for auto-updating timestamps
CREATE TRIGGER update_families_updated_at
    BEFORE UPDATE ON families
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_residents_updated_at
    BEFORE UPDATE ON residents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on tables
ALTER TABLE families ENABLE ROW LEVEL SECURITY;
ALTER TABLE residents ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can read all families
CREATE POLICY "Authenticated users can view families"
    ON families FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Authenticated users can insert families
CREATE POLICY "Authenticated users can create families"
    ON families FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = created_by);

-- Policy: Authenticated users can update families
CREATE POLICY "Authenticated users can update families"
    ON families FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy: Authenticated users can delete families
CREATE POLICY "Authenticated users can delete families"
    ON families FOR DELETE
    TO authenticated
    USING (true);

-- Policy: Authenticated users can read all residents
CREATE POLICY "Authenticated users can view residents"
    ON residents FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Authenticated users can insert residents
CREATE POLICY "Authenticated users can create residents"
    ON residents FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: Authenticated users can update residents
CREATE POLICY "Authenticated users can update residents"
    ON residents FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy: Authenticated users can delete residents
CREATE POLICY "Authenticated users can delete residents"
    ON residents FOR DELETE
    TO authenticated
    USING (true);

-- ============================================
-- STORAGE BUCKET SETUP
-- ============================================

-- Create storage bucket for house photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('house-photos', 'house-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policy: Authenticated users can upload
CREATE POLICY "Authenticated users can upload house photos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'house-photos');

-- Storage Policy: Anyone can view house photos (public bucket)
CREATE POLICY "Anyone can view house photos"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'house-photos');

-- Storage Policy: Authenticated users can update their uploads
CREATE POLICY "Authenticated users can update house photos"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (bucket_id = 'house-photos');

-- Storage Policy: Authenticated users can delete house photos
CREATE POLICY "Authenticated users can delete house photos"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'house-photos');

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert sample family
-- INSERT INTO families (kk_number, address, head_of_household)
-- VALUES ('3301012001010001', 'Jl. Raya Gombang No. 123, RT 01/RW 02', 'Budi Santoso');

-- ============================================
-- USEFUL QUERIES
-- ============================================

-- Get family with all members
-- SELECT f.*, 
--        json_agg(r.*) as members
-- FROM families f
-- LEFT JOIN residents r ON r.family_id = f.id
-- WHERE f.id = 'family-uuid-here'
-- GROUP BY f.id;

-- Get lineage tree for a family
-- WITH RECURSIVE lineage AS (
--     SELECT id, full_name, parent_id, relationship, 0 as level
--     FROM residents
--     WHERE family_id = 'family-uuid-here' AND parent_id IS NULL
--     UNION ALL
--     SELECT r.id, r.full_name, r.parent_id, r.relationship, l.level + 1
--     FROM residents r
--     INNER JOIN lineage l ON r.parent_id = l.id
-- )
-- SELECT * FROM lineage ORDER BY level, full_name;

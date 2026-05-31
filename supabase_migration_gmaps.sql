-- ============================================
-- SIPEN-GO Database Migration
-- Add Google Maps Link Field
-- ============================================

-- Add gmaps_link column to families table
ALTER TABLE families 
ADD COLUMN IF NOT EXISTS gmaps_link TEXT;

-- Add comment
COMMENT ON COLUMN families.gmaps_link IS 'Google Maps link or coordinates for the house location';

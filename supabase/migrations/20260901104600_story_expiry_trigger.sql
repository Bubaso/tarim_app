-- Trigger to automatically expire (unpublish) a portal story when its parent article is unpublished

-- Function to handle the update
CREATE OR REPLACE FUNCTION expire_story_on_article_unpublish()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the status has changed from 'published' to something else
  IF NEW.status != 'published' AND OLD.status = 'published' THEN
    -- Set expires_at to NOW() so it stops showing up in active queries
    UPDATE portal_stories
    SET expires_at = NOW()
    WHERE article_id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if it already exists
DROP TRIGGER IF EXISTS trigger_expire_story ON articles;

-- Create the trigger for status updates
CREATE TRIGGER trigger_expire_story
AFTER UPDATE OF status ON articles
FOR EACH ROW
EXECUTE FUNCTION expire_story_on_article_unpublish();

-- Function to handle article deletion
CREATE OR REPLACE FUNCTION expire_story_on_article_delete()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE portal_stories
  SET expires_at = NOW()
  WHERE article_id = OLD.id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if it already exists
DROP TRIGGER IF EXISTS trigger_expire_story_delete ON articles;

-- Create the trigger for article deletion
CREATE TRIGGER trigger_expire_story_delete
BEFORE DELETE ON articles
FOR EACH ROW
EXECUTE FUNCTION expire_story_on_article_delete();

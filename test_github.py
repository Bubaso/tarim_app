import os
import sys
from scripts.generate_stories import run_story_pipeline

if __name__ == "__main__":
    # Simulate missing github env vars by forcing the fallback
    run_story_pipeline()

import json
import sys

def save_questions(json_data, output_file="sat_questions_full.json"):
    """Save the questions data to a JSON file."""
    try:
        # Parse the JSON data
        questions = json.loads(json_data)
        
        # Save to file with nice formatting
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(questions, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Successfully saved {len(questions)} questions to {output_file}")
        return True
    except Exception as e:
        print(f"❌ Error saving questions: {str(e)}")
        return False

if __name__ == "__main__":
    # Read JSON data from stdin
    json_data = sys.stdin.read()
    save_questions(json_data) 